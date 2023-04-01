//
//  Network.swift
//  Shopping List
//
//  Created by Lucas  Carman  on 3/29/23.
//

import Foundation
import SwiftUI

class Network: ObservableObject {
    @Published var items: [Item] = []
    
    func getItems() {
        guard let url = URL(string: "https://fqdsheotx2.execute-api.us-east-1.amazonaws.com/test") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedItems = try JSONDecoder().decode([Item].self, from: data)
                        print(decodedItems)
                        self.items = decodedItems
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }

}


