# cordova-plugin-timchat

#### Description
腾讯云即时消息 IMSDK4.x 的 cordova/phonegap/ionic 插件

#### Software Architecture
cordova/phonegap hybrid app

#### Installation
cordova install cordova-plugin-timchat

#### Run sample
run './create-tim.sh' in sample directory, and setup.

![call timchat from cordova](https://meehealth.oss-cn-shanghai.aliyuncs.com/tim/3eyau6.gif "call timchat from cordova")

#### XCode setup for iOS

1. remove and re-add "timc.framework"
2. add the "run script" build phase for "../../../sign.sh"
3. add the "Push Notification" capability
4. make sure that your AppDelegate has a property "deviceToken" and get the correct value.
5. make sure that didEnterBackground of TIMChatDelegate is called in applicationDidEnterBackground of your AppDelegate.
6. make sure that didBecomeActive of TIMChatDelegate is called in applicationDidBecomeActive of your AppDelegate.


#### Android studio setup 
