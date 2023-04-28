/*
 import Foundation
 import UIKit
 
 protocol PropertyStoring {
 
 associatedtype T
 
 func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T
 }
 
 extension PropertyStoring {
 func getAssociatedObject(_ key: UnsafeRawPointer!, defaultValue: T) -> T {
 guard let value = objc_getAssociatedObject(self, key) as? T else {
 return defaultValue
 }
 return value
 }
 }
 extension UITextField: PropertyStoring{
 typealias T = UIBarButtonItem?
 
 
 private struct CustomProperties {
 static var doneButton: UIBarButtonItem? = nil
 static var todayButton: UIBarButtonItem? = nil
 }
 var doneButton: UIBarButtonItem? {
 get {
 return getAssociatedObject(&CustomProperties.doneButton, defaultValue: CustomProperties.doneButton)
 }
 set {
 return objc_setAssociatedObject(self, &CustomProperties.doneButton, newValue, .OBJC_ASSOCIATION_RETAIN)
 }
 }
 var todayButton: UIBarButtonItem? {
 get {
 return getAssociatedObject(&CustomProperties.todayButton, defaultValue: CustomProperties.todayButton)
 }
 set {
 return objc_setAssociatedObject(self, &CustomProperties.todayButton, newValue, .OBJC_ASSOCIATION_RETAIN)
 }
 }
 
 @IBInspectable var doneAccessory: Bool{
 get {
 return self.doneAccessory
 }
 set (hasDone) {
 if hasDone{
 addDoneButtonOnKeyboard()
 }
 }
 }
 @IBInspectable var todayAccessory: Bool{
 get {
 return self.todayAccessory
 }
 set (todayAccessory) {
 
 addDoneButtonOnKeyboard2()
 
 }
 }
 
 
 func addDoneButtonOnKeyboard()
 {
 let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
 doneToolbar.barStyle = .default
 
 let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
 let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
 
 let items = [flexSpace, custo, done]
 doneToolbar.items = items
 doneToolbar.sizeToFit()
 
 self.inputAccessoryView = doneToolbar
 self.doneButton = done
 }
 func addDoneButtonOnKeyboard2()
 {
 let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
 doneToolbar.barStyle = .default
 
 let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
 let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
 let today: UIBarButtonItem = UIBarButtonItem(title: todayAccessory, style: .plain, target: self, action: #selector(self.doneButtonAction))
 let items = [flexSpace, today, done]
 doneToolbar.items = items
 doneToolbar.sizeToFit()
 
 self.inputAccessoryView = doneToolbar
 self.doneButton = done
 }
 
 @objc func doneButtonAction()
 {
 self.resignFirstResponder()
 }
 }
 */
