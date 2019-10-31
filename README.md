# cordova-plugin-timchat

#### Description
腾讯云即时消息 IMSDK4.x 的 cordova/phonegap/ionic 插件

#### Software Architecture
cordova/phonegap hybrid app

#### Installation
cordova install cordova-plugin-timchat

#### Run sample
run './create-tim.sh' in sample directory, and setup.

![cordova](sample/demo1.jpg?raw=true "cordova")
![opening](sample/demo2.jpg?raw=true "opening")
![opened](sample/demo3.jpg?raw=true "opened")
![send message](sample/demo4.jpg?raw=true "send message")

#### XCode setup for iOS

1. remove and re-add "timc.framework"
2. add the "run script" build phase for "../../../sign.sh"
3. add the "Push Notification" capability
4. make sure that your AppDelegate has a property "deviceToken" and get the correct value.
5. make sure that didEnterBackground of TIMChatDelegate is called in applicationDidEnterBackground of your AppDelegate.
6. make sure that didBecomeActive of TIMChatDelegate is called in applicationDidBecomeActive of your AppDelegate.


#### Android studio setup 
