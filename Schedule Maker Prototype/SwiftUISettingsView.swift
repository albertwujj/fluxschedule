//
//  SwiftUISettingsView.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 4/24/23.
//  Copyright © 2023 Old Friend. All rights reserved.
//

import SwiftUI

struct DurationPicker: UIViewRepresentable {
    @Binding var duration: TimeInterval
    var is5MinIncrement: Bool!

    func makeUIView(context: Context) -> AccessoryTextField {
        let durationTF = AccessoryTextField()
        let topBarCustomButton = UIButton()
        topBarCustomButton.setTitle(" 88:88 ", for: .normal) // button is just a label
        topBarCustomButton.setTitleColor(.black, for: .normal)
        durationTF.addButtons(customString: nil, customButton: topBarCustomButton)
        durationTF.accessoryDelegate = context.coordinator
        durationTF.delegate = context.coordinator
        context.coordinator.parentView = durationTF
        return durationTF
    }

    func updateUIView(_ durationTF: AccessoryTextField, context: Context) {
      durationTF.customButton!.setTitle(Coordinator.convertDurationToDisplayString(duration: duration), for: .normal)
      durationTF.customButton!.sizeToFit()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AccessoryTextFieldDelegate, UITextFieldDelegate {
        let parent: DurationPicker
        var parentView: AccessoryTextField!

        init(_ parent: DurationPicker) {
            self.parent = parent
        }
        static func convertDurationToDisplayString(duration: TimeInterval) -> String {
          let intDuration = Int(duration)

          /* TODO:
          if self.is5MinIncrement {
              intDuration = Int((Double(intDuration / 60) + 2.5) / Double(5).rounded(.down)) * 5 * 60 // round to x5 minutes
          } */
          let hour:Int = intDuration / 3600
          let minute:Int = (intDuration % 3600) / 60
          var hourString = "\(hour)"
          var minuteString = "\(minute)"
          if(hour < 10) {
              hourString = "0" + hourString
          }
          if(minute < 10) {
              minuteString = "0" + minuteString
          }
          return "\(hourString):\(minuteString)"
        }

        @objc func textFieldDidBeginEditing(_ textField: UITextField) {
          let datePicker = UIDatePicker()
          datePicker.preferredDatePickerStyle = .wheels
          datePicker.datePickerMode = .countDownTimer
          datePicker.countDownDuration = parent.duration
          textField.inputView = datePicker
          datePicker.addTarget(self, action: #selector(Coordinator.updateInputViewDurationLabel), for: .valueChanged)
          (textField as! AccessoryTextField).customButton!.setTitle(Coordinator.convertDurationToDisplayString(duration: parent.duration), for: .normal) // button is just a label
        }

        @objc func updateInputViewDurationLabel(_ sender: UIDatePicker) {
          let duration = (sender.inputView as! UIDatePicker).countDownDuration
          parentView.customButton!.setTitle(Coordinator.convertDurationToDisplayString(duration: duration), for: .normal)
        }

        @objc func textFieldDoneButtonPressed(_ sender: AccessoryTextField) {
          parent.duration = (sender.inputView as! UIDatePicker).countDownDuration
          sender.resignFirstResponder()
        }
        @objc func textFieldCancelButtonPressed(_ sender: AccessoryTextField) {
          sender.resignFirstResponder()
        }

    }
}
struct SwiftUISettingsView: View {
  @ObservedObject var observable: SettingsViewObservable
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Schedule Options")) {
          Toggle(isOn: $observable.isCompactMode, label: { Text("Compact Mode") }).onChange(of: observable.isCompactMode) { (_) in
            observable.onToggleCompact()
          }
          Toggle(isOn: $observable.is5MinIncrement, label: { Text("5 minute increments") }).onChange(of: observable.is5MinIncrement) { (_) in
            observable.onToggle5MinIncrement()
          }
        }
        Section(header: Text("Default Times")) {
          DatePicker("Default Start Time", selection: $observable.defaultStartTime, displayedComponents: .hourAndMinute).onChange(of: observable.defaultStartTime) { (_) in
            observable.onChangeStartTime()
          }.environment(\.timeZone, TimeZone(secondsFromGMT: 0)!)
          HStack {
            Text("Default Duration")
            DurationPicker(duration: $observable.defaultDuration, is5MinIncrement: observable.is5MinIncrement).onChange(of: observable.defaultDuration) { (_) in
              observable.onChangeDuration()
            }
          }
        }
      }.navigationBarTitle(Text("Settings"), displayMode: .inline).navigationBarItems(leading: Button("Back", action: observable.dismiss))
    }
  }
}
