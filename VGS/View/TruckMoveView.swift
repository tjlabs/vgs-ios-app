
import UIKit
import Lottie
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class TruckMoveView: UIView {
    var onReRouteRequested: (() -> Void)?
    var onStartOutdoorNavi: (() -> Void)?
    
    private let disposeBag = DisposeBag()
    
    private let animationView = LottieAnimationView(name: "truck_move")
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 22)
        label.backgroundColor = .clear
        label.textColor = .black
        label.textAlignment = .left
        label.text = "경로 재요청이 필요합니다.\n트럭을 클릭해주세요."
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let mapTransitionButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E47325")
        view.alpha = 0.8
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    private let mapTransitionTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "목적지에서 지도 전환"
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(animationView)
        animationView.contentMode = .scaleAspectFit
        animationView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        animationView.loopMode = .loop
        animationView.play()
        animationView.animationSpeed = 2.0
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.height.equalTo(200)
        }

        addSubview(guideLabel)
        guideLabel.numberOfLines = 0
        guideLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        
        mapTransitionButton.isHidden = true
        addSubview(mapTransitionButton)
        mapTransitionButton.snp.makeConstraints { make in
            make.top.equalTo(guideLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(220)
            make.height.equalTo(50)
        }

        mapTransitionButton.addSubview(mapTransitionTitleLabel)
        mapTransitionTitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    private func bindActions() {
        setupAnimationAction()
        setupMapTransitionAction()
    }
    
    private func setupAnimationAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAnimationTapped))
        animationView.isUserInteractionEnabled = true
        animationView.addGestureRecognizer(tapGesture)
    }
    
    private func setupMapTransitionAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleMapTransition))
        mapTransitionButton.isUserInteractionEnabled = true
        mapTransitionButton.addGestureRecognizer(tapGesture)
    }
    
    
    @objc private func handleAnimationTapped() {
        animationView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.animationView.transform = CGAffineTransform(scaleX: 2.3, y: 2.3)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.animationView.isUserInteractionEnabled = true
                self.animationView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
            }
        })
        
        onReRouteRequested?()
    }
    
    
    public func showMapTransitionOption() {
        guideLabel.text = "경로 요청이 지속적으로 실패하면,\n목적지의 항공 사진 안내만 받으세요"
        mapTransitionButton.isHidden = false
    }
    
    @objc private func handleMapTransition() {
        self.mapTransitionButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.mapTransitionButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.mapTransitionButton.transform = .identity
                self.mapTransitionButton.isUserInteractionEnabled = true
            }
        })
        onStartOutdoorNavi?()
    }
}

