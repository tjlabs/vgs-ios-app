
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

protocol BottomNavigationViewDelegate: AnyObject {
    func didTapNavigationItem(_ title: String, from previousTitle: String)
}

struct NavigationItem {
    let title: String
    let imageName: String
}

class BottomNavigationView: UIView {
    weak var delegate: BottomNavigationViewDelegate?
    
    var navigationItems = [NavigationItem]()
    var navigationItemViews = [UIView]()
    var currentViewName: String = ""
    
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
        navigationItems.append(NavigationItem(title: "길안내", imageName: "ic_bottom_navigation"))
        navigationItems.append(NavigationItem(title: "출입 정보", imageName: "ic_bottom_user"))
        
        for item in navigationItems {
            navigationItemViews.append(NavigationBarItem(title: item.title, imageName: item.imageName))
        }
        
        // Set Initial View
        self.currentViewName = "길안내"
        updateNavigationBarItems(with: self.currentViewName)
    }
    
    private func updateNavigationBarItems(with title: String) {
        for (index, itemView) in navigationItemViews.enumerated() {
            guard let navigationBarItem = itemView as? NavigationBarItem else { continue }
            let currentImageName = navigationItems[index].imageName
            if navigationItems[index].title == title {
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
        handleNavigationAction(for: navigationItems[tappedView.tag].title)
    }
    
    private func handleNavigationAction(for title: String) {
        delegate?.didTapNavigationItem(title, from: currentViewName)
        
        if self.currentViewName != title {
            switch title {
            case "길안내":
                if currentViewName == "출입 정보" {
                    // 출입 정보 -> 길안내
                }
                updateNavigationBarItems(with: title)
                print("(BottomNavigationView) : 출입 정보 tapped")
            case "출입 정보":
                if currentViewName == "길안내" {
                    // 길안내 -> 출입정보
                }
                updateNavigationBarItems(with: title)
                print("(BottomNavigationView) : 길안내 tapped")
            default:
                print("Unknown navigation item tapped")
            }
            self.currentViewName = title
        }
    }
}
