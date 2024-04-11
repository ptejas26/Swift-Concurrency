//
//  ContentView.swift
//  Lesson3-UsingAsynAwait
//
//  Created by Tejas on 2024-04-10.
//

import SwiftUI

final class UsingAsyncAwaitViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("Tile1: \(Thread.current)")
        }
    }
    
    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            
            let title = "Title2: \(Thread.current)"
            DispatchQueue.main.async {
                self.dataArray.append(title)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.dataArray.append("Tile3: \(Thread.current)")
        }
    }
    
    func addAuthor1() async {
        // Unless the MainActor.run is used the code may or may not run on the main thread.
        // Writing `Thread.current` will lead to crashes and inconsistent behavior
        await MainActor.run {
            let author1 = "Author1: \(Thread.current)"
            self.dataArray.append(author1)
        }
        /// Sometime the async tasks will jump on background thread and sometimes not.
        try? await doSomething() // Task.sleep(nanoseconds: 3_000_000_000)
        let author2 = "Author2: \(Thread.current)"
        
        await MainActor.run {
            self.dataArray.append(author2)
            
            let author3 = "Author3: \(Thread.current)"
            self.dataArray.append(author3)
        }
    }
    
    func doSomething() async throws {
        print("doSomething")
    }
}

struct ContentView: View {
    @StateObject private var viewModel = UsingAsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) {
                data in
                Text(data)
            }
        }
        .padding()
        .onAppear {
            Task {
               await viewModel.addAuthor1()
            }
//            viewModel.addTitle1()
//            viewModel.addTitle2()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
