
import Foundation
import RxRelay

class VehicleInfoManager {
    static let shared = VehicleInfoManager()
    
    var isPublicUser: Bool = false
    var isLoadFromCache: Bool = false
    var userCarNumber: String = ""
    
    private init() {}
    
    let vehicleInfoRelay = BehaviorRelay<VehicleInfo?>(value: nil)
    
    func setVehicleInfo(info: VehicleInfo) {
        vehicleInfoRelay.accept(info)
        print("(VehicleInfoManager) setVehicleInfo : \(info)")
    }
    
    func getVehicleInfo() -> VehicleInfo? {
        return vehicleInfoRelay.value
    }
    
    // Car Number
    func loadCarNumberFromCache() {
        let defaults = UserDefaults.standard
        if let carNumber = defaults.string(forKey: "VgsUserCarNumber") {
            if carNumber != "" {
                userCarNumber = carNumber
                isLoadFromCache = true
            } else {
                isLoadFromCache = false
            }
        } else {
            isLoadFromCache = false
        }
        print("UserManager (Load From Cahce) : userCarNumber = \(userCarNumber)")
    }
    
    func saveCarNumberToCache() {
        let defaults = UserDefaults.standard
        defaults.set(userCarNumber, forKey: "VgsUserCarNumber")
        
        print("UserManager (Save To Cahce) : userCarNumber = \(userCarNumber)")
        defaults.synchronize()
    }
    
    func saveVehicleInfoToCache(_ info: VehicleInfo) {
        do {
            let data = try JSONEncoder().encode(info)
            let jsonString = String(data: data, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: "VgsVehicleInfo")
            print("✅ 단일 VehicleInfo 저장 성공")
        } catch {
            print("❌ 단일 VehicleInfo 저장 실패: \(error)")
        }
    }

    func loadVehicleInfoFromCache() -> VehicleInfo? {
        guard let jsonString = UserDefaults.standard.string(forKey: "VgsVehicleInfo"),
                let data = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            let info = try JSONDecoder().decode(VehicleInfo.self, from: data)
            return info
        } catch {
            print("❌ 단일 VehicleInfo 불러오기 실패: \(error)")
            return nil
        }
    }
}
