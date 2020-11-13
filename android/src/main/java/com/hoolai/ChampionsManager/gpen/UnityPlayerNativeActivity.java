package com.hoolai.ChampionsManager.gpen;

import android.app.Activity;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.MotionEvent;
import com.capstones.luaext.DistributePlugin;
import com.capstones.luaext.EventPlugin;
import com.unity3d.player.UnityPlayer;
import android.util.Log;
import com.facebook.react.ReactActivity;

import android.content.Intent;

public class UnityPlayerNativeActivity extends Activity {
    private int height;
    protected UnityPlayer mUnityPlayer;
    private int width;

    public void onCreate(Bundle savedInstanceState) {
		
		// hanoivip: get intent parameter
		Intent intent = getIntent();
		int uid = intent.getIntExtra("uid", 0);
		String token = intent.getStringExtra("token");
		
        EventPlugin.mainActivity = this;
		// hanoivip
		EventPlugin.userToken = token;
		EventPlugin.userId = (long)uid;
        EventPlugin.Load();
        DistributePlugin.mainActivity = this;
        requestWindowFeature(1);
        super.onCreate(savedInstanceState);
        DistributePlugin.OnCreate();
        getWindow().takeSurface(null);
        //setTheme(16973831);
        getWindow().setFormat(2);
        this.mUnityPlayer = new UnityPlayer(this);
        if (this.mUnityPlayer.getSettings().getBoolean("hide_status_bar", true)) {
            getWindow().setFlags(1024, 1024);
        }
        setContentView(this.mUnityPlayer);
        this.mUnityPlayer.requestFocus();
        DisplayMetrics dm = getResources().getDisplayMetrics();
        this.width = dm.widthPixels;
        this.height = dm.heightPixels;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
		Log.e("hanoivip", "onDestroy");
        DistributePlugin.OnDestroy();
        this.mUnityPlayer.quit();
    }

    @Override
    public void onPause() {
        super.onPause();
		Log.e("hanoivip", "onPause");
        DistributePlugin.OnPause();
        this.mUnityPlayer.pause();
    }

    @Override
    public void onResume() {
        super.onResume();
		Log.e("hanoivip", "onResume");
        DistributePlugin.OnResume();
        this.mUnityPlayer.resume();
    }

    @Override
    public void onStop() {
        super.onStop();
		Log.e("hanoivip", "onStop");
        DistributePlugin.OnStop();
    }

    @Override
    public void onRestart() {
        super.onRestart();
		Log.e("hanoivip", "onRestart");
        DistributePlugin.OnRestart();
    }

    @Override
    public void onStart() {
        super.onStart();
		Log.e("hanoivip", "onStart");
        DistributePlugin.OnStart();
        ((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).cancelAll();
    }

    @Override
    public void onLowMemory() {
        super.onLowMemory();
		Log.e("hanoivip", "onLowMemory");
        this.mUnityPlayer.lowMemory();
    }

    @Override
    public void onTrimMemory(int level) {
        super.onTrimMemory(level);
        if (level == 15) {
            this.mUnityPlayer.lowMemory();
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
		Log.e("hanoivip", "onConfigurationChanged");
        DistributePlugin.OnConfigurationChanged(newConfig);
        if ((this.mUnityPlayer.getView().getLayoutParams().width < this.mUnityPlayer.getView().getLayoutParams().height || this.width < this.height) && (this.mUnityPlayer.getView().getLayoutParams().width >= this.mUnityPlayer.getView().getLayoutParams().height || this.width >= this.height)) {
            this.mUnityPlayer.getView().getLayoutParams().width = this.height;
            this.mUnityPlayer.getView().getLayoutParams().height = this.width;
        } else {
            this.mUnityPlayer.getView().getLayoutParams().width = this.width;
            this.mUnityPlayer.getView().getLayoutParams().height = this.height;
        }
        this.mUnityPlayer.configurationChanged(newConfig);
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
		Log.e("hanoivip", "onWindowFocusChanged");
        this.mUnityPlayer.windowFocusChanged(hasFocus);
    }

    public boolean dispatchKeyEvent(KeyEvent event) {
		Log.e("hanoivip", "dispatchKeyEvent");
        if (event.getAction() == 2) {
            return this.mUnityPlayer.injectEvent(event);
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
		Log.e("hanoivip", "onActivityResult");
        DistributePlugin.OnActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
		Log.e("hanoivip", "onNewIntent");
        DistributePlugin.OnNewIntent(intent);
        setIntent(intent);
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
		Log.e("hanoivip", "onSaveInstanceState");
        DistributePlugin.OnSaveInstanceState(outState);
    }

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        //hanoivip: just exit, not close the wrapper
        DistributePlugin.OnBackPressed();
        Log.e("hanoivip", "onBackPressed");
        this.finish();
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return this.mUnityPlayer.injectEvent(event);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Log.e("hanoivip", "onKeyDown");
        /*
        if (keyCode == KeyEvent.KEYCODE_BACK)
        {
            this.finish();
            return true;
        }
        else*/
            return this.mUnityPlayer.injectEvent(event);
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        return this.mUnityPlayer.injectEvent(event);
    }

    @Override
    public boolean onGenericMotionEvent(MotionEvent event) {
        return this.mUnityPlayer.injectEvent(event);
    }
}
