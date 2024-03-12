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
        
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
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
        
        let ciColor = CIColor(color: color)
        let colorValues = [ciColor.red, ciColor.green, ciColor.blue]
        
        for (index, slider) in sliders.enumerated() {
            if let slider = slider {
                slider.value = Float(colorValues[index])
                actionSlider(slider: slider)
                slider.minimumTrackTintColor = colors[index]
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if let toolbar = textField.inputAccessoryView as? UIToolbar,
           let labelItem = toolbar.items?.first(
            where: { $0.customView is UILabel }
           ) as? UIBarButtonItem,
           let label = labelItem.customView as? UILabel {
            label.text = textField.text
            label.sizeToFit()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
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
        
        var newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        newText = newText.replacingOccurrences(of: ",", with: ".")
        
        if newText.contains("..") {
            return false
        }
        
        let numberOfDots = newText.components(separatedBy: ".").count - 1
        if numberOfDots > 1 && string == "." {
            return false
        }
        
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789.,")
        let replacementStringCharacterSet = CharacterSet(charactersIn: string)
        guard allowedCharacterSet.isSuperset(of: replacementStringCharacterSet) else {
            return false
        }
        
        let components = newText.components(separatedBy: CharacterSet(charactersIn: "."))
        let numberOfDigits = components.reduce(0) { $0 + $1.count }
        if numberOfDigits > 3 {
            return false
        }
        
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
        
        addToolbarOnKeyboard()
    }
    
private func addToolbarOnKeyboard() {
    
        let doneToolbar = UIToolbar(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50)
        )
        doneToolbar.barStyle = .default
        
        let label = UILabel()
        label.text = "0.00"
        label.sizeToFit()
        label.textAlignment = .right
        
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
        
        let items = [labelItem, flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        resignFirstResponder()
    }
}
