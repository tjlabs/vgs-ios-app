
import Foundation
import TJLabsAuth

class TJLabsNaviManager {
    static let shared = TJLabsNaviManager()
    
    static let TIMEOUT_VALUE_POST = 5.0
    
    private var sessionCount: Int = 0
    private let sessions: [URLSession]
    
    init() {
        self.sessions = TJLabsNaviManager.createSessionPool()
    }
    
    private static func createSessionPool() -> [URLSession] {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        config.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        return (1...3).map { _ in URLSession(configuration: config) }
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
    
    func getTenant(url: String, completion: @escaping (Int, String) -> Void) {
        TJLabsAuthManager.shared.getAccessToken() { result in
            switch result {
            case .success(let token):
                if let tenantId = TJLabsAuthManager.shared.extractTenantID(from: token) {
                    // URL 구성
                    var urlComponents = URLComponents(string: url + "/\(tenantId)")
                    guard let fullURL = urlComponents?.url else {
                        completion(400, "Invalid URL")
                        return
                    }
                    
                    var request = URLRequest(url: fullURL)
                    request.httpMethod = "GET"
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    
                    // 세션 구성
                    let sessionConfig = URLSessionConfiguration.default
                    sessionConfig.timeoutIntervalForResource = SearchManager.TIMEOUT_VALUE_POST
                    sessionConfig.timeoutIntervalForRequest = SearchManager.TIMEOUT_VALUE_POST
                    let session = URLSession(configuration: sessionConfig)

                    // 데이터 태스크 실행
                    let dataTask = session.dataTask(with: request) { data, response, error in
                        if let error = error {
                            completion(500, error.localizedDescription)
                            return
                        }

                        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                        guard (200..<300).contains(statusCode), let data = data else {
                            let message = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                            completion(statusCode, message)
                            return
                        }

                        let resultData = String(data: data, encoding: .utf8) ?? ""
                        DispatchQueue.main.async {
                            completion(statusCode, resultData)
                        }
                    }

                    dataTask.resume()
                } else {
                    completion(400, "extractTenantID Fail")
                }
            case .failure:
                completion(400, "getAccessToekn Fail")
            }
        }

    }
    
    func getSector(url: String, sector_id: Int, completion: @escaping (Int, String) -> Void) {
        TJLabsAuthManager.shared.getAccessToken() { result in
            switch result {
            case .success(let token):
                // URL 구성
                let urlComponents = URLComponents(string: url + "/\(sector_id)")
                guard let fullURL = urlComponents?.url else {
                    completion(400, "Invalid URL")
                    return
                }
                
                var request = URLRequest(url: fullURL)
                request.httpMethod = "GET"
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                // 세션 구성
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForResource = SearchManager.TIMEOUT_VALUE_POST
                sessionConfig.timeoutIntervalForRequest = SearchManager.TIMEOUT_VALUE_POST
                let session = URLSession(configuration: sessionConfig)

                // 데이터 태스크 실행
                let dataTask = session.dataTask(with: request) { data, response, error in
                    if let error = error {
                        completion(500, error.localizedDescription)
                        return
                    }

                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                    guard (200..<300).contains(statusCode), let data = data else {
                        let message = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                        completion(statusCode, message)
                        return
                    }

                    let resultData = String(data: data, encoding: .utf8) ?? ""
                    DispatchQueue.main.async {
                        completion(statusCode, resultData)
                    }
                }

                dataTask.resume()
            case .failure:
                completion(400, "getAccessToekn Fail")
            }
        }

    }
    
    func decodeTenantResult(from jsonString: String) -> TenantResult? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ 문자열 → 데이터 변환 실패")
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(TenantResult.self, from: data)
            return result
        } catch {
            print("❌ TenantResult 디코딩 실패: \(error)")
            return nil
        }
    }
    
    func decodeSectorResult(from jsonString: String) -> SectorResult? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ 문자열 → 데이터 변환 실패")
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(SectorResult.self, from: data)
            return result
        } catch {
            print("❌ SectorResult 디코딩 실패: \(error)")
            return nil
        }
    }
}
