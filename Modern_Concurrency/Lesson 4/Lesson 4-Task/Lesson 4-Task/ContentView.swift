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
    
    func fetchImage() async throws {
        try? await Task.sleep(seconds: 5)
        do {
            
            guard let url = URL(string: "https://picsum.photos/1000") else {
                return
            }
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            await MainActor.run {
                self.image  = UIImage(data: data)
                print("Image Returned and set to view")
            }
        } catch {
            print(error.localizedDescription)
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
            print(error.localizedDescription)
        }
    }
}

struct TaskBookcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me!") {
                    ContentView()
                }
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
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
        /// this task does the same thing of handling `onAppear` and `onDisAppear` functionality
        /// it does fetchImage on appear and handles the cancel on the disappear
        /// ANOTHER IMPORTANT THING TO NOTE HERE IS:
        /// Task once cancelled does not necessarily cancels the operation, it may still be doing
        /// some work, so you should ideally check for cancellation on a casual basis
        /// https://developer.apple.com/documentation/swift/task
        /// ``` for item in [1, 3, 5, 6, 90] { try await Task.checkCancellation() }```
        ///
        .task {
            try? await viewModel.fetchImage()
        }
//        .onAppear {
//            self.fetchImageTask = Task {
//
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//                await viewModel.fetchImage()
//            }
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//                await viewModel.fetchImage2()
//            }
            
//            Task(priority: .high) {
//                await Task.yield()
//                print("high")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//
//            }
//            Task(priority: .medium) {
//                print("medium")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//            }
//            Task(priority: .low) {
//                print("low")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//            }
//            Task(priority: .background) {
//                print("background")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//            }
//
//            Task(priority: .utility) {
//                print("utility")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//            }
//            Task(priority: .userInitiated) {
//                print("userInitiated")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)
//            }
//            Task {
//                print("Parent")
//                print(Thread.current)
//                print(Task.currentPriority)
//                print(Task.currentPriority.rawValue)

                // Task.detached is the child task that inherits the priority from the parent task.
                // If the priority of the parent task is not specified, the child task will
//                Task.detached {
//                    print("detached")
//                    print(Thread.current)
//                    print(Task.currentPriority)
//                    print(Task.currentPriority.rawValue)
//                }
//            }
//        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TaskBookcampHomeView()
    }
}


extension Task where Success == Never, Failure == Never  {
    static func sleep(seconds: Double) async throws {
        try await Self.sleep(nanoseconds: UInt64((seconds * 1_000_000_000)))
    }
}
