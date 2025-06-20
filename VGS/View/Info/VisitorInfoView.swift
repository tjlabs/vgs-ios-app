
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class VisitorInfoView: UIView {
    private let disposeBag = DisposeBag()
    
    private var titleLabel: UILabel = {
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
    
    private let gateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor(hex: "#A2A1A1").cgColor
        stackView.layer.borderWidth = 1.0
        return stackView
    }()
    
    private let gateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "목적지 게이트"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let gateDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "M15X"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "방문현장"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let placeDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "CUB"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "공종담당자(S)"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let factoryManagerDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "관리자"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "현장담당자(P)"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let placeManagerDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "190"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "출입 기간"
        label.backgroundColor = UIColor(hex: "#F1F1F1")
        return label
    }()
    
    private let durationDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 28)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "2025-02-25 ~ 2025-03-25"
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
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
        
        containerStackView.addArrangedSubview(gateStackView)
        gateStackView.addArrangedSubview(gateTitleLabel)
        gateStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        gateTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(180)
        }
        gateStackView.addArrangedSubview(gateDataLabel)
        
        containerStackView.addArrangedSubview(placeStackView)
        placeStackView.addArrangedSubview(placeTitleLabel)
        placeStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        placeTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(180)
        }
        placeStackView.addArrangedSubview(placeDataLabel)
        
        containerStackView.addArrangedSubview(factoryManagerStackView)
        factoryManagerStackView.addArrangedSubview(factoryManagerTitleLabel)
        factoryManagerStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        factoryManagerTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(180)
        }
        factoryManagerStackView.addArrangedSubview(factoryManagerDataLabel)
        
        containerStackView.addArrangedSubview(placeManagerStackView)
        placeManagerStackView.addArrangedSubview(placeManagerTitleLabel)
        placeManagerStackView.snp.makeConstraints { make in
            make.height.equalTo(55)
        }
        placeManagerTitleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.width.equalTo(180)
        }
        placeManagerStackView.addArrangedSubview(placeManagerDataLabel)
        
        containerStackView.addArrangedSubview(durationStackView)
        durationStackView.addArrangedSubview(durationTitleLabel)
        durationTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        durationStackView.addArrangedSubview(durationDateLabel)
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
            if VehicleInfoManager.shared.isPublicUser {
                titleLabel.text = "목적지 정보"
                gateDataLabel.text = info.target_gate_name
                placeDataLabel.text = info.destination_spot_name
                factoryManagerDataLabel.text = info.const_charger_name
                placeManagerDataLabel.text = info.mat_charger_name
                let start_end = getStartAndEndOfTodayUTC()
                updateAccessDateLabel(startDateString: start_end.start, endDateString: start_end.end, label: durationDateLabel)
            } else {
                gateDataLabel.text = info.target_gate_name
                placeDataLabel.text = info.destination_spot_name
                factoryManagerDataLabel.text = info.const_charger_name
                placeManagerDataLabel.text = info.mat_charger_name
                updateAccessDateLabel(startDateString: info.access_start_date, endDateString: info.access_end_date, label: durationDateLabel)
            }
        }
    }
    
    func getStartAndEndOfTodayUTC() -> (start: String, end: String) {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        
        // 오늘 자정 (00시)
        let startOfDay = calendar.startOfDay(for: now)
        
        // 오늘 24시 = 다음 날 00시
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return ("", "")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let startString = formatter.string(from: startOfDay)
        let endString = formatter.string(from: endOfDay)

        return (startString, endString)
    }
    
    func updateAccessDateLabel(startDateString: String, endDateString: String, label: UILabel) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime] // "Z" 포함된 포맷 지원

        guard let startDateUTC = formatter.date(from: startDateString),
              let endDateUTC = formatter.date(from: endDateString) else {
            label.text = "날짜 형식 오류"
            return
        }

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST
        outputFormatter.dateFormat = "yyyy-MM-dd"

        let startDateKST = outputFormatter.string(from: startDateUTC)
        let endDateKST = outputFormatter.string(from: endDateUTC)

        label.text = "\(startDateKST) ~ \(endDateKST)"
    }
}
