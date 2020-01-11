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
    initialize: function () {
        const self = this;
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
        window.didChatClosed = function (convId) {
            console.log('JS didChatClosed, ' + convId);
        };
        console.log("initialize OK, window.didChatClosed=" + (typeof didChatClosed));
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function () {
        this.receivedEvent('deviceready');
    },

    // Update DOM on a Received Event
    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');
        var chatBtn = document.getElementById('chat');
        var myId = document.getElementById('myid');
        var friendId = document.getElementById('friendId');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id + ', ' + window.cordova.platformId);

        const self = this;
        self.Users = [{
                id: 'yrm',
                usersig: 'eJyrVgrxCdYrSy1SslIy0jNQ0gHzM1NS80oy0zLBwpVFuVDh4pTsxIKCzBQlK0MTAwNDE1NLE0OITGpFQWZRKlDc1NTUyMDAACJakpkLFjM3NzY1MDGBihZnpgNNLa809grM8wjyKUupKgp1izKISHU3cC6ziPR1LA-Iz3GJSK00KzIJNc7IDbVVqgUAv4sxBQ__'
            },
            {
                id: 'hankers',
                usersig: 'eJwtzMkOgjAUheF36drALbYyJKzcOSwUmjSGTSNVLlOwbYxDfHcJsDzfSf4vyQ*Z99SGJCTwgKymjaXuHd5w4kr1jTZ2uWzZqGHAkiSUAVDGY0bnR78GNHp0znkAALM67CYLwzWLI*BLBe9j*QROFL6qz*1VFn79jlRLu2O12X9EnjEphJGPwLU7veUXm5LfHx97M0A_'
            },
            {
                id: 'yan',
                usersig: 'eJwtzE8LgjAcxvH3smsh29waEzqEl*gPRnqpm7Vf45coQ00m0XtPpsfn88D3S4pTHg3QkoTwiJJ12Gig6fGFgceyWbgzVekcGpIwQSkTUgs2P*AdtjC5lJJTSmftsQ6mVCz0Rumlgnaqxo-rygMcMybKFDjuzj4di311v*VPfnCXrHb6o4e37eyW-P6oNjDx'
            },
        ];

        friendId.value = "@TGS#1I2NWTBG3";
        if (window.cordova.platformId == "ios") {
            myId.value = "hankers";
        } else {
            myId.value = "yan";
        }

        console.log('1, userId=' + myId.value);

        chatBtn.addEventListener('click', function () {
            console.log('5');
            self.login();
        }, false);

        console.log('2, chatBtn=' + chatBtn);

        TIMChat.getLoginUser(function (uid) {
            console.log('getLoginUser=' + uid);
            if (uid) {
                myId.value = uid;
            }
        });

        console.log('3');
    },

    login: function () {
        const self = this;
        var myId = document.getElementById('myid');
        var friendId = document.getElementById('friendId');

        TIMChat.getLoginUser(function (loginUser) {
            console.log('getLoginUser=' + loginUser);
            if (myId.value == loginUser) {
                TIMChat.autoLogin({
                    userId: myId.value
                }, function () {
                    self.onLoginSuccess();
                });
            } else {
                var userSigFromServer = "Your SHOULD calculate the userSig on your own server";
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
                        },
                        qnAppID: "d8lk7l4ed",
                        qnTokenUrl: "https://api-demo.qnsdk.com/v1/rtc/token/admin/app/d8lk7l4ed/room/<ROOM>/user/<USER>?bundleId=com.qbox.QNRTCKitDemo",
                        pushNotificationForIOS: "conference.wav",
                        pushNotificationForAndroid: "android.resource://io.hankers.tim01/1234567890"
                    },
                    function () {
                        console.log('login result: success');
                        self.onLoginSuccess();
                    },
                    function () {
                        console.log('login result: failure');
                    }
                );
            }
        });

    },

    onLoginSuccess: function () {
        var friendId = document.getElementById('friendId');
        if (friendId.value.startsWith('@')) {
            TIMChat.chatWithGroupId({
                groupId: friendId.value
            }, function () {
                console.log(5);
            }, function () {
                console.log(6);
            });
        } else {
            TIMChat.chatWithUserId({
                userId: friendId.value
            }, function () {
                console.log(3);
            }, function () {
                console.log(4);
            });
        }
    }

};

app.initialize();
