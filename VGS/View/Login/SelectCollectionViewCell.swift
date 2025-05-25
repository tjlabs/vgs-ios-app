
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
    
    private let cellItemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var vehicleNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 34)
        label.textColor = UIColor(hex: "#E47325")
        label.textAlignment = .left
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var vehicleInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 34)
        label.textColor = UIColor(hex: "#E47325")
        label.textAlignment = .left
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        return label
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
        
        cellView.addSubview(cellItemStackView)
        cellItemStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(15)
            make.leading.trailing.equalToSuperview().inset(25)
        }
        
        cellItemStackView.addArrangedSubview(vehicleNumberLabel)
        cellItemStackView.addArrangedSubview(vehicleInfoLabel)
    }
    
    func configure(data: VehicleInfo) {
        vehicleNumberLabel.text = data.vehicle_reg_no
        vehicleInfoLabel.text = data.company_name + " / " + data.vehicle_type_name
    }
}
