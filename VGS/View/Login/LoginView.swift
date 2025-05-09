
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class LoginView: UIView {
    private let disposeBag = DisposeBag()
    
    var onLoginSuccessed: (() -> Void)?
    var onCellSelected: ((VehicleInfo) -> Void)?
    
    private var selectView: SelectView?
    var isChecked = false
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 48)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "차량 번호"
        return label
    }()
    
    private let vehicleNumberContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var vehicleNumberHintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 32)
        label.textColor = UIColor(hex: "#BDBDBD")
        label.textAlignment = .left
        label.text = "정보를 입력해주세요"
        return label
    }()
    
    private let vehicleNumberTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.notoSansMedium(size: 32)
        textField.textAlignment = .left
        textField.textColor = .black
        textField.backgroundColor = .clear
        return textField
    }()
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let saveUserContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var checkBoxImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "ic_uncheckedBox")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let checkBoxTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 26)
        label.textColor = .black
        label.textAlignment = .right
        label.text = "내 정보 저장하기"
        return label
    }()
    
    private let loginButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E47325")
        view.alpha = 0.8
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    private let loginButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.notoSansBold(size: 48)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "출입 조회"
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        bindActions()
        loadUserProfile()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(60)
            make.top.equalToSuperview().inset(40)
            make.height.equalTo(64)
        }
        
        addSubview(vehicleNumberContainerView)
        vehicleNumberContainerView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(75)
        }
        
        vehicleNumberContainerView.addSubview(vehicleNumberHintLabel)
        vehicleNumberHintLabel.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
        
        vehicleNumberContainerView.addSubview(vehicleNumberTextField)
        vehicleNumberTextField.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
        
        vehicleNumberContainerView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1.5)
            make.leading.trailing.equalToSuperview()
        }
        
        addSubview(saveUserContainerView)
        saveUserContainerView.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.width.equalTo(240)
            make.top.equalTo(vehicleNumberContainerView.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(40)
        }
        
        saveUserContainerView.addSubview(checkBoxImageView)
        checkBoxImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        saveUserContainerView.addSubview(checkBoxTitleLabel)
        checkBoxTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBoxImageView.snp.trailing).offset(5)
            make.top.bottom.trailing.equalToSuperview()
        }
        
        addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(90)
            make.bottom.equalToSuperview().inset(60)
        }
        
        loginButton.addSubview(loginButtonTitleLabel)
        loginButtonTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func bindActions() {
        bindTextField()
        setupKeyboardDismissal()
        setupSaveAction()
        setupLoginAction()
    }
    
    private func bindTextField() {
        vehicleNumberTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.vehicleNumberHintLabel.isHidden = !text.isEmpty
                // 유효성 검사 통과 후 다시 색상 초기화
                if !text.isEmpty {
                    self.lineView.backgroundColor = .black
                    self.vehicleNumberHintLabel.textColor = UIColor(hex: "#BDBDBD")
                    self.vehicleNumberHintLabel.text = "정보를 입력해주세요"
                }
            })
            .disposed(by: disposeBag)
    }

    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func setupSaveAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCheckboxToggle))
        saveUserContainerView.isUserInteractionEnabled = true
        saveUserContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleCheckboxToggle() {
        isChecked.toggle()
        let imageName = isChecked ? "ic_checkedBox" : "ic_uncheckedBox"
        checkBoxImageView.image = UIImage(named: imageName)
        
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.checkBoxImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.checkBoxImageView.transform = .identity
            }
        })
    }
    
    private func loadUserProfile() {
        UserManager.shared.loadProfileFromCache()
        if UserManager.shared.isLoadFromCache {
            print("LoginView : userProfile = \(UserManager.shared.userProfile)")
            self.vehicleNumberTextField.text = UserManager.shared.userProfile.carNumber
            self.vehicleNumberHintLabel.isHidden = true
            handleCheckboxToggle()
        }
    }
    
    private func setupLoginAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLoginButton))
        loginButton.isUserInteractionEnabled = true
        loginButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleLoginButton() {
        let isValid = validateUser()
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.loginButton.transform = .identity
            }
        })
        
        let vehicleNumber = self.vehicleNumberTextField.text ?? ""
        
        if isValid {
            LoginManager.shared.getSearchList(url: LOGIN_URL, input: vehicleNumber, completion: { [self] statusCode, returnedString in
                if statusCode == 200 {
                    UserManager.shared.userProfile.carNumber = vehicleNumber
                    UserManager.shared.saveProfileToCache()
                    
                    if let result = LoginManager.shared.decodeSearchListResult(from: returnedString) {
                        let vehicleInfoList = result.list
                        if result.total > 1 {
                            // 2개 이상
                            showSelectView(vehicleInfoList: vehicleInfoList)
                        } else {
                            // 1개
                            showSelectView(vehicleInfoList: vehicleInfoList)
                        }
                    } else {
                        print("디코딩에 실패했습니다.")
                    }
                } else {
                    print("통신에 실패했습니다.")
                }
            })
        }
    }
    
    private func validateUser() -> Bool {
        guard let text = vehicleNumberTextField.text, !text.isEmpty else {
            applyInvalidUserUI()
            return false
        }

        let containsWhitespace = text.contains { $0.isWhitespace }
        let containsSpecialCharacters = text.range(of: "[^가-힣a-zA-Z0-9]", options: .regularExpression) != nil
        
        if containsWhitespace || containsSpecialCharacters {
            applyInvalidUserUI()
            return false
        }

        return true
    }
    
    private func applyInvalidUserUI() {
        vehicleNumberTextField.text = ""
        lineView.backgroundColor = .red
        vehicleNumberHintLabel.textColor = .red
        vehicleNumberHintLabel.text = "잘못된 입력"
        vehicleNumberHintLabel.isHidden = false
    }
    
    private func showSelectView(vehicleInfoList: [VehicleInfo]) {
        self.onLoginSuccessed?()

        selectView?.removeFromSuperview()

        let selectView = SelectView(vehicleInfoList: vehicleInfoList)
        self.selectView = selectView

        addSubview(selectView)
        selectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectView.onCellItemTapped = { [self] selectedVehicle in
            self.onCellSelected?(selectedVehicle)
        }
    }
    
    public func removeSelectViewIfNeeded() {
        selectView?.removeFromSuperview()
        selectView = nil
    }
}
