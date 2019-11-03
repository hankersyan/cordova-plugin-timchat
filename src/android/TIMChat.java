package io.hankers.cordova;

import android.app.Activity;
import android.util.Log;

import com.tencent.qcloud.tim.timchat.GlobalApp;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Method;

public class TIMChat extends CordovaPlugin {

    private static String TAG = TIMChat.class.getSimpleName();

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

        cordova.getThreadPool().execute(() -> {
            try {
                if (action.compareToIgnoreCase("initTIM") == 0) {
                    JSONObject arg = args.getJSONObject(0);
                    int sdkAppId = arg.getInt("sdkAppId");
//                    int busiId = arg.getInt("busiId");
                    String userId = arg.getString("userId");
                    String userSig = arg.getString("userSig");
                    String secretKey = arg.has("secretKey") ? arg.getString("secretKey") : "";
//                    userSig = GlobalApp.generateUserSigForTest(sdkAppId, userId, secretKey);
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            GlobalApp.init(cordova.getActivity().getApplication(), sdkAppId, secretKey);
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

}
