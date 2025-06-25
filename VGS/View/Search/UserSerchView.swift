
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class UserSerchView: UIView {
    private let disposeBag = DisposeBag()
    
    var onSearchSuccessed: (() -> Void)?
    var onCellSelected: ((VehicleInfo) -> Void)?
    var onSearchInvalid: ((String) -> Void)?
    var onSearchFail: (() -> Void)?
    var onPublicLogin: (() -> Void)?
    
    private var selectView: SelectView?
    var isChecked = false
    
    var isDemoUser = false
    let demoUser = VehicleInfo(dummy: true)
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 46)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "차량 번호 입력"
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let vehicleNumberContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var vehicleNumberHintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansMedium(size: 30)
        label.textColor = UIColor(hex: "#BDBDBD")
        label.textAlignment = .left
        label.text = "11티1234"
        return label
    }()
    
    private let vehicleNumberTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.notoSansMedium(size: 30)
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
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.lineBreakMode = .byClipping
        return label
    }()
    
    private let searchButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#E47325")
        view.alpha = 0.8
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    private let searchButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.notoSansBold(size: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "출입 조회"
        return label
    }()
    
    private let publicLoginButton: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#BDBDBD")
        view.alpha = 0.8
        view.cornerRadius = 15
        view.addShadow(location: .rightBottom, color: .black, opacity: 0.2)
        return view
    }()
    
    private let publicLoginButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.notoSansBold(size: 40)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "일반 사용자"
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        bindActions()
        loadUserCarNumber()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(60)
            make.top.equalToSuperview().inset(40)
            make.height.equalTo(60)
        }
        
        addSubview(vehicleNumberContainerView)
        vehicleNumberContainerView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(70)
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
        
//        addSubview(searchButton)
//        searchButton.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview().inset(40)
//            make.height.equalTo(80)
//            make.bottom.equalToSuperview().inset(60)
//        }
        
//        searchButton.addSubview(searchButtonTitleLabel)
//        searchButtonTitleLabel.snp.makeConstraints { make in
//            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
//        }
        
        addSubview(searchButton)
        searchButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(80)
            make.top.equalTo(checkBoxTitleLabel.snp.bottom).offset(60)
        }
        
        searchButton.addSubview(searchButtonTitleLabel)
        searchButtonTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
        }
        
        addSubview(publicLoginButton)
        publicLoginButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.bottom.equalToSuperview()
            make.height.equalTo(80)
            make.top.equalTo(searchButton.snp.bottom).offset(20)
        }
        
        publicLoginButton.addSubview(publicLoginButtonTitleLabel)
        publicLoginButtonTitleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().inset(5)
        }
    }
    
    private func bindActions() {
        bindTextField()
        setupKeyboardDismissal()
        setupSaveAction()
        setupSearchAction()
        setupPublicLoginAction()
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
                    self.vehicleNumberHintLabel.text = "11티1234"
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
    
    private func loadUserCarNumber() {
        VehicleInfoManager.shared.loadCarNumberFromCache()
        if VehicleInfoManager.shared.isLoadFromCache {
            print("(UserSearchView) : userCarNumber = \(VehicleInfoManager.shared.userCarNumber)")
            self.vehicleNumberTextField.text = VehicleInfoManager.shared.userCarNumber
            self.vehicleNumberHintLabel.isHidden = true
            handleCheckboxToggle()
        }
    }
    
    private func setupSearchAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchButton))
        searchButton.isUserInteractionEnabled = true
        searchButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleSearchButton() {
        let isValid = validateUser()
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.searchButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.searchButton.transform = .identity
            }
        })
        
        let vehicleNumber = self.vehicleNumberTextField.text ?? ""
        
        if isValid {
            if self.isDemoUser {
                VehicleInfoManager.shared.isDemoUser = true
                VehicleInfoManager.shared.userCarNumber = vehicleNumber
                VehicleInfoManager.shared.saveCarNumberToCache()
                self.onCellSelected?(self.demoUser)
                return
            }
            
            SearchManager.shared.getSearchList(url: USER_SEARCH_URL, input: vehicleNumber, completion: { [self] statusCode, returnedString in
                print("(SearchView) getSearchList : \(statusCode) , \(returnedString)")
                if statusCode == 200 {
                    VehicleInfoManager.shared.isDemoUser = false
                    VehicleInfoManager.shared.userCarNumber = vehicleNumber
                    VehicleInfoManager.shared.saveCarNumberToCache()
                    
                    if let result = SearchManager.shared.decodeSearchListResult(from: returnedString) {
                        let vehicleInfoList = result.list
                        
                        let counts = Int(result.total)
                        if counts > 1 {
                            // 2개 이상
                            showSelectView(vehicleInfoList: vehicleInfoList)
                        } else if counts == 1 {
                            self.onCellSelected?(vehicleInfoList[0])
                        } else {
                            self.onSearchFail?()
                        }
                    } else {
                        self.onSearchFail?()
                        print("(SearchView) 디코딩에 실패했습니다.")
                    }
                } else {
                    self.onSearchFail?()
                    print("(SearchView) 통신에 실패했습니다.")
                }
            })
        }
    }
    
    private func validateUser() -> Bool {
        guard let text = vehicleNumberTextField.text, !text.isEmpty else {
            self.onSearchInvalid?("")
//            applyInvalidUserUI()
            return false
        }
        
        if text == "999데9999" {
            self.isDemoUser = true
            return true
        }

        let containsWhitespace = text.contains { $0.isWhitespace }
        let containsSpecialCharacters = text.range(of: "[^가-힣a-zA-Z0-9]", options: .regularExpression) != nil
        
        if containsWhitespace || containsSpecialCharacters {
            self.onSearchInvalid?(text)
//            applyInvalidUserUI()
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
    
    private func setupPublicLoginAction() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePublicLoginButton))
        publicLoginButton.isUserInteractionEnabled = true
        publicLoginButton.addGestureRecognizer(tapGesture)
    }
    
    @objc func handlePublicLoginButton() {
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.publicLoginButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.publicLoginButton.transform = .identity
            }
            self.onPublicLogin?()
        })
    }
    
    private func showSelectView(vehicleInfoList: [VehicleInfo]) {
        self.onSearchSuccessed?()

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
