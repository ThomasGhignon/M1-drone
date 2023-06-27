//
//  NoneTriggerButton.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 08/01/2023.
//

import SwiftUI

struct NoneTriggerButton: View {
    var label: String
    var state: Bool
    
    var body: some View {
        HStack{
            Image(systemName: state ? "checkmark.circle" : "arrow.triangle.2.circlepath")
                .foregroundColor(.white)
            Text("\(label) :")
                .foregroundColor(.white)
            Text(state ? "Passed" : "Waiting")
                .foregroundColor(.white)
        }
        .frame(width: 150, height: 40)
        .background(state ? .blue : Color.gray)
        .cornerRadius(20)
    }
}

struct NoneTriggerButton_Previews: PreviewProvider {
    static var previews: some View {
        NoneTriggerButton(label: "Label", state: true)
    }
}
