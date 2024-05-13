//
//  ContentView.swift
//  Revise-Lesson9
//
//  Created by Tejas on 2024-05-12.
//

import SwiftUI

class MyDataManager {
    static let sharedInstance = MyDataManager()
    private init() { }
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
}

struct HomeView: View {
    let manager = MyDataManager.sharedInstance
    @State private var text: String = ""
    let timer = Timer.publish(every:0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.6).ignoresSafeArea()
            
            Text(text)
        }
        .onReceive(timer) { _ in
//            if let data = text {
//                
//            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            HomeView()
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
