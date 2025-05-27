
import Foundation

enum NaviType {
    case EXTERNAL, OUTDOOR, INDOOR
}

class PositionManager {
    static let shared = PositionManager()
    
    let TIMEOUT_VALUE_POST = 5.0
    
    var naviType: NaviType = .EXTERNAL
    var position = UserPosition()
    
    private var estimatedArrivalTime: String?
    private var currentLat: Double?
    private var currentLon: Double?
    private var hasPosted = false
    
    private var isReadyToPut = false
    
    init() { }
    
    func setNaviType(type: NaviType) {
        self.naviType = type
    }
    
    func updateEstimatedArrivalTime(_ time: String) {
        self.estimatedArrivalTime = time
        tryPostIfReady()
    }
    
    func updateCurrentLocation(lat: Double, lon: Double) {
        self.currentLat = lat
        self.currentLon = lon
        tryPostIfReady()
    }
    
    private func tryPostIfReady() {
        guard !hasPosted,
                let time = estimatedArrivalTime,
                let lat = currentLat,
                let lon = currentLon else { return }

        hasPosted = true

        if let vehicleInfo = VehicleInfoManager.shared.getVehicleInfo() {
            let input = UserInitInput(access_reg_no: vehicleInfo.access_reg_no, driver_no: vehicleInfo.driver_no, arrive_datetime: time, current_gps_x: lat, current_gps_y: lon, target_gate_no: vehicleInfo.target_gate_no!)
            print("Post input: \(input)")
            postUserInit(url: USER_INIT_URL, input: input) { [self] statusCode, returnedString, _ in
                
                print("Post Result: [\(statusCode)] \(returnedString)")
                if statusCode == 200 {
                    if let decodedResult = decodeUserInitResult(from: returnedString) {
                        position.vgs_his_no = decodedResult.data.vgs_hist_no
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
}
