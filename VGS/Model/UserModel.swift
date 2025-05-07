
import Foundation

struct UserProfile {
    var carNumber: String = ""
    
    init(carNumber: String) {
        self.carNumber = carNumber
    }
}


struct SelectCellItem {
    var carNumber: String = ""
    var company: String = ""
    var carType: String = ""
}
