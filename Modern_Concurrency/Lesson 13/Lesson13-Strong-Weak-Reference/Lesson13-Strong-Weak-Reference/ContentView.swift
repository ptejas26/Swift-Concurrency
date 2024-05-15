//
//  ContentView.swift
//  Lesson13-Strong-Weak-Reference
//
//  Created by Tejas on 2024-05-12.
//

import SwiftUI

final class StrongWeakDataManager {
    
    func getData() async -> String {
        return "Final Data"
    }

}

final class StrongWeakViewModel: ObservableObject {
    
    @Published var text: String = "Initial String!"
    var someTask: Task<Void, Never>? = nil
    var tasks: [Task<Void, Never>] = []
    
    
    let manager = StrongWeakDataManager()
    
    /// Strong `self` is implied here
    func fetchData1() {
        Task {
            text = await manager.getData()
        }
    }
    
    /// Strong `self` is not implied but explicity mentioned here
    func fetchData2() {
        Task {
            self.text = await self.manager.getData()
        }
    }
    
    /// Strong `self` explicity mentioned here
    func fetchData3() {
        Task { [self] in
            let text = await self.manager.getData()
            self.text = text
        }
    }
    
    /// Strong `weak self` explicity mentioned here
    func fetchData4() {
        Task { [weak self] in
            self?.text = await self?.manager.getData() ?? "N/A"
            
        }
    }
    
    /// Taking a refernce to the Task to cancel it at a later point
    func fetchData5() {
        self.someTask = Task {
            text = await manager.getData()
        }
    }
    
    /// Using multiple tasks and adding them to the array to be canceled when not in use
    func fetchData6() {
        let task1 = Task {
            self.text = await self.manager.getData()
        }
        self.tasks.append(task1)
        
        let task2 = Task {
            self.text = await self.manager.getData()
        }
        self.tasks.append(task2)
        
        let task3 = Task {
            self.text = await self.manager.getData()
        }
        self.tasks.append(task3)
        
        let task4 = Task {
            self.text = await self.manager.getData()
        }
        self.tasks.append(task4)
    }

    /// purposely making the `Task` as `Strong` reference and using `Detached` which is not encouraged by Apple. Do not cancel tasks to keep Strong refence
    func fetchData8() {
        Task {
            self.text = await self.manager.getData()
        }
        
        Task.detached { [self] in
            self.text = await self.manager.getData()
        }
    }
    
    func fetchData9() async {
        text = await manager.getData()
    }
    
    func cancelTasks() {
        someTask?.cancel()
        
        tasks.forEach { $0.cancel() }
        tasks = []
    }
}

struct StrongWeakView: View {
    
    @StateObject private var viewModel = StrongWeakViewModel()
    
    var body: some View {
        VStack {
            Text(viewModel.text)
        }
        .padding()
        .onAppear {
            viewModel.fetchData1()
        }
        .onDisappear {
            viewModel.cancelTasks()
        }
        .task {
            await viewModel.fetchData9()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StrongWeakView()
    }
}
