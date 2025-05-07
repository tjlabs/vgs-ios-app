
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class LoginViewController: UIViewController {
    
    let logoView = LogoView()
    let loginView = LoginView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(logoView)
        logoView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(120)
            make.height.equalTo(120)
        }
        
        view.addSubview(loginView)
        loginView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
            make.top.equalTo(logoView.snp.bottom).offset(20)
        }
    }
}

