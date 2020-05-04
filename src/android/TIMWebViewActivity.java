package io.hankers.cordova;

import android.os.Bundle;
import android.widget.LinearLayout;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaWebViewImpl;
import org.apache.cordova.engine.SystemWebView;
import org.apache.cordova.engine.SystemWebViewEngine;

public class TIMWebViewActivity extends CordovaActivity {

    SystemWebView webView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
        webView = new org.apache.cordova.engine.SystemWebView(this);
        webView.setLayoutParams(lp);

        LinearLayout rlmain = new LinearLayout(this);
        LinearLayout.LayoutParams llp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT,LinearLayout.LayoutParams.MATCH_PARENT);
        rlmain.addView(webView);

        setContentView(rlmain, llp);

        String url = getIntent().getStringExtra("url");
        if (url == null || url.isEmpty()) {
            url = "file:///android_asset/www/index.html";
        }

        super.init();
        launchUrl = url;
        loadUrl(launchUrl);
    }

    @Override
    protected CordovaWebView makeWebView() {
        return new CordovaWebViewImpl(new SystemWebViewEngine(webView));
    }

    @Override
    protected void createViews() {
        appView.getView().requestFocusFromTouch();
    }

}
