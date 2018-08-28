//
//  AsyncSwift.swift
//  AsyncSwift
//
//  Created by Dustin Simpson on 8/27/18.
//

import Foundation

public class AsyncSwift {
    public init() {
        
    }
    
    public func series(_ fArray: [(@escaping (Bool, Any)->Void)->Void], _ fCallback: @escaping (Bool, [Any])->Void) {
        var finalResults: [Any] = []
        let dGroup = DispatchGroup()
        var workItems: [DispatchWorkItem] = []
        var wasErrorInProcess = false;
        
        
        let dQueue = DispatchQueue(label: "AsyncSwift", qos: .userInitiated)
        
        let semaphore = DispatchSemaphore(value: 0)
        var funcCounter:Int = 0
        for theFunc in fArray {
            dGroup.enter()
            let workItem = DispatchWorkItem {
                
                theFunc({(isError, data) in
                    funcCounter = funcCounter + 1
                    print("this many functions: \(workItems.count)")
                    finalResults.append(data)
                    print("here")
                    if isError {
                        wasErrorInProcess = true
                        for i in funcCounter...workItems.count-1 {
                            workItems[i].cancel()
                            dGroup.leave()
                        }
                    }
                    semaphore.signal()
                    dGroup.leave()
                })
                _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            }
            workItems.append(workItem)
            dQueue.async(execute: workItem)
        }
        dGroup.notify(queue: .main) {
            fCallback(wasErrorInProcess, finalResults)
        }
        
    }
    
}
