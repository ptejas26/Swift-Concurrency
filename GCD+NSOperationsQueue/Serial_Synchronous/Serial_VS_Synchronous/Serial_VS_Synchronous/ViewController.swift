//
//  ViewController.swift
//  Serial_VS_Synchronous
//
//  Created by Tejas on 2024-04-10.
//

import UIKit

final class ViewController: UIViewController {
    
    
    // Example function to simulate synchronous operation
    func synchronousOperation() {
        print("Starting synchronous operation")
        sleep(2) // Simulate a time-consuming task (blocking operation)
        print("Synchronous operation completed")
    }
    
    // Example function to simulate serial execution
    func serialExecution() {
        print("Task 1 started")
        sleep(1) // Simulate a task taking some time
        print("Task 1 completed")
        
        print("Task 2 started")
        sleep(1) // Simulate another task
        print("Task 2 completed")
        
        print("Task 3 started")
        sleep(1) // Simulate yet another task
        print("Task 3 completed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Synchronous operation example
        print("Before synchronous operation")
        synchronousOperation()
        print("After synchronous operation")
        
        // Serial execution example
        print("Before serial execution")
        serialExecution()
        print("After serial execution")
    }
    
    /*
     Explanation:
     synchronousOperation(): This function represents a synchronous operation. It starts by printing a message, then simulates a time-consuming task using sleep(2) for 2 seconds. While this operation is ongoing, the program waits, and only after it completes does it print the completion message.
     
     serialExecution(): This function demonstrates serial execution. It consists of three tasks (Task 1, Task 2, and Task 3). Each task starts by printing a message, then simulates some work using sleep(1) for 1 second. Each task completes before the next one starts, maintaining a specific order of execution.
     
     In both examples, you'll see how synchronous operations block the program's execution until they complete, while serial execution ensures tasks are performed sequentially, one after the other.
     */
}

