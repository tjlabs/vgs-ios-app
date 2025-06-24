
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class InfoContainerView: UIView {
    private let disposeBag = DisposeBag()
    
    var onLogoutTapped: (() -> Void)?
    
    let logoutView = LogoutView()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let visitorInfoView = VisitorInfoView()
    let vehicleInfoView = VehicleInfoView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupLayout()
        bindActions()
        checkPublicUser()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(logoutView)
        logoutView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        
        // 1. Add scrollView to view
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(logoutView.snp.bottom).offset(20)
//            make.top.equalToSuperview().inset(70)
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
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func bindActions() {
        logoutView.onLogoutTapped = {
            self.onLogoutTapped?()
        }
    }
    
    private func checkPublicUser() {
        if VehicleInfoManager.shared.isPublicUser {
            self.vehicleInfoView.isHidden = true
        }
    }
}
