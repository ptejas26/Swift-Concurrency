//
//  SendableBootcamp.swift
//  Lesson 11-Senable
//
//  Created by Tejas Patelia on 2024-04-21.
//

import SwiftUI

actor CurrentUserManager {
    
    func fetchDataFromDatabase(userInfo: MyClassUserInfo) {

    }
}

/// Because this is struct, it is already thread safe and therefore `Sendable`.
/// Explicitly marking it `Sendable` it gets some performance benefits.
struct UserInfo: Sendable {
    let name: String
}

final class MyClassUserInfo: @unchecked Sendable {
    /// As soon as you make it variable, the complier
    /// complaints `Stored property 'name' of 'Sendable'-conforming class 'MyClassUserInfo' is mutable. To solve this problem, mark it @unchecked Sendable
    private var name: String
    let queue = DispatchQueue(label: "com.Sendable.MyClassUserInfo")

    init(name: String) {
        self.name = name
    }
    func updateName(name: String) {
        /// This avoids the data race condition within the class
        queue.async {
            self.name = name
        }
    }
}


final class SendableBootcampViewModel: ObservableObject {

    let manager = CurrentUserManager()

    func updateCurrentUserInfo() async {
//        let userInfo = "USER Info"
        await manager.fetchDataFromDatabase(userInfo: MyClassUserInfo(name: "User info"))
    }
}

struct SendableBootcamp: View {
    @ObservedObject private var viewModel = SendableBootcampViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    SendableBootcamp()
}
