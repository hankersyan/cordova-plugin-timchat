package io.hankers.cordova;

import android.content.Context;
import android.content.res.Resources;
import android.content.res.XmlResourceParser;
import android.util.Log;

import com.tencent.qcloud.tim.timchat.GlobalApp;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.xmlpull.v1.XmlPullParserException;

import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class TIMChat extends CordovaPlugin {

    private static String TAG = TIMChat.class.getSimpleName();
    private static final String preferenceTag = "preference";

    private Map _configMap;
    int sdkAppId;
    long xmPushBusiId;
    String xmPushAppId;
    String xmPushAppKey;
    long hwPushBusiId;
    String hwPushAppId;

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
                try {
                    JSONObject x = new JSONObject();
                    x.put("conversationId", map.get("conversationId"));
                    x.put("userId", map.get("userId"));
                    final String xStr = x.toString();
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            webView.loadUrl("javascript:didChatMoreMenuClicked('" + menuTitle + "', '" + xStr + "')");
                        }
                    });
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
                                int strResId = context.getResources().getIdentifier(key, "string", context.getPackageName());
                                int imgResId = context.getResources().getIdentifier(chatMoreMenus.getString(key), "drawable", context.getPackageName());
                                params.put(String.valueOf(strResId), String.valueOf(imgResId));
                            }
                        }
                        if (params.size() > 0) {
                            GlobalApp.configChatMoreMenus(params);
                        }
                    }

                    String secretKey = arg.has("secretKey") ? arg.getString("secretKey") : "";
//                    userSig = GlobalApp.generateUserSigForTest(sdkAppId, userId, secretKey);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.init(cordova.getActivity().getApplication(), sdkAppId,
                                    xmPushBusiId, xmPushAppId, xmPushAppKey,
                                    hwPushBusiId, hwPushAppId,
                                    secretKey);
                            GlobalApp.login(userId, userSig, new GlobalApp.Callback() {
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
                            });
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

}
