//
//  SwiftUISettingsView.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 4/24/23.
//  Copyright © 2023 Old Friend. All rights reserved.
//

import SwiftUI

struct SwiftUISettingsView: View {
  @ObservedObject var observable: SettingsViewObservable
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("display")) {
          Toggle(isOn: $observable.isCompactMode, label: { Text("Compact Mode") }).onChange(of: observable.isCompactMode) { (_) in
            observable.onToggleCompact()
          }
        }
      }.navigationBarTitle(Text("Settings"), displayMode: .inline).navigationBarItems(leading: Button("Back", action: observable.dismiss))
    }
  }
}
