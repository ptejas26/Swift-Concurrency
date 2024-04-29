import UIKit

let input: [Int] = [-1, 1, -6, 4, 5, -6, 1, 4, 1]
let output: [Int] = [5, -1, 4, 4, -6, -6, 1, 1, 1]


func solution(input: [Int]) -> [Int] {
    var dic = Dictionary<Int, Int>()

    for item in input {
        if let value = dic[item] {
            dic[item] = value + 1
        } else {
            dic[item] = 1
        }
    }
    print(dic)
    let newDic = dic.sorted { $0.value < $1.value }

    print(newDic)

    var result: [Int] = []
    var lastKey: Int = .min
    var lastVal: Int = .min
    for (key, value) in newDic {
        if lastVal == value {
            if lastKey >= key {
                result.append(lastKey)
            } else {
                result.append(key)
            }
        } else {
            result.append(key)
        }
        lastKey = key
        lastVal = value
    }


    return result
}

print(solution(input: input))
