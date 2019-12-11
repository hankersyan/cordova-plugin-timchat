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
3. 离线消息推送
4. 视频会议（七牛云、便宜、没有最低消费）

#### 计划中的功能

1. 分享地理位置
2. 后台跟踪地理位置（考虑到各个平台杀进程，大概能存活5分钟）
3. 自定义消息：投票
4. 红包

#### 安装

cordova plugin add https://github.com/hankersyan/cordova-plugin-timchat.git --variable SDKAPPID=腾讯提供 --variable IOS_BUSIID=腾讯提供 --variable XMPUSH_BUSIID=腾讯提供 --variable XMPUSH_APPID=小米提供 --variable XMPUSH_APPKEY=小米提供 --variable HWPUSH_BUSIID=腾讯提供 --variable HWPUSH_APPID=华为提供


#### 例子
运行sample目录下的 './create-tim.sh', 并进行IDE的设置.

![js调用TIMChat](https://meehealth.oss-cn-shanghai.aliyuncs.com/tim/3izp70.gif "js调用TIMChat")

#### XCode 设置

1. 移除引用 "timc.framework"，重新引用 platforms/ios/<YOUR_PROJECT>/Plugins/cordova-plugin-timchat/timc.framework，并增加引用 timc.framework/Frameworks/ImSDK.framework
2. 在 AppDelegate 里增加 "deviceToken" property，并得到推送所需的设备码
3. 在 AppDelegate 里的 applicationDidEnterBackground 方法里调用 TIMChatDelegate 的 didEnterBackground
4. 在 AppDelegate 里的 applicationDidBecomeActive 方法里调用 TIMChatDelegate 的 didBecomeActive

#### Android studio 设置 
1. 根 build.gradle 里设置 defaultMinSdkVersion=21 
2. AndroidManifest.xml 里增加推送设置，注意替换YOUR.PACKAGE.NAME
```html
		<!-- 小米推送设置 -->
    <permission
        android:name="<YOUR.PACKAGE.NAME>.permission.MIPUSH_RECEIVE"
        android:protectionLevel="signature" />
    <uses-permission android:name="<YOUR.PACKAGE.NAME>.permission.MIPUSH_RECEIVE" />
```

#### 用法

```javascript
window.didChatClosed = function(convId) {
    console.log('聊天页关闭的回调, conversationId=' + convId);
};
window.didChatMoreMenuClicked = function (menuTitle, params) {
    console.log('聊天页里自定义菜单的回调, ', menuTitle, params);
    var par = JSON.parse(params);
    console.log(par);
    var convId = par.conversationId.replace(/[\@\#\$\%\&]/ig, ''); // 会话ID
    var userId = par.userId.replace(/[\@\#\$\%\&]/ig, ''); // 用户ID
    window.openConference(convId, userId); // 打开视频会议
};
TIMChat.initTIM({             // 初始化+登陆
        userId: myUserId,
        userSig: userSigFromServer, // 自己服务器计算好的userSig，参见腾讯云文档
        chatMoreMenus: {
                "会议": "conference" // 聊天页里自定义菜单, 格式为 title : namedImage 
                                // 注意：android 需为 title 添加 string资源
        }
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
window.openConference = function (conferenceId, userId) {
    console.log('201');

    if (typeof QNRtc == 'undefined') {
        alert('QNRtc plugin not found');
        return;
    }
    var appId = 'd8lk7l4ed';
    var roomName = conferenceId;
    var bundleId = 'com.qbox.QNRTCKitDemo';

    console.log('202,' + roomName + ',' + userId);

    var oReq = new XMLHttpRequest();

    oReq.addEventListener("load", function () {
        console.log("load", this.responseText);
        var para = {
            app_id: appId,
            user_id: userId,
            room_name: roomName,
            room_token: this.responseText
        }
        QNRtc.start(para);
    });
    // 获取七牛云token
    oReq.open("GET", "https://api-demo.qnsdk.com/v1/rtc/token/admin/" +
        "app/" + appId +
        "/room/" + roomName +
        "/user/" + userId +
        "?bundleId=" + bundleId);
    oReq.onerror = function () {
        console.log("** An error occurred during the transaction");
        console.log(oReq, oReq.status);
    };
    oReq.send();

    console.log('205');
}
```