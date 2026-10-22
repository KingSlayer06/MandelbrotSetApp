//
//  MandelbrotPalette.swift
//  MandelbrotSetApp
//
//  Created by Himanshu Sherkar on 22/10/26.
//

import Foundation

public enum MandelbrotPalette: Float, CaseIterable, Identifiable {
    case aurora
    case ocean
    case sunset
    case monochrome
    case glacier
    case ember
    case orchid
    case forest
    case sepia
    case neon
    
    public var id: Self { self }
    
    var name: String {
        switch self {
            case .aurora: "Aurora"
            case .ocean: "Ocean"
            case .sunset: "Sunset"
            case .monochrome: "Monochrome"
            case .glacier: "Glacier"
            case .ember: "Ember"
            case .orchid: "Orchid"
            case .forest: "Forest"
            case .sepia: "Sepia"
            case .neon: "Neon"
        }
    }
}
