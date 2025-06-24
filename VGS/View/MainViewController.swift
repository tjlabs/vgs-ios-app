
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then
import TJLabsAuth
import Combine
import TmapUISDK
import TmapNaviSDK
import VSMSDK

class MainViewController: UIViewController, BottomNavigationViewDelegate, NaviArrivalDelegate {
    
    private var routeRequestFailCount = 0
    
    func onRouteRequestFailed() {
        routeRequestFailCount += 1
        
        if truckMoveView == nil {
            let truckView = TruckMoveView()
            self.truckMoveView = truckView
            
            view.addSubview(truckView)
            truckView.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().inset(self.bottomNavigationHeight)
            }
            
            truckView.onReRouteRequested = {
                self.kakaoNaviView.setDriveAgain()
            }
            
            truckView.onStartOutdoorNavi = {
                self.truckMoveView?.removeFromSuperview()
                self.truckMoveView = nil
                
                self.kakaoNaviView.removeFromSuperview()
                self.outdoorNaviView.setIsHidden(isHidden: false)
            }
        }
        
        if routeRequestFailCount >= 3 {
            truckMoveView?.showMapTransitionOption()
        }
    }
    
    func onReRouteRequestSuccessed() {
        truckMoveView?.removeFromSuperview()
        truckMoveView = nil
    }
    
    func isArrival(_ type: ArrivalType) {
        switch(type) {
        case .EXTERNAL:
            // TO-DO
            print("(MainVC) External Navi Ended")
            kakaoNaviView.resetSimulationTapCount()
            self.showDialogView()
        case .OUTDOOR:
            print("(MainVC) Outdoor Navi Ended")
            // TO-DO
        case .INDOOR:
            print("(MainVC) Indoor Navi Ended")
            // TO-DO:
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        setBottomNavigationHeight()
        setupLayout()
        bindActions()
        
        bottomNavigationView.delegate = self
        kakaoNaviView.delegate = self
        
        initSDK()
        
        startTimer()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.locationCheck),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationCheck()
    }
    
    private var bottomNavigationHeight: CGFloat = 100
    let bottomNavigationView = BottomNavigationView()
    let kakaoNaviView = KakaoNaviView()
    private var truckMoveView: TruckMoveView? = nil
    
    var infoContainerView: InfoContainerView?
    let outdoorNaviView = OutdoorNaviView()
    
    var positionTimer: DispatchSourceTimer?
    let TIMER_INTERVAL: TimeInterval = 5.0
    
    // TMAP
    let tmapNaviView = TMapNaviView()
    private var sdkInitComplete: Bool = false
    private var locationAlert: UIAlertController? = nil
    var authCancelable: Set<AnyCancellable> = []
    
    var apiKey: String = "wgk9bctFRs3tsVE91HxRz7ZieprP1beu2TgKttbs"
    var userKey: String = ""
    var deviceKey: String = ""
    
    private func setBottomNavigationHeight() {
        let totalHeight = view.frame.height
        self.bottomNavigationHeight = totalHeight*0.1
    }
    
    private func setupLayout() {
//        view.addSubview(kakaoNaviView)
//        kakaoNaviView.snp.makeConstraints { make in
//            make.top.bottom.leading.trailing.equalToSuperview()
//        }
        
        view.addSubview(outdoorNaviView)
        outdoorNaviView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(self.bottomNavigationHeight-20)
        }
        
//        view.addSubview(kakaoNaviView)
//        kakaoNaviView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.bottom.equalToSuperview().inset(self.bottomNavigationHeight-20)
//        }
        
        view.addSubview(tmapNaviView)
        tmapNaviView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(self.bottomNavigationHeight-20)
        }
        
        view.addSubview(bottomNavigationView)
        bottomNavigationView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.bottomNavigationHeight)
        }
    }
    
    private func bindActions() {
        kakaoNaviView.onRouteRequestFailed = {
            self.onRouteRequestFailed()
        }
        
        kakaoNaviView.onReRouteRequestSuccessed = {
            self.onReRouteRequestSuccessed()
        }
    }
    
    func didTapNavigationItem(_ id: Int, from previousId: Int) {
        // 길안내 : 0 // 출입 정보 : 1
        if previousId == 1 && id == 0 {
            // 출입 정보 → 길안내 전환 처리
            print("MainViewController: 출입 정보 → 길안내")
            self.infoContainerView?.removeFromSuperview()
        } else if previousId == 0 && id == 1 {
            // 길안내 → 출입 정보 전환 처리
            print("MainViewController: 길안내 → 출입 정보")
            controlInfoContainerView()
        }
    }
    
    private func controlInfoContainerView() {
        infoContainerView = InfoContainerView()
        view.addSubview(infoContainerView!)
        infoContainerView!.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomNavigationView.snp.top)
        }
        
        bindLogoutAction()
    }
    
    
    private func bindLogoutAction() {
        infoContainerView?.onLogoutTapped = {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func showDialogView() {
        let dialogView = DialogView(contentViewHeight: 180)
        dialogView.onConfirm = { [weak self] in
            self?.kakaoNaviView.removeFromSuperview()
            self?.outdoorNaviView.setIsHidden(isHidden: false)
        }
        
        view.addSubview(dialogView)
        dialogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // Timer
    private func startTimer() {
        if (self.positionTimer == nil) {
            let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".positionTimer")
            self.positionTimer = DispatchSource.makeTimerSource(queue: queue)
            self.positionTimer!.schedule(deadline: .now(), repeating: TIMER_INTERVAL)
            self.positionTimer!.setEventHandler { [weak self] in
                guard let self = self else { return }
                self.positionTimerUpdate()
            }
            self.positionTimer!.resume()
        }
    }
    
    private func stopTimer() {
        self.positionTimer?.cancel()
        self.positionTimer = nil
    }
    
    private func positionTimerUpdate() {
        if kakaoNaviView.isStartReported {
            PositionManager.shared.sendData()
        }
    }
    
    
    // Permission Alert
    func hideLocationAlert() {
        guard self.locationAlert != nil else {
            return
        }
        print("hide location permission alert")
        self.dismiss(animated: false)
        
        self.locationAlert = nil
    }
    
    func showLocationAlert(){
        guard self.locationAlert == nil else { return }
        
        let alert = UIAlertController(title: "위치 권한 및 정확한 위치를 허용해 주세요.",
                                         message: "앱 설정 화면으로 가시겠습니까? \n '아니오'를 선택하시면 앱이 종료됩니다.",
                                         preferredStyle: UIAlertController.Style.alert)
        print("show location permission alert")
        let logOkAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default){
            (action: UIAlertAction) in
            let url = URL.init(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!)
            } else {
                UIApplication.shared.openURL(url!)
            }
            self.locationAlert = nil
        }
        let logNoAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive){
            (action: UIAlertAction) in
            self.locationAlert = nil
            exit(0)
        }
        alert.addAction(logNoAction)
        alert.addAction(logOkAction)
        self.present(alert, animated: true, completion: {
            print("Alert show complete")
            self.locationAlert = alert
        })
    }
    
    @objc func locationCheck(){
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            let alter = UIAlertController(title: "위치권한 설정이 '안함'으로 되어있습니다.",
                                          message: "앱 설정 화면으로 가시겠습니까? \n '아니오'를 선택하시면 앱이 종료됩니다.",
                                          preferredStyle: UIAlertController.Style.alert)
            let logOkAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default){
                (action: UIAlertAction) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
                } else {
                    UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                }
            }
            let logNoAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive){
                (action: UIAlertAction) in
                exit(0)
            }
            alter.addAction(logNoAction)
            alter.addAction(logOkAction)
            self.present(alter, animated: true, completion: nil)
        }
    }
    
    private func continueAlert(str : String?){
        if(str?.isEmpty != nil){
            let alert = UIAlertController(title: "이어가기 안내",
                                          message: "\(String(describing: str!))(으)로 경로안내를 이어서 받으시겠습니까?\n '아니오'를 선택하시면 이어가기 정보가 삭제됩니다.",
                                          preferredStyle: UIAlertController.Style.alert)
            
            let logOkAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default){
                (action: UIAlertAction) in
                self.continueDrive()
            }
            let logNoAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive){
                (action: UIAlertAction) in
                TmapUISDKManager.shared.clearContinueDriveInfo()
            }
            alert.addAction(logNoAction)
            alert.addAction(logOkAction)
            present(alert, animated: true, completion: {})
        }
    }
    
    private func setTmapUserInfo() {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMAP_API_KEY") as? String {
            self.apiKey = apiKey
            self.deviceKey = UIDevice.modelName
            self.userKey = "TJLabs_\(getCurrentTimeInMilliseconds())"
        }
    }
    
    private func initSDK(){
        setTmapUserInfo()
        authCancelable.cancelAll()
        
        TmapUISDKManager.shared.stateSubject
            .receive(on: DispatchQueue.main, options: nil)
            .sink(receiveValue: { [weak self] (state) in
            switch state {
                case .completed:
                    // SDK의 초기화가 완료되었음을 알림
                    self?.sdkInitComplete = true
                    UIView.showMessage("SDK초기화가 완료되었습니다.")
                    self?.setConfig()
                    self?.embedTMapNavi()
                case let .requestPermission(permission):
                    // Tmap의 화면이 노출되지 않은 상태에서 권한 요청이 필요한 경우 알림
                    if (permission.locationRequest.isEmpty) {
                        self?.hideLocationAlert()
                    } else {
                        self?.showLocationAlert()
                    }
                case .dismissReq:
                    // Tmap에서 요청했던 화면이 종료되었을때 알림
                    self?.dismiss(animated: false, completion: nil)
                case let .dismissNRequestPermission(permission) :
                    // Tmap에서 요청했던 화면이 종료된 후 특정 권한이 필요한 경우 알림
                    // 사용자에게 노출했던 화면을 닫고 권한 popup을 출력한다.
                    self?.dismiss(animated: false, completion: {
                        if (permission.locationRequest.isEmpty) {
                            self?.hideLocationAlert()
                        } else {
                            self?.showLocationAlert()
                        }
                    })
                case let .savedDriveInfo(str?):
                    self?.continueAlert(str: str)
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
        
        sdkConfig.mapViewDelegate = self
        
        TmapUISDKManager.shared.setConfig(config: sdkConfig)
    }
    
    // Route
    private func continueDrive(){
        let sdkAvail = self.sdkInitComplete
        if sdkAvail, let sdkVC = TmapUISDKManager.shared.getViewController() {
            // 3. sdkVC를 child로 추가 (iOS fragment-like pattern)
            self.addChild(sdkVC)
            tmapNaviView.addSubview(sdkVC.view)
            sdkVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sdkVC.view.topAnchor.constraint(equalTo: tmapNaviView.topAnchor),
                sdkVC.view.bottomAnchor.constraint(equalTo: tmapNaviView.bottomAnchor),
                sdkVC.view.leadingAnchor.constraint(equalTo: tmapNaviView.leadingAnchor),
                sdkVC.view.trailingAnchor.constraint(equalTo: tmapNaviView.trailingAnchor)
            ])
            sdkVC.didMove(toParent: self)
            
            TmapUISDKManager.shared.continueDrive()
        } else {
            print("vc is nil")
            UIView.showMessage("에러가 발생 했습니다.\n 다시 시도해주세요. - VC NIL")
        }
    }
    
    func embedTMapNavi() {
        let sdkAvail = self.sdkInitComplete
        if sdkAvail, let sdkVC = TmapUISDKManager.shared.getViewController() {
            // 3. sdkVC를 child로 추가 (iOS fragment-like pattern)
            self.addChild(sdkVC)
            tmapNaviView.addSubview(sdkVC.view)
            sdkVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sdkVC.view.topAnchor.constraint(equalTo: tmapNaviView.topAnchor),
                sdkVC.view.bottomAnchor.constraint(equalTo: tmapNaviView.bottomAnchor),
                sdkVC.view.leadingAnchor.constraint(equalTo: tmapNaviView.leadingAnchor),
                sdkVC.view.trailingAnchor.constraint(equalTo: tmapNaviView.trailingAnchor)
            ])
            sdkVC.didMove(toParent: self)
            
            // 4. 경로 요청 (SDK에 따라 이 시점에서 호출 가능)
            let latitude_goal = 37.16270985567856
            let longitude_goal = 127.32467624370436
            let name_goal = "GATE#6"
            
            let destination = Point(longitude: longitude_goal, latitude: latitude_goal, name: name_goal)
            TmapUISDKManager.shared.requestRoute(destination: destination)
        } else {
            UIView.showMessage("에러가 발생 했습니다.\n 다시 시도해주세요. - VC NIL")
        }
    }
}

extension MainViewController: UISDKMapViewDelegate {
    func addMarker(imageName: String, markerId: String = "", text: String? = nil, point: VSMMapPoint) -> VSMMarkerPoint? {
        let params = VSMMarkerPointParams()
        params.icon = MarkerImage(imageName: imageName, bundle: Bundle.main)
        params.iconSize = params.icon.image?.size ?? .zero
        params.iconAnchor = CGPoint(x: 0.5, y: 1)
        params.text = text ?? ""
        params.position = point
        params.showPriority = 9999
        return VSMMarkerPoint(id: markerId, params: params)
    }
    
    ///polyline
    func addPolyline(fromWgs: Coordinate, toWgs: Coordinate, imageName: String, markerId: String, renderOrder: MarkerRenderOrder = .RENDERING_ORDER_BEFORE_POINT_MARKER) -> VSMMarkerPolyline?{
        //guard let image = UIImage(named: imageName, in: Bundle.main, compatibleWith: nil) else { return nil}
        let params = VSMMarkerPolylineParams()
       
        //params.icon = MarkerImage(image: image)
        params.points = [VSMMapPoint(longitude: fromWgs.longitude, latitude: fromWgs.latitude), VSMMapPoint(longitude: toWgs.longitude, latitude: toWgs.latitude)]
        params.lineWidth = 3
        params.showPriority = 9999
        params.renderOrder = UInt32(renderOrder.rawValue)
        params.touchable = false
        return VSMMarkerPolyline(id: markerId, params: params)
   }
    
    func viewDidLoad(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {
        print("ViewController - mapView - viewDidLoad \(type)")
        // do something
        
        //SKT 타워
        let point = VSMMapPoint(longitude: 126.985173, latitude: 37.566411)
      
        // marker의 표현
        let marker = self.addMarker(imageName: "icon01", text: "SKT 타워", point: point)
        mapView.getMarkerManager().addMarker(marker)

        // 선 표현
        let dash = self.addPolyline(fromWgs: Coordinate(latitude: point.latitude, longitude: point.longitude),
                                    toWgs: Coordinate(latitude: point.latitude + 0.001, longitude: point.longitude + 0.001),
                                            imageName: "",
                                            markerId: "map_goal_dash_marker_id1",
                                            renderOrder: .RENDERING_ORDER_BEFORE_POINT_MARKER)
        mapView.getMarkerManager().addMarker(dash)
    }
    
    func viewWillAppear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {
        // do something
        print("ViewController - mapView - viewWillAppear \(type)")
    }
    
    func viewDidAppear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {
        // do something
        print("ViewController - mapView - viewDidAppear \(type)")
    }
    
    func viewWillDisappear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {
        // do something
        print("ViewController - mapView - viewWillDisappear \(type)")
    }
    
    func viewDidDisappear(_ mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) {
        // do something
        print("ViewController - mapView - viewDidDisappear \(type)")
    }
    
    func markerSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) -> Bool {
        guard let markerId = marker.markerID else { return false }
        print("ViewController - mapView - markerSelected markerId:\(markerId) \(type)")
        return true
    }
    
    func calloutPopupSelected(_ marker: VSMMarkerBase, addedMapView mapView: VSMNavigationView, mapViewType type: MapViewFunctionType) -> Bool {
        guard let markerId = marker.markerID else { return false }
        print("ViewController - mapView - calloutPopupSelected markerId:\(markerId) \(type)")
        return true
    }
   
}
