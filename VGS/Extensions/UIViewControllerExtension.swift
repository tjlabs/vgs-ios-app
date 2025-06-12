
import UIKit

extension UIViewController {
    func showToastWithIcon(message: String, duration: TimeInterval = 2.0) {
        let toastView = UIView()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastView.layer.cornerRadius = 20
        toastView.clipsToBounds = true
        toastView.alpha = 0.0

        // 앱 아이콘 (또는 원하는 이미지)
        let iconImageView = UIImageView()
        if let appIcon = UIApplication.shared.icon {
            iconImageView.image = appIcon
        } else {
            iconImageView.image = UIImage(systemName: "info.circle") // fallback
        }
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.snp.makeConstraints { $0.size.equalTo(36) } // 적당한 아이콘 크기
        iconImageView.cornerRadius = 20

        // 라벨
        let messageLabel = PaddingLabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.5
        messageLabel.lineBreakMode = .byTruncatingTail
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left

        // StackView
        let stackView = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center

        toastView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }

        view.addSubview(toastView)
        toastView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(180)
            make.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.9)
        }

        // 애니메이션
        UIView.animate(withDuration: 0.3, animations: {
            toastView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}

class PaddingLabel: UILabel {
    var inset = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + inset.left + inset.right,
                      height: size.height + inset.top + inset.bottom)
    }
}
