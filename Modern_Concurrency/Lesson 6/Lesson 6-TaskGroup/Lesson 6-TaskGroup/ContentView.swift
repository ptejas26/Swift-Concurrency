//
//  ContentView.swift
//  Lesson 6-TaskGroup
//
//  Created by Tejas on 2024-04-14.
//

import SwiftUI

class TaskGroupBootCampDataManager {
    let url = "https://picsum.photos/200"
    
    func fetchImageWithAsyncLet() async throws -> [UIImage]? {
        async let fetchImg1 = fetchImages(urlString: url)
        async let fetchImg2 = fetchImages(urlString: url)
        
        do {
            let (img1, img2) = await(try fetchImg1, try fetchImg2)
            return [img1, img2]
            //            if
            //            } else {
            //                throw URLError(.badServerResponse)
            //            }
        } catch {
            throw error
            print("Error occured \(error.localizedDescription)")
        }
    }
    
    func fetchImages(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            }
            throw URLError(.badURL)
        } catch  {
            print(error.localizedDescription)
        }
        throw URLError(.badServerResponse)
    }
}

class TaskGroupBootCampViewModel: ObservableObject {
    let manager = TaskGroupBootCampDataManager()

    @Published var images: [UIImage] = []
    
    func getImages() async throws {
        
        do {
            if let images = try await manager.fetchImageWithAsyncLet() {
                self.images.append(contentsOf: images)
            } else {
                throw URLError(.cancelled)
            }
        } catch {
            throw error
        }
    }
    
}

struct ContentView: View {
    
    @StateObject private var viewModel = TaskGroupBootCampViewModel()
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    

    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Task Group 😜😇")
            .task {
                do {
                    try await viewModel.getImages()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
