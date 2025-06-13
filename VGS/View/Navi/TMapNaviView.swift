
import UIKit
import SnapKit
import CoreLocation
import Combine
import TmapUISDK
import TmapNaviSDK
import VSMSDK

class TMapNaviView: UIView, CLLocationManagerDelegate, UISDKMapViewDelegate {
    
    func viewDidLoad(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
        // TO-DO
    }
    
    func viewWillAppear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
        // TO-DO
    }
    
    func viewDidAppear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
        // TO-DO
    }
    
    func viewWillDisappear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
        // TO-DO
    }
    
    func viewDidDisappear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
        // TO-DO
    }
    
    func markerSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) -> Bool {
        // TO-DO
        return true
    }
    
    func calloutPopupSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) -> Bool {
        // TO-DO
        return true
    }
    
    
    var isAuthGranted: Bool = false
    var isStartReported: Bool = false
    
    // Core Location
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"
    
    
    var authCancelable: Set<AnyCancellable> = []
    private var sdkInitComplete: Bool = false
    var onContinueDrive: ((String) -> Void)?
    
    var apiKey: String = ""
    var userKey: String = ""
    var deviceKey: String = ""
    
    init() {
        super.init(frame: .zero)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        isStartReported = false
        initSDK()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSDK() {
        authCancelable.cancelAll()
        
        TmapUISDKManager.shared.stateSubject
            .receive(on: DispatchQueue.main, options: nil)
            .sink(receiveValue: { [weak self] (state) in
            switch state {
                case .completed:
                    // SDK의 초기화가 완료되었음을 알림
                    self?.sdkInitComplete = true
                    UIView.showMessage("(TMapNaviView) SDK초기화가 완료되었습니다.")
                    self?.setConfig()
                case let .savedDriveInfo(str?):
                    self?.onContinueDrive?(str)
                default:
                    print("init state: \(state)")
            }
        }).store(in: &authCancelable)
        
        //initOption
        var initOption = UISDKInitOption()
        initOption.clientDeviceId = UUID().uuidString
        
        initOption.clientApiKey = apiKey
        initOption.userKey = userKey
        initOption.deviceKey = deviceKey

        initOption.uiWindow = UIApplication.shared.windows.first
        TmapUISDKManager.shared.initSDK(initOption: initOption)
    }
    
    func setConfig() {
        var sdkConfig = UISDKConfigOption()
        sdkConfig.carType = .normal                         // 자동차의 종류를 설정합니다.
        sdkConfig.fuelType = .gas                           // 자동차의 유종을 설정합니다.
        sdkConfig.showTrafficAccident = true                // map상에서 유고정보(사고정보) 및 교통량의 표시여부를 설정합니다.
        sdkConfig.mapTextSize = .large                      // map의 text의 크기를 설정합니다.
        sdkConfig.nightMode = .auto                         // dark mode의 동작여부를 설정합니다.
        sdkConfig.isUseSpeedReactMapScale = true            // 속도반응형 지도의 사용여부를 설정합니다.
        sdkConfig.isShowTrafficInRoute = true               // 안내되는 경로상에 교통량의 표시여부를 설정합니다.
        sdkConfig.showExitPopupWhenStopDriving = true       // 주행 종료시 popup의 출력 여부
        sdkConfig.useRealTimeAutoReroute = true             // 주행 시 실시간 경로탐색의 실행 여부
        
        /*
        //트럭 옵션
        //트럭주행 가능 경로의 안내는 아래의 내용과 같이 트럭관련 정보를 이용하여 설정한 뒤 경로요청을 하게 되는 경우, 해당 option에 맞는 주행경로로의 안내가 가능합니다.
        sdkConfig.truckOption = UISDKTruckOption(truckHeight: 300, //cm
                                                 truckLoadingWeight: 25000, //kg
                                                 truckType: .ConstructionTruck)
         */
        
        //custom marker표출을 위한 delegate 설정
        sdkConfig.mapViewDelegate = self
        
        TmapUISDKManager.shared.setConfig(config: sdkConfig)
    }
    
    // Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentCoordinate = location.coordinate
        print("(VGS) currentCoordinate = \(currentCoordinate)")
        if !isAuthGranted {
            reverseGeocode(location)
            isAuthGranted = true
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    private func reverseGeocode(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let placemark = placemarks?.first {
                if let name = placemark.name {
                    self.currentAddress = name
                }
            }
            print("(VGS) currentAddress = \(currentAddress)")
            
            // 이제 네비게이션 시작 가능
        }
    }
}

