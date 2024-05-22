//
//  ContentView.swift
//  Lesson 19-Observable-Macro
//
//  Created by Tejas Patelia on 2024-05-21.
//

import SwiftUI

actor DataManager {

    func fetchServerData() async -> String {
        "Updated title value"
    }
}

//@MainActor
//final class ObservableMacroBootcampViewModel: ObservableObject {
//
//    @Published var title: String = "initial value"
//    let manager = DataManager()
//
//    func getData() async {
//        let data = await manager.fetchServerData()
//        title = data
//    }
//}


/// Now when its not giving and warning and still it does not give any warning
/// printing the `Thread.current` shows that the thread is background
///
/// THIS WARNING WILL NOT APPEAR IF `OBSERVABLE MACRO` IS USED WHICH IS A PROBLEM, DEVELOPER WILL NEVER KNOW WHAT IS HAPPENING IN THE BACKGROUND
///Publishing changes from background threads is not allowed; make sure to publish values from the main thread (via operators like receive(on:)) on model updates.
///SOLUTIONS:
///1.  Either make `title` working on the main actor and the function that updates the `tile`
///2.
@Observable class ObservableMacroBootcampViewModel {

    @MainActor var title: String = "initial value"
    @ObservationIgnored let manager = DataManager()
// 1.
//    @MainActor
//    func getData() async {
//        let data = await manager.fetchServerData()
//        title = data
//        print(Thread.current)
//    }

// 2.
//    func getData() async {
//        let data = await manager.fetchServerData()
//        await MainActor.run {
//            title = data
//            print(Thread.current)
//        }
//    }

// 3.
    func getData()  {
        Task { @MainActor in
            title = await manager.fetchServerData()
            print(Thread.current)
        }
    }
}

struct ObservableMacroBootcampView: View {

    @State private var viewModel = ObservableMacroBootcampViewModel()
    var body: some View {
        VStack {
            Text(viewModel.title)
                .font(.headline)
        }
        .padding()
        .onAppear {
            viewModel.getData()
        }
    }
}

#Preview {
    ObservableMacroBootcampView()
}
