import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class OutdoorNaviViewController: UIViewController, UIScrollViewDelegate {

    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let mainView = UIView().then {
        $0.backgroundColor = .clear
    }

    private let scrollView = UIScrollView().then {
        $0.bouncesZoom = true
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 10.0
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }

    private let mapImageView = UIImageView().then {
//        $0.image = UIImage(named: "img_map_skep")
        $0.image = UIImage(named: "temp_map")
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }
    
    private var userMarkerImageView: UIImageView?
    
    private let requestButton = UIView().then {
        $0.backgroundColor = UIColor(hex: "#E47325")
        $0.alpha = 1.0
        $0.cornerRadius = 15
        $0.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
    }

    private var requestButtonTitleLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = UIFont.notoSansBold(size: 48)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.text = "진입 요청"
    }
    
    let mapView = TJLabsNaviView()
    
    let mapper = PerspectiveMapper()
    private let userCoordTag = 999
    private let USER_CENTER_OFFSET: CGFloat = 40
    private var imageMapMarker: UIImage?
    
    // Core Location
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentAddress: String = "현재 위치"
    
    private var isGuiding: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        view.backgroundColor = .black
        startOutdoor()
        setupLayout()
        bindActions()
        setupNaviView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerAndZoomImage()
    }
    
    private func centerAndZoomImage() {
        guard let image = mapImageView.image else { return }

        let imageSize = image.size
        let scrollSize = scrollView.bounds.size

        // 1. 이미지와 scrollView 비율 계산
        let scaleWidth = scrollSize.width / imageSize.width
        let scaleHeight = scrollSize.height / imageSize.height
        let minScale = min(scaleWidth, scaleHeight)

        // 2. 최소 scale로 설정하고 contentSize, imageView frame 재설정
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale

        mapImageView.frame = CGRect(origin: .zero, size: CGSize(width: imageSize.width, height: imageSize.height))
        scrollView.contentSize = mapImageView.frame.size
        centerImage()
        mapImageView.isHidden = false
    }

    private func setupLayout() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        containerView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(120)
        }
        
//        containerView.addSubview(scrollView)
//        scrollView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.bottom.equalToSuperview().inset(120)
//        }
//
//        scrollView.addSubview(mapImageView)
//        if let imageSize = mapImageView.image?.size {
//            mapImageView.frame = CGRect(origin: .zero, size: imageSize)
//            scrollView.contentSize = imageSize
//        }

        view.addSubview(requestButton)
        requestButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(90)
            make.bottom.equalToSuperview().inset(20)
        }

        requestButton.addSubview(requestButtonTitleLabel)
        requestButtonTitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }
    
    func setupNaviView() {
        mapView.configureFrame(to: mainView)
        mainView.addSubview(mapView)
    }
    
    private func bindActions() {
        setupRequestButtonAction()
//        scrollView.delegate = self
    }

    private func setupRequestButtonAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRequestButton))
        requestButton.isUserInteractionEnabled = true
        requestButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleRequestButton() {
        if isGuiding {
            self.dismiss(animated: true, completion: nil)
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                self.requestButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.requestButton.transform = .identity
                }, completion: { _ in
                    // 1️⃣ 애니메이션 모두 완료된 후 요청 수행
                    self.requestAuth()

                    // 2️⃣ 3초 후 다이얼로그 표시
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.showDialogView()
                    }
                })
            })
        }
    }
    
    private func requestAuth() {
        self.requestButton.backgroundColor = UIColor(hex: "#2c2c2c")
        self.requestButtonTitleLabel.text = "대기중..."
    }

    private func showDialogView() {
        let dialogView = DialogView(contentViewHeight: 240)
        dialogView.setDialogString(title: "운행 시작", message: "요청이 승인되었습니다. 현장으로 진입해주세요. 운행 종료 후 종료 버튼을 눌러주세요.")
        dialogView.onConfirm = { [weak self] in
            self?.isGuiding = true
            self?.mapView.isAuthGranted = true
            self?.requestButton.backgroundColor = UIColor(hex: "#85FF0000")
            self?.requestButtonTitleLabel.text = "운행 종료"
        }
        
        view.addSubview(dialogView)
        dialogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func startOutdoor() {
        self.isGuiding = true
        self.mapView.isAuthGranted = true
        self.requestButton.backgroundColor = UIColor(hex: "#85FF0000")
        self.requestButtonTitleLabel.text = "운행 종료"
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }

    private func centerImage() {
        let scrollSize = scrollView.bounds.size
        let imageSize = mapImageView.frame.size

        let offsetX = max((scrollSize.width - imageSize.width) * 0.5, 0)
        let offsetY = max((scrollSize.height - imageSize.height) * 0.5, 0)

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
    
    func drawRedDotFromPixelCoord(pixelCoord: CGPoint) {
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

        drawRedDot(at: logicalCoord)
    }

    private func drawRedDot(at imagePoint: CGPoint) {
        guard let viewPoint = convertImagePointToViewPoint(imagePoint: imagePoint, in: mapImageView) else { return }

        let dotSize: CGFloat = 10
        let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        dotView.backgroundColor = .red
        dotView.layer.cornerRadius = dotSize / 2
        dotView.center = viewPoint

        mapImageView.addSubview(dotView)
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
    
    // Draw Marker
    func drawUserMarker(at pixelCoord: CGPoint) {
        userMarkerImageView?.removeFromSuperview()

        let markerImage = UIImage(named: "map_marker")
        let markerView = UIImageView(image: markerImage)
        markerView.frame.size = CGSize(width: 40, height: 40)
        markerView.contentMode = .scaleAspectFit
        markerView.center = pixelCoord

        mapImageView.addSubview(markerView)
        userMarkerImageView = markerView
    }
    
    func updateMapForUserLocation(pixelCoord: CGPoint) {
        drawUserMarker(at: pixelCoord)

        // 사용자 위치를 중앙에 오도록 offset 조정
        let zoomScale: CGFloat = 5.0
        scrollView.setZoomScale(zoomScale, animated: true)

        let scrollSize = scrollView.bounds.size
        let offsetX = max(0, pixelCoord.x * zoomScale - scrollSize.width / 2)
        let offsetY = max(0, pixelCoord.y * zoomScale - scrollSize.height / 2)

        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: true)
    }
}
