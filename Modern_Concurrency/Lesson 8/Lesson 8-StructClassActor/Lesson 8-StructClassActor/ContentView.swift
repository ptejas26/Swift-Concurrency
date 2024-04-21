//
//  ContentView.swift
//  Lesson 8-StructClassActor
//
//  Created by Tejas Patelia on 2024-04-15.
//
/*
 Links:
 https://blog.onewayfirst.com/ios/posts/2019-03-19-class-vs-struct/
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language
 https://medium.com/@vinayakkini/swift-basics-struct-vs-class-31b44ade28ae
 https://stackoverflow.com/questions/24217586/structure-vs-class-in-swift-language/59219141#59219141
 https://stackoverflow.com/questions/27441456/swift-stack-and-heap-understanding
 https://stackoverflow.com/questions/24232799/why-choose-struct-over-class/24232845
 https://www.backblaze.com/blog/whats-the-diff-programs-processes-and-threads/

 VALUE TYPES:
 - Struct, Enums, Strings, Tuples, Int, etc
 - Stored in Stack
 - Faster compared to Reference Types
 - Thread Safe! [Unless accessing shared resource in async environment]
 - When you assign or pass value types a new copy of data is created

 REFENCE TYPES:
 - Class, Functions, Actors, Closures
 - Stored in Heap
 - Slower, but synchronized
 - Not thread safe
 - When you assign or pass reference type a new reference to the original instance will be created (pointer)
 - - - - - - - - - - - - - - - -
 STACK
 - Stores value types
 - Variables allocated on the stack are stored directly to the memory, and access to this memory is very fast
 - Each thread has it's own stack!

 HEAP
 - Store reference types
 - Shared access across threads!
 - - - - - - - - - - - - - - - -

 STRUCTURE
 - Based on value type
 - Can be mutated
 - Shared across threads!

 CLASS
 - Based on Reference(Instances)
 - Stored in Heap!
 - Inherit from another class
 
 ACTOR
 - Similar to Class, but thread safe
 - No Inheritance

 - - - - - - - - - - - - - - - -
 When to use which struct, class and actor?

 STRUCT: Data Models, SwiftUI Views
 CLASS: ViewModel in SwiftUI because of Observable Object,
 ACTOR: When you have shared resource like SingletonClass or a NetworkManager, that needs to be accessed from different threads.

 */


import SwiftUI
import Distributed


actor StructClassActorBootCampDataManager {

    func fetchNameDataFromServer() -> String {
//        ....
        return "Tejas"
    }
}

final class StructClassActorBootCampViewModel: ObservableObject {
    @Published var myName: String = "Ram"
    private let dataManger: StructClassActorBootCampDataManager = .init()

    func getMyName() async throws {
        let name = await dataManger.fetchNameDataFromServer()
        await MainActor.run {
            self.myName = name
        }
    }
}


// Structs for View
struct StructClassActorBootCamp: View {
    @StateObject private var viewModel = StructClassActorBootCampViewModel()
    var body: some View {
        VStack {
            Text(viewModel.myName)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(.headline)
                .background(Color.red)
        }
        .task {
            try? await viewModel.getMyName()
        }
    }
}
/// --------------  --------------  --------------  --------------
/// Making the tap-able example

class TapableViewModel: ObservableObject {
    init() {
        print("viewModel INIT")
    }
}

struct TapableView: View {
    let isActive: Bool

    @StateObject private var viewModel = TapableViewModel()

    init(isActive: Bool) {
        self.isActive = isActive
        print("View INIT")
    }
    var body: some View {
        Text("Tapable View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .background(isActive ? Color.red : Color.blue)
    }
}

struct TapableParentView: View {
    @State private var isActive: Bool = false
    var body: some View {
        TapableView(isActive: isActive)
            .onTapGesture {
                isActive.toggle()
            }
    }
}

/// --------------  --------------  --------------  --------------
struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            await testFunction()
        }
    }
}

struct MyStruct {
    var title: String
}
struct CustomStruct {
    private(set) var title: String

    init(title: String) {
        self.title = title
    }

    func updateTitle(title: String) -> Self {
        Self(title: title)
    }
}

extension ContentView {

    func testFunction() async {
        print("Test Function")
//        structTest1()
        print("-------")
//        classTest1()
        print("-------")
//        classTest2()
        print("-------")
        await actorTest1()
    }

    private func structTest1() {
        var objectA = MyStruct(title: "Starting struct title!")
        print("ObjectA: ",objectA.title)
        var objectB = objectA
        print("ObjectB before: ",objectB.title)
//        objectB.title = "Second title"
        print("ObjectB after: ",objectB.title)
        withUnsafePointer(to: &objectA) { pointer in
            print("Memory address of objectA: \(pointer)")
        }

        withUnsafePointer(to: &objectB) { pointer in
            print("Memory address of objectB: \(pointer)")
        }

        var customStruct = CustomStruct(title: "Welcome")
        print("Custom Struct \(customStruct.title)")
        customStruct = customStruct.updateTitle(title: "New Value")
        print("Custom Struct - updateTitle \(customStruct.title)")
    }

    private func classTest1() {

        let objectA = MyClass(title: "Starting class title!")
        print("ObjectA: ",objectA.title)
        let objectB = objectA
        print(objectA === objectB)
        print("ObjectB before: ",objectB.title)
        objectB.title = "Object B Title"
        print("ObjectB after: ",objectB.title)
        print("ObjectA after: ",objectA.title)

//        withUnsafePointer(to: &objectA) { pointer in
//            print("Memory address of objectA: \(pointer)")
//        }
        print(objectA === objectB)
//        withUnsafePointer(to: &objectB) { pointer in
//            print("Memory address of objectB: \(pointer)")
//        }
        print(objectA === objectB)
    }
}

class MyClass {
    var title: String

    init(title: String) {
        self.title = title
    }

    func updateTitle(title: String) {
        self.title = title
    }
}


extension ContentView {
    private func classTest2() {
        print("classTest 2")

        let class1 = MyClass(title: "Title1")
        print("Class1: ", class1.title)
        class1.title = "Title2"
        print("Class1: ", class1.title)
        print(" - - -- - - - -  - - - - -")
        let class2 = MyClass(title: "Title1")
        print("Class2: ", class2.title)
        class2.updateTitle(title:"Title2")
        print("Class2: ", class2.title)
    }
}

actor MyActor {
    var title: String

    init(title: String) {
        self.title = title
    }
    func updateTitle(title: String) {
        self.title = title
    }
}

extension ContentView {
    private func actorTest1() async {

        Task {

             ///Await are the potential suspension points for the threads to wait until another
             ///completes its execution, if at all there is not other thread, it will get to access the
             ///resource.
            let objectA = MyActor(title: "Starting Actor title!")
            await print("ObjectA: ",objectA.title)
            let objectB = objectA
            print(objectA === objectB)
            await print("ObjectB before: ",objectB.title)
            await objectB.updateTitle(title: "Object B Title")
            await print("ObjectB after: ",objectB.title)
            await print("ObjectA after: ",objectA.title)
        }
    }
}

#Preview {
    ContentView()
}

