//
//  ViewController.swift
//  Payment_iOS
//
//  Created by Ujesh Patel on 04/12/19.
//  Copyright © 2019 Ujesh Patel. All rights reserved.
//1) Merchant ID: merchant.com.sa.iDemo
//2) Sandbox: zaid@solutionanalysts.com pass: doGood$123

import UIKit
import Foundation

import BraintreeDropIn
import Braintree

import Stripe

import PassKit

//BraintreeGateway gateway = new BraintreeGateway(
//  Environment.SANDBOX,
//  "vhx2r37c645ky9yk",
//  "vhk8mb5stnhf8k3d",
//  "bfdc6b11872a53e9301d24a6871772cd"
//);

let clientToken = "sandbox_ykwz9w4v_vhx2r37c645ky9yk"

class ViewController: UIViewController {
    @IBOutlet weak var labelResult: UILabel!
    
    lazy var cardTextField: STPPaymentCardTextField = {
        let cardTextField = STPPaymentCardTextField()
        return cardTextField
    }()
    
    lazy var payButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 5
        button.backgroundColor = .systemGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        button.setTitle("Stripe Payment", for: .normal)
        button.addTarget(self, action: #selector(pay), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Stripe
//        cardTextField.backgroundColor = .systemGray
        cardTextField.textColor = .black
        
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [cardTextField, payButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalToSystemSpacingAfter: view.leftAnchor, multiplier: 2),
            view.rightAnchor.constraint(equalToSystemSpacingAfter: stackView.rightAnchor, multiplier: 2),
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 15),
        ])
        
    }
    
    //BrainTTree
    @IBAction func onClickBraintreePayment(_ sender: Any) {
        self.showDropIn(clientTokenOrTokenizationKey: clientToken)
    }
    
    //Apple Pay
    @IBAction func purchaseItem(_ sender: Any) {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.sa.iDemo"
        request.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Some Product", amount: 9.99)
        ]
        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self

        self.present(applePayController!, animated: true, completion: nil)
    }
    
}


//BrainTree
extension ViewController {
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        
        let request =  BTDropInRequest()
        request.threeDSecureRequest?.amount = 10.00
        request.vaultManager = true
        request.shouldMaskSecurityCode = true
        request.cardholderNameSetting = BTFormFieldSetting.required
        request.cardDisabled = false
        request.applePayDisabled = true
        request.paypalDisabled = false
        request.venmoDisabled = true
        
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request, handler: { (controller, result, error)  in
            if (error != nil) {
                print("ERROR")
            } else if (result?.isCancelled == true) {
                print("CANCELLED")
                self.dismiss(animated: true, completion: nil)

            } else if let result = result {
                print("result: \(result)")
                self.labelResult.text = "nonce " + (result.paymentMethod?.nonce ?? "")
                
                self.dismiss(animated: true, completion: nil)

            }
        })
        
        self.present(dropIn!, animated: true, completion: nil)
    }
}

//Stripe
extension ViewController {
    @objc
    func pay() {
        // Create an STPCardParams instance
           let cardParams = STPCardParams()
           cardParams.number = cardTextField.cardNumber
           cardParams.expMonth = cardTextField.expirationMonth
           cardParams.expYear = cardTextField.expirationYear
           cardParams.cvc = cardTextField.cvc

           // Pass it to STPAPIClient to create a Token
           STPAPIClient.shared().createToken(withCard: cardParams) { token, error in
               guard let token = token else {
                   // Handle the error
                   return
               }
               let tokenID = token.tokenId
            
            self.labelResult.text = "Token - " + tokenID
               // Send the token identifier to your server...
           }
    }
}


//Apple Pay
extension ViewController:
PKPaymentAuthorizationViewControllerDelegate{
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        completion(PKPaymentAuthorizationResult(status: PKPaymentAuthorizationStatus.success, errors: []))
//        print(payment.token)
    }
}
