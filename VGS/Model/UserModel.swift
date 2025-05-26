
import Foundation

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
