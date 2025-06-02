
enum ZoomMode {
    case ZOOM_IN
    case ZOOM_OUT
}

enum MapMode {
    case MAP_ONLY
    case MAP_INTERACTION
    case UPDATE_USER
}

enum PlotType {
    case NORMAL
    case FORCE
}

public enum VgsRegion: String {
    case KOREA = "KOREA"
    case CANADA = "CANADA"
    case US_EAST = "US_EAST"
}


public struct OutdoorRoad {
    public var roadType: [Int] = []
    public var nodeNumber: [Int] = []
    public var road: [[Double]] = [[]]
    public var roadMinMax: [Double] = []
    public var roadScale: [Double] = []
    public var roadHeading: [String] = []
    
    public init(roadType: [Int], nodeNumber: [Int], road: [[Double]], roadMinMax:[Double], roadScale: [Double], roadHeading: [String]) {
        self.roadType = roadType
        self.nodeNumber = nodeNumber
        self.road = road
        self.roadMinMax = roadMinMax
        self.roadScale = roadScale
        self.roadHeading = roadHeading
    }
}
