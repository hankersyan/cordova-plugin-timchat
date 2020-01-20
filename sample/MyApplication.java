package io.hankers.tim01;

import android.app.Application;

import com.tencent.qcloud.tim.timchat.GlobalApp;

public class MyApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        GlobalApp.onApplicationCreate(this);
    }

}
