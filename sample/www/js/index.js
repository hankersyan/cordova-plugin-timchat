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
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
        window.didChatClosed = function(convId) {
            console.log('JS didChatClosed,,,,,,,,' + convId);
        };
        console.log("didChatClosed=" + (typeof didChatClosed));
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
        var btnElem = parentElement.querySelector('input[type="button"]');
        var myId = document.getElementById('myid');
        var myPwd = document.getElementById('mypwd');
        var friendId = document.getElementById('friendId');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id + ', ' + window.cordova.platformId);

        var userSigFromServer = "Your SHOULD calculate the userSig on your own server";
        if (window.cordova.platformId == "ios") {
            myId.value = "hankers";
            friendId.value = "@TGS#1I2NWTBG3";
            userSigFromServer = "eJwtzEELgjAYxvHvsnPIu*nQCV0k6FBSpFB0szb1RVxjmonRd0*mx*f3wP9L8mPmDcqSmDAPyMZtlEr3WKLjutCNst16dbIpjEFJYhoA0ICLgC6PGg1aNTvnnAHAoj22zkKfipD6Yq1gNZffanfmGTI2WEiqU5nuy*eQv*x97C9p8rgdWj19Ir*ertGW-P6-vTMF";
        } else {
            myId.value = "yan"
            friendId.value = "@TGS#1I2NWTBG3";
            userSigFromServer = "eJyrVgrxCdYrSy1SslIy0jNQ0gHzM1NS80oy0zLBwpWJeVDh4pTsxIKCzBQlK0MTAwNDE1NLE0OITGpFQWZRKlDc1NTUyMDAACJakpkLFjM3NrQ0NzK2gJqSmQ401SIwvTjcv8okL9mvssg7O8*r3CUgMb3EN9832M8yrNLc0NjUo7jCKD01Rt-RVqkWAPIpMUE_";
        }

        console.log('1, userId=' + myId.value);

        btnElem.addEventListener('click', function() {
            console.log('2');
            TIMChat.initTIM({
                    sdkAppId: 1400145941,
                    userId: myId.value,
                    userSig: userSigFromServer,
                    busiId: 16144,
                    xmPushBusiId: 7685,
                    xmPushAppId: "2882303761518228064",
                    xmPushAppKey: "5531822835064",
                    hwPushBusiId: 0,
                    hwPushAppId: ""
                },
                function() {
                    console.log('login result: success');
                    if (friendId.value.startsWith('@')) {
                        TIMChat.chatWithGroupId({
                            groupId: friendId.value
                        }, function() { console.log(5); }, function() { console.log(6); });
                    } else {
                        TIMChat.chatWithUserId({
                            userId: friendId.value,
                            remark: '',
                            avatar: ''
                        }, function() { console.log(3); }, function() { console.log(4); });
                    }
                },
                function() { console.log('login result: failure'); }
            );
        }, false);
    }
};

app.initialize();
