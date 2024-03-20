//
//  MainViewController.swift
//  ColorizedApp
//
//  Created by Pavel Dolgopolov on 10.03.2024.
//

import UIKit

 protocol SettingsViewControllerDelegate: AnyObject {
    func setColor(_ color: UIColor)
}

final class MainViewController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsVC = segue.destination as? SettingsViewController else {  return }
        
        settingsVC.delegate = self
        settingsVC.color = view.backgroundColor ?? .white
    }
}

extension MainViewController: SettingsViewControllerDelegate {
    func setColor(_ color: UIColor) {
        
        view.backgroundColor = color
    }
}
