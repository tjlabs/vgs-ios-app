
import UIKit

class TJLabsZoomButton: UIButton {
    
    private var imageZoomIn: UIImage?
    private var imageZoomOut: UIImage?
    
    static var zoomMode: ZoomMode = .ZOOM_OUT
    static var zoomModeChangedTime = 0
    
    init() {
        super.init(frame: .zero)
        self.setupAssets()
        
        self.setImage(self.imageZoomIn, for: .normal)
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
        self.imageZoomIn = UIImage(named: "ic_zoomIn")
        self.imageZoomOut = UIImage(named: "ic_zoomOut")
    }
    
    func setButtonImage(to mode: ZoomMode? = nil) {
        TJLabsZoomButton.zoomMode = mode ?? (TJLabsZoomButton.zoomMode == .ZOOM_IN ? .ZOOM_OUT : .ZOOM_IN)
        DispatchQueue.main.async { [self] in
            self.setImage(TJLabsZoomButton.zoomMode == .ZOOM_IN ? imageZoomOut : imageZoomIn, for: .normal)
        }
    }
    
    func updateZoomModeChangedTime(time: Int) {
        TJLabsZoomButton.zoomModeChangedTime = time
    }
}
