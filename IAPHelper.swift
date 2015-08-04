//
//  IAPHelper.swift
//  swift-helpers
//
//  Created by Andrew Brandt on 2/4/15.
//  Copyright (c) 2015 dorystudios. All rights reserved.
//

import StoreKit

protocol IAPHelperDelegate {
    
    func purchaseSuccessful(productString: String)
    func purchaseFailed(productString: String)
    
}

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var delegate: IAPHelperDelegate!
    
    //called by you, to start purchase process
    func attemptPurchase(productName: String) {
        if (SKPaymentQueue.canMakePayments()) {
            var productID:NSSet = NSSet(object: productName)
            var productRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID)
            productRequest.delegate = self
            productRequest.start()
        } else {
            if let delegate = delegate {
                delegate.purchaseFailed(productName)
            }
        }
    }
    
    //called after delegate method productRequest
    func buyProduct(product: SKProduct) {
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
        
    }
    
    // MARK: - SKProductsRequestDelegate method
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        var count: Int = response.products.count
        if (count > 0) {
            var validProducts = response.products
            var product = validProducts[0] as SKProduct
            buyProduct(product)
        } else {
            //something went wrong with lookup, try again?
        }
    }
    
    // MARK: - SKPaymentTransactionObserver method
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        var hasFinished: Bool = false
        for transaction: AnyObject in transactions {
            if !hasFinished {
                if let tx: SKPaymentTransaction = transaction as? SKPaymentTransaction {
                    switch tx.transactionState {
                    case .Purchased:
                        if let delegate = delegate {
                            delegate.purchaseSuccessful(tx.payment.productIdentifier)
                        }
                        queue.finishTransaction(tx)
                        //hasFinished = true
                        break;
                    case .Failed:
                        //delegate.purchaseFailed(tx.payment.productIdentifier)
                        queue.finishTransaction(tx)
                        //hasFinished = true
                        break;
                    case .Deferred:
                        break;
                    case .Purchasing:
                        break;
                    default:
                        queue.finishTransaction(tx)
                        break;
                    }
                }
            }
        }
    }
}
