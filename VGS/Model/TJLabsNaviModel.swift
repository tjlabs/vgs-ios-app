
let USER_PHOENIX_TENANT_SERVER_VERSION = "2025-06-12"
let USER_PHOENIX_SECTOR_SERVER_VERSION = "2025-06-13"

struct TenantResult: Codable {
    let id: Int
    let name: String
    let sectors: [TJLabsSector]
}

struct TJLabsSector: Codable {
    let id: Int
    let name: String
    let map_image: String
}

struct TJLabsNode: Codable {
    let number: Int
    let x: Int
    let y: Int
}

struct TJLabsLink: Codable {
    let number: Int
    let start_node_number: Int
    let end_node_number: Int
}

struct TJLabsRoute: Codable {
    let number: Int
    let node_numbers: [Int]
}

struct SectorResult: Codable {
    let pp_csv: String
    let nodes: [TJLabsNode]
    let links: [TJLabsLink]
    let routes: [TJLabsRoute]
}
