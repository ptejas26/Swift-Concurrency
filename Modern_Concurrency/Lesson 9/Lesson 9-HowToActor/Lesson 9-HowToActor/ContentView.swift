//
//  ContentView.swift
//  Lesson 9-HowToActor
//
//  Created by Tejas Patelia on 2024-04-20.
//

import SwiftUI

/// 1. What is the problem that actor are solving?
/// 2. How was this problem solved prior to Actor?
/// 3. Actors can solve the problem.!
///
/// It is going the data race problem ....

class MyDataManger {

    private init() { }
    static let instance = MyDataManger()
    var data: [String] = []

/// This is the solution without using actors to solve the `Data Race Condition` in
/// in swift.
    let queue = DispatchQueue(label: "com.howtoactor.ca")

    func getRandomData(completionHandler: @escaping (_ title: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
//            return self.data.randomElement()
        }
    }
}

struct HomeView: View {
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            DispatchQueue.global(qos: .background).async {
                MyDataManger.instance.getRandomData(completionHandler: { title in
                    if let text = title {
                        DispatchQueue.main.async {
                            self.text = text
                        }
                    }
                })
            }
        })
    }
}
struct BrowseView: View {

    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.orange.opacity(0.3)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            DispatchQueue.global(qos: .background).async {
                MyDataManger.instance.getRandomData(completionHandler: { title in
                    if let text = title {
                        DispatchQueue.main.async {
                            self.text = text
                        }
                    }
                })
            }
        })
    }
}

/// - -- - - - - - - - - - - - - -- - - - - - - - - -
actor MyActorDataManger {

    private init() { }
    static let instance = MyActorDataManger()
    var data: [String] = []

    func getRandomData() ->  String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        return self.data.randomElement()
    }

/// Anytime you want a function or a property that is not to be directly used
/// in the thread safe paradigm then it can be marked as `nonisolated`
    nonisolated let myName: String = "Ram"
    nonisolated func getName() -> String {
        /// Also, you cannot access the isolated methods or properties from non
        /// isolated context, it will throw a compile time error
        /// ```let data = self.getRandomData()```
        return "Tejas"
    }
}

struct HomeActorView: View {
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onAppear {
           // await MyActorDataManger.instance.data
           /// Above can be only used from asynchronous environment
            print(MyActorDataManger.instance.myName)
            print(MyActorDataManger.instance.getName())
        }
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await MyActorDataManger.instance.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        })
    }
}
struct BrowseActorView: View {

    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.orange.opacity(0.3)
                .ignoresSafeArea()
            Text(text)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            Task {
                if let data = await MyActorDataManger.instance.getRandomData() {
                    await MainActor.run {
                        self.text = data
                    }
                }
            }
        })
    }
}


struct HowToActorsBootCamp: View {
//    @StateObject private var viewModel = HowToActorsBootCampViewModel()
    var body: some View {

        TabView {
//            HomeView()
            HomeActorView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
//            BrowseView()
            BrowseActorView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    HowToActorsBootCamp()
}
