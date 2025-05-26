
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class LogoutView: UIView {
    private let disposeBag = DisposeBag()
    
    var onLogoutTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var logoutImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_logout")!
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.isUserInteractionEnabled = true
    }
    
    private let logoutTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 24)
        label.textColor = UIColor(hex: "#E47325")
        label.textAlignment = .left
        label.text = "초기 등록 화면으로"
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
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        containerView.addSubview(logoutImageView)
        logoutImageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(15)
        }
        
        containerView.addSubview(logoutTitleLabel)
        logoutTitleLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.centerY.equalToSuperview()
            make.leading.equalTo(logoutImageView.snp.trailing).offset(5)
        }
    }
    
    private func bindActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func logoutTapped() {
        onLogoutTapped?()
    }
}

