//
//  AppDelegate.swift
//  StripeIntegration_Majdi
//
//  Created by TAE Akshit on 30/09/19.
//  Copyright © 2019 Majdi Felah. All rights reserved.
//


import UIKit
import Stripe

class ViewController: UIViewController {
    
    @IBOutlet private weak var paymentLabel: UILabel!
    
    private var paymentContext: STPPaymentContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prepare customer context
        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        
        // Prepare payment context with customer context
        preparePaymentContext(with: customerContext)
    }
    
    private func preparePaymentContext(with customerContext: STPCustomerContext) {
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext.delegate = self
        self.paymentContext.hostViewController = self
        self.paymentContext.paymentAmount = 5000 // This is in cents, i.e. $50 USD
    }
    
    // Shows different payment options
    @IBAction func choosePaymentButtonTapped() {
        paymentContext.presentPaymentOptionsViewController()
    }
    
    @IBAction func checkoutButtonTapped() {
        paymentContext.requestPayment()
    }
}

extension ViewController: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        paymentLabel.text = paymentContext.selectedPaymentOption?.label
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        let product = Product(emoji: "👕", price: 2000)
        MyAPIClient.sharedClient.createPaymentIntent(products: [product]) { (secret, error) in
            
            // Got secret back from create payment intent API
            guard let secret = secret else {
                completion(.error, error)
                return
            }
            let params = STPPaymentIntentParams(clientSecret: secret)
            params.paymentMethodId = paymentResult.paymentMethod.stripeId
            STPPaymentHandler.shared().confirmPayment(withParams: params, authenticationContext: paymentContext, completion: { (status, paymentIntent, confirmPaymentError) in
                switch status {
                case .succeeded: completion(.success, nil)
                case .failed: completion(.error, confirmPaymentError)
                case .canceled: completion(.userCancellation, nil)
                @unknown default: completion(.error, nil)
                }
            })
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .error: print("Error occured \(error?.localizedDescription ?? "N.A")")
        case .success: print("Payment success")
        case .userCancellation: return
        @unknown default: return
        }
    }
}
