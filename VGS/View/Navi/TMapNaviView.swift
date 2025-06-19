//
//import UIKit
//import SnapKit
//import CoreLocation
//import Combine
//import TmapUISDK
//import TmapNaviSDK
//import VSMSDK
//
//class TMapNaviView: UIView, CLLocationManagerDelegate, UISDKMapViewDelegate {
//
//    private var naviView: VSMNavigationView?
//    private let locationManager = CLLocationManager()
//    private var currentCoordinate: CLLocationCoordinate2D?
//    private var currentAddress: String = "현재 위치"
//
//    private var sdkInitComplete = false
//    private var isAuthGranted = false
//    var isStartReported = false
//
//    var apiKey: String = ""
//    var userKey: String = "test"
//    var deviceKey: String = "iOS"
//
//    var authCancelable: Set<AnyCancellable> = []
//    var onContinueDrive: ((String) -> Void)?
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        initSDK()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func initSDK() {
//        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMAP_API_KEY") as? String {
//            self.apiKey = apiKey
//        } else {
//            return
//        }
//        authCancelable.cancelAll()
//
//        TmapUISDKManager.shared.stateSubject
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] state in
//                switch state {
//                case .completed:
//                    self?.sdkInitComplete = true
//                    UIView.showMessage("(TMapNaviView) SDK초기화 완료")
//                    self?.setConfig()
//                    self?.embedNavigationView()
//                case let .savedDriveInfo(str?):
//                    self?.onContinueDrive?(str)
//                default:
//                    print("SDK State: \(state)")
//                }
//            }
//            .store(in: &authCancelable)
//
//        var initOption = UISDKInitOption()
//        initOption.clientDeviceId = UUID().uuidString
//        initOption.clientApiKey = apiKey
//        initOption.userKey = userKey
//        initOption.deviceKey = deviceKey
//        initOption.uiWindow = UIApplication.shared.windows.first
//
//        TmapUISDKManager.shared.initSDK(initOption: initOption)
//    }
//
//    private func setConfig() {
//        var config = UISDKConfigOption()
//        config.carType = .normal
//        config.fuelType = .gas
//        config.showTrafficAccident = true
//        config.mapTextSize = .large
//        config.nightMode = .auto
//        config.isUseSpeedReactMapScale = true
//        config.isShowTrafficInRoute = true
//        config.showExitPopupWhenStopDriving = true
//        config.useRealTimeAutoReroute = true
//        config.mapViewDelegate = self
//
//        TmapUISDKManager.shared.setConfig(config: config)
//    }
//
//    private func embedNavigationView() {
//        let naviView = VSMNavigationView()
//        self.naviView = naviView
//        addSubview(naviView)
//        naviView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
////        naviView.delegate = self
//    }
//
//    func requestRoute(to destination: Point) {
//        guard sdkInitComplete else {
//            UIView.showMessage("SDK 초기화가 아직 완료되지 않았습니다")
//            return
//        }
//        print("(TMapNaviView) requestRoute")
//
//        TmapUISDKManager.shared.requestRoute(destination: destination)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//
//        currentCoordinate = location.coordinate
//        print("(TMapNaviView) 현재 위치: \(String(describing: currentCoordinate))")
//
//        if !isAuthGranted && sdkInitComplete {
//            let destination = Point(longitude: 126.9647294, latitude: 37.5299517, name: "용산역")
//            self.requestRoute(to: destination)
//            reverseGeocode(location)
//            isAuthGranted = true
//            locationManager.stopUpdatingLocation()
//        }
//    }
//
//    private func reverseGeocode(_ location: CLLocation) {
//        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
//            guard let self = self else { return }
//            if let placemark = placemarks?.first, let name = placemark.name {
//                self.currentAddress = name
//                print("(TMapNaviView) 현재 주소: \(name)")
//            }
//        }
//    }
//
//    // MARK: - UISDKMapViewDelegate (선택적으로 구현)
//    func markerSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) -> Bool {
//        return true
//    }
//
//    func calloutPopupSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) -> Bool {
//        return true
//    }
//
//    func viewDidLoad(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {}
//    func viewWillAppear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {}
//    func viewDidAppear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {}
//    func viewWillDisappear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {}
//    func viewDidDisappear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {}
//}
