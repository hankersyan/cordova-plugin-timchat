package io.hankers.cordova;

import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.os.AsyncTask;
import android.util.Log;

import com.tencent.imsdk.TIMManager;
import com.tencent.qcloud.tim.timchat.GlobalApp;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParserException;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TIMChat extends CordovaPlugin {

    private static String TAG = TIMChat.class.getSimpleName();
    private static final String preferenceTag = "preference";

    static Application _app = null;
    static String _packageName = null;
    static Resources _resources = null;

    private Map _configMap;
    int sdkAppId;
    long xmPushBusiId;
    String xmPushAppId;
    String xmPushAppKey;
    long hwPushBusiId;
    String hwPushAppId;

    String pushNotificationForAndroid = "";
    String pushNotificationForIOS = "";
    String qnTokenUrl = "";
    String qnAppID = "";

    public TIMChat() {

    }

    /**
     * Sets the context of the Command. This can then be used to do things like
     * get file paths associated with the Activity.
     *
     * @param cordova The context of the main Activity.
     * @param webView The CordovaWebView Cordova is running in.
     */
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        GlobalApp.checkPermission(cordova.getActivity());

        _app = cordova.getActivity().getApplication();
        _packageName = _app.getPackageName();
        _resources = _app.getResources();

        Context context = cordova.getActivity();
        int resId = context.getResources().getIdentifier("config", "xml", context.getPackageName());
        _configMap = loadConfigsFromXml(cordova.getActivity().getResources(), resId);

        sdkAppId = (int) getLongFromConfigs("sdkAppId");
        xmPushBusiId = getLongFromConfigs("xmPush_BusiId");
        xmPushAppId = getStringFromConfigs("xmPush_AppId");
        xmPushAppKey = getStringFromConfigs("xmPush_AppKey");
        hwPushBusiId = getLongFromConfigs("hwPush_BusiId");
        hwPushAppId = getStringFromConfigs("hwPush_AppId");

        GlobalApp.setChatCallback(new GlobalApp.ChatCallback() {
            @Override
            public void didChatClosed(String convId) {
                final String strConvId = convId;
                cordova.getActivity().runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        webView.loadUrl("javascript:didChatClosed('" + strConvId + "')");
                    }
                });
            }

            @Override
            public void didChatMoreMenuClicked(String s, Map<String, String> map) {
                Log.d(TAG, "didChatMoreMenuClicked, " + s + ", " + map);
                final String menuTitle = s;
                if (menuTitle.equalsIgnoreCase("会议")) {
                    TIMChat.this.videoCall(map.get("conversation"));
                }
//                try {
//                    JSONObject x = new JSONObject();
//                    x.put("conversation", map.get("conversation"));
//                    x.put("user", map.get("user"));
//                    final String xStr = x.toString();
//                    cordova.getActivity().runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            webView.loadUrl("javascript:didChatMoreMenuClicked('" + menuTitle + "', '" + xStr + "')");
//                        }
//                    });
//                } catch (Exception e) {
//                    Log.d(TAG, e.toString());
//                }
            }

            @Override
            public void didCustomMessageSelected(Map<String, String> params) {
                Log.d(TAG, "didCustomMessageSelected, " + params.toString());
                try {
                    if (params.containsKey("type") && params.get("type") != null) {
                        int type = Integer.valueOf(params.get("type"));
                        if (type == 1) {
                            String convId = String.valueOf(params.get("conversation"));
                            TIMChat.this.startQNRtc(convId);
                        }
                    }

//                    JSONObject x = new JSONObject();
//                    x.put("conversation", params.get("conversation"));
//                    x.put("user", params.get("user"));
//                    x.put("type", params.get("type"));
//                    x.put("text", params.get("text"));
//                    final String xStr = x.toString();
//                    cordova.getActivity().runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            webView.loadUrl("javascript:didCustomMessageSelected('" + xStr + "')");
//                        }
//                    });
                } catch (Exception e) {
                    Log.d(TAG, e.toString());
                }
            }

            @Override
            public void receivingNewCustomMessage(Map<String, String> params) {
                Log.d(TAG, "receivingNewCustomMessage, " + params.toString());
                try {
                    if (params.containsKey("type") && params.get("type") != null) {
                        int type = Integer.valueOf(params.get("type"));
                        if (type == 1) {
                            GlobalApp.confirm(params.get("text"), new GlobalApp.ConfirmCallback() {
                                @Override
                                public void onCancel() {

                                }

                                @Override
                                public void onOK() {
                                    String convId = String.valueOf(params.get("conversation"));
                                    TIMChat.this.startQNRtc(convId);
                                }
                            });
                        }
                    }

//                    JSONObject x = new JSONObject();
//                    x.put("conversation", params.get("conversation"));
//                    x.put("user", params.get("user"));
//                    x.put("type", params.get("type"));
//                    x.put("text", params.get("text"));
//                    final String xStr = x.toString();
//                    cordova.getActivity().runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            webView.loadUrl("javascript:receivingNewCustomMessage('" + xStr + "')");
//                        }
//                    });
                } catch (Exception e) {
                    Log.d(TAG, e.toString());
                }
            }
        });
    }

    /**
     * Executes the request and returns PluginResult.
     *
     * @param action          The action to execute.
     * @param args            JSONArry of arguments for the plugin.
     * @param callbackContext The callback id used when calling back into JavaScript.
     * @return True if the action was valid, false if not.
     */
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        final Context context = cordova.getContext();
        cordova.getThreadPool().execute(() -> {
            try {
                if (action.compareToIgnoreCase("initTIM") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    String userId = arg.getString("userId");
                    String userSig = arg.getString("userSig");

                    if (arg.has("chatMoreMenus")) {
                        JSONObject chatMoreMenus = arg.getJSONObject("chatMoreMenus");
                        Map<String, String> params = new HashMap<>();
                        if (chatMoreMenus != null) {
                            Iterator<String> keys = chatMoreMenus.keys();

                            // use ResId
                            while (keys.hasNext()) {
                                String key = keys.next();
                                int strResId = TIMChat.getStringResIdByValue(key);
                                if (strResId < 1) {
                                    cordova.getActivity().runOnUiThread(new Runnable() {
                                        @Override
                                        public void run() {
                                            new AlertDialog.Builder(cordova.getActivity())
                                                    .setMessage("You must provide the string resource of " + key)
                                                    .create().show();
                                        }
                                    });
                                    return;
                                }
                                int imgResId = TIMChat.getResourceId(chatMoreMenus.getString(key), "drawable");
                                params.put(String.valueOf(strResId), String.valueOf(imgResId));
                            }
                        }
                        if (params.size() > 0) {
                            GlobalApp.configChatMoreMenus(params);
                        }
                    }

                    pushNotificationForAndroid = arg.has("pushNotificationForAndroid") ? arg.getString("pushNotificationForAndroid") : "";
                    pushNotificationForIOS = arg.has("pushNotificationForIOS") ? arg.getString("pushNotificationForIOS") : "";
                    qnTokenUrl = arg.has("qnTokenUrl") ? arg.getString("qnTokenUrl") : "";
                    qnAppID = arg.has("qnAppID") ? arg.getString("qnAppID") : "";

                    String secretKey = arg.has("secretKey") ? arg.getString("secretKey") : "";
//                    userSig = GlobalApp.generateUserSigForTest(sdkAppId, userId, secretKey);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.init(cordova.getActivity().getApplication(), sdkAppId,
                                    xmPushBusiId, xmPushAppId, xmPushAppKey,
                                    hwPushBusiId, hwPushAppId,
                                    secretKey);
                            GlobalApp.onActivityInit(cordova.getActivity());
                            String loginUser = GlobalApp.getLoginUser();
                            GlobalApp.Callback callback = new GlobalApp.Callback() {
                                @Override
                                public void onError(int i, String s) {
                                    Log.e(TAG, "code=" + i + ", msg=" + s);
                                    callbackContext.error(i);
                                }

                                @Override
                                public void onSuccess(Object o) {
                                    Log.i(TAG, "initTIM success");
                                    callbackContext.success();
                                }
                            };
                            if (loginUser.equalsIgnoreCase(userId)) {
                                GlobalApp.autoLogin(userId, callback);
                            } else {
                                GlobalApp.login(userId, userSig, callback);
                            }
                        }
                    });
                } else if (action.compareToIgnoreCase("chatWithUserId") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    String userId = arg.getString("userId");
                    Log.d(TAG, action + ", " + userId);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.chatWithUserId(userId);
                        }
                    });
                } else if (action.compareToIgnoreCase("chatWithGroupId") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    String groupId = arg.getString("groupId");
                    Log.d(TAG, action + ", " + groupId);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.chatWithGroupId(groupId);
                        }
                    });
                } else if (action.compareToIgnoreCase("sendCustomMessage") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    final String text = arg.getString("message");
                    final String conversation = arg.getString("conversation");
                    final int type = arg.getInt("type");
                    final String pushNotificationForAndroid = arg.getString("pushNotificationForAndroid");
                    final String pushNotificationForIOS = arg.getString("pushNotificationForIOS");
                    Log.d(TAG, action + ", " + text);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.sendCustomMessage(conversation, text, type, pushNotificationForAndroid, pushNotificationForIOS);
                        }
                    });
                } else if (action.compareToIgnoreCase("sendTextMessage") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    final String text = arg.getString("message");
                    final String conversation = arg.getString("conversation");
                    Log.d(TAG, action + ", " + text);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.sendTextMessage(text, conversation);
                        }
                    });
                } else if (action.compareToIgnoreCase("confirm") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    final String desc = arg.getString("description");
                    Log.d(TAG, action + ", " + desc);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.confirm(desc, new GlobalApp.ConfirmCallback() {
                                @Override
                                public void onCancel() {
                                    Log.e(TAG, "onCancel");
                                    callbackContext.error(1);
                                }

                                @Override
                                public void onOK() {
                                    Log.i(TAG, "onOK");
                                    callbackContext.success();
                                }
                            });
                        }
                    });
                } else if (action.compareToIgnoreCase("getLoginUser") == 0) {
                    Log.d(TAG, action);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            String userId = GlobalApp.getLoginUser();
                            callbackContext.success(userId);
                        }
                    });
                } else if (action.compareToIgnoreCase("autoLogin") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    final String userId = arg.getString("userId");
                    Log.d(TAG, action + ", " + userId);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.autoLogin(userId, new GlobalApp.Callback() {

                                @Override
                                public void onError(int i, String s) {
                                    JSONObject ret = new JSONObject();
                                    try {
                                        ret.put("code", i);
                                        ret.put("msg", s);
                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                    callbackContext.error(ret);
                                }

                                @Override
                                public void onSuccess(Object o) {
                                    callbackContext.success();
                                }
                            });
                        }
                    });
                } else {
                    Method method = TIMChat.class.getDeclaredMethod(action, JSONArray.class, CallbackContext.class);
                    method.invoke(TIMChat.this, args, callbackContext);
                }
            } catch (Exception e) {
                Log.e(TAG, e.toString());
            }
        });
        return true;
    }

    private List<String> supportedKeys = new ArrayList(Arrays.asList(
            "sdkAppId", "xmPush_BusiId", "xmPush_AppId", "xmPush_AppKey", "hwPush_BusiId", "hwPush_AppId"));

    private String getStringFromConfigs(String key) {
        if (_configMap.containsKey(key)) {
            String val = String.valueOf(_configMap.get(key));
            return val.startsWith("@") ? val.substring(1) : val;
        }
        return "";
    }

    private long getLongFromConfigs(String key) {
        if (_configMap.containsKey(key)) {
            String val = String.valueOf(_configMap.get(key));
            val = val.startsWith("@") ? val.substring(1) : val;
            return Long.valueOf(val);
        }
        return 0;
    }

    private Map loadConfigsFromXml(Resources res, int configXmlResourceId) {
        //
        // Resources is the same thing from above that can be obtained
        // by context.getResources()
        // configXmlResourceId is the resource id integer obtained in step 1
        XmlResourceParser xrp = res.getXml(configXmlResourceId);

        Map configs = new HashMap();

        //
        // walk the config.xml tree and save all <preference> tags we want
        //
        try {
            xrp.next();
            while (xrp.getEventType() != XmlResourceParser.END_DOCUMENT) {
                if (preferenceTag.equals(xrp.getName())) {
                    String key = matchSupportedKeyName(xrp.getAttributeValue(null, "name"));
                    if (key != null) {
                        String s = xrp.getAttributeValue(null, "value");
                        configs.put(key, s);
                    }
                }
                xrp.next();
            }
        } catch (XmlPullParserException ex) {
            Log.e(TAG, ex.toString());
        } catch (IOException ex) {
            Log.e(TAG, ex.toString());
        }

        return configs;
    }

    private String matchSupportedKeyName(String testKey) {
        //
        // If key matches, return the version with correct casing.
        // If not, return null.
        // O(n) here is okay because this is a short list of just a few items
        for (String realKey : supportedKeys) {
            if (realKey.equalsIgnoreCase(testKey)) {
                return realKey;
            }
        }
        return null;
    }

    public static int getResourceId(String name, String type) {
        int ic = _resources.getIdentifier(name, type, _packageName);
        return ic;
    }

    public static int getStringResIdByValue(String strVal)
    {
        // because string name can not be unicode
        // R.string.class
        try {
            Class<?> act = Class.forName(_packageName + ".R");

            Class stringCls = null;
            for(Class innerClass: act.getDeclaredClasses())
            {
                if (innerClass.getName().endsWith("string")) {
                    stringCls = innerClass;
                    break;
                }
            }

            if (stringCls != null) {
                Field fields[] = stringCls.getFields();
                for (Field field : fields) {
                    int resId = _app.getResources().getIdentifier(field.getName(), "string", _packageName);
                    String resVal = _app.getString(resId);
                    if (resVal.equalsIgnoreCase(strVal)) {
                        return resId;
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void videoCall(String conversationId) {
        String msg = "加入视频会议";
        int type = 1;

        GlobalApp.sendCustomMessage(conversationId, msg, type, pushNotificationForAndroid, pushNotificationForIOS);

        this.startQNRtc(conversationId);
    }

    public void startQNRtc(final String conversationId) {
        try {
            Class cls = Class.forName("cordova.plugin.qnrtc.QNRtc");
            //Method method = cls.getMethod("setResource");
            //Object o = method.invoke(null, cordova.getActivity().getApplication());
            Method[] methods = cls.getMethods();
            for (Method m : methods) {
                if ("setResource".equals(m.getName())) {
                    // for static methods we can use null as instance of class
                    m.invoke(null, new Object[] {cordova.getActivity().getApplication()});
                    break;
                }
            }
            //QNRtc.setResource(cordova.getActivity().getApplication());
            new RequestTokenTask().execute(conversationId);
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
        }
    }

    private class RequestTokenTask extends AsyncTask<String, Void, String> {

        String roomId = "";

        @Override
        protected String doInBackground(String... strings) {
            String conversationId = strings[0];
            roomId = conversationId
                    .replace("#", "")
                    .replace("@", "")
                    .replace("$", "")
                    .replace("%", "")
                    .replace("&", "");
            String userId = TIMManager.getInstance().getLoginUser();
            String url = qnTokenUrl.replace("<ROOM>", roomId).replace("<USER>", userId);
            String token = "";
            try {
                HttpURLConnection urlConnection = (HttpURLConnection) new URL(url).openConnection();
                urlConnection.setRequestMethod("GET");
                int statusCode = urlConnection.getResponseCode();
                if (statusCode == 200) {
                    InputStream it = new BufferedInputStream(urlConnection.getInputStream());
                    InputStreamReader read = new InputStreamReader(it);
                    BufferedReader buff = new BufferedReader(read);
                    StringBuilder dta = new StringBuilder();
                    String chunks;
                    while ((chunks = buff.readLine()) != null) {
                        dta.append(chunks);
                    }
                    token = dta.toString();
                } else {
                    //Handle else
                }
            } catch (Exception ex) {
                Log.e(TAG, ex.getLocalizedMessage());
            }

            return token.trim();
        }

        @Override
        protected void onPostExecute(String result) {
            final String roomToken = result;
            TIMChat.this.cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (roomToken == null) {
                        Log.e(TAG, "empty token");
                        return;
                    }
                    String userId = TIMManager.getInstance().getLoginUser();

                    try {
                        Class cls = Class.forName("cordova.plugin.qnrtc.activity.RoomActivity");
                        Intent intent = new Intent(TIMChat.this.cordova.getActivity(), cls);
                        intent.putExtra("ROOM_ID", roomId);
                        intent.putExtra("ROOM_TOKEN", roomToken);
                        intent.putExtra("USER_ID", userId);
                        TIMChat.this.cordova.getActivity().startActivity(intent);
                    } catch (Exception e) {
                        Log.e(TAG, e.getLocalizedMessage());
                    }
                }
            });
        }
    }
}
