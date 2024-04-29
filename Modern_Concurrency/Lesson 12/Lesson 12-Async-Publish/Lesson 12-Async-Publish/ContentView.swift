//
//  AsyncPublisherBootcamp.swift
//  Lesson 12-Async-Publish
//
//  Created by Tejas Patelia on 2024-04-25.
//

import SwiftUI
import Combine
import Collections

//struct MyStruct {
//    var myName: String
//}
//
//var myStruct = [MyStruct]()
//myStruct.append(MyStruct(myName: ""))

var cancellable = Set<AnyCancellable>()

class AsyncPublisherDataManager {

    @Published var myData: [String] = []

    func addData() async {

        myData.append("Apple")
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange 2")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")

        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Pineapple")
    }

}

class AsyncPublisherBootcampViewModel: ObservableObject {

    @MainActor @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()

/// Combine version of handling the `Published`
    init() {
        Task {
            await addSubscriber()
        }
    }

    private func addSubscriber() async {
///       This is a combine way of listening to a `@Published` property
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellable)

///      Another way of doing this is using `AsyncPublisher`
///
        await MainActor.run {
            self.dataArray = ["ONE"]
        }

        for await string in manager.$myData.values {
            await MainActor.run {
                self.dataArray = string
            }
            break
        }

        await MainActor.run {
            self.dataArray.append("TWO")
        }

    }

    func start() async {
       let data =  await manager.addData()
//        self.dataArray = data

//        let treeSet = TreeSet<Int>()
//        treeSet.
    }
}

struct AsyncPublisherBootcamp: View {
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { item in
                    Text(item)
                        .font(.headline)
                }
            }
        }
        .padding()
        .task {
            await viewModel.start()
        }
    }
}

#Preview {
    AsyncPublisherBootcamp()
}
