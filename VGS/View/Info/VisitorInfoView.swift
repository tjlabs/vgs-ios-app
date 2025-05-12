
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class VisitorInfoView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 30)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "방문 정보"
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
        stackView.distribution = .fillProportionally
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let factoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let factoryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "공사현장 명"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let factoryDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "M15X"
        return label
    }()
    
    private let placeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let placeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "방문현장"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let placeDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "CUB"
        return label
    }()
    
    private let factoryManagerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let factoryManagerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "공종담당자(S)"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let factoryManagerDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "관리자"
        return label
    }()
    
    private let placeManagerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let placeManagerTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "현장담당자(P)"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let placeManagerDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "190"
        return label
    }()
    
    private let durationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let durationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "출입 기간"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let durationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "2025-02-25 ~ 2025-03-25"
        return label
    }()
    
    private let durationInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "일일체류시간 8시간"
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
        
        containerStackView.addArrangedSubview(factoryStackView)
        factoryStackView.addArrangedSubview(factoryTitleLabel)
        factoryStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        factoryTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(140)
        }
        factoryStackView.addArrangedSubview(factoryDataLabel)
        
        containerStackView.addArrangedSubview(placeStackView)
        placeStackView.addArrangedSubview(placeTitleLabel)
        placeStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        placeTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(140)
        }
        placeStackView.addArrangedSubview(placeDataLabel)
        
        containerStackView.addArrangedSubview(factoryManagerStackView)
        factoryManagerStackView.addArrangedSubview(factoryManagerTitleLabel)
        factoryManagerStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        factoryManagerTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(140)
        }
        factoryManagerStackView.addArrangedSubview(factoryManagerDataLabel)
        
        containerStackView.addArrangedSubview(placeManagerStackView)
        placeManagerStackView.addArrangedSubview(placeManagerTitleLabel)
        placeManagerStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        placeManagerTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(140)
        }
        placeManagerStackView.addArrangedSubview(placeManagerDataLabel)
        
        containerStackView.addArrangedSubview(durationStackView)
        durationStackView.addArrangedSubview(durationTitleLabel)
        durationTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        durationStackView.addArrangedSubview(durationDateLabel)
        durationStackView.addArrangedSubview(durationInfoLabel)
    }
    
    private func bindActions() {
        
    }
}
