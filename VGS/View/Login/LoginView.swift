
import UIKit
import SnapKit
import RxCocoa
import RxSwift
import RxRelay
import Then

class LoginView: UIView {
    private let disposeBag = DisposeBag()
    var isChecked = false
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.notoSansBold(size: 48)
        label.textColor = .black
        label.textAlignment = .left
        label.text = "차량 번호"
        return label
    }()
    
    private let carNumberContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let carNumberTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.notoSansMedium(size: 32)
        textField.textAlignment = .left
        textField.textColor = .black
        textField.placeholder = "정보를 입력해주세요"
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
        
        addSubview(carNumberContainerView)
        carNumberContainerView.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(40)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(75)
        }
        
        carNumberContainerView.addSubview(carNumberTextField)
        carNumberTextField.snp.makeConstraints{ make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
        
        carNumberContainerView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1.5)
            make.leading.trailing.equalToSuperview()
        }
        
        addSubview(saveUserContainerView)
        saveUserContainerView.snp.makeConstraints { make in
            make.height.equalTo(42)
            make.width.equalTo(240)
            make.top.equalTo(carNumberContainerView.snp.bottom).offset(10)
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
        setupKeyboardDismissal()
        setupSaveAction()
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
}
