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
3. 离线消息推送(iOS,华为,小米)
4. 多人视频会议A--七牛云（便宜、没有最低消费）

#### 计划中的功能

5. 分享地理位置
6. 后台跟踪地理位置（考虑到各个平台杀进程，大概能存活5分钟）
7. 自定义消息：投票
8. 红包
9. 多人视频会议B--腾讯云

#### 安装

cordova plugin add cordova-plugin-timchat --variable SDKAPPID=腾讯提供 --variable IOS_BUSIID=腾讯提供 --variable XMPUSH_BUSIID=腾讯提供 --variable XMPUSH_APPID=小米提供 --variable XMPUSH_APPKEY=小米提供 --variable HWPUSH_BUSIID=腾讯提供 --variable HWPUSH_APPID=华为提供

国内镜像

cordova plugin add https://gitee.com/hankersyan/cordova-plugin-timchat.git --variable SDKAPPID=腾讯提供 --variable IOS_BUSIID=腾讯提供 --variable XMPUSH_BUSIID=腾讯提供 --variable XMPUSH_APPID=小米提供 --variable XMPUSH_APPKEY=小米提供 --variable HWPUSH_BUSIID=腾讯提供 --variable HWPUSH_APPID=华为提供


#### 例子
即时消息+视频会议：运行sample目录下的 './create-tim-rtc.sh', 并进行IDE的设置.

即时消息：运行sample目录下的 './create-tim.sh', 并进行IDE的设置.

![js调用TIMChat](https://meehealth.oss-cn-shanghai.aliyuncs.com/tim/3ki9qe.gif "js调用TIMChat")

#### XCode 设置

1. 移除引用 "timc.framework"，重新引用 platforms/ios/<YOUR_PROJECT>/Plugins/cordova-plugin-timchat/timc.framework，并增加引用 timc.framework/Frameworks/ImSDK.framework
2. 在 AppDelegate 里增加 "deviceToken" property，并得到推送所需的设备码

如果集成了七牛云视频会议插件，还需要：

3. 在 YOUR_PROJECT_NAME-Prefix.pch 文件里引用头文件 #import "Plugins/cordova-plugin-rtc-qiniu/QRDPublicHeader.h"
4. 视频呼叫时的IOS自定义铃声，由于腾讯IM离线推送的自定义铃声是音频文件的相对路径，故需查看 wav/caf 文件在编译后包里的相对路径，推送设定的 pushNotificationForIOS 值使用此相对路径。
5. 视频呼叫时的Android自定义铃声，由于腾讯IM离线推送的Android自定义铃声只能使用资源ID，所以必须先编译android工程，得到铃声 wav 文件的资源ID。

#### Android studio 设置 
1. 根 build.gradle 里设置 defaultMinSdkVersion=21 
2. AndroidManifest.xml 里增加推送设置，注意替换YOUR.PACKAGE.NAME
```html
    <!-- 华为推送设置 in application section -->
    <meta-data
        android:name="com.huawei.hms.client.appid"
        android:value="appid=你的APPID"/>

    <!-- 华为推送设置 in manifest -->
    <permission
        android:name="<YOUR.PACKAGE.NAME>.permission.PROCESS_PUSH_MSG"
        android:protectionLevel="signatureOrSystem"/>
    <uses-permission android:name="<YOUR.PACKAGE.NAME>.permission.PROCESS_PUSH_MSG" />

		<!-- 小米推送设置 in manifest -->
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
    window.openConferenceWithParams(menuTitle, params);
};
window.receivingNewCustomMessage = function(params) {
    console.log('接收到新的自定义消息的回调, ' + params);
    TIMChat.confirm({
        "description": "加入会议?"
    }, function() {
        console.log('JS joining meeting', params);
        window.openConferenceWithParams(null, params);
    });
};
window.didCustomMessageSelected = function(params) {
    console.log('聊天消息列表里用户点击自定义消息的回调, ' + params);
    window.openConferenceWithParams(null, params);
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
};
window.openConferenceWithParams = function(menuTitle, params) {
  var par = JSON.parse(params);
  console.log(par);
  var confId = par.conversation.replace(/[\@\#\$\%\&]/ig, ''); // 七牛云会议ID禁用特殊字符
  if (menuTitle == "会议") {
      window.openConference(confId, myUserId);
      // request
      TIMChat.sendCustomMessage({
          'conversation': par.conversation,
          'message': '加入视频会议',
          'type': 1, // 自定义消息类型: 1=视频会议
          'pushNotificationForAndroid': 'android.resource://your.package.name/id.of.r.raw.sound',
          'pushNotificationForIOS': 'sounds/conference.wav'
      });
  } else if (par.type == 1) {
      // answer
      window.openConference(confId, myUserId);
  }
};
```