//
//  ActionButtonComponent.swift
//  Storybook
//
//  Created by Borut Tomazin on 23/01/2023.
//

import SwiftUI
import PovioKitUI

struct ActionButtonComponentView: View {
  var body: some View {
    List {
      Section("Regular Button") {
        ActionButton()
          .title("Regular button")
          .frame(height: 48)
      }.listRowSeparator(.hidden)
      
      Section("Button with Title Image") {
        ActionButton()
          .title("Button with Left Title Image")
          .titleLeftImage(.init(image: Image(systemName: "plus"),
                                size: .init(width: 15, height: 15)))
          .frame(height: 48)
        ActionButton()
          .title("Button with Right Title Image")
          .titleRightImage(.init(image: Image(systemName: "plus"),
                                 size: .init(width: 15, height: 15)))
          .frame(height: 48)
      }.listRowSeparator(.hidden)
      
      Section("Button with Left/Right Image") {
        ActionButton()
          .title("Button with Left Image")
          .leftImage(.init(image: Image(systemName: "airplane.circle"),
                           size: .init(width: 30, height: 30)))
          .frame(height: 48)
        ActionButton()
          .title("Button with Right Image")
          .rightImage(.init(image: Image(systemName: "airplane.circle"),
                            size: .init(width: 30, height: 30)))
          .frame(height: 48)
      }.listRowSeparator(.hidden)
      
      Section("Small buttons") {
        ActionButton()
          .title("Regular small Button")
          .frame(height: 32)
        ActionButton()
          .title("Small Button with Left Image")
          .leftImage(.init(image: Image(systemName: "airplane.circle"),
                           size: .init(width: 20, height: 20)))
          .frame(height: 32)
      }.listRowSeparator(.hidden)
      
      Section("Custom Buttons") {
        ActionButton()
          .title("Outlined Button")
          .textColor(.primary)
          .backgroundType(.plain(.white))
          .borderColor(.secondary)
          .borderWidth(1)
          .frame(height: 48)
        ActionButton()
          .title("Custom corner radius Button")
          .borderColor(.secondary)
          .borderWidth(1)
          .cornerRadius(.custom(4))
          .frame(height: 48)
        ActionButton()
          .title("Disabled Button")
          .borderColor(.secondary)
          .borderWidth(1)
          .cornerRadius(.custom(4))
          .frame(height: 48)
          .disabled(true)
      }.listRowSeparator(.hidden)
    }
  }
}

struct ActionButtonComponentView_Previews: PreviewProvider {
  static var previews: some View {
    ActionButtonComponentView()
  }
}
