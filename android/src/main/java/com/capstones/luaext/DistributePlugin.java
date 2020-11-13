package com.capstones.luaext;

import android.app.Activity;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.Log;
import com.capstones.sgpsdk.SGPPlugin;

public class DistributePlugin {
    public static String TAG = "SGPSDK";
    public static Object eventObject;
    public static Activity mainActivity;

    static {
        System.loadLibrary("DistributePlugin");
        Log.d("hanoivip", "DistributePlugin loaded");
    }

    public static void OnCreate() {
        SGPPlugin.mainActivity = mainActivity;
        SGPPlugin.OnCreate();
    }

    public static void OnStop() {
        SGPPlugin.OnStop();
    }

    public static void OnDestroy() {
        SGPPlugin.OnDestroy();
    }

    public static void OnResume() {
        SGPPlugin.OnResume();
    }

    public static void OnPause() {
        SGPPlugin.OnPause();
    }

    public static void OnRestart() {
        SGPPlugin.OnRestart();
    }

    public static void OnStart() {
        SGPPlugin.OnStart();
    }

    public static void OnActivityResult(int requestCode, int resultCode, Intent data) {
        SGPPlugin.OnActivityResult(requestCode, resultCode, data);
    }

    public static void OnConfigurationChanged(Configuration newConfig) {
        SGPPlugin.OnConfigurationChanged(newConfig);
    }

    public static void OnNewIntent(Intent intent) {
        SGPPlugin.OnNewIntent(intent);
    }

    public static void OnSaveInstanceState(Bundle outState) {
        SGPPlugin.OnSaveInstanceState(outState);
    }

    public static void OnBackPressed() {
        SGPPlugin.OnBackPressed();
    }

    public static void Load() {
    }

    public static void Init() {
        Log.d("", "-------------------------Init-------------------");
        SGPPlugin.Init();
    }

    public static void PreInit(String cate, int token) {
    }
}
