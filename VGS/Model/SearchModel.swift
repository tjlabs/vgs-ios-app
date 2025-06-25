
// MARK: RUN
let BASE_URL: String = "https://hyy.irfm.tjlabscorp.com/api"

// MARK: DEV
//let BASE_URL: String = "https://hycdev.irfm.tjlabscorp.com/api"

let USER_SEARCH_URL: String = BASE_URL + "/v2/AccessReg/ListForVGS"
let USER_INIT_URL: String = BASE_URL + "/v2/VgsHist"
let USER_POS_URL: String = BASE_URL + "/v2/VgsHist"

struct SearchListResult: Codable {
    let list: [VehicleInfo]
    let total: Double
    let success: Bool
    let code: Int
    let errors: String?
    let message: String
}

struct VehicleInfo: Codable {
    let id: String
    let no: Double
    let access_reg_no: Int
    let company_no: Int
    let vehicle_no: Int
    let driver_no: Double
    let const_charger_no: Double
    let mat_charger_no: Double
    let access_start_date: String
    let access_end_date: String
    let vehicle_class: String?
    let work_type_no: Int
    let company_name: String
    let company_contact: String?
    let vehicle_reg_no: String
    let driver_name: String
    let driver_contact: String
    let const_charger_name: String
    let const_charger_contact: String?
    let mat_charger_name: String
    let mat_charger_contact: String?
    let pre_reg_wo: Bool
    let reg_permit_wo: Bool
    let tag_issue_wo: Bool?
    let sk_manager_permit_wo: Bool?
    let mat_manager_permit_wo: Bool?
    let system_manager_permit_wo: Bool?
    let stay_permit_hour: Double
    let request_div: String?
    let visit_div: String?
    let visit_div_name: String
    let mat_list: String
    let in_request_wo: Bool
    let in_permit_wo: Bool
    let request_div_name: String?
    let vehicle_type_name: String
    let vehicle_class_name: String?
    let work_type_name: String
    let vehicle_type: String
    let tag_issue_no: String?
    let vehicle_region_div: String
    let vehicle_region_div_name: String
    let target_x: Double?
    let target_y: Double?
    let target_floor_no: Int?
    let target_building_no: Int?
    let target_sector_no: Int?
    let target_floor_code: String?
    let target_building_code: String?
    let target_sector_code: String?
    let target_gate_no: Int?
    let target_gate_name: String?
    let target_gate_code: String?
    let destination_spot_no: Int?
    let destination_spot_name: String?
    let destination_spot_code: String?
    let buffer_parking_lot_no: Int?
    let buffer_parking_lot_name: String?
    let buffer_parking_lot_code: String?
    let gate_gps_x: Double?
    let gate_gps_y: Double?
    let output_order: Double
    let use_wo: Double
    let del_wo: Double
    let insert_user_no: Int
    let insert_datetime: String
    let update_user_no: Int
    let update_datetime: String
    let delete_user_no: Int?
    let delete_datetime: String?
    let insert_user_name: String
    let update_user_name: String
    let delete_user_name: String?
    let use_wo_name: String?
    let del_wo_name: String?
    let total_count: Double
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "알 수 없음"
        no = try container.decodeIfPresent(Double.self, forKey: .no) ?? -1
        access_reg_no = try container.decodeIfPresent(Int.self, forKey: .access_reg_no) ?? -1
        company_no = try container.decodeIfPresent(Int.self, forKey: .company_no) ?? -1
        vehicle_no = try container.decodeIfPresent(Int.self, forKey: .vehicle_no) ?? -1
        driver_no = try container.decodeIfPresent(Double.self, forKey: .driver_no) ?? -1
        const_charger_no = try container.decodeIfPresent(Double.self, forKey: .const_charger_no) ?? -1
        mat_charger_no = try container.decodeIfPresent(Double.self, forKey: .mat_charger_no) ?? -1
        access_start_date = try container.decodeIfPresent(String.self, forKey: .access_start_date) ?? "알 수 없음"
        access_end_date = try container.decodeIfPresent(String.self, forKey: .access_end_date) ?? "알 수 없음"
        vehicle_class = try container.decodeIfPresent(String.self, forKey: .vehicle_class) ?? "알 수 없음"
        work_type_no = try container.decodeIfPresent(Int.self, forKey: .work_type_no) ?? -1
        company_name = try container.decodeIfPresent(String.self, forKey: .company_name) ?? "알 수 없음"
        company_contact = try container.decodeIfPresent(String.self, forKey: .company_contact) ?? "알 수 없음"
        vehicle_reg_no = try container.decodeIfPresent(String.self, forKey: .vehicle_reg_no) ?? "알 수 없음"
        driver_name = try container.decodeIfPresent(String.self, forKey: .driver_name) ?? "알 수 없음"
        driver_contact = try container.decodeIfPresent(String.self, forKey: .driver_contact) ?? "알 수 없음"
        const_charger_name = try container.decodeIfPresent(String.self, forKey: .const_charger_name) ?? "알 수 없음"
        const_charger_contact = try container.decodeIfPresent(String.self, forKey: .const_charger_contact) ?? "알 수 없음"
        mat_charger_name = try container.decodeIfPresent(String.self, forKey: .mat_charger_name) ?? "알 수 없음"
        mat_charger_contact = try container.decodeIfPresent(String.self, forKey: .mat_charger_contact) ?? "알 수 없음"
        pre_reg_wo = try container.decodeIfPresent(Bool.self, forKey: .pre_reg_wo) ?? false
        reg_permit_wo = try container.decodeIfPresent(Bool.self, forKey: .reg_permit_wo) ?? false
        tag_issue_wo = try container.decodeIfPresent(Bool.self, forKey: .tag_issue_wo) ?? false
        sk_manager_permit_wo = try container.decodeIfPresent(Bool.self, forKey: .sk_manager_permit_wo) ?? false
        mat_manager_permit_wo = try container.decodeIfPresent(Bool.self, forKey: .mat_manager_permit_wo) ?? false
        system_manager_permit_wo = try container.decodeIfPresent(Bool.self, forKey: .system_manager_permit_wo) ?? false
        stay_permit_hour = try container.decodeIfPresent(Double.self, forKey: .stay_permit_hour) ?? -1
        request_div = try container.decodeIfPresent(String.self, forKey: .request_div) ?? "알 수 없음"
        visit_div = try container.decodeIfPresent(String.self, forKey: .visit_div) ?? "알 수 없음"
        visit_div_name = try container.decodeIfPresent(String.self, forKey: .visit_div_name) ?? "알 수 없음"
        mat_list = try container.decodeIfPresent(String.self, forKey: .mat_list) ?? "알 수 없음"
        in_request_wo = try container.decodeIfPresent(Bool.self, forKey: .in_request_wo) ?? false
        in_permit_wo = try container.decodeIfPresent(Bool.self, forKey: .in_permit_wo) ?? false
        request_div_name = try container.decodeIfPresent(String.self, forKey: .request_div_name) ?? "알 수 없음"
        vehicle_type_name = try container.decodeIfPresent(String.self, forKey: .vehicle_type_name) ?? "알 수 없음"
        vehicle_class_name = try container.decodeIfPresent(String.self, forKey: .vehicle_class_name) ?? "알 수 없음"
        work_type_name = try container.decodeIfPresent(String.self, forKey: .work_type_name) ?? "알 수 없음"
        vehicle_type = try container.decodeIfPresent(String.self, forKey: .vehicle_type) ?? "알 수 없음"
        tag_issue_no = try container.decodeIfPresent(String.self, forKey: .tag_issue_no) ?? "알 수 없음"
        vehicle_region_div = try container.decodeIfPresent(String.self, forKey: .vehicle_region_div) ?? "알 수 없음"
        vehicle_region_div_name = try container.decodeIfPresent(String.self, forKey: .vehicle_region_div_name) ?? "알 수 없음"
        target_x = try container.decodeIfPresent(Double.self, forKey: .target_x) ?? -1
        target_y = try container.decodeIfPresent(Double.self, forKey: .target_y) ?? -1
        target_floor_no = try container.decodeIfPresent(Int.self, forKey: .target_floor_no) ?? -1
        target_building_no = try container.decodeIfPresent(Int.self, forKey: .target_building_no) ?? -1
        target_sector_no = try container.decodeIfPresent(Int.self, forKey: .target_sector_no) ?? -1
        target_floor_code = try container.decodeIfPresent(String.self, forKey: .target_floor_code) ?? "알 수 없음"
        target_building_code = try container.decodeIfPresent(String.self, forKey: .target_building_code) ?? "알 수 없음"
        target_sector_code = try container.decodeIfPresent(String.self, forKey: .target_sector_code) ?? "알 수 없음"
        target_gate_no = try container.decodeIfPresent(Int.self, forKey: .target_gate_no) ?? -1
        target_gate_name = try container.decodeIfPresent(String.self, forKey: .target_gate_name) ?? "알 수 없음"
        target_gate_code = try container.decodeIfPresent(String.self, forKey: .target_gate_code) ?? "알 수 없음"
        destination_spot_no = try container.decodeIfPresent(Int.self, forKey: .destination_spot_no) ?? -1
        destination_spot_name = try container.decodeIfPresent(String.self, forKey: .destination_spot_name) ?? "알 수 없음"
        destination_spot_code = try container.decodeIfPresent(String.self, forKey: .destination_spot_code) ?? "알 수 없음"
        buffer_parking_lot_no = try container.decodeIfPresent(Int.self, forKey: .buffer_parking_lot_no) ?? -1
        buffer_parking_lot_name = try container.decodeIfPresent(String.self, forKey: .buffer_parking_lot_name) ?? "알 수 없음"
        buffer_parking_lot_code = try container.decodeIfPresent(String.self, forKey: .buffer_parking_lot_code) ?? "알 수 없음"
        gate_gps_x = try container.decodeIfPresent(Double.self, forKey: .gate_gps_x) ?? -1
        gate_gps_y = try container.decodeIfPresent(Double.self, forKey: .gate_gps_y) ?? -1
        output_order = try container.decodeIfPresent(Double.self, forKey: .output_order) ?? -1
        use_wo = try container.decodeIfPresent(Double.self, forKey: .use_wo) ?? -1
        del_wo = try container.decodeIfPresent(Double.self, forKey: .del_wo) ?? -1
        insert_user_no = try container.decodeIfPresent(Int.self, forKey: .insert_user_no) ?? -1
        insert_datetime = try container.decodeIfPresent(String.self, forKey: .insert_datetime) ?? "알 수 없음"
        update_user_no = try container.decodeIfPresent(Int.self, forKey: .update_user_no) ?? -1
        update_datetime = try container.decodeIfPresent(String.self, forKey: .update_datetime) ?? "알 수 없음"
        delete_user_no = try container.decodeIfPresent(Int.self, forKey: .delete_user_no) ?? -1
        delete_datetime = try container.decodeIfPresent(String.self, forKey: .delete_datetime) ?? "알 수 없음"
        insert_user_name = try container.decodeIfPresent(String.self, forKey: .insert_user_name) ?? "알 수 없음"
        update_user_name = try container.decodeIfPresent(String.self, forKey: .update_user_name) ?? "알 수 없음"
        delete_user_name = try container.decodeIfPresent(String.self, forKey: .delete_user_name) ?? "알 수 없음"
        use_wo_name = try container.decodeIfPresent(String.self, forKey: .use_wo_name) ?? "알 수 없음"
        del_wo_name = try container.decodeIfPresent(String.self, forKey: .del_wo_name) ?? "알 수 없음"
        total_count = try container.decodeIfPresent(Double.self, forKey: .total_count) ?? -1
    }
}

extension VehicleInfo {
    init(dummy: Bool) {
        self.id = "9999"
        self.no = 1
        self.access_reg_no = 0
        self.company_no = 0
        self.vehicle_no = 0
        self.driver_no = 0
        self.const_charger_no = 0
        self.mat_charger_no = 0
        self.access_start_date = "2025-06-01T14:59:59Z"
        self.access_end_date = "2030-08-24T14:59:59Z"
        self.vehicle_class = nil
        self.work_type_no = 0
        self.company_name = "TJLABS"
        self.company_contact = nil
        self.vehicle_reg_no = "999데9999"
        self.driver_name = "신*현"
        self.driver_contact = "010-****-****"
        self.const_charger_name = "현장담당자"
        self.const_charger_contact = nil
        self.mat_charger_name = "자재담당자"
        self.mat_charger_contact = nil
        self.pre_reg_wo = false
        self.reg_permit_wo = false
        self.tag_issue_wo = nil
        self.sk_manager_permit_wo = nil
        self.mat_manager_permit_wo = nil
        self.system_manager_permit_wo = nil
        self.stay_permit_hour = 0
        self.request_div = nil
        self.visit_div = nil
        self.visit_div_name = ""
        self.mat_list = ""
        self.in_request_wo = false
        self.in_permit_wo = false
        self.request_div_name = nil
        self.vehicle_type_name = "레미콘"
        self.vehicle_class_name = nil
        self.work_type_name = " 건축"
        self.vehicle_type = "레미콘"
        self.tag_issue_no = nil
        self.vehicle_region_div = "yongin"
        self.vehicle_region_div_name = "용인"
        self.target_x = nil
        self.target_y = nil
        self.target_floor_no = nil
        self.target_building_no = nil
        self.target_sector_no = nil
        self.target_floor_code = nil
        self.target_building_code = nil
        self.target_sector_code = "hyy-nz2"
        self.target_gate_no = 2
        self.target_gate_name = "GATE #6"
        self.target_gate_code = "gate_6"
        self.destination_spot_no = 76
        self.destination_spot_name = "WWT 목적지"
        self.destination_spot_code = "wwt_2"
        self.buffer_parking_lot_no = -1
        self.buffer_parking_lot_name = "알 수 없음"
        self.buffer_parking_lot_code = "알 수 없음"
        self.gate_gps_x = 37.163349
        self.gate_gps_y = 127.325228
        self.output_order = 0
        self.use_wo = 0
        self.del_wo = 0
        self.insert_user_no = 0
        self.insert_datetime = ""
        self.update_user_no = 0
        self.update_datetime = ""
        self.delete_user_no = nil
        self.delete_datetime = nil
        self.insert_user_name = ""
        self.update_user_name = ""
        self.delete_user_name = nil
        self.use_wo_name = nil
        self.del_wo_name = nil
        self.total_count = 1
    }
}

struct UserProfile {
    var carNumber: String = ""
    
    init(carNumber: String) {
        self.carNumber = carNumber
    }
}

struct SelectCellItem {
    var vehicleNumber: String
    var company: String
    var vehicleType: String
}
