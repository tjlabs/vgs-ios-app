
struct UserStartInput: Codable {
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

struct UserPosition: Codable {
    var vgs_his_no: Double = 0
    var arrive_datetime: String = ""
    var current_gps_x: Double = 0
    var current_gps_y: Double = 0
    var target_gate_no: Double = 0
    var speed: Double = 0
    var current_location: String = ""
    var sector_code: String = ""
    var building_code: String = ""
    var floor_code: String = ""
    var current_x: Double = 0
    var current_y: Double = 0
}
