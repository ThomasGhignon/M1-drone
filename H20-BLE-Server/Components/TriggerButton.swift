//
//  triggerButton.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 08/01/2023.
//

import SwiftUI

struct TriggerButton: View {
    var label: String
    var state: Bool
    var desc: String
    var type: String = ""
    var action: () -> Void
    
    var body: some View {
        VStack{
            Text(label)
                .foregroundColor(.white)
            
            Button {
                self.action()
            } label: {
                if type != "" {
                    Image(systemName: "ellipsis.circle")
                } else {
                    Image(systemName: "restart")
                        .rotationEffect(Angle(degrees: 180))
                }
                Text(type == "" ? state ? "restart" : "start" : type)
            }.cornerRadius(200)
            Text(desc)
        }
        .frame(width: 150, height: 150)
        .background(state ? .blue : Color.gray)
        .cornerRadius(20)
    }
}

struct TriggerButton_Previews: PreviewProvider {
    static var previews: some View {
        TriggerButton(label: "Label", state: false, desc: "Test de desc", type: "UUID", action: {})
    }
}
