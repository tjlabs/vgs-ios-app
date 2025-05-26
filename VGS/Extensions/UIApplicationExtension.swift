
import UIKit

extension UIApplication {
    var icon: UIImage? {
        guard
            let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcons = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcons["CFBundleIconFiles"] as? [String],
            let lastIconName = iconFiles.last
        else {
            return nil
        }

        return UIImage(named: lastIconName)
    }
}
