
import Foundation
import UIKit

class UserManager {
    static let shared = UserManager()
    
    var isLoadFromCache: Bool = false
    var userProfile = UserProfile(carNumber: "")
    
    private init() { }

    func loadProfileFromCache() {
        let defaults = UserDefaults.standard
        if let carNumber = defaults.string(forKey: "VgsUserCarNumber") {
            if carNumber != "" {
                userProfile.carNumber = carNumber
                isLoadFromCache = true
            } else {
                isLoadFromCache = false
            }
        } else {
            isLoadFromCache = false
        }
        print("UserManager (Load From Cahce) : userProfile = \(userProfile)")
    }
    
    func saveProfileToCache() {
        let defaults = UserDefaults.standard
        defaults.set(userProfile.carNumber, forKey: "VgsUserCarNumber")
        
        print("UserManager (Save To Cahce) : userProfile = \(userProfile)")
        defaults.synchronize()
    }
}
