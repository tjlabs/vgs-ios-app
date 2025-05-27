
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class SelectView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var onCellItemTapped: ((VehicleInfo) -> Void)?
    
    private let disposeBag = DisposeBag()
    
    var vehicleInfoList = [VehicleInfo]()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 30)
        label.backgroundColor = .white
        label.textColor = .black
        label.textAlignment = .center
        label.text = "내 차량을 선택해주세요"
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.isPrefetchingEnabled = false
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SelectCollectionViewCell.self, forCellWithReuseIdentifier: SelectCollectionViewCell.reuseIdentifier)
        
        return collectionView
    }()
    
    init(vehicleInfoList: [VehicleInfo]) {
        super.init(frame: .zero)
        self.vehicleInfoList = vehicleInfoList
        
        setupLayout()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(0)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    private func bindActions() {
        
    }
    
    private func mapToSelectCellItems(vehicleInfoList: [VehicleInfo]) -> [SelectCellItem] {
        var items = [SelectCellItem]()
        
        for info in vehicleInfoList {
            let item = SelectCellItem(vehicleNumber: info.vehicle_reg_no, company: info.company_name, vehicleType: info.vehicle_type_name)
            items.append(item)
        }
        
        return items
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vehicleInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectCollectionViewCell.reuseIdentifier, for: indexPath) as! SelectCollectionViewCell
        let item = vehicleInfoList[indexPath.row]
        cell.configure(data: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = vehicleInfoList[indexPath.row]
        onCellItemTapped?(item)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let height: CGFloat = 160
        
        return CGSize(width: width, height: height)
    }
}
