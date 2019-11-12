//
//  AppDelegate.swift
//  StripeIntegration_Majdi
//
//  Created by TAE Akshit on 30/09/19.
//  Copyright © 2019 Majdi Felah. All rights reserved.
//


import Foundation
import Stripe
import Alamofire

class MyAPIClient: NSObject {
    
    enum APIError: Error {
        case unknown
        
        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            }
        }
    }
    
    static let sharedClient = MyAPIClient()
    
    // Backend base URL
    let baseURL: URL = URL(string: "https://stripe-integration-test-akshit.herokuapp.com")!
    
    func createPaymentIntent(products: [Product], completion: @escaping ((String?, Error?) -> Void)) {
        let url = self.baseURL.appendingPathComponent("create_payment_intent")
        let params: [String: Any] = [
            
            // We need to change this key to our own product identifier(s)
            "products": products.map({ (p) -> String in
                return p.emoji
            })
        ]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (dataResponse) in
            switch dataResponse.result {
            case .success(let json):
                guard let jsonValue = json as? [String: Any],
                    let secret = jsonValue["secret"] as? String else {
                    return
                }
                completion(secret, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

extension MyAPIClient: STPCustomerEphemeralKeyProvider {
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
}
