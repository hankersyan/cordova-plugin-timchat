# cordova-plugin-timchat

#### Description
腾讯云即时消息 IMSDK4.x 的 cordova/phonegap/ionic 插件

#### Software Architecture
cordova/phonegap hybrid app supporting android/iOS

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
7. make sure that references to TUIKitFace and TUIKitResource bundles.

#### Android studio setup 
1. change defaultMinSdkVersion=21 in build.gradle

#### Usage

```javascript
TIMChat.initTIM({						// 初始化+登陆
        sdkAppId: 0,				// 腾讯云申请的APP ID
        userId: myUserId,
        userSig: userSigFromServer, // 自己服务器计算好的userSig，参见腾讯云文档
        busiId: 0						// 腾讯云IM消息推送ID
    },
    function() {
        console.log('login result: success');
        if (friendId.startsWith('@')) {
            TIMChat.chatWithGroupId({		// 群聊
                groupId: friendId
            }, function() { console.log('group ok'); }, function() { console.log('group fail'); });
        } else {
            TIMChat.chatWithUserId({		// 单聊
                userId: friendId,
                remark: '',
                avatar: ''
            }, function() { console.log('user ok'); }, function() { console.log('user fail'); });
        }
    },
    function() { console.log('login result: failure'); }
);
```