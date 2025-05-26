
import UIKit
import SnapKit

class KakaoNaviView: UIView, KNNaviView_GuideStateDelegate, KNNaviView_StateDelegate, KNGuidance_GuideStateDelegate, KNGuidance_RouteGuideDelegate, KNGuidance_VoiceGuideDelegate, KNGuidance_SafetyGuideDelegate, KNGuidance_LocationGuideDelegate, KNGuidance_CitsGuideDelegate {
    
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
        self.naviView.guidanceGuideStarted(aGuidance)
    }
    
    func guidanceCheckingRouteChange(_ aGuidance: KNGuidance) {
        // TO-DO
        self.naviView.guidanceCheckingRouteChange(aGuidance)
    }
    
    func guidanceOut(ofRoute aGuidance: KNGuidance) {
        // TO-DO
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
        delegate?.isArrival(.EXTERNAL)
//        self.naviView.guidanceGuideEnded(aGuidance, isShowDriveResultDialog: true)
    }
    
    func guidance(_ aGuidance: KNGuidance, didUpdate aRoutes: [KNRoute], multiRouteInfo aMultiRouteInfo: KNMultiRouteInfo?) {
        // TO-DO
        
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
//        self.kakaoNaviPos.
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
        // TO-DO
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
                let longitude: Double = curLatLon.x
                let latitude: Double = curLatLon.y
                let now = Date()
                let elapsed = now.timeIntervalSince(locationStartTime)
                if elapsed >= 10 {
                    PositionManager.shared.updateCurrentLocation(lat: latitude, lon: longitude)
                } else {
                    print("🕒 위치 업데이트 무시 (기준시간 이내 \(elapsed)초)")
                }
                isCurLocExist = true
            }
        }
        
        if !isCurLocExist {
            if let latLon = convertKATECToWGS84(pos: DoublePoint(x: aLocationGuide.gpsMatched.pos.x, y: aLocationGuide.gpsMatched.pos.y)) {
                let longitude: Double = latLon.x
                let latitude: Double = latLon.y
                let now = Date()
                let elapsed = now.timeIntervalSince(locationStartTime)
                if elapsed >= 10 {
                    PositionManager.shared.updateCurrentLocation(lat: latitude, lon: longitude)
                } else {
                    print("🕒 위치 업데이트 무시 (기준시간 이내 \(elapsed)초)")
                }
            }
        }
        let speed: Int32 = aLocationGuide.gpsMatched.speed
        let heading: Int32 = aLocationGuide.gpsMatched.angle

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
    
    var naviView = KNNaviView.init()
    var routePriority: KNRoutePriority = .time
    var routeAvoidOption: KNRouteAvoidOption = .none
    var routeGuidance = KNGuidance()
    var naviVolume: Float = 1.0
    var isGuideEnded: Bool = false
    
    var isStartReported: Bool = false
    private var locationStartTime: Date = Date()
    
    weak var delegate: NaviArrivalDelegate?
    
    init() {
        super.init(frame: .zero)
        authKNSDK(completion: { [self] knError in
            if knError == nil {
                setupLayout()
                setDrive()
            } else {
                print("(VGS) Auth : \(knError)")
            }
        })
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
    }
    
    private func setNaviViewOption() { }
    
    private func setDrive() {
        // 시작 점은 TJLABS 회사 위치
        let latitude_start = 37.495758
        let longitude_start = 127.038249
        let name_start = "Start Point"
        
        // 도착 점은 COEX
//        let latitude_goal = 37.513109
//        let longitude_goal = 127.058375
        
        let latitude_goal = 37.49559667720228
        let longitude_goal = 127.03842115551231
        let name_goal = "Goal Point"
        
        let vias: [KNPOI] = []
        
        guard let sdkInstance = KNSDK.sharedInstance() else {
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
                print("(VGS) Failed to create trip : \(String(describing: aError))")
            } else if let trip = aTrip {
                // 경로 생성 성공
                print("(VGS) Trip created successfully : \(trip)")
                self.requestRoute(for: trip)
            }
        }
    }
    
    private func requestRoute(for trip: KNTrip) {
        trip.route(with: routePriority, avoidOptions: routeAvoidOption.rawValue) { [weak self] (aError, aRoutes) in
            guard let self = self else { return }
            if let error = aError {
                // 경로 요청 실패
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
                    naviView = KNNaviView(guidance: guidance, trip: trip, routeOption: routePriority, avoidOption: routeAvoidOption.rawValue)
                    naviView.frame = containerView.bounds
//                    naviView.frame = self.view.bounds
                    naviView.guideStateDelegate = self
                    naviView.stateDelegate = self
                    naviView.sndVolume(self.naviVolume)
                    setNaviViewOption()
                    locationStartTime = Date()
                    containerView.addSubview(naviView)
                } else {
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
    
    func calArrivalTimeString(secondsToArrival: Int32) -> String {
        // 현재 시간에 초를 더한 도착 시간 계산
        let arrivalDate = Date().addingTimeInterval(TimeInterval(secondsToArrival))
        
        // ISO 8601 형식으로 포맷 (UTC 기준)
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC 기준
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return formatter.string(from: arrivalDate)
    }
}
