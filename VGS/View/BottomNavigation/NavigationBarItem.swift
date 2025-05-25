
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class NavigationBarItem: UIView {
    private var itemImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Unknown"
        label.textAlignment = .center
        label.textColor = UIColor(hex: "#A2A1A1")
        label.font = UIFont.notoSansBold(size: 12)
        return label
    }()
    
    init(title: String, imageName: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        itemImageView.image = UIImage(named: imageName)!
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        snp.makeConstraints{ make in
            make.height.equalTo(75)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints{ make in
            make.height.equalTo(22)
            make.leading.trailing.equalToSuperview()
        }
        
        addSubview(itemImageView)
        itemImageView.snp.makeConstraints{ make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalTo(titleLabel.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    func updateImage(named imageName: String) {
        itemImageView.image = UIImage(named: imageName)
    }
    
    func updateLabelColor(color: UIColor) {
        titleLabel.textColor = color
    }
}
