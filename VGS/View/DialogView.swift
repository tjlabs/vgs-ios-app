
import UIKit
import SnapKit

class DialogView: UIView {
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?
 
    private lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//        view.isUserInteractionEnabled = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
//        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "목적지 도착"
        label.font = UIFont.notoSansBold(size: 24)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "경로 안내를 종료하시겠습니까?"
        label.font = UIFont.notoSansBold(size: 20)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.notoSansBold(size: 16)
        button.backgroundColor = UIColor(hex: "#E47325")
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("아니오", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.notoSansBold(size: 16)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(dismissDialog), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(darkView)
        darkView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(30)
            make.height.equalTo(180)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
//        contentView.addSubview(confirmButton)
//        confirmButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().offset(-20)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//            make.height.equalTo(40)
//        }
        
        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(contentView.snp.centerX).offset(-10)
            make.height.equalTo(40)
        }

        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalTo(contentView.snp.centerX).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
    }

    @objc private func dismissDialog() {
        onCancel?()
        removeFromSuperview()
    }
    
    @objc private func confirmTapped() {
        onConfirm?()
        removeFromSuperview()
    }
}
