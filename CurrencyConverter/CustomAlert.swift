//
//  CustomAlert.swift
//  CurrencyConverter
//
//  Created by Lucas on 22/11/24.
//
import SwiftUI

struct CustomAlert: View {
    var message: String
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Error")
                .font(.headline)

            Text(message)
                .font(.body)

            Button("OK") {
                onDismiss()
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxWidth: 300)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

