//
//  ContentView.swift
//  Lesson 1 DoTryCatchThrows
//
//  Created by Tejas on 2024-04-10.
// Covers do try catch and throws and rethrows
import SwiftUI

final class DoTryCatchThrowDataManager {
    let isActive: Bool = true
    
    func getTitle() -> String? {
        if isActive {
            return "New Text"
        } else {
            return nil
        }
    }
}

final class DoTryCatchThrowsViewModel: ObservableObject {
    @Published var title: String = ""
    let manager = DoTryCatchThrowDataManager()
    
    func fetchText() {
        if let newTitle = manager.getTitle() {
            self.title = newTitle
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = DoTryCatchThrowsViewModel()
    
    var body: some View {
        
        Text(viewModel.title)
        .frame(width: 300, height: 300)
        .background(Color.blue)
        .foregroundColor(.white)
        .font(.system(.largeTitle))
        .onTapGesture {
            print("This is executing")
            viewModel.fetchText()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
