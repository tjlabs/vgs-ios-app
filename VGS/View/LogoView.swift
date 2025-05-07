
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class LogoView: UIView {
    private let disposeBag = DisposeBag()
    
    private var logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    init() {
        super.init(frame: .zero)
        logoImageView.image = UIImage(named: "img_sk")!
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints{ make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}

