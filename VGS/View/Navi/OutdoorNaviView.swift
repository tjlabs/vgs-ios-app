import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

enum ButtonState {
    case NONE, REQUEST, WAIT, FINISH, EXIT
}

class OutdoorNaviView: UIView, UIScrollViewDelegate {

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
        $0.image = UIImage(named: "temp_map")
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.isHidden = true
        $0.isUserInteractionEnabled = true
    }

    private var userMarkerImageView: UIImageView?

    private let driverStateButton = UIView().then {
        $0.backgroundColor = UIColor(hex: "#E47325")
        $0.alpha = 1.0
        $0.cornerRadius = 15
        $0.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
    }

    private var driverStateButtonTitleLabel = UILabel().then {
        $0.backgroundColor = .clear
        $0.font = UIFont.notoSansBold(size: 42)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.text = "진입 요청"
    }

    let mapView = TJLabsNaviView()

    let mapper = PerspectiveMapper()
    private let userCoordTag = 999
    private let USER_CENTER_OFFSET: CGFloat = 40
    private var imageMapMarker: UIImage?

    private var isGuiding: Bool = false
    private var curButtonState: ButtonState = .NONE
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        isHidden = true
        
        setupLayout()
        bindActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIsHidden(isHidden: Bool) {
        self.isHidden = isHidden
        if !isHidden {
            setupNaviView()
            startOutdoor()
        }
    }

    private func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(110)
        }

        addSubview(driverStateButton)
        driverStateButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(70)
            make.bottom.equalToSuperview().inset(30)
        }

        driverStateButton.addSubview(driverStateButtonTitleLabel)
        driverStateButtonTitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }

    func setupNaviView() {
        mapView.configureFrame(to: mainView)
        mainView.addSubview(mapView)
    }

    private func bindActions() {
        setupDriverStateButtonAction()
    }

    private func setupDriverStateButtonAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDriverStateButton))
        driverStateButton.isUserInteractionEnabled = true
        driverStateButton.addGestureRecognizer(tapGesture)
    }

    @objc private func handleDriverStateButton() {
        UIView.animate(withDuration: 0.1, animations: {
            self.driverStateButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.driverStateButton.transform = .identity
            }, completion: { _ in
                self.changeButtonState(curState: self.curButtonState)
            })
        })
    }


    private func showDialogView() {
        let dialogView = DialogView(contentViewHeight: 260)
        dialogView.setDialogString(title: "운행 시작", message: "요청이 승인되었습니다. 현장으로 진입해주세요.\n작업 종료 후 종료 버튼을 눌러주세요.")
        dialogView.onConfirm = { [weak self] in
            self?.isGuiding = true
            self?.mapView.isAuthGranted = true
            self?.changeButtonState(curState: self!.curButtonState)
        }

        self.addSubview(dialogView)
        dialogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func startOutdoor() {
        self.isGuiding = true
        self.mapView.isAuthGranted = true
        changeButtonState(curState: self.curButtonState)
    }
    
    private func changeButtonState(curState: ButtonState) {
        print("changeButtonState : curState = \(curState)")
        if curState == .NONE {
            // NONE -> REQUEST
            self.curButtonState = .REQUEST
            self.driverStateButton.backgroundColor = UIColor(hex: "#E47325")
            self.driverStateButtonTitleLabel.text = "진입 요청"
        } else if curState == .REQUEST {
            // REQUEST -> WAIT
            self.curButtonState = .WAIT
            requestAuth()
        } else if curState == .WAIT {
            // WAIT -> FINISH
            self.curButtonState = .FINISH
            self.driverStateButton.backgroundColor = UIColor(hex: "#00B050")
            self.driverStateButtonTitleLabel.text = "작업 종료"
        } else if curState == .FINISH {
            // FINISH -> EXIT
            self.curButtonState = .EXIT
            self.driverStateButton.backgroundColor = UIColor(hex: "#C00000")
            self.driverStateButtonTitleLabel.text = "운행 종료"
        } else {
            self.curButtonState = .NONE
            self.driverStateButton.backgroundColor = UIColor(hex: "#C00000")
            self.driverStateButtonTitleLabel.text = "NONE"
            self.removeFromSuperview()
        }
        print("changeButtonState : change to = \(self.curButtonState)")
    }
    
    private func requestAuth() {
        self.driverStateButton.backgroundColor = UIColor(hex: "#424242")
        self.driverStateButtonTitleLabel.text = "대기중"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.showDialogView()
        }
    }
}
