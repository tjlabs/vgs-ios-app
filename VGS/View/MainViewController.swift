
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then
import TJLabsAuth

class MainViewController: UIViewController, BottomNavigationViewDelegate, NaviArrivalDelegate {
    
    func isArrival(_ type: ArrivalType) {
        switch(type) {
        case .EXTERNAL:
            // TO-DO
            print("(MainVC) External Navi Ended")
            kakaoNaviView.resetSimulationTapCount()
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
        bindActions()
        
        bottomNavigationView.delegate = self
        kakaoNaviView.delegate = self
        
        startTimer()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.locationCheck),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationCheck()
    }
    
    private var bottomNavigationHeight: CGFloat = 100
    let bottomNavigationView = BottomNavigationView()
    let kakaoNaviView = KakaoNaviView()
    
    var infoContainerView: InfoContainerView?
    let outdoorNaviView = OutdoorNaviView()
    
    var positionTimer: DispatchSourceTimer?
    let TIMER_INTERVAL: TimeInterval = 5.0
    
    private var locationAlert: UIAlertController? = nil
    
    private func setBottomNavigationHeight() {
        let totalHeight = view.frame.height
        self.bottomNavigationHeight = totalHeight*0.1
    }
    
    private func setupLayout() {
//        view.addSubview(kakaoNaviView)
//        kakaoNaviView.snp.makeConstraints { make in
//            make.top.bottom.leading.trailing.equalToSuperview()
//        }
        
        view.addSubview(outdoorNaviView)
        outdoorNaviView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(self.bottomNavigationHeight-20)
        }
        
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
    
    private func bindActions() {

    }
    
    func didTapNavigationItem(_ id: Int, from previousId: Int) {
        // 길안내 : 0 // 출입 정보 : 1
        if previousId == 1 && id == 0 {
            // 출입 정보 → 길안내 전환 처리
            print("MainViewController: 출입 정보 → 길안내")
            self.infoContainerView?.removeFromSuperview()
        } else if previousId == 0 && id == 1 {
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
            self?.outdoorNaviView.setIsHidden(isHidden: false)
        }
        
        view.addSubview(dialogView)
        dialogView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
    
    
    // Permission Alert
    func hideLocationAlert() {
        guard self.locationAlert != nil else {
            return
        }
        print("hide location permission alert")
        self.dismiss(animated: false)
        
        self.locationAlert = nil
    }
    
    func showLocationAlert(){
        guard self.locationAlert == nil else { return }
        
        let alert = UIAlertController(title: "위치 권한 및 정확한 위치를 허용해 주세요.",
                                         message: "앱 설정 화면으로 가시겠습니까? \n '아니오'를 선택하시면 앱이 종료됩니다.",
                                         preferredStyle: UIAlertController.Style.alert)
        print("show location permission alert")
        let logOkAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default){
            (action: UIAlertAction) in
            let url = URL.init(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!)
            } else {
                UIApplication.shared.openURL(url!)
            }
            self.locationAlert = nil
        }
        let logNoAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive){
            (action: UIAlertAction) in
            self.locationAlert = nil
            exit(0)
        }
        alert.addAction(logNoAction)
        alert.addAction(logOkAction)
        self.present(alert, animated: true, completion: {
            print("Alert show complete")
            self.locationAlert = alert
        })
    }
    
    @objc func locationCheck(){
        let status = CLLocationManager.authorizationStatus()
        
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            let alter = UIAlertController(title: "위치권한 설정이 '안함'으로 되어있습니다.",
                                          message: "앱 설정 화면으로 가시겠습니까? \n '아니오'를 선택하시면 앱이 종료됩니다.",
                                          preferredStyle: UIAlertController.Style.alert)
            let logOkAction = UIAlertAction(title: "네", style: UIAlertAction.Style.default){
                (action: UIAlertAction) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(NSURL(string:UIApplication.openSettingsURLString)! as URL)
                } else {
                    UIApplication.shared.openURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                }
            }
            let logNoAction = UIAlertAction(title: "아니오", style: UIAlertAction.Style.destructive){
                (action: UIAlertAction) in
                exit(0)
            }
            alter.addAction(logNoAction)
            alter.addAction(logOkAction)
            self.present(alter, animated: true, completion: nil)
        }
    }
}
