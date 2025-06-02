
import UIKit

class TJLabsMyLocationButton: UIButton {
    
    private var imageMyLocation: UIImage?
    
    init() {
        super.init(frame: .zero)
        self.setupAssets()
        
        self.setImage(self.imageMyLocation, for: .normal)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 4
        self.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAssets() {
        imageMyLocation = UIImage(named: "ic_myLocation")
    }
}
