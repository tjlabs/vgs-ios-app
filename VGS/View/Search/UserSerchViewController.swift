
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class UserSearchViewController: UIViewController {
    
    let topView = TopView()
    let logoView = LogoView()
    let userSearchView = UserSerchView()
    
    private let privacyPolicyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 16)
        label.textColor = UIColor(hex: "#FF03A9F4")
        label.textAlignment = .center
        label.text = "개인정보처리방침"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindActions()
        topView.setArrowBackOption(isHidden: true, title: "다시 검색하기")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayout() {
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().inset(50)
//            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        view.addSubview(logoView)
        logoView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.height.equalTo(120)
        }
        
        view.addSubview(userSearchView)
        userSearchView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
            make.top.equalTo(logoView.snp.bottom)
        }
        
        view.addSubview(privacyPolicyLabel)
        privacyPolicyLabel.snp.makeConstraints{ make in
            make.width.equalTo(150)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func bindActions() {
        topView.onBackArrowTapped = { [weak self] in
            UIView.animate(withDuration: 1.0, animations: {
                self?.userSearchView.removeSelectViewIfNeeded()
                self?.topView.setArrowBackOption(isHidden: true, title: "다시 검색하기")
            })
        }
        
        userSearchView.onSearchSuccessed = { [weak self] in
            UIView.animate(withDuration: 1.0, animations: {
                self?.topView.setArrowBackOption(isHidden: false, title: "다시 검색하기")
            })
        }
        
        userSearchView.onCellSelected = { [self] selectedVehicle in
            moveToInfoVC(vehicleInfo: selectedVehicle)
        }
        
        userSearchView.onSearchFail = {
            DispatchQueue.main.async {
                self.showToastWithIcon(message: "검색 결과가 없습니다.\n차량 번호를 다시 한번 확인해주세요.")
            }
        }
        
        userSearchView.onPublicLogin = {
            self.movePublicToMainVC()
        }
        
        setupPrivacyPolicyAction()
    }
    
    private func setupPrivacyPolicyAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedPrivacyPolicy))
        privacyPolicyLabel.isUserInteractionEnabled = true
        privacyPolicyLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func tappedPrivacyPolicy() {
        showPPVC()
    }
    
    func showPPVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    private func moveToInfoVC(vehicleInfo: VehicleInfo) {
        guard let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else { return }
        VehicleInfoManager.shared.setVehicleInfo(info: vehicleInfo)
        VehicleInfoManager.shared.isPublicUser = false
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    private func movePublicToMainVC() {
        VehicleInfoManager.shared.isPublicUser = true
        guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else { return }
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
}

