//
//  ItemList.swift
//  Shopping List
//
//  Created by Lucas  Carman  on 3/27/23.
//

import SwiftUI

struct ItemList: View {
    @ObservedObject var itemData = ItemData()
    @State var needRefresh: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color("Olivine"), Color("BlackHaze"), Color("Olivine")]),
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                List(itemData.items, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(item.id)")
                                .font(.headline)
                            Text(item.itemname)
                                .font(.subheadline)
                        }
                        VStack(alignment: .trailing) {
                            Text(item.itemname)
                                .font(.headline)
                            Text(item.comment)
                                .font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            // remove the item from your backend
                            loadDataForItemId(itemid: item.id)
                            
                            // remove the item from the itemData.items array
                            if let index = itemData.items.firstIndex(where: { $0.id == item.id }) {
                                itemData.items.remove(at: index)
                            }
                        }) {
                            Image(systemName: "trash.circle")
                                .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .onAppear(perform: loadData)
        }
            .accentColor(.white)
    }
    
    func loadData() {
        guard let url = URL(string: "https://fqdsheotx2.execute-api.us-east-1.amazonaws.com/test/getitems") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Item].self, from: data) {
                    DispatchQueue.main.async {
                        self.itemData.items = decodedResponse
                    }
                    return
                }
            }
            
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
    
    func loadDataForItemId(itemid: Int) {
        let url = URL(string: "https://fqdsheotx2.execute-api.us-east-1.amazonaws.com/test/deleteItemFromList")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "itemid": "\(itemid)"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if response.statusCode == 200 {
                print("Request sent successfully")
            } else {
                print("Error: status code \(response.statusCode)")
            }
        }
        task.resume()
    }
}

class ItemData: ObservableObject {
    @Published var items = [Item]()
}

struct Item: Codable, Identifiable {
    let id: Int
    let itemname: String
    let quantity: Int
    let unit: String
    let comment: String
    
    struct ItemList_Previews: PreviewProvider {
        static var previews: some View {
            ItemList()
            
        }
    }
}
