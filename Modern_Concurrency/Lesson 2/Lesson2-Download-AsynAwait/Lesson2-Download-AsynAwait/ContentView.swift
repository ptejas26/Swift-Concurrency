//
//  ContentView.swift
//  Lesson2-Download-AsynAwait
//
//  Created by Tejas on 2024-04-10.
//

import SwiftUI
import Combine

final class DownloadImageAsynAwaitManager {
    
    let imageURL: URL = URL(string: "https://picsum.photos/seed/picsum/100/100")!
    
    func downloadUsingEscaping(completionHandler: @escaping (UIImage?, Error?) -> ())  {
        
        URLSession.shared.dataTask(with: URLRequest(url: imageURL)) { responseData, urlResponse, responseError in
            guard let data = responseData,
                  let image = UIImage(data: data),
                  let response = urlResponse as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                completionHandler(nil, URLError(.badURL))
                return
            }
            completionHandler(image, nil)
        }
        .resume()
    }
    
    func downloadUsingCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: imageURL)
            .map({ (data, response) in
                UIImage(data: data)
            })
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    func downloadUsingAsyncAwait() async throws -> UIImage? {
        do {
            let (imageData, _) = try await URLSession.shared.data(for: URLRequest(url: imageURL))
            guard let image = UIImage(data: imageData) else {
                return nil
            }
            return image
        } catch {
            throw error
        }
    }
}


final class AsynAwaitViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let manager = DownloadImageAsynAwaitManager()
    var cancelableSet = Set<AnyCancellable>()
    
    func fetchImage() {
        manager.downloadUsingEscaping { [weak self] image, error in
            guard let image else {
                return
            }
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    func fetchImageUsingCombine() {
        manager.downloadUsingCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { image in
                self.image = image
            }
            .store(in: &cancelableSet)
    }
    
    func fetchImageUsingAsyncAwait() async throws {
        let image = try? await manager.downloadUsingAsyncAwait()
        await MainActor.run {
            self.image = image
        }
    }
}

struct ContentView: View {
    
    @StateObject private var viewModel =  AsynAwaitViewModel()
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            }
        }
        .onAppear {
//            viewModel.fetchImage()
//            viewModel.fetchImageUsingCombine()
            Task {
                try? await viewModel.fetchImageUsingAsyncAwait()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
