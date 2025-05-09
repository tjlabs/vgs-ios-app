
let VGS_TOKEN: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6ImFwaVN5c3RlbVVzZXI1IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZSI6ImFwaVN5c3RlbVVzZXI1IiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIjoiIiwiaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZWlkZW50aWZpZXIiOiIwZDUxYTI0YS04NWNhLTQ4OWItODZmYy03MDE3NjBjNjQ4YjIiLCJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvY2xhaW1zL2V4cGlyYXRpb24iOiI17JuUIOuqqSAwOCAyMDI1IDA5OjIxOjAyIOyYpOyghCIsIm5iZiI6MTc0NjYwOTY2MiwiZXhwIjoxNzQ5MjAxNjYyLCJpc3MiOiJodHRwczovL3RqLnNoaW5qamFuZy5jb20iLCJhdWQiOiJodHRwczovL3RqLnNoaW5qamFuZy5jb20ifQ.2ncWpMJLYoVMoY_K0RLPF1od0VaHvqCh-trXcaaqo8M"

let BASE_URL: String = "https://hycdev.irfm.tjlabscorp.com/api"
let LOGIN_URL: String = BASE_URL + "/v2/AccessReg/ListForVGS"


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
    let visit_site: String
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
    let target_gps_x: Double
    let target_gps_y: Double
    let gate_gps_x: Double
    let gate_gps_y: Double
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
}
