package com.reactlibrary;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import android.content.Intent;
import com.hoolai.ChampionsManager.gpen.UnityPlayerNativeActivity;

public class ZuqiuModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public ZuqiuModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "Zuqiu";
    }

    @ReactMethod
    public void sampleMethod(String stringArgument, int numberArgument, Callback callback) {
        // TODO: Implement some actually useful functionality
        callback.invoke("Received numberArgument: " + numberArgument + " stringArgument: " + stringArgument);
    }
	
	@ReactMethod
	public void enterGame(String token, int uid, Callback callback) {
		ReactApplicationContext context = getReactApplicationContext();
		Intent intent = new Intent(context, UnityPlayerNativeActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
		intent.putExtra("token", token);
		intent.putExtra("uid", uid);
		context.startActivity(intent);
	}
}
