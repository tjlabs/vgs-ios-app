
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class InfoViewController: UIViewController {

    let topView = TopView()
//    let logoView = LogoView()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let visitorInfoView = VisitorInfoView()
    let vehicleInfoView = VehicleInfoView()
//    let importedMaterialView = ImportedMaterialView()
    
    var isChecked = false
    
    // Start
    private let confirmContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var checkBoxImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_uncheckedBox")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let checkBoxTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 24)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "위 사항을 빠짐없이 확인했습니다."
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        return label
    }()
    
    private let startButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E47325")
        view.alpha = 0.8
        view.isUserInteractionEnabled = true
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    private let startButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.notoSansBold(size: 48)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "출발"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindActions()
        topView.setArrowBackOption(isHidden: false, title: "차량 선택하기")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayout() {
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        // 1. Add scrollView to view
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }

        // 2. Add contentView to scrollView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // 3. Add visitorInfoView to contentView
        contentView.addSubview(visitorInfoView)
        visitorInfoView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(375)
        }
        
        contentView.addSubview(vehicleInfoView)
        vehicleInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(visitorInfoView.snp.bottom).offset(10)
            make.height.equalTo(165)
        }
        
        // // MARK: - Confirm
        contentView.addSubview(confirmContainerView)
        confirmContainerView.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.top.equalTo(vehicleInfoView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        confirmContainerView.addSubview(checkBoxImageView)
        checkBoxImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        confirmContainerView.addSubview(checkBoxTitleLabel)
        checkBoxTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxImageView.snp.trailing).offset(4)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        // // MARK: - Start
        contentView.addSubview(startButton)
        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(90)
            make.top.equalTo(confirmContainerView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(20)
        }
        
        startButton.addSubview(startButtonTitleLabel)
        startButtonTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func bindActions() {
        topView.onBackArrowTapped = { [self] in
            goToBack()
        }
        setupConfirmAction()
        setupStartAction()
    }
    
    private func setupConfirmAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCheckboxToggle))
        confirmContainerView.isUserInteractionEnabled = true
        confirmContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleCheckboxToggle() {
        isChecked.toggle()
        let imageName = isChecked ? "ic_checkedBox" : "ic_uncheckedBox"
        checkBoxImageView.image = UIImage(named: imageName)
        
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.checkBoxImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkBoxImageView.transform = .identity
            }
        })
    }
    
    private func setupStartAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleStartButton))
        startButton.isUserInteractionEnabled = true
        startButton.addGestureRecognizer(tapGesture)
    }
    
    private func checkValidVisitDuration(info: VehicleInfo) -> Bool {
        let startDateString = info.access_start_date
        let endDateString = info.access_end_date
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime] // "Z" 포함된 포맷 지원
        
        guard let startDateUTC = formatter.date(from: startDateString),
              let endDateUTC = formatter.date(from: endDateString) else {
            return false
        }
        
        let now = Date()
        return (startDateUTC...endDateUTC).contains(now)
    }
    
    @objc func handleStartButton() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.startButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.startButton.transform = .identity
            }
        })
        
        if isChecked {
            if let vehicleInfo = VehicleInfoManager.shared.getVehicleInfo() {
                startButton.isUserInteractionEnabled = false
                let isValid = checkValidVisitDuration(info: vehicleInfo)
                print("(InfoVC) checkValidVisitDuration : isValid = \(isValid)")
                if isValid {
                    moveToMainVC(vehicleInfo: vehicleInfo)
                } else {
                    startButton.isUserInteractionEnabled = true
                }
            }
        } else {
            self.showToastWithIcon(message: "정보 확인에 대해 체크해주세요")
            startButton.isUserInteractionEnabled = true
        }
    }
    
    func goToBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func moveToMainVC(vehicleInfo: VehicleInfo) {
        guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return }
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
}
