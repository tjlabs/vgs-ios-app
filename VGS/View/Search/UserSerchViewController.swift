
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
            make.bottom.equalToSuperview().inset(20)
            make.top.equalTo(logoView.snp.bottom)
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
//                self.showToastWithIcon(message: "차량 조회에 실패 했습니다")
                self.showToastWithIcon(message: "검색 결과가 없습니다.\n차량 번호를 다시 한번 확인해주세요.")
            }
        }
    }
    
    private func moveToInfoVC(vehicleInfo: VehicleInfo) {
        guard let infoVC = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else { return }
        VehicleInfoManager.shared.setVehicleInfo(info: vehicleInfo)
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
}

