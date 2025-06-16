
import Foundation

class OutdoorRoadManager {
    static let shared = OutdoorRoadManager()
    
    var isPerformed: Bool = false
    
    var outdoorRoadDataMap = [String: OutdoorRoad]()
//    static var ppDataLoaded = [String: PathPixelDataIsLoaded]()
//    weak var delegate: PathPixelDelegate?
    
    var region: String = VgsRegion.KOREA.rawValue
    var tenantInfo = TenantResult(id: 0, name: "", sectors: [])
    var sectorInfo = SectorResult(pp_csv: "", nodes: [], links: [], routes: [])
    
    var outdoorPathPixels = [Int: [[Int]]]()
    var outdoorNodes = [Int: [Int: [Int]]]()
    var outdoorLinks = [Int: [Int: [Int]]]()
    var outdoorRoutes = [Int: [Int: [Int]]]()
    
    init() { }
    
    func setRegion(region: String) {
        self.region = region
    }
    
    func setInfo(tenantInfo: TenantResult, sectorInfo: SectorResult) {
        self.tenantInfo = tenantInfo
        self.sectorInfo = sectorInfo
    }
    
    func loadOutdoorPp(pp_csv: String, sector_id: Int) {
        // TO-DO
//        let ppLocalUrl = loadOutdoorPpFromFile(key: fname)
//        if (ppLocalUrl.0) {
//
//        } else {
//
//        }
        
        let fname = "Outdoor_\(sector_id)"
        let urlComponents = URLComponents(string: pp_csv)
        FileDownloader.shared.downloadCSVFile(from: (urlComponents?.url)!, fname: fname, completion: { [self] url, error in
            if error == nil {
                do {
                    if let unwrappedUrl = url {
                        let roadCoord: [[Int]] = parseOutdoorRoadFile(url: unwrappedUrl)
                        self.outdoorPathPixels[sector_id] = roadCoord
                        NotificationCenter.default.post(name: .outdoorPathPixelUpdated, object: nil, userInfo: ["pathPixelKey": sector_id])
                    } else {
                        print("Error invalid url: \(url)")
                    }
                } catch {
                    print("Error reading file (1):", error.localizedDescription)
                }
            } else {
                print("Error reading file (2)")
            }
        })
    }
    
    
    func loadOutdoorNodeLink(sector_id: Int, nodes: [TJLabsNode], links: [TJLabsLink]) {
        var nodeDict = [Int: [Int]]()
        var linkDict = [Int: [Int]]()
        
        for node in nodes {
            nodeDict[node.number] = [node.x, node.y]
        }
        
        for link in links {
            linkDict[link.number] = [link.start_node_number, link.end_node_number]
        }
        
        self.outdoorNodes[sector_id] = nodeDict
        self.outdoorLinks[sector_id] = linkDict
        NotificationCenter.default.post(name: .outdoorNodeLinkUpdated, object: nil, userInfo: ["nodeLinkKey": sector_id])
    }
    
    func loadOutdoorRoutes(sector_id: Int, routes: [TJLabsRoute]) {
        var routeDict = [Int: [Int]]()
        
        for route in routes {
            routeDict[route.number] = route.node_numbers
        }
        self.outdoorRoutes[sector_id] = routeDict
        NotificationCenter.default.post(name: .outdoorRoutesUpdated, object: nil, userInfo: ["routeKey": sector_id])
    }
    
    public func loadOutdoorPpFromFile(key: String) -> (Bool, URL?) {
        do {
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let savedURL = documentsURL.appendingPathComponent("\(key).csv")
            
            if FileManager.default.fileExists(atPath: savedURL.path) {
                print("(OutdoorRoadManager) Outdoor Path-Pixel : \(key).csv exists")
                return (true, savedURL)
            } else {
                return (false, nil)
            }
        } catch {
            return (false, nil)
        }
    }
    
    
    func loadOutdoorRoadfromFile(fileName: String) -> [[Int]] {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("(OutdoorRoadManager) error : \(fileName)")
            return [[Int]]()
        }
        let roadCoord:[[Int]] = parseOutdoorRoadFile(url: URL(fileURLWithPath: path))
        return roadCoord
    }
    
    func parseOutdoorRoadFile(url: URL) -> [[Int]] {
        var roadXY = [[Int]]()

        do {
            let content = try String(contentsOf: url)
            let lines = content.components(separatedBy: .newlines)

            for line in lines {
                let values = line.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                if values.count == 2,
                   let x = Int(values[0]),
                   let y = Int(values[1]) {
                    roadXY.append([x, y])
                }
            }
        } catch {
            print("(OutdoorRoadManager) Error reading file: \(error)")
        }

        return roadXY
    }
}
