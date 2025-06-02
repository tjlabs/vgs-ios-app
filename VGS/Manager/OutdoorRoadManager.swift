
import Foundation

class OutdoorRoadManager {
    static var isPerformed: Bool = false
    
    static var outdoorRoadDataMap = [String: OutdoorRoad]()
//    static var ppDataLoaded = [String: PathPixelDataIsLoaded]()
//    weak var delegate: PathPixelDelegate?
    
    var region: String = VgsRegion.KOREA.rawValue
    
    init() { }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func loadOutdoorRoad(fileName: String) -> [[Double]] {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("(OutdoorRoadManager) error : \(fileName)")
            return [[Double]]()
        }
        let roadCoord:[[Double]] = parseOutdoorRoad(url: URL(fileURLWithPath: path))
        return roadCoord
    }
    
    func parseOutdoorRoad(url: URL) -> [[Double]] {
        var roadXY = [[Double]]()

        do {
            let content = try String(contentsOf: url)
            let lines = content.components(separatedBy: .newlines)

            for line in lines {
                print("(OutdoorRoadManager) line: \(line)")
                let values = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                if values.count == 2,
                   let x = Double(values[0]),
                   let y = Double(values[1]) {
                    roadXY.append([x, y])
                }
            }
        } catch {
            print("(OutdoorRoadManager) Error reading file: \(error)")
        }

        return roadXY
    }
}
