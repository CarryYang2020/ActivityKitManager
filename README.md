# ActivityKitManager

## Installation

Can be installed on any iOS project, ActivityKit requires iOS 16.1 (or above) to work.

You can integrate manually by putting  `ActivityKitManager.swift`  in your Xcode project. Make sure to enable `Copy items if needed` and `Create groups`.

## Quick Start into Live Activities

1. Add the `Push Notifications` capability to your iOS target.

<img src="https://public.reol.ch/ActivityKitManager/step1.png" width="600"/>

2. Add a `Widget Extension` target to your project and name it. For this quick start, we will name it `ExampleLA`

<img src="https://public.reol.ch/ActivityKitManager/step2.png" width="600"/>

3. Delete the `ExampleLA.swift` and `ExampleLABundle.swift` files.
4. Replace the content of `ExampleLALiveActivity.swift` with:

```swift 
import ActivityKit
import WidgetKit
import SwiftUI

struct  ExampleAttributes: ActivityAttributes {
    public  typealias  LiveWidgetStatus = ContentState

    var var1: String
    // here are static variable, defined *once* when initializing the Live Activity

    public struct ContentState: Codable, Hashable {
        var var2: String
        // here are variable dependend on a state, i.e. will be modified
        // modification can happen locally or through APNs (thus the Codable/Hashable)
    }
}

@main
struct Widgets: WidgetBundle {
    var body: some Widget {
        if #available(iOSApplicationExtension 16.1, *) {
            ActivityKitWidget()
        }
    }
}

struct ActivityKitView : View {
    
    var var1: String
    var var2: String
    
    var body: some View {
        VStack{
            Text("Hello World!")
            Text("Variable 1: \(var1)")
            Text("Variable 2: \(var2)")
        }
    }
}

@available(iOSApplicationExtension 16.1, *)
struct ActivityKitWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExampleAttributes.self) { context in
            // SwiftUI Live Activity content
            ActivityKitView(var1: context.attributes.var1,
                            var2: context.state.var2)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                }
                DynamicIslandExpandedRegion(.trailing) {
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Hello World!")
                }
                DynamicIslandExpandedRegion(.bottom) {
                }
            } compactLeading: {
                Text("🐶")
            } compactTrailing: {
                Text("😻")
            } minimal: {
                Text("🐸")
            }
            .keylineTint(.white)
        }
    }
}

struct DemoWidget: View {
    var body: some View {
        ActivityKitView(var1: "Preview content 1", var2: "Preview content 2")
    }
}

struct ActivityKit_Preview: PreviewProvider {
    static var previews: some View {
        DemoWidget()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
```

5. In some viewController do the following:
```swift
let attr = ExampleAttributes(var1: "Static text")
let state = ExampleAttributes.LiveWidgetStatus(var2: "Variable text")
ActivityKitManager.start(ExampleAttributes.self, attr, state)
```

## Usage

##### Check if Live Activities are enabled
```swift
print(ActivitiyKitManager.isAllowed)
// true/false
```

##### Count Live Activities by  state
```swift
ActivityKitManager.count(ExampleAttributes.self, .active))
// 1
ActivityKitManager.count(ExampleAttributes.self, .dismissed))
// 2
ActivityKitManager.count(ExampleAttributes.self, .stopped))
// 0
```

##### Start a Live Activity
```swift
let attr = ExampleAttributes(...)
let state = ExampleAttributes.LiveWidgetStatus(...)
let token = .none // .token for APN registration
ActivityKitManager.start(attr, state, token)
```

##### Update a Live Activity (identified by its id)
```swift
let state = ExampleAttributes.LiveWidgetStatus(...)
let id = "......."
ActivityKitManager.start(ExampleAttributes.self, state, id)
```

##### Update all Live Activities
```swift
let state = ExampleAttributes.LiveWidgetStatus(...)
ActivityKitManager.start(ExampleAttributes.self, state)
```

##### Stop a Live Activity
```swift
ActivityKitManager.stop(ExampleAttributes.self, "ABC123"))
```

##### Stop all Live Activities
```swift
ActivityKitManager.stop(ExampleAttributes.self))
```

##### Get a dictionnary of all APN push tokens
```swift
print(ActivityKitManager.getAPNtoken(ExampleAttributes.self))
// [ABC123 : ABC123, ..., DEF456 : DEF456]
```

##### Get a dictionnary of APN push tokens
```swift
print(ActivityKitManager.getAPNtoken(ExampleAttributes.self, "ABC123"))
// [ABC123 : ABC123]
```

##### Get state of a Live Activity
```swift
ActivityKitManager.getState(ExampleAttributes.self, "ABC123"))
// .active / .dismissed / .stopped
```

##### State helper functions
```swift
ActivityKitManager.isActive(ExampleAttributes.self, "ABC123"))
ActivityKitManager.isDismissed(ExampleAttributes.self, "ABC123"))
// true/false
```
