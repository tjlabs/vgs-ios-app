
import Foundation

enum NaviType {
    case EXTERNAL, OUTDOOR, INDOOR
}

class PositionManager {
    static let shared = PositionManager()
    private let userInitKey = "VgsUserInit"
    
    let TIMEOUT_VALUE_POST = 5.0
    
    var naviType: NaviType = .EXTERNAL
    var position = UserPosition()
    
    private var estimatedArrivalTime: String?
    private var updatedArrivalTime: String?
    
    private var currentLat: Double?
    private var currentLon: Double?
    var currentHeading: Double?
    
    private var hasPosted = false
    
    private var isReadyToPut = false
    
    init() {}
    
    func setNaviType(type: NaviType) {
        self.naviType = type
        
        switch(self.naviType) {
        case .EXTERNAL:
            print("(PositionManager) setNaviType : EXTERNAL")
        case .OUTDOOR:
            print("(PositionManager) setNaviType : OUTDOOR")
        case .INDOOR:
            print("(PositionManager) setNaviType : INDOOR")
        }
    }
    
    func updateEstimatedArrivalTime(_ time: String) {
        print("(PositionManager) arrivalTime : updateEstimatedArrivalTime = \(time)")
        self.estimatedArrivalTime = time
        tryPostIfReady()
    }
    
    func updateArrivalTime(_ time: String) {
        print("(PositionManager) arrivalTime : updateArrivalTime = \(time)")
        self.updatedArrivalTime = time
        self.position.arrive_datetime = time
    }
    
    func updateCurrentLocation(lat: Double, lon: Double) {
//        print("(PositionManager) updateCurrentLocation : \(self.naviType) , lat = \(lat) , lon = \(lon)")
        self.currentLat = lat
        self.currentLon = lon
        self.position.current_gps_x = lat
        self.position.current_gps_y = lon
        tryPostIfReady()
    }
    
    func sendData() {
        if isReadyToPut {
            let input = self.position
            let url = USER_POS_URL + "/\(input.vgs_hist_no)"
            switch(self.naviType) {
            case .EXTERNAL:
                print("(PositionManager) Send Data in EXTERNAL // \(input)")
                putUserPos(url: url, input: input, completion: { [self] statusCode, returnedString, inputData in
//                    print("(PositionManager) Send Data Result EXTERNAL // \(statusCode) // \(returnedString)")
                })
            case .OUTDOOR:
                print("(PositionManager) Send Data in OUTDOOR // \(input)")
                putUserPos(url: url, input: input, completion: { [self] statusCode, returnedString, inputData in
//                    print("(PositionManager) Send Data Result EXTERNAL // \(statusCode) // \(returnedString)")
                })
            case .INDOOR:
                print("(PositionManager) Send Data in INDOOR")
            }
        }
    }
    
    private func tryPostIfReady() {
        guard !hasPosted,
              !VehicleInfoManager.shared.isPublicUser,
                let time = estimatedArrivalTime,
                let lat = currentLat,
                let lon = currentLon else { return }

        hasPosted = true
        
        if let vehicleInfo = VehicleInfoManager.shared.getVehicleInfo() {
            if let cachedData = loadFromCache() {
                if cachedData.access_reg_no == vehicleInfo.access_reg_no && cachedData.driver_no == vehicleInfo.driver_no {
                    position.driver_no = cachedData.driver_no
                    position.access_reg_no = cachedData.access_reg_no
                    position.vgs_hist_no = cachedData.vgs_hist_no
                    position.target_gate_no = cachedData.target_gate_no!
                    self.isReadyToPut = true
                    print("(PositionManager) Already Initialized")
                    return
                }
            }
            
            let input = UserInitInput(access_reg_no: vehicleInfo.access_reg_no, driver_no: vehicleInfo.driver_no, arrive_datetime: time, current_gps_x: lat, current_gps_y: lon, target_gate_no: vehicleInfo.target_gate_no!)
            print("(PositionManager) Post input: \(input)")
            postUserInit(url: USER_INIT_URL, input: input) { [self] statusCode, returnedString, _ in
                
                print("(PositionManager) Post Result: [\(statusCode)] \(returnedString)")
                if statusCode == 200 {
                    if let decodedResult = decodeUserInitResult(from: returnedString) {
                        saveToCache(decodedResult.data)
                        position.vgs_hist_no = decodedResult.data.vgs_hist_no
                        position.target_gate_no = decodedResult.data.target_gate_no!
                        
                        self.isReadyToPut = true
                    }
                }
            }
        }
    }
    
    private func encodeJson<T: Encodable>(_ param: T) -> Data? {
        do {
            return try JSONEncoder().encode(param)
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func makeRequest(url: String, method: String = "POST", body: Data?) -> URLRequest? {
        let VGS_TOKEN = Bundle.main.infoDictionary?["VGS_TOKEN"] as? String ?? ""
        
        guard let url = URL(string: url) else { return nil }
        var request = URLRequest(url: url)

        request.httpMethod = method
        request.httpBody = body
        request.setValue("Bearer \(VGS_TOKEN)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        }
        return request
    }

    private func performRequest<T>(
        request: URLRequest,
        session: URLSession,
        input: T,
        completion: @escaping (Int, String, T) -> Void
    ) {
        session.dataTask(with: request) { data, response, error in
            let code = (response as? HTTPURLResponse)?.statusCode ?? 500

            // Handle errors
            if let error = error {
                let message = (error as? URLError)?.code == .timedOut ? "Timed out" : error.localizedDescription
                DispatchQueue.main.async {
                    completion(code, message, input)
                }
                return
            }

            // Validate response status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(statusCode) else {
                let message = (response as? HTTPURLResponse)?.description ?? "Request failed"
                DispatchQueue.main.async {
                    completion(code, message, input)
                }
                return
            }

            // Successful response
            let resultData = String(data: data ?? Data(), encoding: .utf8) ?? ""
            DispatchQueue.main.async {
                completion(statusCode, resultData, input)
            }
        }.resume()
    }
    
    func postUserInit(url: String, input: UserInitInput, completion: @escaping (Int, String, UserInitInput) -> Void) {
        guard let body = encodeJson(input),
              let request = makeRequest(url: url, body: body) else {
            DispatchQueue.main.async { completion(406, "Invalid URL or failed to encode JSON", input) }
            return
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        sessionConfig.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        let session = URLSession(configuration: sessionConfig)
        performRequest(request: request, session: session, input: input, completion: completion)
    }
    
    func putUserPos(url: String, input: UserPosition, completion: @escaping (Int, String, UserPosition) -> Void) {
        guard let body = encodeJson(input),
              let request = makeRequest(url: url, method: "PUT", body: body) else {
            DispatchQueue.main.async { completion(406, "Invalid URL or failed to encode JSON", input) }
            return
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        sessionConfig.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        let session = URLSession(configuration: sessionConfig)
        performRequest(request: request, session: session, input: input, completion: completion)
    }
    
    func decodeUserInitResult(from jsonString: String) -> UserInitResult? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ 문자열 → 데이터 변환 실패")
            return nil
        }

        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode(UserInitResult.self, from: data)
            return result
        } catch {
            print("❌ 디코딩 실패: \(error)")
            return nil
        }
    }
    
    func saveToCache(_ data: UserInitData) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            let jsonString = String(data: encodedData, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: userInitKey)
            print("✅ UserInitData 저장 완료")
        } catch {
            print("❌ UserInitData 저장 실패: \(error)")
        }
    }

    func loadFromCache() -> UserInitData? {
        guard let jsonString = UserDefaults.standard.string(forKey: userInitKey),
                let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let data = try JSONDecoder().decode(UserInitData.self, from: jsonData)
            print("✅ UserInitData 불러오기 성공")
            return data
        } catch {
            print("❌ UserInitData 불러오기 실패: \(error)")
            return nil
        }
    }

    func clearCache() {
        UserDefaults.standard.removeObject(forKey: userInitKey)
        print("🧹 UserInitData 캐시 제거 완료")
    }
}
