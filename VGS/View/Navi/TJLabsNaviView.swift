
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then
import CoreLocation
import TJLabsAuth

enum RoadType: String {
    case FRAME = "FRAME"
    case MAIN = "MAIN"
    case SUB = "SUB"
}

class TJLabsNaviView: UIView, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    var isAuthGranted: Bool = false
    
    private var mapImageView = UIImageView()
    private let scrollView = UIScrollView()
    private var velocityLabel = TJLabsVelocityLabel()
    private let myLocationButton = TJLabsMyLocationButton()
    private let zoomButton = TJLabsZoomButton()
    private let overSpeedFlashView = UIView()
    
    private var imageMapMarker: UIImage?
    private let userCoordTag = 999
    private let USER_CENTER_OFFSET: CGFloat = 60
    private var mode: MapMode = .MAP_ONLY
    private var prePixelCoord: CGPoint?
    private var preHeading: Double?
    private let TIME_FOR_REST: Int = 3000
    private var mapModeChangedTime = 0
    
    // Speed Limit
    var currentSpeed: Double = 0
    private let LIMIT_SPEED: Double = 30 // Kmh
    var flashTimer: DispatchSourceTimer?
    let TIMER_INTERVAL: TimeInterval = 1.5
    
    // Core Location
    let mapper = PerspectiveMapper()
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"
    private var preCourse: Double = 0
    
    // Outdoor Road
//    var outdoorRoadManager = OutdoorRoadManager()
//    var OutdoorRoad = [[Double]]()
    var nodeData = [Int: [Int]]()
    var linkData = [Int: [Int]]()
    var routeData = [TJLabsRoute]()
    
    // Auth
    var service_sector_id: Int = 24
    var tjlabsAuthGranted: Bool = false
    var tenantInfo = TenantResult(id: 0, name: "", sectors: [])
    var sectorInfo = SectorResult(pp_csv: "", nodes: [], links: [], routes: [])
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        notificationCenterAddObserver()
        authTJLabs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        notificationCenterRemoveObserver()
    }
    
    private func authTJLabs() {
        TJLabsAuthConstants.setServerURL(region: AuthRegion.KOREA.rawValue, serverType: "phoenix")
        TJLabsAuthManager.shared.auth(name: "skep", password: "Skep1234!", completion: { statusCode, isSuccess in
            print("(TJLabsNaviView) authTJLabs : \(statusCode) , \(isSuccess)")
            if isSuccess {
                self.tjlabsAuthGranted = true
                self.getTenantResult()
            }
        })
    }
    
    private func getTenantResult() {
        let url = TJLabsAuthConstants.getUserBaseURL() + "/" + USER_PHOENIX_TENANT_SERVER_VERSION + "/tenant"
//        print("(TJLabsNaviView) getTenant : url = \(url)")
        TJLabsNaviManager.shared.getTenant(url: url, completion: { [self] statusCode, returnedString in
            if statusCode == 200 {
                if let decodedResult = TJLabsNaviManager.shared.decodeTenantResult(from: returnedString) {
//                    print("(TJLabsNaviView) getTenant decodedResult = \(decodedResult)")
                    self.tenantInfo = decodedResult
                    let sectors = decodedResult.sectors
                    for sector in sectors {
                        if sector.id == self.service_sector_id {
                            getSectorResult(sector_id: sector.id)
                        }
                    }
                }
            }
        })
    }
    
    private func getSectorResult(sector_id: Int) {
        let url = TJLabsAuthConstants.getUserBaseURL() + "/" + USER_PHOENIX_SECTOR_SERVER_VERSION + "/sector"
//        print("(TJLabsNaviView) getSector : url = \(url)")
        TJLabsNaviManager.shared.getSector(url: url, sector_id: sector_id, completion: { statusCode, returnedString in
            if statusCode == 200 {
                if let decodedResult = TJLabsNaviManager.shared.decodeSectorResult(from: returnedString) {
//                    print("(TJLabsNaviView) getSector decodedResult = \(decodedResult)")
                    self.sectorInfo = decodedResult
                    OutdoorRoadManager.shared.loadOutdoorPp(pp_csv: decodedResult.pp_csv, sector_id: sector_id)
                    OutdoorRoadManager.shared.loadOutdoorNodeLink(sector_id: sector_id, nodes: decodedResult.nodes, links: decodedResult.links)
//                    OutdoorRoadManager.shared.loadOutdoorLink(sector_id: sector_id, links: decodedResult.links)
                    OutdoorRoadManager.shared.loadOutdoorRoutes(sector_id: sector_id, routes: decodedResult.routes)
                }
            }
        })
    }
    
    func configureFrame(to matchView: UIView) {
        self.frame = matchView.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
//        loadOutdoorRoad()
        
        setupAssets()
        setupLayout()
        setupLocation()
        setupButtons()
        setupButtonActions()
        setupLabels()
        setupFlashView()
        startTimer()
    }
    
//    func loadOutdoorRoad() {
//        let roadCoord: [[Double]] = outdoorRoadManager.loadOutdoorRoadfromFile(fileName: "skep_pixel_road")
//        self.OutdoorRoad = roadCoord
//    }
    
    private func setupAssets() {
        imageMapMarker = UIImage(named: "map_marker")
        mapImageView.image = UIImage(named: "img_map_skep")
    }
    
    private func setupLayout() {
        setupMapImageView()
        plotOutdoorRoad(type: .FRAME)
        plotOutdoorRoad(type: .MAIN)
        plotOutdoorRoad(type: .SUB)
    }
    
    private func setupFlashView() {
        overSpeedFlashView.backgroundColor = UIColor(hex: "#E91E1E").withAlphaComponent(0.4)
        overSpeedFlashView.isUserInteractionEnabled = false
        overSpeedFlashView.alpha = 0
        addSubview(overSpeedFlashView)
        bringSubviewToFront(overSpeedFlashView)

        overSpeedFlashView.snp.makeConstraints { make in
            make.edges.equalTo(mapImageView)
        }
    }
    
    private func setupMapImageView() {
        scrollView.frame = self.bounds
        scrollView.backgroundColor = .clear
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.isScrollEnabled = false
        scrollView.delegate = self
        addSubview(scrollView)
        
        mapImageView.contentMode = .scaleAspectFit
        mapImageView.backgroundColor = .clear
        mapImageView.frame = scrollView.bounds
        mapImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.addSubview(mapImageView)
        mapImageView.isHidden = false
    }
    
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupLabels() {
        addSubview(velocityLabel)
        NSLayoutConstraint.activate([
            velocityLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 80),
            velocityLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50)
        ])
    }
    
    private func setupButtons() {
        [zoomButton, myLocationButton].forEach {
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            myLocationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            myLocationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            zoomButton.trailingAnchor.constraint(equalTo: myLocationButton.trailingAnchor),
            zoomButton.bottomAnchor.constraint(equalTo: myLocationButton.topAnchor, constant: -10)
        ])
        
        zoomButton.isHidden = false
        myLocationButton.isHidden = false
    }
    
    private func setupButtonActions() {
        myLocationButton.addAction(UIAction { [weak self] _ in
            self?.myLocationButtonTapped()
        }, for: .touchUpInside)
        
        myLocationButton.addAction(UIAction { [weak self] _ in
            self?.myLocationButtonTappedOver()
        }, for: [.touchUpInside, .touchUpOutside])
        
        zoomButton.addAction(UIAction { [weak self] _ in
            self?.zoomButtonTapped()
        }, for: .touchUpInside)
        
        zoomButton.addAction(UIAction { [weak self] _ in
            self?.zoomButtonTappedOver()
        }, for: [.touchUpInside, .touchUpOutside])
    }
    
    private func myLocationButtonTapped() {
        self.zoomButton.isUserInteractionEnabled = false
        self.myLocationButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1) {
            self.myLocationButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        self.mode = .UPDATE_USER
        forceToZoomInMode()
    }
    
    private func myLocationButtonTappedOver() {
        UIView.animate(withDuration: 0.1) {
            self.myLocationButton.transform = CGAffineTransform.identity
            self.zoomButton.isUserInteractionEnabled = true
            self.myLocationButton.isUserInteractionEnabled = true
        }
    }
    
    private func forceToZoomInMode() {
        if TJLabsZoomButton.zoomMode == .ZOOM_OUT {
            toggleZoomMode(to: .ZOOM_IN)
            if let pixelCoord = prePixelCoord, let heading = preHeading {
                plotUserCoordWithZoomAndRotation(pixelCoord: pixelCoord, heading: heading)
            }
        } else {
            if let pixelCoord = prePixelCoord, let heading = preHeading {
                plotUserCoordWithZoomAndRotation(pixelCoord: pixelCoord, heading: heading)
            }
        }
    }
    
    private func zoomButtonTapped() {
        self.zoomButton.isUserInteractionEnabled = false
        self.myLocationButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1) {
            self.zoomButton.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
        toggleZoomMode()
    }
    
    private func zoomButtonTappedOver() {
        UIView.animate(withDuration: 0.1) {
            self.zoomButton.transform = CGAffineTransform.identity
            self.zoomButton.isUserInteractionEnabled = true
            self.myLocationButton.isUserInteractionEnabled = true
        }
    }
        
    private func toggleZoomMode(to mode: ZoomMode? = nil) {
        zoomButton.setButtonImage(to: mode)
        if TJLabsZoomButton.zoomMode == .ZOOM_IN {
            if let pixelCoord = prePixelCoord, let heading = preHeading {
                plotUserCoordWithZoomAndRotation(pixelCoord: pixelCoord, heading: heading)
            }
        } else {
            zoomButton.updateZoomModeChangedTime(time: getCurrentTimeInMilliseconds())
            // 현재 전체 모드
            if let pixelCoord = prePixelCoord, let heading = preHeading, self.mode != .MAP_INTERACTION {
                plotUserCoord(pixelCoord: pixelCoord, heading: heading)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        currentCoordinate = location.coordinate
        if !mapImageView.isHidden && isAuthGranted {
            var coord = [currentCoordinate!.latitude, currentCoordinate!.longitude]
            var curCourse = location.course
            
            // Simulation
            if SimulationPath.isSimulation {
                coord = SimulationPath.path[SimulationPath.pathIndex]
                curCourse = coord[2]
                SimulationPath.pathIndex += 1
                
                if SimulationPath.pathIndex > SimulationPath.path.count-1 {
                    SimulationPath.pathIndex = SimulationPath.path.count-1
                }
            }
            
            PositionManager.shared.updateCurrentLocation(lat: coord[0], lon: coord[1])
            let speedKmh = location.speed*3.6
//            let speedKmh: Double = 35
            PositionManager.shared.position.speed = speedKmh
            self.currentSpeed = speedKmh
            DispatchQueue.main.async {
                let velocityString = String(Int(round(speedKmh)))
                self.velocityLabel.setText(text: velocityString)
            }
            
            if curCourse == -1.0 {
                curCourse = preCourse
                PositionManager.shared.currentHeading = preCourse
            } else {
                PositionManager.shared.currentHeading = curCourse
                preCourse = location.course
            }
//            print("(GPS Check) \(currentCoordinate!.latitude),\(currentCoordinate!.longitude),\(PositionManager.shared.currentHeading!)")
            print("(GPS Check) \(coord)")
            
            let converted = mapper.latLonToPixel(lat: coord[0], lon: coord[1])
            var convertedHeading = (90.91 - curCourse).truncatingRemainder(dividingBy: 360)
//            var convertedHeading = (92.4 - curCourse).truncatingRemainder(dividingBy: 360)
            if convertedHeading < 0 {
                convertedHeading += 360
            }
            
            updateUserCoord(pixelCoord: converted, heading: convertedHeading)
//            plotUserCoordWithZoomAndRotation(pixelCoord: converted, heading: convertedHeading)
        }
    }
    
    private func updateUserCoord(pixelCoord: CGPoint, heading: Double) {
        if mode == .MAP_ONLY {
            mode = .UPDATE_USER
            toggleZoomMode(to: .ZOOM_IN)
            DispatchQueue.main.async { [self] in
                zoomButton.isHidden = false
                myLocationButton.isHidden = false
            }
        } else if mode == .MAP_INTERACTION {
            DispatchQueue.main.async { [self] in
                if zoomButton.isHidden {
                    zoomButton.isHidden = false
                    myLocationButton.isHidden = false
                }
            }
            if (getCurrentTimeInMilliseconds() - mapModeChangedTime) > TIME_FOR_REST && mapModeChangedTime != 0 {
                mode = .UPDATE_USER
            }
        }
        
        if TJLabsZoomButton.zoomMode == .ZOOM_IN {
            plotUserCoordWithZoomAndRotation(pixelCoord: pixelCoord, heading: heading)
        } else {
            // 모드 전환 시기 확인
            if (getCurrentTimeInMilliseconds() - TJLabsZoomButton.zoomModeChangedTime) > TIME_FOR_REST && TJLabsZoomButton.zoomModeChangedTime != 0 {
                toggleZoomMode()
                plotUserCoordWithZoomAndRotation(pixelCoord: pixelCoord, heading: heading)
            } else {
                plotUserCoord(pixelCoord: pixelCoord, heading: heading)
            }
        }
    }
    
    private func checkLimitSpeed(speedKmh: Double) {
        if speedKmh >= LIMIT_SPEED {
            flashMapRed()
        }
    }
    
    private func flashMapRed() {
        DispatchQueue.main.async { [self] in
            guard overSpeedFlashView.alpha == 0 else { return }

            UIView.animate(withDuration: 0.2, animations: {
                self.overSpeedFlashView.alpha = 1.0
            }) { _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.overSpeedFlashView.alpha = 0.0
                })
            }
        }
    }
    
    private func plotOutdoorRoad(type: RoadType) {
        for (key, value) in self.linkData {
            let linkNumber = key
            let startNode = value[0]
            let endNode = value[1]
            
            guard let startCoordArray = self.nodeData[startNode],
                  let endCoordArray = self.nodeData[endNode],
                  startCoordArray.count == 2,
                  endCoordArray.count == 2 else {
                continue
            }

            let startPixel = CGPoint(x: startCoordArray[0], y: startCoordArray[1])
            let endPixel = CGPoint(x: endCoordArray[0], y: endCoordArray[1])
            
            DispatchQueue.main.async { [self] in
                guard let image = mapImageView.image,
                      let cgImage = image.cgImage else {
                    return
                }
                
                let pixelSize = CGSize(width: cgImage.width, height: cgImage.height)
                let logicalSize = image.size
                
                let scaleX = logicalSize.width / pixelSize.width
                let scaleY = logicalSize.height / pixelSize.height
                
                let startLogical = CGPoint(x: startPixel.x * scaleX, y: startPixel.y * scaleY)
                let endLogical = CGPoint(x: endPixel.x * scaleX, y: endPixel.y * scaleY)
                
                guard let startViewPoint = convertImagePointToViewPoint(imagePoint: startLogical, in: mapImageView),
                      let endViewPoint = convertImagePointToViewPoint(imagePoint: endLogical, in: mapImageView) else {
                    return
                }

                let path = UIBezierPath()
                path.move(to: startViewPoint)
                path.addLine(to: endViewPoint)

                let shapeLayer = CAShapeLayer()
                shapeLayer.path = path.cgPath
                
                var lineColor = UIColor.black
                var lineWidth = 1.0
                
                switch (type) {
                case .FRAME:
                    lineColor = UIColor(hex: "#000000")
                    shapeLayer.lineCap = .round
                    lineWidth = 8.0
                case .MAIN:
                    lineColor = UIColor(hex: "#888888")
                    lineWidth = 6.0
                    shapeLayer.lineCap = .round
                case .SUB:
                    lineColor = UIColor(hex: "#FFD600")
                    lineWidth = 1.0
                    shapeLayer.lineDashPattern = [4, 2]
                }
                
                shapeLayer.strokeColor = lineColor.cgColor
                shapeLayer.lineWidth = lineWidth
                
                shapeLayer.name = "link_\(type.rawValue)_\(linkNumber)"

                mapImageView.layer.addSublayer(shapeLayer)
            }
        }
    }
    
    private func plotUserCoord(pixelCoord: CGPoint, heading: Double) {
        DispatchQueue.main.async { [self] in
            guard let image = mapImageView.image,
                  let cgImage = image.cgImage else {
                return
            }

            let pixelSize = CGSize(width: cgImage.width, height: cgImage.height)
            let logicalSize = image.size

            let scaleX = logicalSize.width / pixelSize.width
            let scaleY = logicalSize.height / pixelSize.height

            let logicalCoord = CGPoint(
                x: pixelCoord.x * scaleX,
                y: pixelCoord.y * scaleY
            )
            
            mapImageView.transform = .identity
            mapImageView.viewWithTag(userCoordTag)?.removeFromSuperview()

            guard let viewPoint = convertImagePointToViewPoint(imagePoint: logicalCoord, in: mapImageView) else { return }

            let marker = self.imageMapMarker
            let coordSize: CGFloat = 30
            let pointView = UIImageView(image: marker)
            pointView.frame = CGRect(x: 0, y: 0, width: coordSize, height: coordSize)
            pointView.center = viewPoint
            pointView.tag = userCoordTag
            // 그림자 효과
            pointView.layer.shadowColor = UIColor.black.cgColor
            pointView.layer.shadowOpacity = 0.25
            pointView.layer.shadowOffset = CGSize(width: 0, height: 2)
            pointView.layer.shadowRadius = 2

            // 방향 회전
            let rotationAngle = CGFloat(-(heading-90) * .pi / 180)
            pointView.transform = CGAffineTransform(rotationAngle: rotationAngle)

            mapImageView.addSubview(pointView)
            
            prePixelCoord = pixelCoord
            preHeading = heading
        }
    }
    
    
    private func plotUserCoordWithZoomAndRotation(pixelCoord: CGPoint, heading: Double) {
        DispatchQueue.main.async { [self] in
            guard let image = mapImageView.image,
                  let cgImage = image.cgImage else {
                return
            }

            let pixelSize = CGSize(width: cgImage.width, height: cgImage.height)
            let logicalSize = image.size

            let scaleX = logicalSize.width / pixelSize.width
            let scaleY = logicalSize.height / pixelSize.height

            let logicalCoord = CGPoint(
                x: pixelCoord.x * scaleX,
                y: pixelCoord.y * scaleY
            )

            // 기존 마커 제거
            mapImageView.viewWithTag(userCoordTag)?.removeFromSuperview()

            guard let viewPoint = convertImagePointToViewPoint(imagePoint: logicalCoord, in: mapImageView) else { return }

            let marker = self.imageMapMarker
            let coordSize: CGFloat = 15
            let pointView = UIImageView(image: marker)
            pointView.frame = CGRect(x: 0, y: 0, width: coordSize, height: coordSize)
            pointView.center = viewPoint
            pointView.tag = userCoordTag
            // 그림자 효과
            pointView.layer.shadowColor = UIColor.black.cgColor
            pointView.layer.shadowOpacity = 0.25
            pointView.layer.shadowOffset = CGSize(width: 0, height: 2)
            pointView.layer.shadowRadius = 2
            
            UIView.animate(withDuration: 0.55, delay: 0, options: .curveEaseInOut, animations: {
                self.mapImageView.addSubview(pointView)
            }, completion: nil)
            
            let rotationAngle = CGFloat((heading-90) * .pi / 180)
            let scaleFactor: CGFloat = 4.0
            let mapCenterX = scrollView.bounds.midX
            let mapCenterY = scrollView.bounds.midY
            let pointViewCenterInSelf = scrollView.convert(pointView.center, to: self.scrollView)
                
            let dx = -USER_CENTER_OFFSET * cos(heading * (.pi / 180))
            let dy = USER_CENTER_OFFSET * sin(heading * (.pi / 180))
            
            let mapRotatingX = mapCenterX - pointViewCenterInSelf.x
            let mapRotatingY = mapCenterY - pointViewCenterInSelf.y
            
            let translationX = mapCenterX - pointViewCenterInSelf.x + dx
            let translationY = mapCenterY - pointViewCenterInSelf.y + dy
            
            UIView.animate(withDuration: 0.55, delay: 0, options: .curveEaseInOut, animations: {
                self.mapImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
                    .scaledBy(x: scaleFactor, y: scaleFactor)
                    .translatedBy(x: translationX, y: translationY)
            }, completion: nil)
            
//            UIView.animate(withDuration: 0.55, delay: 0, options: .curveEaseInOut, animations: {
//                self.mapImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
//                    .scaledBy(x: scaleFactor, y: scaleFactor)
//                    .translatedBy(x: mapRotatingX, y: mapRotatingY)
//            }, completion: nil)
            
            pointView.transform = CGAffineTransform(rotationAngle: -rotationAngle)
            
            prePixelCoord = pixelCoord
            preHeading = heading
        }
    }
    
    private func convertImagePointToViewPoint(imagePoint: CGPoint, in imageView: UIImageView) -> CGPoint? {
        guard let image = imageView.image else { return nil }

        let imageSize = image.size
        let viewSize = imageView.bounds.size

        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height

        var drawSize = CGSize.zero
        if imageAspect > viewAspect {
            drawSize.width = viewSize.width
            drawSize.height = viewSize.width / imageAspect
        } else {
            drawSize.height = viewSize.height
            drawSize.width = viewSize.height * imageAspect
        }

        let offsetX = (viewSize.width - drawSize.width) / 2.0
        let offsetY = (viewSize.height - drawSize.height) / 2.0

        let scaleX = drawSize.width / imageSize.width
        let scaleY = drawSize.height / imageSize.height

        let viewX = offsetX + imagePoint.x * scaleX
        let viewY = offsetY + imagePoint.y * scaleY

        return CGPoint(x: viewX, y: viewY)
    }
    
    // Flash Timer
    private func startTimer() {
        if (self.flashTimer == nil) {
            let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".positionTimer")
            self.flashTimer = DispatchSource.makeTimerSource(queue: queue)
            self.flashTimer!.schedule(deadline: .now(), repeating: TIMER_INTERVAL)
            self.flashTimer!.setEventHandler { [weak self] in
                guard let self = self else { return }
                self.flashTimerUpdate()
            }
            self.flashTimer!.resume()
        }
    }
    
    public func stopTimer() {
        self.flashTimer?.cancel()
        self.flashTimer = nil
    }
    
    func flashTimerUpdate() {
        self.checkLimitSpeed(speedKmh: self.currentSpeed)
    }
    
    // MARK: - Observer
    func notificationCenterAddObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePathPixelUpdate(_:)), name: .outdoorPathPixelUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNodeLinkUpdate(_:)), name: .outdoorNodeLinkUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRoutesUpdate(_:)), name: .outdoorRoutesUpdated, object: nil)
    }
    
    func notificationCenterRemoveObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handlePathPixelUpdate(_ notification: Notification) {
        if let sectorId = notification.userInfo?["pathPixelKey"] as? Int {
            if let ppData = OutdoorRoadManager.shared.outdoorPathPixels[sectorId] {
//                print("(TJLabsNaviView) 🟦 pathPixelKey 업데이트됨: \(sectorId)")
            }
        }
    }

    @objc private func handleNodeLinkUpdate(_ notification: Notification) {
        guard let sectorId = notification.userInfo?["nodeLinkKey"] as? Int,
              let nodeData = OutdoorRoadManager.shared.outdoorNodes[sectorId],
              let linkData = OutdoorRoadManager.shared.outdoorLinks[sectorId] else { return }
        
//        print("(TJLabsNaviView) nodeData : \(nodeData)")
//        print("(TJLabsNaviView) linkData : \(linkData)")
        self.nodeData = nodeData
        self.linkData = linkData
    }

    @objc private func handleRoutesUpdate(_ notification: Notification) {
        if let sectorId = notification.userInfo?["routeKey"] as? Int {
            if let routeData = OutdoorRoadManager.shared.outdoorRoutes[sectorId] {
                print("(TJLabsNaviView) routeData : \(routeData)")
                self.routeData = routeData
            }
        }
    }
}
