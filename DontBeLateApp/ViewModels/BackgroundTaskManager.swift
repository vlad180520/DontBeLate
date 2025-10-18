//
//  BackgroundTaskManager.swift
//  DontBeLate
//
//  Created on 2025
//

import Foundation
import BackgroundTasks

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private let backgroundTaskIdentifier = "com.dontbelate.eventcheck"
    
    private init() {}
    
    // Register background tasks
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task: task as! BGAppRefreshTask)
        }
    }
    
    // Schedule background refresh
    func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled")
        } catch {
            print("Could not schedule background refresh: \(error.localizedDescription)")
        }
    }
    
    // Handle background task
    private func handleBackgroundTask(task: BGAppRefreshTask) {
        scheduleBackgroundRefresh()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            EventMonitor.shared.checkUpcomingEvents()
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        queue.addOperation(operation)
    }
}

