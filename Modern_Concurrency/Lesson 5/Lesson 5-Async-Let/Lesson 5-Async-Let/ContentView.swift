//
//  ContentView.swift
//  Lesson 5-Async-Let
//
//  Created by Tejas on 2024-04-14.
//

import SwiftUI
class AsyncLetViewModel: ObservableObject {
    
}

struct ContentView: View {
    @State private var viewModel = AsyncLetViewModel()
    @State private var images: [UIImage] = []
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    @State var isTextHidden: Bool = true
    @State var errorText: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                if !isTextHidden {
                    VStack {
                        Text(errorText)
                            .font(.headline)
                            .padding()
                        Button("Try Again") {
                            Task {
                                await tryAgain()
                            }
                        }
                    }
                }
                ScrollView {
                    LazyVGrid(columns: column) {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                        }
                    }
                }
            }
            
            .navigationTitle("Async Let 😍")
        }
        .padding()
        .onAppear {
            //images.append(UIImage(systemName: "heart.fill")!)
            Task {
                /// Below block of code executes sequentially, loading one image after the other.
                //                let img1 = try await fetchImages()
                //                images.append(img1)
                //
                //                let img2 = try await fetchImages()
                //                images.append(img2)
                //
                //                let img3 = try await fetchImages()
                //                images.append(img3)
                //
                //                let img4 = try await fetchImages()
                //                images.append(img4)
                //
                //                let img5 = try await fetchImages()
                //                images.append(img5)
                //
                //                let img6 = try await fetchImages()
                //                images.append(img6)
                
                /// ASYNC LET
                
//                async let fetchImg1 = fetchImages()
//                async let fetchImg2 = fetchImages()
//                async let fetchImg3 = fetchImages()
//                async let fetchImg4 = fetchImages()
//                async let fetchImg5 = fetchImages(5)
//                async let fetchImg6 = fetchImages()
//                do {
//                    let (img1, img2, img3, img4, img5, img6) = await (try fetchImg1, try fetchImg2, try fetchImg3, try fetchImg4, try fetchImg5, try fetchImg6)
//                    images.append(contentsOf: [img1, img2, img3, img4, img5, img6])
//                } catch {
//                    errorText = "Some wrong happened \(error.localizedDescription)"
//                    isTextHidden = false
//
//                    print("Some wrong happened \(error.localizedDescription)")
//                }
                
                async let fetchImg11 = fetchImages()
                async let fetchTitle1 = fetchTitle1()
                
                let (img11, title1) = await (try fetchImg11, fetchTitle1)
                print(title1)
            }
        }
    }
    
    func fetchTitle1() async -> String {
        return "New Title"
    }
    
    func tryAgain() async {
        Task {
            print("Try again clicked, call API again")
            if let image = try? await fetchImages() {
                images.append(image)
            }
        }
    }
    
    func fetchImages(_ int: Int = 0) async throws -> UIImage {
        do {
            if int == 5 {
                throw URLError(.badURL)
            }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
