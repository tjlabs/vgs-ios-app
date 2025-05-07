
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class SelectCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectCollectionViewCell"
    
    private let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#322E2E")
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupLayout() {
        addSubview(cellView)
        cellView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func configure(data: SelectCellItem) {
    }
}
