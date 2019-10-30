/**
 * cordova is available under the MIT License (2008).
 * See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright (c) Matt Kane 2010
 * Copyright (c) 2011, IBM Corporation
 * Copyright (c) 2012-2017, Adobe Systems
 */


var exec = cordova.require("cordova/exec");


var TIMChat = {
    /**
     * 初始化
     * @param successCallback
     * @param errorCallback
     */
    initTIM: function (params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'initTIM', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    chatWithUserId: function (params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'chatWithUserId', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    chatWithGroupId: function (params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'chatWithGroupId', [params]);
    }
};

module.exports = TIMChat;
