
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
    private var imageMapMarker: UIImage?
    private let userCoordTag = 999
    private let USER_CENTER_OFFSET: CGFloat = 15
    
    // Core Location
    let mapper = PerspectiveMapper()
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupAssets()
        setupLayout()
        setupLocation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAssets()
        setupLayout()
        setupLocation()
    }
    
    func configureFrame(to matchView: UIView) {
        self.frame = matchView.bounds
        print("(TJLabsNaviView) configureFrame \(self.frame)")
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func setupAssets() {
        imageMapMarker = UIImage(named: "map_marker")
        mapImageView.image = UIImage(named: "img_map_skep")
    }
    
    private func setupLayout() {
        setupMapImageView()
    }
    
    private func setupMapImageView() {
        scrollView.frame = self.bounds
        scrollView.backgroundColor = .clear
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 14.0
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
            PositionManager.shared.position.speed = location.speed
            PositionManager.shared.currentHeading = location.course
            
            let converted = mapper.latLonToPixel(lat: coord[0], lon: coord[1])
            var convertedHeading = (92.4 - location.course).truncatingRemainder(dividingBy: 360)
            if convertedHeading < 0 {
                convertedHeading += 360
            }
            
            plotUserCoordWithZoomAndRotation(pixelCoord: converted, heading: convertedHeading)
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

            // 기존 마커 제거
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
            let coordSize: CGFloat = 6
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
            let scaleFactor: CGFloat = 14.0
            let mapCenterX = scrollView.bounds.midX
            let mapCenterY = scrollView.bounds.midY
            let pointViewCenterInSelf = scrollView.convert(pointView.center, to: self.scrollView)
                
            let dx = -USER_CENTER_OFFSET * cos(heading * (.pi / 180))
            let dy = USER_CENTER_OFFSET * sin(heading * (.pi / 180))
                
            let translationX = mapCenterX - pointViewCenterInSelf.x + dx
            let translationY = mapCenterY - pointViewCenterInSelf.y + dy
            
            UIView.animate(withDuration: 0.55, delay: 0, options: .curveEaseInOut, animations: {
                self.mapImageView.transform = CGAffineTransform(rotationAngle: rotationAngle)
                    .scaledBy(x: scaleFactor, y: scaleFactor)
                    .translatedBy(x: translationX, y: translationY)
            }, completion: nil)
            pointView.transform = CGAffineTransform(rotationAngle: -rotationAngle)
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
