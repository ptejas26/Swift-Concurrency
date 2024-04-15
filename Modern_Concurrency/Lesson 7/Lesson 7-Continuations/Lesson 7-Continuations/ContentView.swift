//
//  ContentView.swift
//  Lesson 7-Continuations
//
//  Created by Tejas on 2024-04-14.
//

import SwiftUI

class CheckedContinuationDataManager {
    
    let url = "https://picsum.photos/200"
    
    func fetchImagesUsingContinuation() async throws -> UIImage {
        
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, urlResponse, error in
                
                if let data, let uiimage = UIImage(data: data) {
                    continuation.resume(returning: uiimage)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.notConnectedToInternet))
                }
            }.resume()
        }
    }
}

final class CheckedContinuationViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let dataManager = CheckedContinuationDataManager()
    
    func getImageFromServer() async throws {
        let image = try await dataManager.fetchImagesUsingContinuation()
        await MainActor.run {
            self.image = image
        }
    }
    
}

struct ContentView: View {
    @StateObject private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .task {
            try? await viewModel.getImageFromServer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
