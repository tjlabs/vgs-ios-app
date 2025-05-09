
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class LoginViewController: UIViewController {
    
    let topView = TopView()
    let logoView = LogoView()
    let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindActions()
        topView.setArrowBackHidden(isHidden: true)
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
        
        view.addSubview(loginView)
        loginView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
            make.top.equalTo(logoView.snp.bottom)
        }
    }
    
    private func bindActions() {
        topView.onBackArrowTapped = { [weak self] in
            self?.loginView.removeSelectViewIfNeeded()
            self?.topView.setArrowBackHidden(isHidden: true)
        }
        
        loginView.onLoginSuccessed = { [weak self] in
            self?.topView.setArrowBackHidden(isHidden: false)
        }
        
        loginView.onCellSelected = { [self] selectedVehicle in
            moveToInfoVC(vehicleInfo: selectedVehicle)
        }
    }
    
    private func moveToInfoVC(vehicleInfo: VehicleInfo) {
        guard let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else { return }
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}

