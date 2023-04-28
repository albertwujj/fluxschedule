

import UIKit
import StoreKit

enum IAPHandlerAlertType{
  case disabled
  case restored
  case purchased
  
  func message() -> String{
    switch self {
    case .disabled: return "Purchases are disabled in your device! The purchase did not go through."
    case .restored: return "You've successfully restored your purchase!"
    case .purchased: return "You've successfully bought this purchase!"
    }
  }
}


class IAPHandler: NSObject {
  static let shared = IAPHandler()
  
  let NON_CONSUMABLE_PURCHASE_PRODUCT_ID = "9P3FVEPY7V.fluxplus"
  
  fileprivate var productID = ""
  fileprivate var productsRequest = SKProductsRequest()
  fileprivate var iapProducts = [SKProduct]()
  
  var purchaseStatusBlock: ((IAPHandlerAlertType, SKPaymentTransaction?) -> Void)?
  
  // MARK: - MAKE PURCHASE OF A PRODUCT
  func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
  
  func purchaseMyProduct(index: Int){
    if iapProducts.count == 0 { return }
    
    if self.canMakePurchases() {
      let product = iapProducts[index]
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(self)
      SKPaymentQueue.default().add(payment)
      
      print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
      productID = product.productIdentifier
    } else {
      purchaseStatusBlock?(.disabled, nil)
    }
  }
  
  // MARK: - RESTORE PURCHASE
  func restorePurchase(){
    SKPaymentQueue.default().add(self)
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  
  // MARK: - FETCH AVAILABLE IAP PRODUCTS
  func fetchAvailableProducts(){
    
    // Put here your IAP Products ID's
    let productIdentifiers = NSSet(objects: NON_CONSUMABLE_PURCHASE_PRODUCT_ID)
    
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
    productsRequest.delegate = self
    productsRequest.start()
  }
}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver{
  // MARK: - REQUEST IAP PRODUCTS
  func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
    
    if (response.products.count > 0) {
      iapProducts = response.products
      for product in iapProducts{
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let price1Str = numberFormatter.string(from: product.price)
        print(product.localizedDescription + "\nfor just \(price1Str!)")
      }
    }
  }
  
  func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    for trans in queue.transactions {
      purchaseStatusBlock?(.restored, trans)
    }
  }
  
  // MARK:- IAP PAYMENT QUEUE
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction:AnyObject in transactions {
      if let trans = transaction as? SKPaymentTransaction {
        switch trans.transactionState {
        case .purchased:
          print("purchased")
          SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
          purchaseStatusBlock?(.purchased, trans)
          break
          
        case .failed:
          print("failed")
          SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
          break
        case .restored:
          print("restored")
          purchaseStatusBlock?(.restored, trans)
          SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
          break
          
        default: break
        }}}
  }
}

