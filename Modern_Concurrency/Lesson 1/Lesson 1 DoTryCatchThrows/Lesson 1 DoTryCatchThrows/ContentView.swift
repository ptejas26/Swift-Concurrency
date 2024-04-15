//
//  ContentView.swift
//  Lesson 1 DoTryCatchThrows
//
//  Created by Tejas on 2024-04-10.
//

import SwiftUI

final class DoTryCatchThrowDataManager {
    let isActive: Bool = true
    
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
    
    func getTitle4() throws -> String {
        if false {
            return "FINAL TEXT"
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    func getTitle5() throws -> String {
        if isActive {
            return "THIS WILL NEVER BE EXECUTING"
        } else {
            throw URLError(.backgroundSessionRequiresSharedContainer)
        }
    }
    
    typealias CompletionBlock = (Int) throws ->  Int
    func getTitle6(intValue: Int, completionBlock: ((Int) throws -> Int)?) rethrows -> Int? {
        do {
            if let value = try completionBlock?(intValue) {
                return value
            }
            throw URLError(.badURL)
        } catch {
            
        }
        return nil
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
            
            if let title4 = try? manager.getTitle4() {
                self.title = title4
                print("Setting title 4")
            }
            
            // This will execute even if the getTitle4 is throwing error, because it is marked as try?
            let title5 = try manager.getTitle5()
            self.title = title5 ?? "NA"
            print("Setting title 5")
            
//            let normalTitle = manager.getTitle6(intValue: 4, completionBlock: <#T##DoTryCatchThrowDataManager.CompletionBlock?##DoTryCatchThrowDataManager.CompletionBlock?##(Int) throws -> Int#>)
                //Optional<() throws -> Int>
            let normalTitle = try manager.getTitle6(intValue: 5) { value throws -> Int in
                return 51 + value
            }
            print(normalTitle)
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
