
import UIKit
import Combine
//import TmapUISDK
//import TmapNaviSDK
//import VSMSDK

class NaviViewController: UIViewController, CLLocationManagerDelegate {
//    func viewDidLoad(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
//        // TO-DO
//    }
//    
//    func viewWillAppear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
//        // TO-DO
//    }
//    
//    func viewDidAppear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
//        // TO-DO
//    }
//    
//    func viewWillDisappear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
//        // TO-DO
//    }
//    
//    func viewDidDisappear(_ mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) {
//        // TO-DO
//    }
//    
//    func markerSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) -> Bool {
//        // TO-DO
//        return false
//    }
//    
//    func calloutPopupSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: TmapUISDK.MapViewFunctionType) -> Bool {
//        // TO-DO
//        return false
//    }
    
    
//    private var naviView: VSMNavigationView?
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"

    private var sdkInitComplete = false
    private var isAuthGranted = false
    var isStartReported = false

    var apiKey: String = ""
    var userKey: String = "test"
    var deviceKey: String = "iOS"

    var authCancelable: Set<AnyCancellable> = []
    var onContinueDrive: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        initSDK()
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(self.locationCheck),
//                                               name: UIApplication.willEnterForegroundNotification,
//                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        locationCheck()
    }
    
    // main 화면은 세로 고정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}
