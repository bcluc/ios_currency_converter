//
//  ContentView.swiftTextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
//  CurrencyConverter
//
//  Created by Lucas on 22/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currencies: [String] = []
    @State private var exchangeRates: [String: Double] = [:]
    @State private var fromCurrency: String = ""
    @State private var toCurrency: String = ""
    @State private var inputAmount: String = ""
    @State private var result: Double? = nil
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading currencies...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Form {
                        Section(header: Text("Select Currencies")) {
                            Picker("From", selection: $fromCurrency) {
                                ForEach(currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Picker("To", selection: $toCurrency) {
                                ForEach(currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Section(header: Text("Amount")) {
                            TextField("Enter amount", text: $inputAmount)
                                
                        }
                        
                        Section {
                            Button(action: convertCurrency) {
                                Text("Convert")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        
                        if let result = result {
                            Section(header: Text("Result")) {
                                Text("\(inputAmount) \(fromCurrency) = \(String(format: "%.2f", result)) \(toCurrency)")
                                    .bold()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Currency Converter")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                fetchCurrencies()
            }
        }
    }

    func fetchCurrencies() {
        guard let url = URL(string: Config.apiURL+"?access_key="+Config.apiKey) else {
            self.errorMessage = "Invalid API URL"
            self.isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                    self.showAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                    self.showAlert = true
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let rates = json?["rates"] as? [String: Double] {
                    DispatchQueue.main.async {
                        self.currencies = Array(rates.keys).sorted()
                        self.exchangeRates = rates
                        self.isLoading = false
                        self.fromCurrency = self.currencies.first ?? ""
                        self.toCurrency = self.currencies.first ?? ""
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to parse currency rates"
                        self.isLoading = false
                        self.showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    self.isLoading = false
                    self.showAlert = true
                }
            }
        }.resume()
    }

    func convertCurrency() {
        guard let amount = Double(inputAmount) else {
            self.errorMessage = "Invalid amount entered"
            self.showAlert = true
            return
        }
        
        guard let fromRate = exchangeRates[fromCurrency], let toRate = exchangeRates[toCurrency] else {
            self.errorMessage = "Conversion rates not available"
            self.showAlert = true
            return
        }
        
        let euroAmount = amount / fromRate
        let convertedAmount = euroAmount * toRate
        self.result = convertedAmount
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

