import UIKit
import SnapKit
import Then

class OutdoorNaviView: UIView {
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let mapImageView = UIImageView().then {
        $0.image = UIImage(named: "temp_map")
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .systemYellow
        $0.isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(mapImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyImageConstraints()
    }

    private func applyImageConstraints() {
        guard let imageSize = mapImageView.image?.size else { return }

        let viewSize = bounds.size
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height

        var targetSize = CGSize.zero
        if imageAspect > viewAspect {
            targetSize.width = viewSize.width
            targetSize.height = viewSize.width / imageAspect
        } else {
            targetSize.height = viewSize.height
            targetSize.width = viewSize.height * imageAspect
        }

        mapImageView.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(200)
            make.centerX.equalToSuperview()
            make.width.equalTo(targetSize.width)
            make.height.equalTo(targetSize.height)
        }

        DispatchQueue.main.async {
            self.drawRedDotFromPixelCoord(pixelCoord: CGPoint(x: 183, y: 158))
        }
    }

    func drawRedDotFromPixelCoord(pixelCoord: CGPoint) {
        guard let image = mapImageView.image,
              let cgImage = image.cgImage else {
            return
        }

        let pixelSize = CGSize(width: cgImage.width, height: cgImage.height)
        let logicalSize = image.size

        let scaleX = logicalSize.width / pixelSize.width
        let scaleY = logicalSize.height / pixelSize.height

        let logicalCoord = CGPoint(
            x: pixelCoord.x * scaleX,
            y: pixelCoord.y * scaleY
        )

        drawRedDot(at: logicalCoord)
    }

    private func drawRedDot(at imagePoint: CGPoint) {
        guard let viewPoint = convertImagePointToViewPoint(imagePoint: imagePoint, in: mapImageView) else { return }

        let dotSize: CGFloat = 10
        let dotView = UIView(frame: CGRect(x: 0, y: 0, width: dotSize, height: dotSize))
        dotView.backgroundColor = .red
        dotView.layer.cornerRadius = dotSize / 2
        dotView.center = viewPoint

        mapImageView.addSubview(dotView)
    }

    private func convertImagePointToViewPoint(imagePoint: CGPoint, in imageView: UIImageView) -> CGPoint? {
        guard let image = imageView.image else { return nil }

        let imageSize = image.size
        let viewSize = imageView.bounds.size

        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height

        var drawSize = CGSize.zero
        if imageAspect > viewAspect {
            drawSize.width = viewSize.width
            drawSize.height = viewSize.width / imageAspect
        } else {
            drawSize.height = viewSize.height
            drawSize.width = viewSize.height * imageAspect
        }

        let offsetX = (viewSize.width - drawSize.width) / 2.0
        let offsetY = (viewSize.height - drawSize.height) / 2.0

        let scaleX = drawSize.width / imageSize.width
        let scaleY = drawSize.height / imageSize.height

        let viewX = offsetX + imagePoint.x * scaleX
        let viewY = offsetY + imagePoint.y * scaleY

        return CGPoint(x: viewX, y: viewY)
    }
}
