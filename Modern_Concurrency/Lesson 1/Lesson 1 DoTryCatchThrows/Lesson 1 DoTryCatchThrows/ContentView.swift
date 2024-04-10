//
//  ContentView.swift
//  Lesson 1 DoTryCatchThrows
//
//  Created by Tejas on 2024-04-10.
//

import SwiftUI

final class DoTryCatchThrowDataManager {
    let isActive: Bool = false
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("New Text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New Text 2")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitle3() throws -> String {
        if isActive {
            return "New Text 3"
        } else {
            throw URLError(.badURL)
        }
    }
}

final class DoTryCatchThrowsViewModel: ObservableObject {
    @Published var title: String = ""
    let manager = DoTryCatchThrowDataManager()
    
    func fetchText() {
//        1
//        if let newTitle = manager.getTitle().title {
//            self.title = newTitle
//        } else if let error = manager.getTitle().error {
//            self.title = error.localizedDescription
//        }
        
//        2
//        let result = manager.getTitle2()
//        var title: String
//        switch result {
//        case .success(let strTitle):
//            title = strTitle
//        case .failure(let error):
//            title = error.localizedDescription
//        }
//        self.title = title
        
//        3
        do {
            let title = try manager.getTitle3()
            print("When error is thrown, it will not even run this line")
            self.title = title
        } catch {
            self.title = error.localizedDescription
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
