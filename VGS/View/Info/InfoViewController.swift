
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class InfoViewController: UIViewController {

    let topView = TopView()
    let logoView = LogoView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        bindActions()
        topView.setArrowBackHidden(isHidden: false)
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
        
        view.addSubview(logoView)
        logoView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(topView.snp.bottom).offset(20)
            make.height.equalTo(120)
        }
        
    }
    
    private func bindActions() {
        topView.onBackArrowTapped = { [self] in
            goToBack()
        }
    }
    
    func goToBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
