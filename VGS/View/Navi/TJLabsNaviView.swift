
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then
import CoreLocation

class TJLabsNaviView: UIView, UIScrollViewDelegate, CLLocationManagerDelegate {
    
    var pathIndex = 0
//    let path: [[Double]] = [
//        [37.495851, 127.039205, 248.7366],
//        [37.495823, 127.039116, 248.7366],
//        [37.495796, 127.039027, 248.7366],
//        [37.495768, 127.038937, 248.7366],
//        [37.495741, 127.038848, 248.7365],
//        [37.495713, 127.038759, 248.7365],
//        [37.495686, 127.038670, 248.7365],
//        [37.495658, 127.038581, 248.7365],
//        [37.495631, 127.038492, 248.7364],
//        [37.495603, 127.038402, 248.7364]
//    ]
    
//    let path: [[Double]] = [
//        [37.163409, 127.313875, 142.64],
//        [37.16334059821426, 127.31393250685393, 142.64],
//        [37.16327219642852, 127.31399001370786, 142.64],
//        [37.16320379464278, 127.3140475205618, 142.64],
//        [37.16313539285704, 127.31410502741573, 142.64],
//        [37.1630669910713, 127.31416253426966, 142.64],
//        [37.16299858928556, 127.31422004112359, 142.64],
//        [37.16293018749982, 127.31427754797752, 142.64],
//        [37.16286178571408, 127.31433505483146, 142.64],
//        [37.16279338392834, 127.31439256168539, 142.64],
//        [37.1627249821426, 127.31445006853932, 142.64],
//        [37.16265658035686, 127.31450757539325, 142.64],
//        [37.16258817857112, 127.31456508224719, 142.64],
//        [37.16251977678538, 127.31462258910112, 142.64],
//        [37.16245137499964, 127.31468009595505, 142.64],
//        [37.1623829732139, 127.31473760280898, 142.64],
//        [37.16231457142816, 127.31479510966292, 142.64],
//        [37.16224616964242, 127.31485261651685, 142.64],
//        [37.16217776785668, 127.31491012337078, 142.64],
//        [37.16210936607094, 127.31496763022471, 142.64]
//    ]
    
    let path: [[Double]] = [
        [37.157610, 127.313240, 353.2426],
        [37.157734, 127.313222, 353.2426],
        [37.157859, 127.313203, 353.2426],
        [37.157983, 127.313185, 353.2426],
        [37.158107, 127.313166, 353.2426],
        [37.158231, 127.313148, 353.2426],
        [37.158356, 127.313129, 353.2426],
        [37.158480, 127.313111, 353.2426],
        [37.158604, 127.313092, 353.2426],
        [37.158728, 127.313074, 353.2426]
    ]
    
    var isAuthGrated: Bool = false
    
    private var mapImageView = UIImageView()
    private let scrollView = UIScrollView()
    private var velocityLabel = TJLabsVelocityLabel()
    private let myLocationButton = TJLabsMyLocationButton()
    private let zoomButton = TJLabsZoomButton()
    private var imageMapMarker: UIImage?
    private let userCoordTag = 999
    private let USER_CENTER_OFFSET: CGFloat = 50
    private var mode: MapMode = .MAP_ONLY
    private var prePixelCoord: CGPoint?
    private var preHeading: Double?
    private let TIME_FOR_REST: Int = 3000
    private var mapModeChangedTime = 0
    
    // Core Location
    let mapper = PerspectiveMapper()
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"
    private var preCourse: Double = 0
    
    // Outdoor Road
    var outdoorRoadManager = OutdoorRoadManager()
    var OutdoorRoad = [[Double]]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadOutdoorRoad()
        
        setupAssets()
        setupLayout()
        setupLocation()
        setupButtons()
        setupButtonActions()
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadOutdoorRoad()
        
        setupAssets()
        setupLayout()
        setupLocation()
        setupButtons()
        setupButtonActions()
        setupLabels()
    }
    
    func configureFrame(to matchView: UIView) {
        self.frame = matchView.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func loadOutdoorRoad() {
        let roadCoord: [[Double]] = outdoorRoadManager.loadOutdoorRoad(fileName: "skep_pixel_road")
        self.OutdoorRoad = roadCoord
    }
    
    private func setupAssets() {
        imageMapMarker = UIImage(named: "map_marker")
        mapImageView.image = UIImage(named: "img_map_skep")
    }
    
    private func setupLayout() {
        setupMapImageView()
        plotOutdoorRoad(outdoorRoad: self.OutdoorRoad)
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
        let pixelCoord = mapper.latLonToPixel(lat: currentCoordinate!.latitude, lon: currentCoordinate!.longitude)
//        let latitude_start = 37.495758
//        let longitude_start = 127.038249
//        
//        let pixelCoord = mapper.latLonToPixel(lat: latitude_start, lon: longitude_start)
//        print("(TJLabsNaviView) Position : \(pixelCoord)")
        
        if !mapImageView.isHidden && isAuthGrated {
            let coord = [currentCoordinate!.latitude, currentCoordinate!.longitude]
//            let coord = path[pathIndex]
//            pathIndex += 1
//            if pathIndex > path.count-1 {
//                pathIndex = path.count-1
//            }
            PositionManager.shared.updateCurrentLocation(lat: coord[0], lon: coord[1])
            let speedKmh = location.speed*3.6
            PositionManager.shared.position.speed = speedKmh
            DispatchQueue.main.async {
                let velocityString = String(Int(round(speedKmh)))
                self.velocityLabel.setText(text: velocityString)
            }
            var curCourse = location.course
            if curCourse == -1.0 {
                curCourse = preCourse
                PositionManager.shared.currentHeading = preCourse
            } else {
                PositionManager.shared.currentHeading = curCourse
                preCourse = location.course
            }
            print("(GPS Check) \(currentCoordinate!.latitude),\(currentCoordinate!.longitude),\(PositionManager.shared.currentHeading!)")
            
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
    
    private func plotOutdoorRoad(outdoorRoad: [[Double]]) {
        print("(plotOutdoorRoad) : \(outdoorRoad)")
        DispatchQueue.main.async { [self] in
            guard let image = mapImageView.image,
                  let cgImage = image.cgImage else {
                return
            }

            let pixelSize = CGSize(width: cgImage.width, height: cgImage.height)
            let logicalSize = image.size

            let scaleX = logicalSize.width / pixelSize.width
            let scaleY = logicalSize.height / pixelSize.height
            
            for coord in OutdoorRoad {
                let pixelCoord: CGPoint = CGPoint(x: coord[0], y: coord[1])
                let logicalCoord = CGPoint(
                    x: pixelCoord.x * scaleX,
                    y: pixelCoord.y * scaleY
                )
                
                guard let viewPoint = convertImagePointToViewPoint(imagePoint: logicalCoord, in: mapImageView) else { return }

                let markerSize: CGFloat = 10
                let pointView = UIView(frame: CGRect(x: viewPoint.x - markerSize / 2, y: viewPoint.y - markerSize / 2, width: markerSize, height: markerSize))
//                pointView.backgroundColor = .systemYellow
                pointView.backgroundColor = UIColor(hex: "#565656")
//                pointView.layer.cornerRadius = markerSize / 2
                pointView.layer.cornerRadius = 3
                mapImageView.addSubview(pointView)
            }
            
            for coord in OutdoorRoad {
                let pixelCoord: CGPoint = CGPoint(x: coord[0], y: coord[1])
                let logicalCoord = CGPoint(
                    x: pixelCoord.x * scaleX,
                    y: pixelCoord.y * scaleY
                )
                
                guard let viewPoint = convertImagePointToViewPoint(imagePoint: logicalCoord, in: mapImageView) else { return }

                let markerSize: CGFloat = 2
                let pointView = UIView(frame: CGRect(x: viewPoint.x - markerSize / 2, y: viewPoint.y - markerSize / 2, width: markerSize, height: markerSize))
                pointView.backgroundColor = .systemYellow
                pointView.layer.cornerRadius = 0.2
                mapImageView.addSubview(pointView)
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
            let coordSize: CGFloat = 20
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
}
