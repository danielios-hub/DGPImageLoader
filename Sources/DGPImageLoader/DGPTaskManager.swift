//
//  DGPTaskManager.swift
//  SocialGaming
//
//  Created by Daniel Gallego Peralta on 16/09/2020.
//  Copyright © 2020 Daniel Gallego Peralta. All rights reserved.
//

import Foundation

class DGPTaskManager: NSObject {
    var tasks : [URL:DGPDataTask]
    let semaphoreRequest : DispatchSemaphore
    let lock : NSLock
    
    override init() {
        tasks = [:]
        lock = NSLock()
        semaphoreRequest = DispatchSemaphore(value: DGPImageLoaderConfig.shared.maxRequestSimultaneous)
        super.init()
    }
    
    func addTask(_ task: URLSessionDataTask, url: URL, options: Set<DGPDownloadOption>, completion: DGPCompletionHandler?) {
        if let currentTask = self.task(for: url) {
            if let completion = completion {
                currentTask.addCallback(block: completion)
            }
        } else {
            lock.lock()
            let modelTask = DGPDataTask(task: task, url: url,
                                        options: options,  completion: completion)
            tasks[url] = modelTask
            lock.unlock()
            semaphoreRequest.wait()
            modelTask.start()
        }
    }
    
    func task(for url: URL) -> DGPDataTask? {
        lock.lock()
        let task = tasks[url]
        lock.unlock()
        return task
    }
    
    func task(for dataTask: URLSessionTask) -> DGPDataTask? {
        guard let url = dataTask.originalRequest?.url else {
            return nil
        }
        
        return task(for: url)
    }
    
    func cancel(for url: URL) {
        if let task = self.task(for: url) {
            lock.lock()
            task.cancel()
            lock.unlock()
        }
    }
    
    func cancelAll() {
        lock.lock()
        tasks.values.forEach {
            $0.cancel()
        }
        lock.unlock()
    }
    
    func removeTask(model: DGPDataTask) {
        lock.lock()
        tasks[model.url] = nil
        lock.unlock()
    }
    
}

extension DGPTaskManager : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let task = task(for: dataTask) {
            task.didReceiveData(data)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        guard let modelTask = self.task(for: task) else {
            return
        }
        
        modelTask.completed(with: error)
        semaphoreRequest.signal()
        removeTask(model: modelTask)
    }
}
