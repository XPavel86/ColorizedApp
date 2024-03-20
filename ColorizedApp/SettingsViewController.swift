//
//  ViewController.swift
//  HW2-3
//
//  Created by Pavel Dolgopolov on 15.02.2024.
//

import UIKit

final class SettingsViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet var colorView: UIView!
    
    @IBOutlet var redSlider: UISlider!
    @IBOutlet var greenSlider: UISlider!
    @IBOutlet var blueSlider: UISlider!
    
    @IBOutlet var redValue: UILabel!
    @IBOutlet var greenValue: UILabel!
    @IBOutlet var blueValue: UILabel!
    
    @IBOutlet var redTextField: UITextField!
    @IBOutlet var greenTextField: UITextField!
    @IBOutlet var blueTextField: UITextField!
    
    // MARK: - Public Properties
    var color = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
    
    weak var delegate: SettingsViewControllerDelegate?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        [redTextField, greenTextField, blueTextField].forEach {
            $0?.delegate = self
            $0?.setSettings()
        }
        setupUI()
    }
    
    // MARK: - Overrides Methods
    override func viewWillLayoutSubviews() {
        colorView.layer.cornerRadius = 20
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideKeyboard()
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - IB Actions
    @IBAction func actionSlider(slider sender: UISlider) {
        let value = String(format: "%.2f", sender.value)
        
        switch sender {
        case redSlider:
            redValue.text = value
            redTextField.text = value
                  
        case greenSlider:
            greenValue.text = value
            greenTextField.text = value
            
        default:
            blueValue.text = value
            blueTextField.text = value
        }
        
        color = UIColor(
            red: CGFloat(redSlider.value),
            green: CGFloat(greenSlider.value),
            blue: CGFloat(blueSlider.value),
            alpha: 1.0
        )
        
        colorView.backgroundColor = color
    }
    
    @IBAction func donePressed() {
        hideKeyboard()
        delegate?.setColor(color)
        dismiss(animated: true)
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Extension SettingsViewController
extension SettingsViewController: UITextFieldDelegate {
    
    func setupUI() {
        let colors: [UIColor] = [.red, .green, .blue]
        let sliders: [UISlider] = [redSlider, greenSlider, blueSlider]
        
        let ciColor = CIColor(color: color)
        let colorValues = [ciColor.red, ciColor.green, ciColor.blue]
        
        for (index, slider) in sliders.enumerated() {
                slider.value = Float(colorValues[index])
                actionSlider(slider: slider)
                slider.minimumTrackTintColor = colors[index]
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

        textField.addToolbarOnKeyboard()
        textField.updateToolbarLabel()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        textField.updateToolbarLabel()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        textField.inputAccessoryView = nil
        
        if textField.text == "" {
            textField.text = "0.00"
        }
        
        if let text = textField.text, let value = Float(text) {
            switch textField {
            case redTextField:
                redSlider.setValue(value, animated: true)
                actionSlider(slider: redSlider)
                
            case greenTextField:
                greenSlider.setValue(value, animated: true)
                actionSlider(slider: greenSlider)
                
            default:
                blueSlider.setValue(value, animated: true)
                actionSlider(slider: blueSlider)
            }
        }
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        guard let text = textField.text else { return true }
        var newText = (text as NSString).replacingCharacters(in: range, with: string)
   
        newText = newText.replacingOccurrences(of: ",", with: ".")
        
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.,")
        let replacementStringCharacterSet = CharacterSet(charactersIn: string)
        guard allowedCharacterSet.isSuperset(of: replacementStringCharacterSet) else {
            showAlert(message: "Вводите только числа и знаки")
            return false
        }
        
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        if numberOfDots > 1 {
            showAlert(message: "Введите только одну точку")
            return false
        }
        
        if let dotIndex = newText.firstIndex(of: ".") {
            let digitsAfterDot = newText.suffix(from: newText.index(after: dotIndex))
            if digitsAfterDot.count > 2 {
                showAlert(message: "Введите не более двух знаков после точки")
                return false
            }
        }
        
        if let value = Float(newText), !(0...1).contains(value) {
            showAlert(message: "Введите значение в диапазоне от 0 до 1")
            return false
        }
        
        textField.text = newText
        return false
    }
    
    private func showAlert(message: String)
        {
            let alert = UIAlertController(
                title: "Ошибка", message: message, preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
}

// MARK: - Extension UITextField
extension UITextField {
    
    func setSettings() {
        autocorrectionType = .no
        smartQuotesType = .no
        smartDashesType = .no
        smartInsertDeleteType = .no
        keyboardType = .decimalPad
        textContentType = .oneTimeCode
        inputAccessoryView = nil
    }
    
     func addToolbarOnKeyboard() {
    
        let doneToolbar = UIToolbar()

        let label = UILabel()
        label.text = self.text ?? "0.00"
        label.sizeThatFits(CGSize(width: 50, height: 10))
        label.textAlignment = .right
         
        let swipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(clearText))
         
         label.addGestureRecognizer(swipe)
         label.isUserInteractionEnabled = true
        
        let labelItem = UIBarButtonItem(customView: label)
        
        let flexSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
         
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonAction)
        )
 
        doneToolbar.items = [labelItem, flexSpace, done]
        doneToolbar.sizeToFit()

        inputAccessoryView = doneToolbar
    }
    
    @objc func clearText() {
          self.text = ""
      }
    
    @objc func doneButtonAction() {
        resignFirstResponder()
    }
    
    func updateToolbarLabel() {
            if let toolbar = inputAccessoryView as? UIToolbar,
               let labelItem = toolbar.items?.first(
                where: { $0.customView is UILabel }
               ) as? UIBarButtonItem,
               let label = labelItem.customView as? UILabel {
                label.text = text
            }
        }
}
