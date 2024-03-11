//
//  DataColor.swift
//  ColorizedApp
//
//  Created by Pavel Dolgopolov on 10.03.2024.
//

import Foundation

struct ColorRGB: CustomStringConvertible {
    var description: String {
            return "(\(red), \(green), \(green))"
        }
     
    var red: Float
    var green: Float
    var blue: Float
    
    init(red: Float, green: Float, blue: Float) {
            self.red = red
            self.green = green
            self.blue = blue
        }
    
    init(_ rgb: (Float, Float, Float)) {
            self.red = rgb.0
            self.green = rgb.1
            self.blue = rgb.2
        }
}
