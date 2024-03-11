//
//  ViewController.swift
//  HW2-3
//
//  Created by Pavel Dolgopolov on 15.02.2024.
//

import UIKit

class SettingsViewController: UIViewController {
    
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
    var color = ColorRGB(red: 0.1, green: 0.3, blue: 0.5)
    
    weak var delegate: SettingsViewControllerDelegate?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        [redTextField, greenTextField, blueTextField].forEach {
            $0?.delegate = self
            $0?.setSettings()
        }
        setupUI()
    }
    
    override func viewWillLayoutSubviews() {
        colorView.layer.cornerRadius = 20
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
        
        color = ColorRGB(
            red: redSlider.value,
            green: greenSlider.value,
            blue: blueSlider.value
        )
        
        colorView.backgroundColor = UIColor(
            red: CGFloat(redSlider.value),
            green: CGFloat(greenSlider.value),
            blue: CGFloat(blueSlider.value),
            alpha: 1.0
        )
    }
    
    @IBAction func donePressed() {
        hideKeyboard()
        delegate?.setColor(color: color)
        dismiss(animated: true)
    }
    
    // MARK: - Exported methods
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Extensions
extension SettingsViewController: UITextFieldDelegate {
    
    func setupUI() {
        let colors: [UIColor] = [.red, .green, .blue]
        let sliders: [UISlider?] = [redSlider, greenSlider, blueSlider]
        let colorValues = [color.red, color.green, color.blue]
        
        for (index, slider) in sliders.enumerated() {
            if let slider = slider {
                slider.value = colorValues[index]
                actionSlider(slider: slider)
                slider.minimumTrackTintColor = colors[index]
            }
        }
    }
  
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        // Заменяем запятую на точку
        var newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        newText = newText.replacingOccurrences(of: ",", with: ".")
        
        // Проверяем, что в тексте нет двух точек подряд
        if newText.contains("..") {
            return false
        }
        
        // Проверяем, что в тексте не более одной точки
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        if numberOfDots > 1 && string == "." {
            return false
        }
        
        // Проверяем, что вводимый символ - цифра, точка или запятая
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.,")
        let replacementStringCharacterSet = CharacterSet(charactersIn: string)
        guard allowedCharacterSet.isSuperset(of: replacementStringCharacterSet) else {
            return false
        }
        
        // Проверяем длину вводимого текста
        let components = newText.components(separatedBy: CharacterSet(charactersIn: "."))
        let numberOfDigits = components.reduce(0) { $0 + $1.count }
        if numberOfDigits > 3 {
            return false
        }
        
        // Преобразуем текст в число и проверяем, что оно находится в диапазоне от 0 до 1
        if let value = Float(newText), !(0...1).contains(value) {
            return false
        }
        
        textField.text = newText
        return false
    }
}

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
}
