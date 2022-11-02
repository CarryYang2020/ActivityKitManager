// Copyright (c) 2022 Alexandre Reol https://github.com/alexandrereol/ActivityKitManager.git

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import ActivityKit

@available(iOS 16.1, *)
class ActivityKitManager {
    
    static var isAllowed: Bool {
        get {
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
    }
    
    static func start<T: ActivityAttributes, C: Codable>(_ startAttributes: T, _ startContentState: C, token: PushType?) {
        do {
            let deliveryActivity = try Activity<T>.request(attributes: startAttributes, contentState: startContentState as! T.ContentState, pushType: token)
            print("[ActivityKitManager] Requested Live Activity with ID -> \(deliveryActivity.id)")
        } catch (let error) {
            print("[ActivityKitManager] Error requesting Live Activity -> \(error.localizedDescription)")
        }
    }
    
    static func update<T: ActivityAttributes, C: Codable>(_ AttributeType: T.Type, _ contentState: C, id: String? = nil) {
        Task {
            guard id != nil else {
                for activity in Activity<T>.activities.filter({$0.activityState == .active}){
                    await activity.update(using: contentState as! T.ContentState)
                }
                return
            }
            for activity in Activity<T>.activities.filter({$0.id == id}) {
                await activity.update(using: contentState as! T.ContentState)
            }
        }
    }
    
    static func getAPNtoken<T: ActivityAttributes>(_ AttributeType: T.Type, id: String? = nil) -> [String: String] {
        var result: [String: String] = [:]
        guard id != nil else {
            for activity in Activity<T>.activities.filter({$0.activityState == .active}) {
                if let token = activity.pushToken?.hexString {
                    result[activity.id] = token
                } else {
                    print("[ActivityKitManager] APN token not (yet) available for ID -> \(activity.id)")
                    print("[ActivityKitManager] Make sure you have passed \".token\" when running start()")
                }
            }
            return result
        }
        if let token = Activity<T>.activities.filter({$0.id == id}).first?.pushToken?.hexString {
            result[id!] = token
            return result
        } else {
            print("[ActivityKitManager] APN token not (yet) available for ID -> \(id!)")
            print("[ActivityKitManager] Make sure you have passed \".token\" when running start()")
        }
        return [:]
    }
    
    static func getState<T: ActivityAttributes>(_ AttributeType: T.Type, id: String) -> ActivityState? {
        return Activity<T>.activities.filter({$0.id == id}).first?.activityState
    }
    
    static func isActive<T: ActivityAttributes>(_ AttributeType: T.Type, id: String) -> Bool {
        return !Activity<T>.activities.filter({$0.activityState == .active && $0.id == id}).isEmpty
    }
    
    static func isDismissed<T: ActivityAttributes>(_ AttributeType: T.Type, id: String) -> Bool {
        return !Activity<T>.activities.filter({$0.activityState == .dismissed && $0.id == id}).isEmpty
    }
    
    static func count<T: ActivityAttributes>(_ AttributeType: T.Type, state: ActivityState = .active) -> Int {
        return Activity<T>.activities.filter({$0.activityState == state}).count
    }
    
    static func stop<T: ActivityAttributes>(_ AttributeType: T.Type, id: String? = nil) {
        Task {
            guard id != nil else {
                for activity in Activity<T>.activities.filter({$0.activityState == .active}){
                    await activity.end(dismissalPolicy: .immediate)
                }
                return
            }
            await Activity<T>.activities.filter({$0.id == id}).first?.end(dismissalPolicy: .immediate)
        }
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
