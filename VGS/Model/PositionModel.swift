
enum ArrivalType {
    case EXTERNAL, OUTDOOR, INDOOR
}

protocol NaviArrivalDelegate: AnyObject {
    func isArrival(_ type: ArrivalType)
}

struct UserInitInput: Codable {
    var access_reg_no: Double = 0
    var driver_no: Double = 0
    var arrive_datetime: String = ""
    var current_gps_x: Double = 0
    var current_gps_y: Double = 0
    var target_gate_no: Double = 0
    
    init(access_reg_no: Double, driver_no: Double, arrive_datetime: String, current_gps_x: Double, current_gps_y: Double, target_gate_no: Double) {
        self.access_reg_no = access_reg_no
        self.driver_no = driver_no
        self.arrive_datetime = arrive_datetime
        self.current_gps_x = current_gps_x
        self.current_gps_y = current_gps_y
        self.target_gate_no = target_gate_no
    }
}

struct UserInitResult: Codable {
    let data: UserInitData
    let success: Bool
    let code: Int
    let errors: String?
    let message: String
}

struct UserInitData: Codable {
    let id: String
    let no: Double
    let vgs_hist_no: Double
    let access_reg_no: Double
    let driver_no: Double
    let target_gate_no: Double?
    let departure_datetime: String?
    let arrive_datetime: String
    let current_gps_x: Double?
    let current_gps_y: Double?
    let output_order: String?
    let use_wo: String?
    let del_wo: String?
    let insert_user_no: Double?
    let insert_datetime: String?
    let update_user_no: Double?
    let update_datetime: String?
    let delete_user_no: Double?
    let delete_datetime: String?
    let insert_user_name: String?
    let update_user_name: String?
    let delete_user_name: String?
    let use_wo_name: String?
    let del_wo_name: String?
    let total_count: Double?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "알 수 없음"
        no = try container.decodeIfPresent(Double.self, forKey: .no) ?? -1
        vgs_hist_no = try container.decodeIfPresent(Double.self, forKey: .vgs_hist_no) ?? -1
        access_reg_no = try container.decodeIfPresent(Double.self, forKey: .access_reg_no) ?? -1
        driver_no = try container.decodeIfPresent(Double.self, forKey: .driver_no) ?? -1
        target_gate_no = try container.decodeIfPresent(Double.self, forKey: .target_gate_no) ?? -1
        departure_datetime = try container.decodeIfPresent(String.self, forKey: .departure_datetime) ?? "알 수 없음"
        arrive_datetime = try container.decodeIfPresent(String.self, forKey: .arrive_datetime) ?? "알 수 없음"
        current_gps_x = try container.decodeIfPresent(Double.self, forKey: .current_gps_x) ?? -1
        current_gps_y = try container.decodeIfPresent(Double.self, forKey: .current_gps_y) ?? -1
        output_order = try container.decodeIfPresent(String.self, forKey: .output_order) ?? "알 수 없음"
        use_wo = try container.decodeIfPresent(String.self, forKey: .use_wo) ?? "알 수 없음"
        del_wo = try container.decodeIfPresent(String.self, forKey: .del_wo) ?? "알 수 없음"
        insert_user_no = try container.decodeIfPresent(Double.self, forKey: .insert_user_no) ?? -1
        insert_datetime = try container.decodeIfPresent(String.self, forKey: .insert_datetime) ?? "알 수 없음"
        update_user_no = try container.decodeIfPresent(Double.self, forKey: .update_user_no) ?? -1
        update_datetime = try container.decodeIfPresent(String.self, forKey: .update_datetime) ?? "알 수 없음"
        delete_user_no = try container.decodeIfPresent(Double.self, forKey: .delete_user_no) ?? -1
        delete_datetime = try container.decodeIfPresent(String.self, forKey: .delete_datetime) ?? "알 수 없음"
        insert_user_name = try container.decodeIfPresent(String.self, forKey: .insert_user_name) ?? "알 수 없음"
        update_user_name = try container.decodeIfPresent(String.self, forKey: .update_user_name) ?? "알 수 없음"
        delete_user_name = try container.decodeIfPresent(String.self, forKey: .delete_user_name) ?? "알 수 없음"
        use_wo_name = try container.decodeIfPresent(String.self, forKey: .use_wo_name) ?? "알 수 없음"
        del_wo_name = try container.decodeIfPresent(String.self, forKey: .del_wo_name) ?? "알 수 없음"
        total_count = try container.decodeIfPresent(Double.self, forKey: .total_count) ?? -1
    }
}

struct UserPosition: Codable {
//    var vgs_hist_no: Double
//    var arrive_datetime: String = ""
//    var current_gps_x: Double = 0
//    var current_gps_y: Double = 0
//    var target_gate_no: Double = 0
//    var speed: Double = 0
//    var current_location: String = "알 수 없음"
    var vgs_hist_no: Double?
    var driver_no: Double?
    var access_reg_no: Double?
    var arrive_datetime: String?
    var current_gps_x: Double?
    var current_gps_y: Double?
    var target_gate_no: Double?
    var speed: Double?
    var current_location: String?
//    var sector_code: String?
//    var building_code: String?
//    var floor_code: String?
//    var current_x: Double?
//    var current_y: Double?
}
