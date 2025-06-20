
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class VehicleInfoView: UIView {
    private let disposeBag = DisposeBag()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 30)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "차량/운전자 정보"
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
    
    private let vehicleNumberStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let vehicleNumberTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "차량 번호"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let vehicleNumberDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "1111"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private let vehicleTypeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let vehicleTypeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "차종"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let vehicleTypeDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "덤프트럭"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
//    private let vehicleCompanyStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.distribution = .fillProportionally
//        stackView.spacing = 10
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
//        stackView.layer.borderWidth = 1.0
//        return stackView
//    }()
//    
//    private let vehicleCompanyTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.notoSansBold(size: 20)
//        label.textColor = .black
//        label.textAlignment = .center
//        label.text = "업체"
//        label.backgroundColor = UIColor(hex: "#F1F1F1")
//        return label
//    }()
//    
//    private let vehicleCompanyDataLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.notoSansBold(size: 20)
//        label.textColor = .black
//        label.textAlignment = .left
//        label.text = "티제이랩스"
//        return label
//    }()
    
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
        
        containerStackView.addArrangedSubview(vehicleNumberStackView)
        vehicleNumberStackView.addArrangedSubview(vehicleNumberTitleLabel)
        vehicleNumberTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(150)
        }
        vehicleNumberStackView.addArrangedSubview(vehicleNumberDataLabel)
        
        containerStackView.addArrangedSubview(vehicleTypeStackView)
        vehicleTypeStackView.addArrangedSubview(vehicleTypeTitleLabel)
        vehicleTypeTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(150)
        }
        vehicleTypeStackView.addArrangedSubview(vehicleTypeDataLabel)
        
//        containerStackView.addArrangedSubview(vehicleCompanyStackView)
//        vehicleCompanyStackView.addArrangedSubview(vehicleCompanyTitleLabel)
//        vehicleCompanyTitleLabel.snp.makeConstraints { make in
//            make.top.bottom.leading.equalToSuperview()
//            make.width.equalTo(100)
//        }
//        vehicleCompanyStackView.addArrangedSubview(vehicleCompanyDataLabel)
    }
    
    private func bindActions() {
        VehicleInfoManager.shared.vehicleInfoRelay
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] info in
                self?.updateVehicleInfo(info: info)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateVehicleInfo(info: VehicleInfo) {
        DispatchQueue.main.async { [self] in
            // Update UI
            vehicleNumberDataLabel.text = info.vehicle_reg_no
            vehicleTypeDataLabel.text = info.vehicle_type_name
        }
    }
}
