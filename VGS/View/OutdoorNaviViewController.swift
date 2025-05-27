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

    private let scrollView = UIScrollView().then {
        $0.bouncesZoom = true
        $0.minimumZoomScale = 1.0
        $0.maximumZoomScale = 10.0
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }

    private let mapImageView = UIImageView().then {
        $0.image = UIImage(named: "img_map_skep")
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }

    private let requestButton = UIView().then {
        $0.backgroundColor = UIColor(hex: "#E47325")
        $0.alpha = 0.8
        $0.cornerRadius = 15
        $0.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
    }

    private let requestButtonTitleLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = UIFont.notoSansBold(size: 48)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.text = "진입 요청"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindActions()
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

        containerView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(120)
        }

        scrollView.addSubview(mapImageView)
        if let imageSize = mapImageView.image?.size {
            mapImageView.frame = CGRect(origin: .zero, size: imageSize)
            scrollView.contentSize = imageSize
        }

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

    private func bindActions() {
        setupRequestButtonAction()
        scrollView.delegate = self
    }

    private func setupRequestButtonAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRequestButton))
        requestButton.isUserInteractionEnabled = true
        requestButton.addGestureRecognizer(tapGesture)
    }

    @objc func handleRequestButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.requestButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.requestButton.transform = .identity
            }
        })
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

    // testDot 관련 함수는 동일하게 사용 가능합니다
    // 필요한 경우 drawRedDotFromPixelCoord/convertImagePointToViewPoint 로직을 재조정 하세요
}
