
import Foundation

class SearchManager {
    static let shared = SearchManager()
    
    static let TIMEOUT_VALUE_POST = 5.0

    private var sessionCount: Int = 0
    private let sessions: [URLSession]
    
    init() {
        self.sessions = SearchManager.createSessionPool()
    }
    
    // MARK: - Helper Methods
    private static func createSessionPool() -> [URLSession] {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = TIMEOUT_VALUE_POST
        config.timeoutIntervalForRequest = TIMEOUT_VALUE_POST
        return (1...3).map { _ in URLSession(configuration: config) }
    }
    
    func getSearchList(url: String, input: String, completion: @escaping (Int, String) -> Void) {
        // URL 구성
        var urlComponents = URLComponents(string: url)
        urlComponents?.queryItems = [URLQueryItem(name: "searchTxt", value: input)]
        
        guard let fullURL = urlComponents?.url else {
            completion(400, "Invalid URL")
            return
        }
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(VGS_TOKEN)", forHTTPHeaderField: "Authorization")
        
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
    }
    
    
    func decodeSearchListResult(from jsonString: String) -> SearchListResult? {
        guard let data = jsonString.data(using: .utf8) else {
            print("❌ 문자열 → 데이터 변환 실패")
            return nil
        }

        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode(SearchListResult.self, from: data)
            return result
        } catch {
            print("❌ 디코딩 실패: \(error)")
            return nil
        }
    }
}
