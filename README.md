# cordova-plugin-timchat

#### 描述
腾讯云即时消息 IMSDK4.x 的 cordova/phonegap/ionic 插件

#### 架构
cordova/phonegap hybrid app

#### 支持的平台
android/iOS

#### 已实现的功能

1. 单聊/群聊/会话列表
2. 发送文本/图片/短语音/短视频消息
3. 离线消息推送(iOS,华为,小米)
4. 多人视频会议A--七牛云（便宜、没有最低消费）
5. 内置Web浏览器，支持cordova插件
6. 自定义群或用户详情页面


#### 安装

cordova plugin add cordova-plugin-timchat --variable SDKAPPID=腾讯提供 --variable IOS_BUSIID=腾讯提供 --variable XMPUSH_BUSIID=腾讯提供 --variable XMPUSH_APPID=小米提供 --variable XMPUSH_APPKEY=小米提供 --variable HWPUSH_BUSIID=腾讯提供 --variable HWPUSH_APPID=华为提供

国内镜像

cordova plugin add https://gitee.com/hankersyan/cordova-plugin-timchat.git --variable SDKAPPID=腾讯提供 --variable IOS_BUSIID=腾讯提供 --variable XMPUSH_BUSIID=腾讯提供 --variable XMPUSH_APPID=小米提供 --variable XMPUSH_APPKEY=小米提供 --variable HWPUSH_BUSIID=腾讯提供 --variable HWPUSH_APPID=华为提供


#### 例子
即时消息+视频会议：运行sample目录下的 './create-tim-rtc.sh', 并进行IDE的设置.

即时消息：运行sample目录下的 './create-tim.sh', 并进行IDE的设置.

![js调用TIMChat](https://meehealth.oss-cn-shanghai.aliyuncs.com/tim/3ki9qe.gif "js调用TIMChat")

#### XCode 设置

1. 在 AppDelegate 里增加 "deviceToken" property，并得到推送所需的设备码，参见sample

如果集成了七牛云视频会议插件，还需要：

2. 在 YOUR_PROJECT_NAME-Prefix.pch 文件里引用头文件 #import "Plugins/cordova-plugin-rtc-qiniu/QRDPublicHeader.h"
3. 视频呼叫时的IOS自定义铃声，由于腾讯IM离线推送的自定义铃声是音频文件的相对路径，故需查看 wav/caf 文件在编译后包里的相对路径，推送设定的 pushNotificationForIOS 值使用此相对路径。
4. 视频呼叫时的Android自定义铃声，由于腾讯IM离线推送的Android自定义铃声只能使用资源ID，所以必须先编译android工程，得到铃声 wav 文件的资源ID。

#### Android studio 设置 
1. 根 build.gradle 里设置 defaultMinSdkVersion=21 
2. 在 Application.onCreate 事件中调用 GlobalApp.onApplicationCreate(this) 
3. AndroidManifest.xml 里增加推送设置，注意替换YOUR.PACKAGE.NAME
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
TIMChat.initTIM({             // 初始化+登陆
        userId: myUserId,
        userSig: userSigFromServer, // 自己服务器计算好的userSig，参见腾讯云文档
        // 如果集成七牛云视频会议，还需以下配置
        chatMoreMenus: {
                "会议": "conference" // 聊天页里自定义菜单, 格式为 title : namedImage 
                                // 注意：android 需为 title 添加 string资源
        },
        qnAppID: "d8lk7l4ed",   // 七牛云App ID
        qnTokenUrl: "https://api-demo.qnsdk.com/v1/rtc/token/admin/app/d8lk7l4ed/room/<ROOM>/user/<USER>?bundleId=com.qbox.QNRTCKitDemo", // 计算七牛云token的自己服务器的URL，<ROOM>和<USER>是占位符，会被本插件替换
        pushNotificationForIOS: "conference.wav", // 视频呼叫时，iOS的离线推送提示音
        pushNotificationForAndroid: "android.resource://YOUR.PACKAGE.NAME/raw资源ID",  // 视频呼叫时，android的离线推送提示音
        groupProfileUrl: "http://YOUR.DOMAIN.COM/groupprofile.html?token=xxx.ooo", // 群详情页面
        userProfileUrl: "http://YOUR.DOMAIN.COM/userprofile.html?token=xxx.ooo",   // 用户详情页面
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
document.addEventListener("deviceready", function() {
    // 侦听resume事件，应用程序从后台再次打开
    document.addEventListener("resume", onResume, false);
}, false);
function onResume() {
    console.log('JS::onResume');
    setTimeout(function() {
        // 获取会话列表(本地)
        TIMChat.getConversations({}, (conversations)=>{
            // 在这里刷新会话列表
            console.log("Conversations=", JSON.stringify(conversations));
        });
    }, 500);
}
```

#### 内部web浏览器，群或用户详情页面

1. 在聊天框里，用户点击右上角群详情时，打开自定义的群详情页面，自动追加群ID，如：&id=12345
2. 在聊天框里，用户点击用户头像时，打开自定义的用户详情页，自动追加用户ID，如：&id=54321
3. 详情页面使用内置Web浏览器，支持cordova插件，支持本地html文件和远程url
4. 如果使用本地html文件，如：groupprofile.html（位于www目录下），需引用 cordova.js
5. 如果使用远程url，如：http://x.cn/groupprofile.html，需安装 cordova-plugin-remote-injection 插件，并在 config.xml 里增加 allow-navigation
6. TIMChat.dismiss 关闭该浏览器窗口
7. TIMChat.showToast 显示Toast
8. TIMChat.alert 对话框

```javascript
function saveFunction() {
    YOUR_SAVE_FUNCTION((result) => {
        if (result.errcode == 0) {
            TIMChat.showToast('修改成功'); // ToastToast
            setTimeout(function () {
                backOrClose();
            }, 1000);
        } else {
            if (!result.errmsg) result.errmsg = '未知错误';
            TIMChat.alert(result.errmsg); // 对话框
        }
    });
}
function backOrClose() {
    console.log('history.length=' + history.length + ", document.referrer=" + document.referrer);
    if (document.referrer == "") { // 已经回到首页
        TIMChat.dismiss();  // 关闭内置浏览器窗口
    } else {
        history.back();  // 网页还可以back
    }
}
```
