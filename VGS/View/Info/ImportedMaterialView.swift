
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class ImportedMaterialView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 30)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "반입 자재"
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        view.layer.borderWidth = 2.0
        return view
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let nameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let nameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "자재명"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let nameDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "고기"
        return label
    }()
    
    private let unitStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let unitTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "단위"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let unitDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "kg"
        return label
    }()
    
    private let countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let countTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "수량"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let countDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "0"
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
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(5)
            make.height.equalTo(40)
        }
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        containerView.addSubview(containerStackView)
        containerStackView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        containerStackView.addArrangedSubview(nameStackView)
        nameStackView.addArrangedSubview(nameTitleLabel)
        nameTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(100)
        }
        nameStackView.addArrangedSubview(nameDataLabel)
        
        containerStackView.addArrangedSubview(unitStackView)
        unitStackView.addArrangedSubview(unitTitleLabel)
        unitTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(100)
        }
        unitStackView.addArrangedSubview(unitDataLabel)
        
        containerStackView.addArrangedSubview(countStackView)
        countStackView.addArrangedSubview(countTitleLabel)
        countTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(100)
        }
        countStackView.addArrangedSubview(countDataLabel)
    }
    
    private func bindActions() {
        
    }
}
