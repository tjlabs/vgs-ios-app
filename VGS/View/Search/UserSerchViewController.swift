
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
    let scrollView = UIScrollView()
    let contentView = UIView()
    
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        view.addSubview(privacyPolicyLabel)
        privacyPolicyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(5)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
//            make.leading.trailing.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(privacyPolicyLabel.snp.top)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        // logoView
        contentView.addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }

        // userSearchView
        contentView.addSubview(userSearchView)
        userSearchView.snp.makeConstraints { make in
            make.top.equalTo(logoView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(5)
        }

//        // privacyPolicyLabel
//        contentView.addSubview(privacyPolicyLabel)
//        privacyPolicyLabel.snp.makeConstraints { make in
//            make.top.equalTo(userSearchView.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(150)
//            make.height.equalTo(50)
//            make.bottom.equalToSuperview().inset(40) // ⬅️ ✅ 콘텐츠 끝 위치 명시!
//        }
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

