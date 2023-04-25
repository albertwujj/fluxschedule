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

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .countDownTimer
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.updateDuration), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ datePicker: UIDatePicker, context: Context) {
        datePicker.countDownDuration = duration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        let parent: DurationPicker

        init(_ parent: DurationPicker) {
            self.parent = parent
        }

        @objc func updateDuration(datePicker: UIDatePicker) {
            parent.duration = datePicker.countDownDuration
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
          }.environment(\.timeZone, TimeZone(secondsFromGMT: 0)!).datePickerStyle(.wheel)
          HStack {
            Text("Default Duration")
            DurationPicker(duration: $observable.defaultDuration).onChange(of: observable.defaultDuration) { (_) in
              observable.onChangeDuration()
            }
          }
        }
      }.navigationBarTitle(Text("Settings"), displayMode: .inline).navigationBarItems(leading: Button("Back", action: observable.dismiss))
    }
  }
}
