/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        const self = this;
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
        window.didChatClosed = function(convId) {
            console.log('JS didChatClosed, ' + convId);
        };
        window.didChatMoreMenuClicked = function(menuTitle, params) {
            console.log('JS didChatMoreMenuClicked, ', menuTitle, params);
            self.openConferenceWithParams(menuTitle, params);
        };
        window.receivingNewCustomMessage = function(params) {
            console.log('JS receivingNewCustomMessage, ' + params);
            TIMChat.confirm({
                "description": "加入会议?"
            }, function() {
                console.log('JS joining meeting', params);
                self.openConferenceWithParams(null, params);
            });
        };
        window.didCustomMessageSelected = function(params) {
            console.log('JS didCustomMessageSelected, ' + params);
            self.openConferenceWithParams(null, params);
        };
        console.log("initialize OK, window.didChatClosed=" + (typeof didChatClosed));
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        var chatBtn = document.getElementById('chat');
        var myId = document.getElementById('myid');
        var myPwd = document.getElementById('mypwd');
        var friendId = document.getElementById('friendId');
        var rtcBtn = document.getElementById('rtc');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id + ', ' + window.cordova.platformId);

        var userSigFromServer = "Your SHOULD calculate the userSig on your own server";

        const self = this;
        self.Users = [
            { id: 'yrm', usersig: 'eJyrVgrxCdYrSy1SslIy0jNQ0gHzM1NS80oy0zLBwpVFuVDh4pTsxIKCzBQlK0MTAwNDE1NLE0OITGpFQWZRKlDc1NTUyMDAACJakpkLFjM3NzY1MDGBihZnpgNNLa809grM8wjyKUupKgp1izKISHU3cC6ziPR1LA-Iz3GJSK00KzIJNc7IDbVVqgUAv4sxBQ__' },
            { id: 'hankers', usersig: 'eJwtzMkOgjAUheF36drALbYyJKzcOSwUmjSGTSNVLlOwbYxDfHcJsDzfSf4vyQ*Z99SGJCTwgKymjaXuHd5w4kr1jTZ2uWzZqGHAkiSUAVDGY0bnR78GNHp0znkAALM67CYLwzWLI*BLBe9j*QROFL6qz*1VFn79jlRLu2O12X9EnjEphJGPwLU7veUXm5LfHx97M0A_' },
            { id: 'yan', usersig: 'eJwtzE8LgjAcxvH3smsh29waEzqEl*gPRnqpm7Vf45coQ00m0XtPpsfn88D3S4pTHg3QkoTwiJJ12Gig6fGFgceyWbgzVekcGpIwQSkTUgs2P*AdtjC5lJJTSmftsQ6mVCz0Rumlgnaqxo-rygMcMybKFDjuzj4di311v*VPfnCXrHb6o4e37eyW-P6oNjDx' },
        ];

        friendId.value = "@TGS#1I2NWTBG3";
        userSigFromServer = "";
        if (window.cordova.platformId == "ios") {
            myId.value = "hankers";
        } else {
            myId.value = "yan";
        }

        console.log('1, userId=' + myId.value);

        chatBtn.addEventListener('click', function() {
            console.log('2');
            for (var i = 0; i < self.Users.length; i++) {
                if (self.Users[i].id == myId.value) {
                    userSigFromServer = self.Users[i].usersig;
                    break;
                }
            }
            if (!userSigFromServer || userSigFromServer.length < 1) {
                alert('userSig is null, please choose one of hankers, yan, yrm');
                return;
            }
            TIMChat.initTIM({
                    userId: myId.value,
                    userSig: userSigFromServer,
                    chatMoreMenus: { // 聊天输入框里的自定义菜单
                        "会议": "conference" // 推送提示音，声音资源
                    }
                },
                function() {
                    console.log('login result: success');
                    if (friendId.value.startsWith('@')) {
                        TIMChat.chatWithGroupId({
                            groupId: friendId.value
                        }, function() {
                            console.log(5);
                        }, function() {
                            console.log(6);
                        });
                    } else {
                        TIMChat.chatWithUserId({
                            userId: friendId.value
                        }, function() {
                            console.log(3);
                        }, function() {
                            console.log(4);
                        });
                    }
                },
                function() {
                    console.log('login result: failure');
                }
            );
        }, false);

        console.log('2, rtcBtn=' + rtcBtn);

        rtcBtn.addEventListener('click', this.startConference.bind(this), false);
        document.getElementById('name').value = 'u' + Math.floor((Math.random() * 1000) + 1);

        console.log('3');
    },

    startConference: function() {
        var roomName = document.getElementById('room').value;
        var userId = document.getElementById('name').value;
        this.openConference(roomName, userId);
    },

    openConference: function(conferenceId, userId) {
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

        oReq.addEventListener("load", function() {
            console.log("load", this.responseText);
            var para = {
                app_id: appId,
                user_id: userId,
                room_name: roomName,
                room_token: this.responseText
            }
            QNRtc.start(para);
        });
        oReq.open("GET", "https://api-demo.qnsdk.com/v1/rtc/token/admin/" +
            "app/" + appId +
            "/room/" + roomName +
            "/user/" + userId +
            "?bundleId=" + bundleId);
        oReq.onerror = function() {
            console.log("** An error occurred during the transaction");
            console.log(oReq, oReq.status);
        };
        oReq.send();

        console.log('205');
    },

    openConferenceWithParams: function(menuTitle, params) {
        const self = this;
        var par = JSON.parse(params);
        console.log(par);
        var confId = par.conversation.replace(/[\@\#\$\%\&]/ig, '');
        var userId = document.getElementById('name').value;
        //var userId = par.user.replace(/[\@\#\$\%\&]/ig, '');

        if (menuTitle == "会议") {
            self.openConference(confId, userId);
            // request
            TIMChat.sendCustomMessage({
                'conversation': par.conversation,
                'message': '加入视频会议',
                'type': 1,
                'pushNotificationForAndroid': 'android.resource://your.package.name/id.of.r.raw.sound',
                'pushNotificationForIOS': 'sounds/conference.wav'
            });
        } else if (par.type == 1) {
            // answer
            self.openConference(confId, userId);
        }
    },
};

app.initialize();