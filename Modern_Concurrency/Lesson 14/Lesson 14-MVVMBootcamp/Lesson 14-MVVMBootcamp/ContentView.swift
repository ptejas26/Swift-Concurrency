//
//  ContentView.swift
//  Lesson 14-MVVMBootcamp
//
//  Created by Tejas on 2024-05-19.
//

import SwiftUI

class MyManamagerClass {
    
    func getData() async throws -> String {
        "Some Data~!"
    }
    
}
actor MyManamagerActor {
    func getData() async throws -> String {
        "Some Data~!"
    }
}

final class MVVMBootcampViewModel: ObservableObject {
    
    private var tasks: [Task<Void, Error>]? = []
    let managerClass = MyManamagerClass()
    let managerActor = MyManamagerActor()
    @MainActor @Published private(set) var myData: String = "Starting text"
    
    /// One way is to mark this method @MainActor and not just the @Published property. On the other hand, another solution is to go within the Task { ..
    @MainActor
    func onCallToActionButtonPressed() {
        /// The issue here was, the try was written inside the Task and Task was declared
        /// Task<Void, Never> whereas the `let task` had a throwing function which result in `error` and therefore to fix this
        /// `1. Either change the declaration to Task<Void, Error> from Task<Void, Void>
        /// `2. Add the throwing function which is marked with try within do catch`
        let task = Task { ///`@MainActor in` is also possible
//            myData = try await managerClass.getData()
            myData = try await managerActor.getData()
            /// From the above code there is no need to write below code
            ///  ```
            ///  let myDataNew = try await managerActor.getData()
            ///  await MainActor.run(body: {  }) ```
            ///  because simply the complier is handling this in background
            ///  UPDATE: Whenever a function call happens on another actor and expects a return value, it automatically gives the return value on the actor the function was called. So No NEED of the above switching to MainActor.
        }
        tasks?.append(task)
    }
    
    func cancelTask() {
        tasks?.forEach({ task in
            task.cancel()
        })
        tasks = []
    }
}

struct ContentView: View {
    
    @StateObject private var viewModel = MVVMBootcampViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text(viewModel.myData)
            Button(viewModel.myData) {
                viewModel.onCallToActionButtonPressed()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
