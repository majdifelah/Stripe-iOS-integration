//
//  AppDelegate.swift
//  StripeIntegration_Majdi
//
//  Created by TAE Akshit on 30/09/19.
//  Copyright © 2019 Majdi Felah. All rights reserved.
//


import Foundation

struct Product {
    let emoji: String
    let price: Int
    
    var priceText: String {
        return "$\(price/100).00"
    }
}
