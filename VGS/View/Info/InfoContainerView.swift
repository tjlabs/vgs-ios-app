
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class InfoContainerView: UIView {
    private let disposeBag = DisposeBag()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let visitorInfoView = VisitorInfoView()
    let vehicleInfoView = VehicleInfoView()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        setupLayout()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // 1. Add scrollView to view
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(70)
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
            make.height.equalTo(410)
        }
        
        contentView.addSubview(vehicleInfoView)
        vehicleInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(visitorInfoView.snp.bottom).offset(10)
            make.height.equalTo(205)
        }
    }
    
    private func bindActions() {
        
    }
}
