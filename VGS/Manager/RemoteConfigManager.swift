
import UIKit
import FirebaseCore
import FirebaseRemoteConfig

class AppConfig {
    var latestVersion: String?
    var minVersion: String?
    var isOn: Bool?
    var message: String?
}

class RemoteConfigManager: NSObject {

    static let sharedManager = RemoteConfigManager()
    
    override private init() {}
    
    public func isAvailable() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(10)) { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate()
                
                // 데이터 Fetch
                let appConfig: AppConfig = AppConfig()
                appConfig.isOn = remoteConfig["ios_splash_message_caps"].boolValue
                appConfig.message = remoteConfig["ios_splash_message"].stringValue
                
                var titleServer: String = "Server Maintenance"
                var messageServer: String = "We will come back with a better look"
                var buttonTitle: String = "OK"
                let locale = Locale.current
                if let countryCode = locale.regionCode, countryCode == "KR" {
                    titleServer = "서버 점검"
                    messageServer = "더 나은 모습으로 찾아뵙겠습니다"
                    buttonTitle = "확인"
                }
                
                if (appConfig.isOn!) {
                    let alertController = UIAlertController.init(title: titleServer, message: messageServer, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction.init(title: buttonTitle, style: UIAlertAction.Style.default, handler: { (action) in
                        // 앱 종료하기
                        
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            exit(0)
                        }
                        
                    }))
                    var topController = UIApplication.shared.keyWindow?.rootViewController
                    if topController != nil {
                        while let presentedViewController = topController?.presentedViewController {
                            topController = presentedViewController
                        }
                    }
                    topController!.present(alertController, animated: false, completion: {

                    })
                }
            }
        }
    }

    public func launching(completionHandler: @escaping (_ conf: AppConfig) -> (), forceUpdate: @escaping (_ need: Bool)->()) {
        let remoteConfig = RemoteConfig.remoteConfig()

        remoteConfig.fetch(withExpirationDuration: TimeInterval(10)) { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate()

                // 데이터 Fetch
                let appConfig: AppConfig = AppConfig()
                appConfig.isOn = remoteConfig["ios_splash_message_caps"].boolValue
                appConfig.message = remoteConfig["ios_splash_message"].stringValue
                appConfig.latestVersion = remoteConfig["ios_latest_version"].stringValue
                appConfig.minVersion = remoteConfig["ios_min_version"].stringValue

                completionHandler(appConfig)
                
                var titleServer: String = "Server Maintenance"
                var messageServer: String = "We will come back with a better look"
                var buttonTitle: String = "OK"
                
                var titleUpdate: String = "Update"
                var messageUpdateForce: String = "There are essential updates. Would you like to update?"
                var messageUpdateSelect: String = "We have the latest updates. Would you like to update?"
                var buttonTitleUpdate: String = "Update"
                var buttonTitleUpdateSelect: String = "Later"
                
                let locale = Locale.current
                if let countryCode = locale.regionCode, countryCode == "KR" {
                    titleUpdate = "업데이트"
                    messageUpdateForce = "더 나은 모습으로 찾아뵙겠습니다"
                    messageUpdateSelect = "최신 업데이트가 있습니다. 업데이트 하시겠습니까?"
                    buttonTitleUpdate = "업데이트"
                    buttonTitleUpdateSelect = "나중에"
                }
                
                if (appConfig.isOn!) {
                    let alertController = UIAlertController.init(title: titleServer, message: messageServer, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction.init(title: buttonTitle, style: UIAlertAction.Style.default, handler: { (action) in
                        // 앱 종료하기
                        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            exit(0)
                        }
                        
                    }))
                    var topController = UIApplication.shared.keyWindow?.rootViewController
                    if topController != nil {
                        while let presentedViewController = topController?.presentedViewController {
                            topController = presentedViewController
                        }
                    }
                    topController!.present(alertController, animated: false, completion: {

                    })
                } else {
                    let currentVersion: String = self.currentAppVersion()
                    print("Current App Version : \(currentVersion)")
                    print("App Config (Latest Version) : \(appConfig.latestVersion)")
                    print("App Config (Min Version) : \(appConfig.minVersion)")

                    // 강제업데이트
                    let needForcedUpdate:Bool = (self.compareVersion(versionA: currentVersion, versionB: appConfig.minVersion) == ComparisonResult.orderedAscending)
                    forceUpdate(needForcedUpdate)
                    if needForcedUpdate {
                        let alertController = UIAlertController.init(title: titleUpdate, message: messageUpdateForce, preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction.init(title: buttonTitleUpdate, style: UIAlertAction.Style.default, handler: { (action) in
                            // 앱스토어마켓으로 이동
                            self.openAppStore()
                        }))
                        var topController = UIApplication.shared.keyWindow?.rootViewController
                        if topController != nil {
                            while let presentedViewController = topController?.presentedViewController {
                                topController = presentedViewController
                            }
                        }
                        topController!.present(alertController, animated: false, completion: {

                        })
                    }

                    // 선택업데이트
                    let needUpdate:Bool = (self.compareVersion(versionA: currentVersion, versionB: appConfig.minVersion) != ComparisonResult.orderedAscending) && (self.compareVersion(versionA: currentVersion, versionB: appConfig.latestVersion) == ComparisonResult.orderedAscending)
                    if needUpdate {
                        let alertController = UIAlertController.init(title: titleUpdate, message: messageUpdateSelect, preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction.init(title: buttonTitleUpdate, style: UIAlertAction.Style.default, handler: { (action) in
                            // 앱스토어마켓으로 이동
                            self.openAppStore()
                        }))
                        alertController.addAction(UIAlertAction.init(title: buttonTitleUpdateSelect, style: UIAlertAction.Style.default, handler: { (action) in
                            // 앱으로 진입
                        }))
                        var topController = UIApplication.shared.keyWindow?.rootViewController
                        if topController != nil {
                            while let presentedViewController = topController?.presentedViewController {
                                topController = presentedViewController
                            }
                        }
                        topController!.present(alertController, animated: false, completion: {

                        })
                    }
                }
            }
        }
    }

    private func compareVersion(versionA:String!, versionB:String!) -> ComparisonResult {
        let majorA = Int(Array(versionA.split(separator: "."))[0])!
        let majorB = Int(Array(versionB.split(separator: "."))[0])!

        if majorA > majorB {
            return ComparisonResult.orderedDescending
        } else if majorB > majorA {
            return ComparisonResult.orderedAscending
        }

        let minorA = Int(Array(versionA.split(separator: "."))[1])!
        let minorB = Int(Array(versionB.split(separator: "."))[1])!
        if minorA > minorB {
            return ComparisonResult.orderedDescending
        } else if minorB > minorA {
            return ComparisonResult.orderedAscending
        }
        
        var minorSubA = 0
        if (Array(versionA.split(separator: ".")).count > 2) {
            minorSubA = Int(Array(versionA.split(separator: "."))[2])!
        }
        let minorSubB = Int(Array(versionB.split(separator: "."))[2])!
        
        if minorSubA > minorSubB {
            return ComparisonResult.orderedDescending
        } else if minorSubB > minorSubA {
            return ComparisonResult.orderedAscending
        }
        
        return ComparisonResult.orderedSame
    }

    func currentAppVersion() -> String {
      if let info: [String: Any] = Bundle.main.infoDictionary,
          let currentVersion: String
            = info["CFBundleShortVersionString"] as? String {
            return currentVersion
      }
      return "nil"
    }
    
    func openAppStore() {
        let appID = "1622542997"
        let url: String = "itms-apps://itunes.apple.com/app/" + appID
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
