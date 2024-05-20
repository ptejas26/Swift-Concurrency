//
//  ContentView.swift
//  Lesson 15-Refreshable
//
//  Created by Tejas on 2024-05-19.
//

import SwiftUI

final actor RefreshableDataManager {
    
    func getData() async -> [String] {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        return ["Initial String", "second Value", "third Value"]
    }
    
}

@MainActor
final class RefreshableBootcampViewModel: ObservableObject {
    let manager = RefreshableDataManager()
    @Published private(set) var stringArray: [String] = []
    
    func loadData(withRefershableData: String? = nil) async {
        stringArray = await manager.getData()
        if let withRefershableData {
            stringArray.append(withRefershableData)
        }
    }
}

struct ContentView: View {
    
    @StateObject private var viewModel = RefreshableBootcampViewModel()
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.stringArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
            .refreshable {
                await viewModel.loadData(withRefershableData: "Refreshed")
            }
        }
        .task {
            await viewModel.loadData()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
