
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then
import Combine
import TmapUISDK
import TmapNaviSDK
import VSMSDK

class InfoViewController: UIViewController, UISDKMapViewDelegate {
    let topView = TopView()
//    let logoView = LogoView()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let visitorInfoView = VisitorInfoView()
    let vehicleInfoView = VehicleInfoView()
//    let importedMaterialView = ImportedMaterialView()
    
    var isChecked = false
    
    // Start
    private let confirmContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var checkBoxImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_uncheckedBox")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let checkBoxTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 24)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "위 사항을 빠짐없이 확인했습니다."
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        return label
    }()
    
//    private let startButton: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(hex: "#E47325")
//        view.alpha = 0.8
//        view.isUserInteractionEnabled = true
//        view.cornerRadius = 15
//        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
//        return view
//    }()
    
    private let startButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E47325")
        view.alpha = 0.8
        view.isUserInteractionEnabled = true
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    private let startButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.notoSansBold(size: 48)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "출발"
        return label
    }()

    // TMAP
    var authCancelable: Set<AnyCancellable> = []
    var buttonCancelable: Set<AnyCancellable> = []
    
    private var sdkInitComplete: Bool = false
    private var locationAlert: UIAlertController? = nil
    var apiKey: String = ""
    let userKey: String = "TJLABS_USER"
    let deviceKey: String = "iOS"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindActions()
        topView.setArrowBackOption(isHidden: false, title: "차량 선택하기")
        
        initSDK()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.locationCheck),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationCheck()
    }
    
    // main 화면은 세로 고정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    private func setupLayout() {
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        // 1. Add scrollView to view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 2. Add contentView to scrollView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // 3. Add visitorInfoView to contentView
        contentView.addSubview(visitorInfoView)
        visitorInfoView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(375)
        }
        
        contentView.addSubview(vehicleInfoView)
        vehicleInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(visitorInfoView.snp.bottom).offset(10)
            make.height.equalTo(165)
        }
        
        // // MARK: - Confirm
        contentView.addSubview(confirmContainerView)
        confirmContainerView.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.top.equalTo(vehicleInfoView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        confirmContainerView.addSubview(checkBoxImageView)
        checkBoxImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        confirmContainerView.addSubview(checkBoxTitleLabel)
        checkBoxTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxImageView.snp.trailing).offset(4)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        // // MARK: - Start
        contentView.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(90)
            make.top.equalTo(confirmContainerView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        startButton.addSubview(startButtonTitleLabel)
        startButtonTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func bindActions() {
        topView.onBackArrowTapped = { [self] in
            goToBack()
        }
        setupConfirmAction()
        setupStartAction()
//        setButtonAction()
    }
    
    private func setupConfirmAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCheckboxToggle))
        confirmContainerView.isUserInteractionEnabled = true
        confirmContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleCheckboxToggle() {
        isChecked.toggle()
        let imageName = isChecked ? "ic_checkedBox" : "ic_uncheckedBox"
        checkBoxImageView.image = UIImage(named: imageName)
        
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.checkBoxImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkBoxImageView.transform = .identity
            }
        })
    }
    
    private func setupStartAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStartButton))
        startButton.isUserInteractionEnabled = true
        startButton.addGestureRecognizer(tapGesture)
    }
    
    private func checkValidVisitDuration(info: VehicleInfo) -> Bool {
        let startDateString = info.access_start_date
        let endDateString = info.access_end_date
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime] // "Z" 포함된 포맷 지원
        
        guard let startDateUTC = formatter.date(from: startDateString),
              let endDateUTC = formatter.date(from: endDateString) else {
            return false
        }
        
        let now = Date()
        return (startDateUTC...endDateUTC).contains(now)
    }
    
    @objc func handleStartButton() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.startButton.transform = .identity
            }
        })
        
        if isChecked {
            if let vehicleInfo = VehicleInfoManager.shared.getVehicleInfo() {
                startButton.isUserInteractionEnabled = false
                let isValid = checkValidVisitDuration(info: vehicleInfo)
                print("(InfoVC) checkValidVisitDuration : isValid = \(isValid)")
                if isValid {
                    startButton.isUserInteractionEnabled = true
                    moveToMainVC(vehicleInfo: vehicleInfo)
//                    moveToNaviVC(vehicleInfo: vehicleInfo)
                } else {
                    startButton.isUserInteractionEnabled = true
                }
            }
        } else {
            DispatchQueue.main.async {
                self.showToastWithIcon(message: "정보 확인에 대해 체크해주세요")
            }
            startButton.isUserInteractionEnabled = true
        }
    }
    
    func goToBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func moveToMainVC(vehicleInfo: VehicleInfo) {
        guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return }
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
    private func moveToNaviVC(vehicleInfo: VehicleInfo) {
        let latitude_goal = 37.16270985567856
        let longitude_goal = 127.32467624370436
        let name_goal = "GATE#6"
        
        // 도착점은 현장
//        if let info = VehicleInfoManager.shared.getVehicleInfo() {
//            latitude_goal = Double(info.gate_gps_x ?? 37.164209)
//            longitude_goal = Double(info.gate_gps_y ?? 127.323388)
//            name_goal = info.target_gate_name ?? "정문"
//        }
        let destination = Point(longitude: longitude_goal, latitude: latitude_goal, name: name_goal)
        route(destination: destination)
    }
    
    // MARK: - TMap
    private func initSDK(){
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMAP_API_KEY") as? String {
            self.apiKey = apiKey
        } else {
            return
        }
        
        authCancelable.cancelAll()
        
        TmapUISDKManager.shared.stateSubject
            .receive(on: DispatchQueue.main, options: nil)
            .sink(receiveValue: { [weak self] (state) in
            switch state {
                case .completed:
                    // SDK의 초기화가 완료되었음을 알림
                    self?.sdkInitComplete = true
                    self?.showToastWithIcon(message: "TMAP 초기화 완료")
                    self?.setConfig()
                    
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
            self.locationAlert = alert
        })
    }
    
    ///경로안내
    private func route(destination: Point) {
        let sdkAvail = self.sdkInitComplete
        DispatchQueue.main.async {
            if sdkAvail,
               let vc = TmapUISDKManager.shared.getViewController() {
                vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(vc, animated: true, completion: nil)
//                self.navigationController?.pushViewController(vc, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   TmapUISDKManager.shared.requestRoute(destination: destination)
                }
            } else {
                print("vc is nil")
                self.showToastWithIcon(message: "에러가 발생 했습니다.\n 다시 시도해주세요. - VC NIL")
            }
        }
    }
    
    //이어가기
    private func continueDrive() {
        let sdkAvail = self.sdkInitComplete
        DispatchQueue.main.async {
            if sdkAvail, let vc = TmapUISDKManager.shared.getViewController() {
                vc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                self.present(vc, animated: true, completion: nil)
                TmapUISDKManager.shared.continueDrive()
            } else {
                print("vc is nil")
                self.showToastWithIcon(message: "에러가 발생 했습니다.\n 다시 시도해주세요. - VC NIL")
            }
        }
    }
    
    //이어가기 alert
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
    
    private func driveInfo(){
        TmapUISDKManager.shared.driveGuidePublisher
            .receive(on: DispatchQueue.main, options: nil)
            .sink(receiveValue: { data in

                print("driveInfo : \(String(describing: data))")
            
            }).store(in: &authCancelable)

    }
    
    private func driveStatus(){
        TmapUISDKManager.shared.driveStatusPublisher
            .receive(on: DispatchQueue.main, options: nil)
            .sink(receiveValue: { data in

                print("driveStatus : \(String(describing: data))")
            
            }).store(in: &authCancelable)
    }
    
    @objc
    func locationCheck(){
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
