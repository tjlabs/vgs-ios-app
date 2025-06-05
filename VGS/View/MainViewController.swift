
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class MainViewController: UIViewController, BottomNavigationViewDelegate, NaviArrivalDelegate {
    
    func isArrival(_ type: ArrivalType) {
        switch(type) {
        case .EXTERNAL:
            // TO-DO
            print("(MainVC) External Navi Ended")
            self.showDialogView()
        case .OUTDOOR:
            print("(MainVC) Outdoor Navi Ended")
            // TO-DO
        case .INDOOR:
            print("(MainVC) Indoor Navi Ended")
            // TO-DO:
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        
        setBottomNavigationHeight()
        setupLayout()
        
        bottomNavigationView.delegate = self
        kakaoNaviView.delegate = self
        
        startTimer()
    }
    
    private var bottomNavigationHeight: CGFloat = 100
    let bottomNavigationView = BottomNavigationView()
    let kakaoNaviView = KakaoNaviView()
    var infoContainerView: InfoContainerView?
//    let outdoorNaviView = OutdoorNaviView()
    
    var positionTimer: DispatchSourceTimer?
    let TIMER_INTERVAL: TimeInterval = 5.0
    
    private func setBottomNavigationHeight() {
        let totalHeight = view.frame.height
        self.bottomNavigationHeight = totalHeight*0.1
    }
    
    private func setupLayout() {
//        view.addSubview(kakaoNaviView)
//        kakaoNaviView.snp.makeConstraints { make in
//            make.top.bottom.leading.trailing.equalToSuperview()
//        }
        
//        view.addSubview(outdoorNaviView)
//        outdoorNaviView.snp.makeConstraints { make in
//            make.top.bottom.leading.trailing.equalToSuperview()
//        }
        
        view.addSubview(kakaoNaviView)
        kakaoNaviView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(self.bottomNavigationHeight-20)
        }
        
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
        
        bindLogoutAction()
    }
    
    private func bindLogoutAction() {
        infoContainerView?.onLogoutTapped = {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    private func showDialogView() {
        let dialogView = DialogView(contentViewHeight: 180)
        dialogView.onConfirm = { [weak self] in
            self?.kakaoNaviView.removeFromSuperview()
            self?.moveToOutdoorNaviVC()
        }
        
        view.addSubview(dialogView)
        dialogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func moveToOutdoorNaviVC() {
        let estimatedArrivalTime = calArrivalTimeString(secondsToArrival: 1)
        PositionManager.shared.updateArrivalTime(estimatedArrivalTime)
        PositionManager.shared.position.current_location = "영내"
        PositionManager.shared.setNaviType(type: .OUTDOOR)
        guard let outdoorNaviVC = self.storyboard?.instantiateViewController(withIdentifier: "OutdoorNaviViewController") as? OutdoorNaviViewController else { return }
        outdoorNaviVC.modalPresentationStyle = .fullScreen
        self.navigationController?.present(outdoorNaviVC, animated: true)
    }
    
    // Timer
    private func startTimer() {
        if (self.positionTimer == nil) {
            let queue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".positionTimer")
            self.positionTimer = DispatchSource.makeTimerSource(queue: queue)
            self.positionTimer!.schedule(deadline: .now(), repeating: TIMER_INTERVAL)
            self.positionTimer!.setEventHandler { [weak self] in
                guard let self = self else { return }
                self.positionTimerUpdate()
            }
            self.positionTimer!.resume()
        }
    }
    
    private func stopTimer() {
        self.positionTimer?.cancel()
        self.positionTimer = nil
    }
    
    private func positionTimerUpdate() {
        if kakaoNaviView.isStartReported {
            PositionManager.shared.sendData()
        }
    }
}
