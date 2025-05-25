
import Foundation
import RxRelay

class VehicleInfoManager {
    static let shared = VehicleInfoManager()
    
    private init() {}
    
    let vehicleInfoRelay = BehaviorRelay<VehicleInfo?>(value: nil)
    
    func setVehicleInfo(info: VehicleInfo) {
        vehicleInfoRelay.accept(info)
        print("(VehicleInfoManager) setVehicleInfo : \(info)")
    }
    
    func getVehicleInfo() -> VehicleInfo? {
        return vehicleInfoRelay.value
    }
}
