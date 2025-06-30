
import UIKit
import SnapKit
import CoreLocation
import AVFoundation

class KakaoNaviView: UIView, KNNaviView_GuideStateDelegate, KNNaviView_StateDelegate, KNGuidance_GuideStateDelegate, KNGuidance_RouteGuideDelegate, KNGuidance_VoiceGuideDelegate, KNGuidance_SafetyGuideDelegate, KNGuidance_LocationGuideDelegate, KNGuidance_CitsGuideDelegate, CLLocationManagerDelegate {
    
    var onReRouteRequestSuccessed: (() -> Void)?
    var onRouteRequestFailed: (() -> Void)?
    
    func naviViewGuideEnded(_ aNaviView: KNNaviView) {
        // TO-DO
        print("(VGS) naviViewGuideEnded")
    }
    
    func naviViewGuideState(_ aGuideState: KNGuideState) {
        // TO-DO
    }
    
    func naviViewDidUpdateSndVolume(_ aVolume: Float) {
        // TO-DO
    }
    
    func naviViewDidUpdateUseDarkMode(_ aDarkMode: Bool) {
        // TO-DO
    }
    
    func naviViewDidUpdateMapCameraMode(_ aMapViewCameraMode: MapViewCameraMode) {
        // TO-DO
    }
    
    func naviViewDidMenuItem(withId aId: Int32, toggle aToggle: Bool) {
        // TO-DO
        print("(VGS) naviViewDidMenuItem")
    }
    
    func naviViewScreenState(_ aKNNaviViewState: KNNaviViewState) {
        // TO-DO
    }
    
    func naviViewPopupOpenCheck(_ aOpen: Bool) {
        // TO-DO
    }
    
    func naviViewIsArrival(_ aIsArrival: Bool) {
        // TO-DO
        print("(VGS) naviViewIsArrival")
    }
    
    func guidanceGuideStarted(_ aGuidance: KNGuidance) {
        // TO-DO
        print("(VGS) guidanceGuideStarted : \(aGuidance)")
        self.naviView.guidanceGuideStarted(aGuidance)
    }
    
    func guidanceCheckingRouteChange(_ aGuidance: KNGuidance) {
        // TO-DO
        self.naviView.guidanceCheckingRouteChange(aGuidance)
    }
    
    func guidanceOut(ofRoute aGuidance: KNGuidance) {
        print("🚗 사용자 경로 이탈 감지: 재탐색 시작")
        guard let currentCoord = currentCoordinate else { return }

        let latitude_start = currentCoord.latitude
        let longitude_start = currentCoord.longitude
        let name_start = currentAddress
        
        var latitude_goal = 37.16270985567856
        var longitude_goal = 127.32467624370436
        var name_goal = "GATE #6"
        
//        var latitude_start = latitude_goal
//        var longitude_start = longitude_goal
//        var name_start = name_goal

        if let info = VehicleInfoManager.shared.getVehicleInfo() {
            latitude_goal = Double(info.gate_gps_x ?? 37.16270985567856)
            longitude_goal = Double(info.gate_gps_y ?? 127.32467624370436)
            name_goal = info.target_gate_name ?? "GATE #6"
        }

        guard let sdkInstance = KNSDK.sharedInstance() else { return }

        guard let startKATEC = convertWGS84ToKATEC(lon: longitude_start, lat: latitude_start),
                let goalKATEC = convertWGS84ToKATEC(lon: longitude_goal, lat: latitude_goal) else {
            print("🛑 좌표 변환 실패")
            return
        }

        let start = KNPOI(name: name_start, x: startKATEC.x, y: startKATEC.y)
        let goal = KNPOI(name: name_goal, x: goalKATEC.x, y: goalKATEC.y)
        let vias: [KNPOI] = []

        sdkInstance.makeTrip(withStart: start, goal: goal, vias: vias) { [weak self] (error, trip) in
            guard let self = self else { return }
            if let error = error {
                print("🛑 재탐색 실패: \(error)")
                return
            }

            if let trip = trip {
                print("🔁 경로 재생성 성공")
                self.routeGuidance.start(with: trip, priority: self.routePriority, avoidOptions: self.routeAvoidOption.rawValue)
            }
        }
        self.naviView.guidanceOut(ofRoute: aGuidance)
    }
    
    func guidanceRouteUnchanged(_ aGuidance: KNGuidance) {
        // TO-DO
        self.naviView.guidanceRouteUnchanged(aGuidance)
    }
    
    func guidance(_ aGuidance: KNGuidance, routeUnchangedWithError aError: KNError) {
        // TO-DO
        self.naviView.guidance(aGuidance, routeUnchangedWithError: aError)
    }
    
    func guidanceRouteChanged(_ aGuidance: KNGuidance, from aFromRoute: KNRoute, from aFromLocation: KNLocation, to aToRoute: KNRoute, to aToLocation: KNLocation, reason aChangeReason: KNGuideRouteChangeReason) {
        // TO-DO
        self.naviView.guidanceRouteChanged(aGuidance)
    }
    
    func guidanceGuideEnded(_ aGuidance: KNGuidance) {
        // 목적지 도착
        isGuideEnded = true
        delegate?.isArrival(.EXTERNAL)
//        self.naviView.guidanceGuideEnded(aGuidance, isShowDriveResultDialog: true)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdate aRoutes: [KNRoute], multiRouteInfo aMultiRouteInfo: KNMultiRouteInfo?) {
        
        var remainingTime: Int32 = 0
        for route in aRoutes {
            remainingTime += route.totalTime
            print("(VGS) : Route = \(route) // Time = \(route.totalTime)")
        }
        
        if !isStartReported && remainingTime != 0 {
            let estimatedArrivalTime = calArrivalTimeString(secondsToArrival: remainingTime)
            PositionManager.shared.updateEstimatedArrivalTime(estimatedArrivalTime)
            isStartReported = true
        }
        
        if isStartReported {
            let estimatedArrivalTime = calArrivalTimeString(secondsToArrival: remainingTime)
            PositionManager.shared.updateArrivalTime(estimatedArrivalTime)
        }

        self.naviView.guidance(aGuidance, didUpdate: aRoutes, multiRouteInfo: aMultiRouteInfo)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdateIndoorRoute aRoute: KNRoute?) {
        // TO-DO
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdateRouteGuide aRouteGuide: KNGuide_Route) {
        // TO-DO
        self.naviView.guidance(aGuidance, didUpdateRouteGuide: aRouteGuide)
    }
    
    func guidance(_ aGuidance: KNGuidance, shouldPlayVoiceGuide aVoiceGuide: KNGuide_Voice, replaceSndData aNewData: AutoreleasingUnsafeMutablePointer<NSData?>!) -> Bool {
        // TO-DO
        return true
    }
    
    func guidance(_ aGuidance: KNGuidance, willPlayVoiceGuide aVoiceGuide: KNGuide_Voice) {
        self.naviView.guidance(aGuidance, willPlayVoiceGuide: aVoiceGuide)
    }
    
    func guidance(_ aGuidance: KNGuidance, didFinishPlayVoiceGuide aVoiceGuide: KNGuide_Voice) {
        // TO-DO
        self.naviView.guidance(aGuidance, didFinishPlayVoiceGuide: aVoiceGuide)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdateSafetyGuide aSafetyGuide: KNGuide_Safety) {
        // TO-DO
        self.naviView.guidance(aGuidance, didUpdateSafetyGuide: aSafetyGuide)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdateAroundSafeties aSafeties: [KNSafety]?) {
        // TO-DO
        self.naviView.guidance(aGuidance, didUpdateAroundSafeties: aSafeties)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdate aLocationGuide: KNGuide_Location) {
        var isCurLocExist: Bool = false
        if let curLocation = aLocationGuide.location {
            if let curLatLon = convertKATECToWGS84(pos: curLocation.pos) {
                PositionManager.shared.position.current_location = curLocation.roadName ?? "알 수 없음"
                let longitude: Double = curLatLon.x
                let latitude: Double = curLatLon.y
                let now = Date()
                let elapsed = now.timeIntervalSince(locationStartTime)
                if elapsed >= 5 {
                    if !isGuideEnded {
                        PositionManager.shared.updateCurrentLocation(lat: latitude, lon: longitude)
                        checkArrived(curLat: latitude, curLon: longitude)
                    }
                } else {
//                    print("🕒 위치 업데이트 무시 (기준시간 이내 \(elapsed)초)")
                }
                isCurLocExist = true
            }
        }
        
        if !isCurLocExist {
            if let latLon = convertKATECToWGS84(pos: DoublePoint(x: aLocationGuide.gpsMatched.pos.x, y: aLocationGuide.gpsMatched.pos.y)) {
                PositionManager.shared.position.current_location = "알 수 없음"
                let longitude: Double = latLon.x
                let latitude: Double = latLon.y
                let now = Date()
                let elapsed = now.timeIntervalSince(locationStartTime)
                if elapsed >= 5 {
                    if !isGuideEnded {
                        PositionManager.shared.updateCurrentLocation(lat: latitude, lon: longitude)
                        checkArrived(curLat: latitude, curLon: longitude)
                    }
                } else {
//                    print("🕒 위치 업데이트 무시 (기준시간 이내 \(elapsed)초)")
                }
            }
        }
        let speed: Int32 = aLocationGuide.gpsMatched.speed
        let heading: Int32 = aLocationGuide.gpsMatched.angle
        PositionManager.shared.position.speed = Double(speed)
        PositionManager.shared.currentHeading = Double(heading)
        
//        print("(VGS) 📍 현 위치: \(aLocationGuide.gpsMatched.pos) // speed = \(speed) // heading = \(heading)")
        
        self.naviView.guidance(aGuidance, didUpdate: aLocationGuide)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdateCitsGuide aCitsGuide: KNGuide_Cits) {
        // TO-DO
        self.naviView.guidance(aGuidance, didUpdateCitsGuide: aCitsGuide)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var forceGuidanceEndButton = UIView().then {
        $0.backgroundColor = UIColor.black
        $0.alpha = 1.0
        $0.isHidden = true
        $0.cornerRadius = 15
    }
    
    private let forceGuidanceEndButtonTitle = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = UIFont.notoSansBold(size: 20)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.2
        $0.text = "영내 도착"
    }
    
    private let simulationButtonTitle = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = UIFont.notoSansBold(size: 14)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.2
        $0.isHidden = true
        $0.text = "목적지에서 지도 전환"
    }
    private var simulationTapCount: Int = 0
    
    var naviView = KNNaviView.init()
    var routePriority: KNRoutePriority = .time
    var routeAvoidOption: KNRouteAvoidOption = .none
    var routeGuidance = KNGuidance()
    var naviVolume: Float = 10.0
    var isGuideEnded: Bool = false
    
    var isAuthGranted: Bool = false
    var isStartReported: Bool = false
    private var locationStartTime: Date = Date()
    
    weak var delegate: NaviArrivalDelegate?
    
    // Core Location
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"
    
    init() {
        super.init(frame: .zero)
        setNaviViewOption()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        isStartReported = false
//        authKNSDK(completion: { [self] knError in
//            if knError == nil {
//                setupLayout()
//                setDrive()
//            } else {
//                print("(VGS) Auth : \(knError)")
//            }
//        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func authKNSDK(completion: @escaping (KNError?) -> Void) {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String {
            KNSDK.sharedInstance()?.initialize(withAppKey: apiKey, clientVersion: "1.0") { knError in
                completion(knError)
            }
        } else {
            completion(KNError.init(code: "auth fail", msg: "auth fail"))
        }
    }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
//            make.bottom.equalToSuperview().inset(20)
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let totalHeight = frame.height
        addSubview(forceGuidanceEndButton)
        forceGuidanceEndButton.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.height.equalTo(totalHeight*0.06)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(60)
        }
        
        forceGuidanceEndButton.addSubview(forceGuidanceEndButtonTitle)
        forceGuidanceEndButtonTitle.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
        
        addSubview(simulationButtonTitle)
        simulationButtonTitle.snp.makeConstraints { make in
            make.width.equalTo(140)
            make.height.equalTo(totalHeight*0.06)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(60)
        }
    }
    
    private func setNaviViewOption() {
        self.setupAudioSession()
    }
    
    
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
            print("🎧 AVAudioSession 설정 완료")
        } catch {
            print("❌ AVAudioSession 설정 실패: \(error)")
        }
    }
    
    private func setupForceGuidanceEndButtonAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleForceGuidanceEndButton))
        forceGuidanceEndButton.isUserInteractionEnabled = true
        forceGuidanceEndButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleForceGuidanceEndButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.forceGuidanceEndButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.forceGuidanceEndButton.transform = .identity
            }, completion: { _ in
                self.routeGuidance.stop()
                self.isStartReported = true
                self.isGuideEnded = true
                self.delegate?.isArrival(.EXTERNAL)
            })
        })
    }
    
    private func setupSimulationButtonAction() {
        if VehicleInfoManager.shared.isDemoUser {
            self.simulationButtonTitle.isHidden = false
        } else {
            self.simulationButtonTitle.isHidden = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSimulationButton))
        simulationButtonTitle.isUserInteractionEnabled = true
        simulationButtonTitle.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleSimulationButton() {
        simulationTapCount += 1
        if simulationTapCount >= 5 {
            SimulationPath.isSimulation = true
            self.routeGuidance.stop()
            self.isStartReported = true
            self.isGuideEnded = true
            self.delegate?.isArrival(.EXTERNAL)
        }
    }
    
    public func resetSimulationTapCount() {
        self.simulationTapCount = 0
    }
    
    private func checkArrived(curLat: Double, curLon: Double) {
        var isArrived: Bool = false
        guard let info = VehicleInfoManager.shared.getVehicleInfo() else { return }

        let latitude_goal = Double(info.gate_gps_x ?? 37.164209)
        let longitude_goal = Double(info.gate_gps_y ?? 127.323388)

        let distance = haversineDistance(lat1: curLat, lon1: curLon,
                                          lat2: latitude_goal, lon2: longitude_goal)

        if distance <= 20 {
            isArrived = true
        }

        if isArrived {
            self.routeGuidance.stop()
            self.isStartReported = true
            self.isGuideEnded = true
            self.delegate?.isArrival(.EXTERNAL)
        }
    }
    
    private func haversineDistance(lat1: Double, lon1: Double,
                                   lat2: Double, lon2: Double) -> Double {
        let R = 6371000.0

        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180

        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)

        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        return R * c
    }
    
    public func setDriveAgain() {
        // Test Drive
//        let latitude_start = 37.495758
//        let longitude_start = 127.038249
//        let name_start = "Start Point"
        
        // 도착 점은 COEX
//        let latitude_goal = 37.513109
//        let longitude_goal = 127.058375
//        let name_goal = "Goal Point"
        
        print("(VGS) setDrive : currentCoord = \(currentCoordinate)")
        let latitude_start = currentCoordinate?.latitude ?? 37.495758
        let longitude_start = currentCoordinate?.longitude ?? 127.038249
        let name_start = currentAddress

        let latitude_goal = 37.16270985567856
        let longitude_goal = 127.32467624370436
        let name_goal = "GATE#6"
        
        // 도착점은 현장
//        if let info = VehicleInfoManager.shared.getVehicleInfo() {
//            latitude_goal = Double(info.gate_gps_x ?? 37.164209)
//            longitude_goal = Double(info.gate_gps_y ?? 127.323388)
//            name_goal = info.target_gate_name ?? "정문"
//        }

        let vias: [KNPOI] = []
        
        guard let sdkInstance = KNSDK.sharedInstance() else {
            self.onRouteRequestFailed?()
            print("(VGS) Error : Failed to get SDK instance")
            return
        }
        
        var startCoord: [Int32] = [0, 0]
        if let startKATEC = convertWGS84ToKATEC(lon: longitude_start, lat: latitude_start) {
            print("(VGS) start KATEC = \(startKATEC)")
            startCoord[0] = startKATEC.x
            startCoord[1] = startKATEC.y
        }
        var goalCoord: [Int32] = [0, 0]
        if let goalKATEC = convertWGS84ToKATEC(lon: longitude_goal, lat: latitude_goal) {
            print("(VGS) goal KATEC = \(goalKATEC)")
            goalCoord[0] = goalKATEC.x
            goalCoord[1] = goalKATEC.y
        }

        let start = KNPOI(name: name_start, x: startCoord[0], y: startCoord[1])
        let goal = KNPOI(name: name_goal, x: goalCoord[0], y: goalCoord[1])
        
        sdkInstance.makeTrip(withStart: start, goal: goal, vias: vias) { [self] (aError, aTrip) in
            if let error = aError {
                // 경로 생성 실패
                self.onRouteRequestFailed?()
                print("(VGS) Failed to create trip : \(String(describing: aError))")
            } else if let trip = aTrip {
                // 경로 생성 성공
                print("(VGS) Trip created successfully : \(trip)")
                self.requestRoute(for: trip, re: true)
            }
        }
    }
    
    private func setDrive() {
        // Test Drive
//        let latitude_start = 37.495758
//        let longitude_start = 127.038249
//        let name_start = "Start Point"
        
        // 도착 점은 COEX
//        let latitude_goal = 37.513109
//        let longitude_goal = 127.058375
//        let name_goal = "Goal Point"
        
        print("(VGS) setDrive : currentCoord = \(currentCoordinate)")
        let latitude_start = currentCoordinate?.latitude ?? 37.495758
        let longitude_start = currentCoordinate?.longitude ?? 127.038249
        let name_start = currentAddress

        let latitude_goal = 37.16270985567856
        let longitude_goal = 127.32467624370436
        let name_goal = "GATE#6"
        
        // 도착점은 현장
//        if let info = VehicleInfoManager.shared.getVehicleInfo() {
//            latitude_goal = Double(info.gate_gps_x ?? 37.164209)
//            longitude_goal = Double(info.gate_gps_y ?? 127.323388)
//            name_goal = info.target_gate_name ?? "정문"
//        }

        let vias: [KNPOI] = []
        
        guard let sdkInstance = KNSDK.sharedInstance() else {
            self.onRouteRequestFailed?()
            print("(VGS) Error : Failed to get SDK instance")
            return
        }
        
        var startCoord: [Int32] = [0, 0]
        if let startKATEC = convertWGS84ToKATEC(lon: longitude_start, lat: latitude_start) {
            print("(VGS) start KATEC = \(startKATEC)")
            startCoord[0] = startKATEC.x
            startCoord[1] = startKATEC.y
        }
        var goalCoord: [Int32] = [0, 0]
        if let goalKATEC = convertWGS84ToKATEC(lon: longitude_goal, lat: latitude_goal) {
            print("(VGS) goal KATEC = \(goalKATEC)")
            goalCoord[0] = goalKATEC.x
            goalCoord[1] = goalKATEC.y
        }

        let start = KNPOI(name: name_start, x: startCoord[0], y: startCoord[1])
        let goal = KNPOI(name: name_goal, x: goalCoord[0], y: goalCoord[1])
        
        sdkInstance.makeTrip(withStart: start, goal: goal, vias: vias) { [self] (aError, aTrip) in
            if let error = aError {
                // 경로 생성 실패
                self.onRouteRequestFailed?()
                print("(VGS) Failed to create trip : \(String(describing: aError))")
            } else if let trip = aTrip {
                // 경로 생성 성공
                print("(VGS) Trip created successfully : \(trip)")
                self.requestRoute(for: trip, re: false)
            }
        }
    }
    
    private func requestRoute(for trip: KNTrip, re: Bool) {
        trip.route(with: routePriority, avoidOptions: routeAvoidOption.rawValue) { [weak self] (aError, aRoutes) in
            guard let self = self else {
                self?.onRouteRequestFailed?()
                return
            }
            
            if let error = aError {
                // 경로 요청 실패
//                isAuthGranted = true
//                isStartReported = true
//
//                isGuideEnded = true
//                delegate?.isArrival(.EXTERNAL)
                self.onRouteRequestFailed?()
                print("(VGS) Failed to request route : \(String(describing: aError))")
            } else if let routes = aRoutes {
                // 경로 요청 성공
                print("(VGS) Routes requested successfully : \(routes)")
                if let guidance = KNSDK.sharedInstance()?.sharedGuidance() {
                    PositionManager.shared.setNaviType(type: .EXTERNAL)
                    
                    // 각 가이던스 델리게이트 등록
                    guidance.guideStateDelegate = self
                    guidance.routeGuideDelegate = self
                    guidance.voiceGuideDelegate = self
                    guidance.safetyGuideDelegate = self
                    guidance.locationGuideDelegate = self
                    guidance.citsGuideDelegate = self
                    self.routeGuidance = guidance
                    
                    // 주행 UI 생성
                    if re {
                        self.onReRouteRequestSuccessed?()
                    }
                    
                    naviView = KNNaviView(guidance: guidance, trip: trip, routeOption: routePriority, avoidOption: routeAvoidOption.rawValue)
                    naviView.frame = containerView.bounds
                    naviView.guideStateDelegate = self
                    naviView.stateDelegate = self
                    naviView.sndVolume(self.naviVolume)
                    setNaviViewOption()
                    locationStartTime = Date()
                    containerView.addSubview(naviView)
//                    self.forceGuidanceEndButton.isHidden = false
                    guidance.start(with: trip, priority: routePriority, avoidOptions: routeAvoidOption.rawValue)
                } else {
                    self.onRouteRequestFailed?()
                    print("(VGS) Error : Cannot get shared guidance")
                }
            }
        }
    }
    
    private func convertWGS84ToKATEC(lon: Double, lat: Double) -> IntPoint? {
        let katecCoord = KNSDK.sharedInstance()?.convertWGS84ToKATEC(withLongitude: lon, latitude: lat)
        return katecCoord
    }
    
    private func convertKATECToWGS84(pos: DoublePoint) -> DoublePoint? {
        let wgs84Coord = KNSDK.sharedInstance()?.convertKATECToWGS84With(x: Int32(pos.x), y: Int32(pos.y))
        return wgs84Coord
    }
    
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
            authKNSDK { knError in
                DispatchQueue.main.async {
                    self.setupLayout()
                    self.setupForceGuidanceEndButtonAction()
                    self.setupSimulationButtonAction()
                }
                if knError == nil {
//                    self.onRouteRequestFailed?()
                    DispatchQueue.main.async {
//                        self.setupLayout()
//                        self.setupForceGuidanceEndButtonAction()
                        self.setDrive()
                    }
                } else {
                    self.onRouteRequestFailed?()
                }
            }
        }
    }
}
