import UIKit

//enum NumberError: Error {
//    case nanError
//    case infinityError
//
//    var localizedDescription1: String {
//        switch self {
//        case .nanError:
//            return "This is not a number buddy"
//        case .infinityError:
//            return "Value is infinity and therefore not my fault"
//        }
//    }
//}
//
//func test1() throws -> Int? {
//    if !(6.7).isNaN {
//        throw NumberError.nanError
//    } else {
//        return 2
//    }
//}
//
//do {
//    let value = try test1()
//    print(value)
//} catch {
//    print(error)
//
//    if let error1 = error as? NumberError {
//        print(error1.localizedDescription1)
//        print(error1.localizedDescription1)
//        print(error)
//    }
//}



// Not much IMP
//enum MyError: Error {
//    case someError
//}
//
//struct CustomError: LocalizedError {
//    var errorDescription: String? {
//        return NSLocalizedString("An error occurred.", comment: "")
//    }
//
//    var localizedFailureReason: String? {
//        return NSLocalizedString("The operation failed due to some reason.", comment: "")
//    }
//
//    var recoverySuggestion: String? {
//        return NSLocalizedString("Please try again later.", comment: "")
//    }
//}
//
//func doSomething() throws {
//    throw CustomError()
//}
//
//do {
//    try doSomething()
//} catch {
//    if let error = error as? CustomError {
//        print(error.localizedDescription) // Prints: An error occurred.
//        print(error.localizedFailureReason) // Prints: The operation failed due to some reason.
//        print(error.recoverySuggestion) // Prints: Please try again later.
//
//    }
//
//}


// My Rethrows Example from the main project
//
typealias CompletionBlock = (() throws -> Void)?

func getTitle(firstValue: Int, completion: CompletionBlock) throws -> Int? {
    return 30 + firstValue
}
try getTitle(firstValue: 40, completion: nil) // 70


typealias CompletionBlock1 = (Int) throws ->  Int
func getTitle1(intValue: Int, completionBlock: CompletionBlock1?) rethrows -> Int? {
    do {
        if let value = try completionBlock?(intValue) {
            return value
        }
        throw URLError(.badURL)
    } catch {
        
    }
    return nil
}

let normalTitle = try getTitle1(intValue: 5) { value throws -> Int in
    return 51 + value
}
print(normalTitle)


// Example from ChatGPT
enum CustomError: Error {
    case someError
}

func divide(_ a: Int, by b: Int) throws -> Int {
    guard b != 0 else {
        throw CustomError.someError
    }
    return a / b
}

func processNumbers(_ numbers: [Int], using closure: (Int, Int) throws -> Int) rethrows -> [Int] {
    
    var results = [Int]()
    for i in 0..<numbers.count - 1 {
        do {
            let result = try closure(numbers[i], numbers[i+1])
            results.append(result)
        } catch {
            // Handle error
            print("Error occurred: \(error)")
        }
    }
    return results
}

let numbers = [10, 5, 0, 4]

do {
    let results = try processNumbers(numbers, using: divide)
    print("Results: \(results)")
} catch {
    print("Error processing numbers: \(error)")
}
