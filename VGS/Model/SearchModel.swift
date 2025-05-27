
let VGS_TOKEN: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImFwaVN5c3RlbVVzZXI1IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6ImFwaVN5c3RlbVVzZXI1IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoiIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiIwZDUxYTI0YS04NWNhLTQ4OWItODZmYy03MDE3NjBjNjQ4YjIiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL2V4cGlyYXRpb24iOiI17JuUIOuqqSAwOCAyMDI1IDA5OjIxOjAyIOyYpOyghCIsIm5iZiI6MTc0NjYwOTY2MiwiZXhwIjoxNzQ5MjAxNjYyLCJpc3MiOiJodHRwczovL3RqLnNoaW5qamFuZy5jb20iLCJhdWQiOiJodHRwczovL3RqLnNoaW5qamFuZy5jb20ifQ.2ncWpMJLYoVMoY_K0RLPF1od0VaHvqCh-trXcaaqo8M"

let BASE_URL: String = "https://hycdev.irfm.tjlabscorp.com/api"
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
    let access_reg_no: Double
    let company_no: Double
    let vehicle_no: Double
    let driver_no: Double
    let const_charger_no: Double
    let mat_charger_no: Double
    let access_start_date: String
    let access_end_date: String
    let vehicle_class: String?
    let work_type_no: Double
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
    let target_floor_no: Double?
    let target_building_no: Double?
    let target_sector_no: Double?
    let target_floor_code: String?
    let target_building_code: String?
    let target_sector_code: String?
    let target_gate_no: Double?
    let target_gate_name: String?
    let destination_spot_no: Double?
    let destination_spot_name: String?
    let gate_gps_x: Double?
    let gate_gps_y: Double?
    let output_order: Double
    let use_wo: Double
    let del_wo: Double
    let insert_user_no: Double
    let insert_datetime: String
    let update_user_no: Double
    let update_datetime: String
    let delete_user_no: Double?
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
        access_reg_no = try container.decodeIfPresent(Double.self, forKey: .access_reg_no) ?? -1
        company_no = try container.decodeIfPresent(Double.self, forKey: .company_no) ?? -1
        vehicle_no = try container.decodeIfPresent(Double.self, forKey: .vehicle_no) ?? -1
        driver_no = try container.decodeIfPresent(Double.self, forKey: .driver_no) ?? -1
        const_charger_no = try container.decodeIfPresent(Double.self, forKey: .const_charger_no) ?? -1
        mat_charger_no = try container.decodeIfPresent(Double.self, forKey: .mat_charger_no) ?? -1
        access_start_date = try container.decodeIfPresent(String.self, forKey: .access_start_date) ?? "알 수 없음"
        access_end_date = try container.decodeIfPresent(String.self, forKey: .access_end_date) ?? "알 수 없음"
        vehicle_class = try container.decodeIfPresent(String.self, forKey: .vehicle_class) ?? "알 수 없음"
        work_type_no = try container.decodeIfPresent(Double.self, forKey: .work_type_no) ?? -1
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
        target_floor_no = try container.decodeIfPresent(Double.self, forKey: .target_floor_no) ?? -1
        target_building_no = try container.decodeIfPresent(Double.self, forKey: .target_building_no) ?? -1
        target_sector_no = try container.decodeIfPresent(Double.self, forKey: .target_sector_no) ?? -1
        target_floor_code = try container.decodeIfPresent(String.self, forKey: .target_floor_code) ?? "알 수 없음"
        target_building_code = try container.decodeIfPresent(String.self, forKey: .target_building_code) ?? "알 수 없음"
        target_sector_code = try container.decodeIfPresent(String.self, forKey: .target_sector_code) ?? "알 수 없음"
        target_gate_no = try container.decodeIfPresent(Double.self, forKey: .target_gate_no) ?? -1
        target_gate_name = try container.decodeIfPresent(String.self, forKey: .target_gate_name) ?? "알 수 없음"
        destination_spot_no = try container.decodeIfPresent(Double.self, forKey: .destination_spot_no) ?? -1
        destination_spot_name = try container.decodeIfPresent(String.self, forKey: .destination_spot_name) ?? "알 수 없음"
        gate_gps_x = try container.decodeIfPresent(Double.self, forKey: .gate_gps_x) ?? -1
        gate_gps_y = try container.decodeIfPresent(Double.self, forKey: .gate_gps_y) ?? -1
        output_order = try container.decodeIfPresent(Double.self, forKey: .output_order) ?? -1
        use_wo = try container.decodeIfPresent(Double.self, forKey: .use_wo) ?? -1
        del_wo = try container.decodeIfPresent(Double.self, forKey: .del_wo) ?? -1
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
