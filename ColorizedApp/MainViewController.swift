//
//  MainViewController.swift
//  ColorizedApp
//
//  Created by Pavel Dolgopolov on 10.03.2024.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func setColor(color: ColorRGB)
}
 
class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let settingsVC = segue.destination as? SettingsViewController
        settingsVC?.delegate = self
        
        settingsVC?.color = extractRGB(from: view.backgroundColor ?? .white) 
    }
    
    func extractRGB(from color: UIColor) -> ColorRGB {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return ColorRGB(red: Float(red), green: Float(green), blue: Float(blue))
    }
}

extension MainViewController: SettingsViewControllerDelegate {
    
    func setColor(color: ColorRGB) {
        
        view.backgroundColor = UIColor(
            red: CGFloat(color.red),
            green: CGFloat(color.green),
            blue: CGFloat(color.blue),
            alpha: 1
        )
    }
}
