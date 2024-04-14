//
//  ContentView.swift
//  Lesson 4-Task
//
//  Created by Tejas on 2024-04-14.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {

        do {
            
            guard let url = URL(string: "https://picsum.photos/1000") else {
                return
            }
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            
            self.image  = UIImage(data: data)
            
        } catch {
            
        }
    }
    
    func fetchImage2() async {
        
        do {
            
            guard let url = URL(string: "https://picsum.photos/1000") else {
                return
            }
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            
            self.image2  = UIImage(data: data)
            
        } catch {
            
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskBootcampViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchImage()
            }
            Task {
                await viewModel.fetchImage2()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
