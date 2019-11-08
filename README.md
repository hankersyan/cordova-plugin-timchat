# cordova-plugin-timchat

#### 描述
腾讯云即时消息 IMSDK4.x 的 cordova/phonegap/ionic 插件

#### 架构
cordova/phonegap hybrid app

#### 支持的平台
android/iOS

#### 已实现的功能

1. 单聊/群聊
2. 发送文本/图片/短语音/短视频消息

#### 计划中的功能

1. 消息推送
2. 视频会议（七牛云、便宜、没有最低消费）
3. 分享地理位置
4. 后台跟踪地理位置（考虑到各个平台杀进程，大概能存活5分钟）
5. 自定义消息：投票
6. 红包

#### 安装

cordova plugin add https://github.com/hankersyan/cordova-plugin-timchat.git


#### 例子
运行sample目录下的 './create-tim.sh', 并进行IDE的设置.

![js调用TIMChat](https://meehealth.oss-cn-shanghai.aliyuncs.com/tim/3eyau6.gif "js调用TIMChat")

#### XCode 设置

1. 移除并重新引用 "timc.framework"
2. 在 build phase 里增加 "run script"，shell项内容设置为 "../../../sign.sh"
3. 在 capability 里增加 "Push Notification"
4. 在 AppDelegate 里增加 "deviceToken" property，并得到推送所需的设备码
5. 在 AppDelegate 里的 applicationDidEnterBackground 方法里调用 TIMChatDelegate 的 didEnterBackground
6. 在 AppDelegate 里的 applicationDidBecomeActive 方法里调用 TIMChatDelegate 的 didBecomeActive
7. 引用 TUIKitFace and TUIKitResource 两个 bundle

#### Android studio 设置 
1. 根 build.gradle 里设置 defaultMinSdkVersion=21 
2. AndroidManifest.xml 里增加推送设置，注意替换YOUR.PACKAGE.NAME
    <permission
        android:name="<YOUR.PACKAGE.NAME>.permission.MIPUSH_RECEIVE"
        android:protectionLevel="signature" />
    <uses-permission android:name="<YOUR.PACKAGE.NAME>.permission.MIPUSH_RECEIVE" />


#### 用法

```javascript
TIMChat.initTIM({						// 初始化+登陆
        sdkAppId: 0,				// 腾讯云申请的APP ID
        userId: myUserId,
        userSig: userSigFromServer, // 自己服务器计算好的userSig，参见腾讯云文档
        busiId: 0,						// 腾讯云IM提供的iOS推送 busiID
        xmPushBusiId: 0,			// 腾讯云IM提供的小米推送 busiID
        xmPushAppId: "",			// 小米推送提供的APPID
        xmPushAppKey: "",			// 小米推送提供的APPKEY
        hwPushBusiId: 0,			// 腾讯云IM提供的华为推送 busiID
        hwPushAppId: ""				// 华为推送提供的APPID
    },
    function() {
        console.log('login result: success');
        if (friendId.startsWith('@')) {
            TIMChat.chatWithGroupId({		// 群聊
                groupId: friendId
            }, function() { console.log('chatWithGroupId ok'); }, function() { console.log('chatWithGroupId fail'); });
        } else {
            TIMChat.chatWithUserId({		// 单聊
                userId: friendId
            }, function() { console.log('chatWithUserId ok'); }, function() { console.log('chatWithUserId fail'); });
        }
    },
    function() { console.log('login result: failure'); }
);
```