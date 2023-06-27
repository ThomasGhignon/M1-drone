//
//  BLE_object.swift
//  H20-BLE-Server
//
//  Created by GHIGNON Thomas on 27/12/2022.
//

import SwiftUI

struct BLE_object: View {
    var name: String
        var state: String

        var body: some View {
            HStack {
                Text(name)
                Text(state)
            }
        }
}

struct BLE_object_Previews: PreviewProvider {
    static var previews: some View {
        BLE_object()
    }
}
