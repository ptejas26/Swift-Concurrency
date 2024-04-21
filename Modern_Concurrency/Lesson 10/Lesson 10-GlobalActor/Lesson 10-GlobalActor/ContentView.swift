//
//  ContentView.swift
//  Lesson 10-GlobalActor
//
//  Created by Tejas Patelia on 2024-04-20.
//

import SwiftUI

@globalActor struct MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
//    static let sharedInstance = MyNewDataManager()
//    private init() { }
    func getDataFromDatabase() -> [String] {
        return ["One", "Two", "Three"]
    }

    /// Refresher 😃
    func myNewFunc() async throws -> [UIImage]? {
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in

            var imgArray: [UIImage] = []

            group.addTask {
                UIImage(systemName: "heart.fill")
            }

            group.addTask {
                UIImage(systemName: "heart.fill")
            }
//          not allowed
//            imgArray = try await group.compactMap { $0 }

            for try await item in group {
                if let item  {
                    imgArray.append(item)
                }
            }
            return imgArray
        }
    }

}

class GlobalActorBootCampViewModel: ObservableObject {
    @MainActor @Published var dataArray: [String] = []
    let manager = MyFirstGlobalActor.shared

    func getData() async {
        let data = await manager.getDataFromDatabase()

        await MainActor.run {
            self.dataArray = data
        }
    }
    
    /// Say if you want to add this function to an actor but because it is
    /// not in an actor, you would want to add it to global actor
    /// global actor is a shared place of actor that takes/accepts
    /// properties or functions as part of it.
    /// Step 1: Make a struct with `@globalActor`
    /// Step 2: Create its `shared` property and it should be provided with
    /// an `actor` type as instantiation say `let shared = MySampleActor()`
    /// then mark the said function [to whom you want to add to global actor]
    /// with `@NameOfSTruct` before calling function.
    /// ```
    ///
    /// @globalAction struct MyGlobalActor {
    ///         static var shared = MySampleActor()
    /// }
    ///
    /// actor MySampleActor {
    ///
    /// }
    ///
    /// class SomeClass {
    ///      // Now this function will be added to global Action
    ///     @MyGlobalActor func someFunction() {
    ///
    ///     }
    /// }
    /// ```
    /// Once `someFunction` starts participating in`globalActor` it will be a candidate
    /// as async function, making its caller to `await someFunction()`
    ///
    ///
    /*As an iOS developer creating a `@globalActor` attribute in Swift, you need to consider several factors to determine whether to use a class, struct, or actor. Let's evaluate each option in the context of creating a global actor:

    1. **Class**:
    - **Use Case**: If you need shared mutable state that is accessed and mutated by multiple concurrent tasks, and you want changes to the state to be visible across all references, a class-based global actor might be appropriate.
    - **Example**: If you're creating a global actor to manage a shared cache or database connection that needs to be accessed and updated by different parts of your application concurrently, a class-based global actor could be suitable.

    2. **Struct**:
    - **Use Case**: If you prefer value semantics and want to ensure that the state is copied when passed between different parts of your application, and you don't need shared mutability, a struct-based global actor might be suitable.
    - **Example**: If you're creating a global actor to manage immutable configuration settings or state that doesn't need to be shared and mutated across different parts of your application, a struct-based global actor could be appropriate.

    3. **Actor**:
    - **Use Case**: If you need to enforce exclusive access to mutable state in a concurrent environment and want to protect against data races, an actor-based global actor is the most appropriate choice.
    - **Example**: If you're creating a global actor to manage a shared resource or state that needs to be accessed and mutated by multiple concurrent tasks, and you want to ensure that access to the state is serialized to prevent data races, an actor-based global actor would be the best option.

    In summary, the choice between class, struct, and actor for creating a `@globalActor` attribute in Swift depends on your application's requirements for reference vs. value semantics, the need for concurrent access to mutable state, and whether you want to protect against data races. If you need shared mutable state with reference semantics, use a class-based global actor. If you prefer isolated state with value semantics, use a struct-based global actor. If you require exclusive access to mutable state in a concurrent environment, use an actor-based global actor.
     */

    @MyFirstGlobalActor
///   Similar to a `@globalActor` any class, function or properties can be marked as`@MainActor`
///   Which will allow them to be isolated to the `MainActor`.
///   IF a class is marked as MainActor Class then everything within that class becomes isolated to `@MainActor`
///   and in case you want to remove isolation to a method or properties use `nonisolated` keyword
    func myHeavyOperationFunction() {
        /// Some heavy operation
        /// ...... ......
        ///
        Task {
            let data = await manager.getDataFromDatabase() + ["Five", "Seven", "And So on"]
            await MainActor.run {
                self.dataArray = data
            }
        }
    }
}
/// -- - - - - --  - - - --- - -- -
@MainActor struct MyStruct {
    nonisolated var string: String {
        return ""
    }

    nonisolated lazy var myRandomString: String = {
        if let string = ["Ram", "Shyam", "Gopal"].randomElement() {
            return string
        }
        return ""
    }()

    nonisolated static let myStaticString: String = {
        return "MySTatic nonisolated computed property"
    }()

    nonisolated static let myStaticString1: String = "MySTatic nonisolated computed property"

    /// `ERROR` 'nonisolated' can not be applied to stored properties
    /// nonisolated var myRandomValue: String = "This is random"
}

struct GlobalActorBootCamp: View {
    @StateObject private var viewModel = GlobalActorBootCampViewModel()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .padding(5)
                }
            }
            .scenePadding(.top)
        }
        .task {
//            await viewModel.getData()
            await viewModel.myHeavyOperationFunction()
        }
    }
}

#Preview {
    GlobalActorBootCamp()
}
