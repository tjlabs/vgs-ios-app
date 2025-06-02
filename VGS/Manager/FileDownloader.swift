import Foundation

public class FileDownloader {
    public static let shared = FileDownloader()
    
    var region: String = "KOREA"
    
    public func downloadCSVFile(from url: URL, fname: String, completion: @escaping (URL?, Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (tempLocalURL, response, error) in
            guard let tempLocalURL = tempLocalURL, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

                let regionDirectory = documentsURL.appendingPathComponent(self.region)
                if !FileManager.default.fileExists(atPath: regionDirectory.path) {
                    try FileManager.default.createDirectory(at: regionDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                
                let savedURL = regionDirectory.appendingPathComponent("\(fname).csv")

                if FileManager.default.fileExists(atPath: savedURL.path) {
                    try FileManager.default.removeItem(at: savedURL)
                }
                
                try FileManager.default.moveItem(at: tempLocalURL, to: savedURL)
                completion(savedURL, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    func setRegion(region: String) {
        self.region = region
    }
}
