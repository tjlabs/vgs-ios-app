
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

protocol BottomNavigationViewDelegate: AnyObject {
    func didTapNavigationItem(_ id: Int, from previousId: Int)
}

struct NavigationItem {
    let id: Int
    let title: String
    let imageName: String
}

class BottomNavigationView: UIView {
    weak var delegate: BottomNavigationViewDelegate?
    
    var navigationItems = [NavigationItem]()
    var navigationItemViews = [UIView]()
    var currentViewId: Int = -1
    
    private let bottomNavigationTopLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#EFEFF0")
        return view
    }()
    
    private let bottomNavigationItemStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeNavigationBarItems()
        setupLayout()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .white
        
        addSubview(bottomNavigationTopLine)
        bottomNavigationTopLine.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(2)
            make.leading.trailing.equalToSuperview()
        }
        
        addSubview(bottomNavigationItemStackView)
        bottomNavigationItemStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        for view in self.navigationItemViews {
            bottomNavigationItemStackView.addArrangedSubview(view)
        }
    }
    
    private func makeNavigationBarItems() {
        navigationItems.append(NavigationItem(id: 0, title: "길안내", imageName: "ic_bottom_navigation"))
        
        let navItemTitle: String = VehicleInfoManager.shared.isPublicUser ? "일반 사용자" : "출입 정보"
        navigationItems.append(NavigationItem(id: 1, title: navItemTitle, imageName: "ic_bottom_user"))
        
        for item in navigationItems {
            navigationItemViews.append(NavigationBarItem(title: item.title, imageName: item.imageName))
        }
        
        // Set Initial View
        self.currentViewId = 0
        updateNavigationBarItems(with: self.currentViewId)
    }
    
    private func updateNavigationBarItems(with id: Int) {
        for (index, itemView) in navigationItemViews.enumerated() {
            guard let navigationBarItem = itemView as? NavigationBarItem else { continue }
            let currentImageName = navigationItems[index].imageName
            if navigationItems[index].id == id {
                let updatedImageName = currentImageName + "_fill"
                navigationBarItem.updateImage(named: updatedImageName)
                navigationBarItem.updateLabelColor(color: UIColor(hex: "#E47325"))
            } else {
                if currentImageName.contains("_fill") {
                    let updatedImageName = currentImageName.replacingOccurrences(of: "_fill", with: "")
                    navigationBarItem.updateImage(named: updatedImageName)
                    navigationBarItem.updateLabelColor(color: UIColor(hex: "#E47325"))
                } else {
                    navigationBarItem.updateImage(named: currentImageName)
                    navigationBarItem.updateLabelColor(color: UIColor(hex: "#A2A1A1"))
                }
            }
        }
        bottomNavigationItemStackView.layoutIfNeeded()
    }
    
    private func bindActions() {
        for (index, itemView) in navigationItemViews.enumerated() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigationBarItemTapped(_:)))
            itemView.tag = index
            itemView.addGestureRecognizer(tapGesture)
            itemView.isUserInteractionEnabled = true
        }
    }
    
    @objc private func navigationBarItemTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view as? NavigationBarItem else { return }
        handleNavigationAction(for: navigationItems[tappedView.tag].id)
    }
    
    private func handleNavigationAction(for id: Int) {
        delegate?.didTapNavigationItem(id, from: currentViewId)
        
        if self.currentViewId != id {
            switch id {
            case 0:
                if currentViewId == 1 {
                    // 출입 정보 -> 길안내
                }
                updateNavigationBarItems(with: id)
            case 1:
                if currentViewId == 0 {
                    // 길안내 -> 출입정보
                }
                updateNavigationBarItems(with: id)
            default:
                print("Unknown navigation item tapped")
            }
            self.currentViewId = id
        }
    }
}
