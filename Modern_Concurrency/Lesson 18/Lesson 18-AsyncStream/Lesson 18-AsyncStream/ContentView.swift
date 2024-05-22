//
//  ContentView.swift
//  Lesson 18-AsyncStream
//
//  Created by Tejas Patelia on 2024-05-20.
//

import SwiftUI

@MainActor
class AsyncStreamDataManager {
    func generateValues(
        currentValue: @escaping (Int)-> Void,
        onFinish: @escaping (Error?) -> Void
    ) {
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        for value in values {
            DispatchQueue.main.asyncAfter(deadline:.now() + Double(value)) {
                currentValue(value)
                if value == values.last {
                    onFinish(nil)
                }
            }
        }
    }

    func generateValuesUsingAsyncStream() -> AsyncStream<Int> {
        AsyncStream { [weak self] continuation in
            generateValues { intVal in
                continuation.yield(intVal)
            } onFinish: { _ in
                continuation.finish()
            }
        }
    }

    func generateValuesUsingAsyncStreamWithOnFinish() -> AsyncStream<Int> {
        AsyncStream { continuation in
            generateValues { intVal in
                continuation.yield(intVal)
            } onFinish: { _ in
                continuation.finish()
            }
        }
    }

    func generateValuesUsingAsyncStreamWithOnFinishAndError() -> AsyncThrowingStream<Int, Error> {
        AsyncThrowingStream { continuation in
            generateValues { intVal in
                print(intVal)
                continuation.yield(intVal)
            } onFinish: { error in
                continuation.finish(throwing: error)
            }
        }
    }

}
@MainActor
final class AsyncStreamViewModel: ObservableObject {
    let manager = AsyncStreamDataManager()

    @Published var currentValue: Int = 0

    func getFakeData() {
        manager.generateValues { value in
            self.currentValue = value
        } onFinish: { error in
            print(error)
        }
    }

    func tryingToDropFirst2() async {
        for await item in manager.generateValuesUsingAsyncStream().dropFirst(2) {
            print(item)
        }

    }

    func getFakeDataUsingAsyncStream() {
        /// This tasks even if cancelled it will not cancel the ongoing stream.
        /// So there is needs to be separately handled.
        let task = Task {
                //            for await item in manager.generateValuesUsingAsyncStream() {
                //                self.currentValue = item
                //            }
            do {
                for try await item in  manager.generateValuesUsingAsyncStreamWithOnFinishAndError() {
                    await MainActor.run {
                        self.currentValue = item
                    }
                }
            } catch {
               print(error)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("Task Cancelled")
            task.cancel()
        }


    }
}

struct AsyncStreamView: View {

    @StateObject private var viewModel = AsyncStreamViewModel()
    var body: some View {
        VStack {
            Text("\(viewModel.currentValue)")
        }
        .padding()
        .task {
            viewModel.getFakeDataUsingAsyncStream()//getFakeData()
            await viewModel.tryingToDropFirst2()//getFakeData()
        }
    }
}

#Preview {
    AsyncStreamView()
}
