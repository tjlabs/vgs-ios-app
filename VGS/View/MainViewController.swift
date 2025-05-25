
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class MainViewController: UIViewController, BottomNavigationViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBottomNavigationHeight()
        setupLayout()
        
        bottomNavigationView.delegate = self
    }
    
    private var bottomNavigationHeight: CGFloat = 100
    let bottomNavigationView = BottomNavigationView()
    let kakaoNaviView = KakaoNaviView()
    var infoContainerView: InfoContainerView?
//    let outdoorNaviView = OutdoorNaviView()
    
    private func setBottomNavigationHeight() {
        let totalHeight = view.frame.height
        self.bottomNavigationHeight = totalHeight*0.1
    }
    
    private func setupLayout() {
        view.addSubview(kakaoNaviView)
        kakaoNaviView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
//        view.addSubview(outdoorNaviView)
//        outdoorNaviView.snp.makeConstraints { make in
//            make.top.bottom.leading.trailing.equalToSuperview()
//        }
        
        view.addSubview(bottomNavigationView)
        bottomNavigationView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(self.bottomNavigationHeight)
        }
    }
    
    func didTapNavigationItem(_ title: String, from previousTitle: String) {
        if previousTitle == "출입 정보" && title == "길안내" {
            // 출입 정보 → 길안내 전환 처리
            print("MainViewController: 출입 정보 → 길안내")
            self.infoContainerView?.removeFromSuperview()
        } else if previousTitle == "길안내" && title == "출입 정보" {
            // 길안내 → 출입 정보 전환 처리
            print("MainViewController: 길안내 → 출입 정보")
            controlInfoContainerView()
        }
    }
    
    private func controlInfoContainerView() {
        infoContainerView = InfoContainerView()
        view.addSubview(infoContainerView!)
        infoContainerView!.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomNavigationView.snp.top)
        }
    }
}
