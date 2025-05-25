
import Foundation

class VehicleInfoManager {
    static let shared = VehicleInfoManager()
    
    var info: VehicleInfo?
    
    init() { }
    
    func setVehicleInfo(info: VehicleInfo) {
        self.info = info
        print("(VehicleInfoManager) setVehicleInfo : \(self.info)")
    }
    
    func getVehicleInfo() -> VehicleInfo? {
        return self.info
    }
}
