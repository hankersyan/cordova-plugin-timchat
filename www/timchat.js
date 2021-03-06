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
    initTIM: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'initTIM', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    chatWithUserId: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'chatWithUserId', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    chatWithGroupId: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'chatWithGroupId', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    sendCustomMessage: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'sendCustomMessage', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    sendTextMessage: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'sendTextMessage', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    confirm: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'confirm', [params]);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    getLoginUser: function(successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'getLoginUser', null);
    },
    /**
     *
     * @param successCallback
     * @param errorCallback
     * @param params
     */
    autoLogin: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'autoLogin', [params]);
    },
    getConversations: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'getConversations', [params]);
    },
    dismiss: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'dismiss', [params]);
    },
    alert: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'alert', [params]);
    },
    showToast: function(params, successCallback, errorCallback) {
        exec(successCallback, errorCallback, 'TIMChat', 'showToast', [params]);
    },
};

module.exports = TIMChat;