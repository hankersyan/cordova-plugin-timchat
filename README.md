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
5. 群或用户详情页面可自定义

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

1. 在 AppDelegate 里增加 "deviceToken" property，并得到推送所需的设备码，参见sample

如果集成了七牛云视频会议插件，还需要：

2. 视频呼叫时的IOS自定义铃声，由于腾讯IM离线推送的自定义铃声是音频文件的相对路径，故需查看 wav/caf 文件在编译后包里的相对路径，推送设定的 pushNotificationForIOS 值使用此相对路径。
3. 视频呼叫时的Android自定义铃声，由于腾讯IM离线推送的Android自定义铃声只能使用资源ID，所以必须先编译android工程，得到铃声 wav 文件的资源ID。

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
				groupProfileUrl: "http://YOUR.DOMAIN.COM/groupprofile.html?token=xxx.ooo", // 用户从聊天框会打开群详情页面，此处自定义群详情页的URL，群ID自动追加为id参数
				userProfileUrl: "http://YOUR.DOMAIN.COM/userprofile.html?token=xxx.ooo",   // 用户从聊天框会打开用户详情页面，此处自定义用户详情页的URL，用户ID自动追加为id参数
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
// 侦听resume事件，应用程序从后台再次打开
document.addEventListener("resume", onResume, false);
function onResume() {
    console.log('JS::onResume');
    setTimeout(function() {
    		// 获取会话列表(本地)
        TIMChat.getConversations({}, (conversations)=>{
            console.log("Conversations=", JSON.stringify(conversations));
        });
    }, 500);
}
```

#### 群或用户详情页面示例

```javascript
function doSubmit() { // 右上角按钮会调用此函数，不要修改函数名
    yourSubmitFunction((result) => {
        if (result.成功) {
            console.log('操作成功', result);
            jsbridgingShowToast('修改成功'); // 成功后显示消息
            setTimeout(function () {
                jsbridgingBack();						// 并退出
            }, 1000);
        } else {
            if (!result.errmsg) result.errmsg = '未知错误';
            jsbridgingAlert(result.errmsg); // 失败后显示对话框
        }
    });
}
//
// JS Bridging 定义了三个函数，无需修改
//
var nativeAlert;
var nativeShowToast;
var nativeBack;
function jsbridgingAlert(msg) { // 显示对话框
    if (typeof Android != "undefined") {
        Android.alert(msg);
    } else {
        nativeAlert(msg); // iOS
    }
}
function jsbridgingShowToast(msg) { // 显示悬浮消息
    if (typeof Android != "undefined") {
        Android.showToast(msg);
    } else {
        nativeShowToast(msg); // iOS
    }
}
function jsbridgingBack() { // 退出页面
    if (typeof Android != "undefined") {
        Android.back();
    } else {
        nativeBack(); // iOS
    }
}
function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function () { document.documentElement.removeChild(WVJBIframe) }, 0)
}
setupWebViewJavascriptBridge(function (bridge) {
    /* Initialize your app here */
    bridge.registerHandler('doSubmit', function (data, responseCallback) {
        console.log("JS doSubmit called with:", data)
        responseCallback(data)
        doSubmit();
    })
    nativeAlert = function (msg) {
        bridge.callHandler('nativeAlert', { 'msg': msg }, function responseCallback(responseData) {
            console.log("JS nativeAlert received response:", responseData)
        })
    }
    nativeShowToast = function (msg) {
        bridge.callHandler('nativeShowToast', { 'msg': msg }, function responseCallback(responseData) {
            console.log("JS nativeShowToast received response:", responseData)
        })
    }
    nativeBack = function (msg) {
        bridge.callHandler('nativeBack', {}, function responseCallback(responseData) {
            console.log("JS nativeBack received response:", responseData)
        })
    }
})
//
// JS Bridging 定义结束
//
```
