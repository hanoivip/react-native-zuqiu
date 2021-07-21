package com.unity3d.player;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.Handler.Callback;
import android.os.Looper;
import android.os.Message;
import android.os.MessageQueue.IdleHandler;
import android.os.Process;
import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.InputEvent;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;

import android.widget.FrameLayout;

import java.io.UnsupportedEncodingException;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;

public class UnityPlayer extends FrameLayout {
    public static Activity currentActivity = null;

    /* renamed from: r */
    private static boolean isMainLoaded;

    /* renamed from: a */
    UnityMain unityMain = null;

    TextInputDialog inputDialog = null;

    /* renamed from: c */
    public int userOrient = -1;

    public boolean hasSurface = false;

    /* renamed from: e */
    private boolean f150e = true;
    /* access modifiers changed from: private */

    /* renamed from: f */
    public GameState gameState = new GameState();

    private final ConcurrentLinkedQueue jobs = new ConcurrentLinkedQueue();

    //private BroadcastReceiver f153h = null;

    /* renamed from: i */
    private boolean f154i = false;

    /* renamed from: j */
    private MyPhoneStateListener phoneListner = new MyPhoneStateListener();

    /* renamed from: k */
    private TelephonyManager phone;
    /* access modifiers changed from: private */

    /* renamed from: l */
    //public SplashView splash;


    /* renamed from: p */
    public Context context;
    /* access modifiers changed from: private */

    public SurfaceView rootSurface;
    /* access modifiers changed from: private */

    /* renamed from: s */
    public boolean quiting;
    /* access modifiers changed from: private */

    // video
    //public Video f164t;

    private class MyPhoneStateListener extends PhoneStateListener {

        public final void onCallStateChanged(int i, String str) {
            boolean z = true;
            UnityPlayer unityPlayer = UnityPlayer.this;
            if (i != 1) {
                z = false;
            }
            unityPlayer.nativeMuteMasterAudio(z);
        }
    }

    enum UnityState {
        PAUSE,
        RESUME,
        QUIT,
        SURFACE_LOST,
        SURFACE_ACQUIRED,
        FOCUS_LOST,
        FOCUS_GAINED,
        NEXT_FRAME
    }

    private class UnityMain extends Thread {

        /* renamed from: a */
        Handler messageHandler;

        /* renamed from: b */
        boolean playing;

        /* renamed from: c */
        boolean haveSurface;

        /* renamed from: d */
        int focusState;

        /* renamed from: e */
        int splashDuration;

        private UnityMain() {
            this.playing = false;
            this.haveSurface = false;
            this.focusState = 1;
            this.splashDuration = 5;
        }

        /* renamed from: a */
        private void sendMessage(UnityState dVar) {
            if (this.messageHandler != null) {
                Message.obtain(this.messageHandler, 2269, dVar).sendToTarget();
            }
        }

        /* renamed from: a */
        public final void onStop() {
            sendMessage(UnityState.QUIT);
        }

        /* renamed from: a */
        public final void mo13191a(Runnable runnable) {
            if (this.messageHandler != null) {
                sendMessage(UnityState.PAUSE);
                Message.obtain(this.messageHandler, runnable).sendToTarget();
            }
        }

        public final void onResume() {
            sendMessage(UnityState.RESUME);
        }

        public final void lostSurface(Runnable runnable) {
            if (this.messageHandler != null) {
                sendMessage(UnityState.SURFACE_LOST);
                Message.obtain(this.messageHandler, runnable).sendToTarget();
            }
        }

        /* renamed from: c */
        public final void onFocus() {
            sendMessage(UnityState.FOCUS_GAINED);
        }

        /* renamed from: c */
        public final void acuireSurface(Runnable runnable) {
            if (this.messageHandler != null) {
                Message.obtain(this.messageHandler, runnable).sendToTarget();
                sendMessage(UnityState.SURFACE_ACQUIRED);
            }
        }

        /* renamed from: d */
        public final void onLostFocus() {
            sendMessage(UnityState.FOCUS_LOST);
        }

        public final void run() {
            setName("UnityMainXXX");
            Looper.prepare();
            this.messageHandler = new Handler(new Callback() {
                private void onFocus() {
                    if (UnityMain.this.focusState == 3 && UnityMain.this.haveSurface) {
                        UnityPlayer.this.nativeFocusChanged(true);
                        UnityMain.this.focusState = 1;
                    }
                }

                public final boolean handleMessage(Message message) {
                    //Log.d("hanoivip", "UnityMain handle " + message.what);
                    if (message.what != 2269) {
                        return false;
                    }
                    UnityState dVar = (UnityState) message.obj;
                    if (dVar == UnityState.NEXT_FRAME) {
                        return true;
                    }
                    if (dVar == UnityState.QUIT) {
                        Looper.myLooper().quit();
                    } else if (dVar == UnityState.RESUME) {
                        UnityMain.this.playing = true;
                    } else if (dVar == UnityState.PAUSE) {
                        UnityMain.this.playing = false;
                    } else if (dVar == UnityState.SURFACE_LOST) {
                        UnityMain.this.haveSurface = false;
                    } else if (dVar == UnityState.SURFACE_ACQUIRED) {
                        UnityMain.this.haveSurface = true;
                        onFocus();
                    } else if (dVar == UnityState.FOCUS_LOST) {
                        if (UnityMain.this.focusState == 1) {// focus changed
                            UnityPlayer.this.nativeFocusChanged(false);
                        }
                        UnityMain.this.focusState = 2;// lost focus
                    } else if (dVar == UnityState.FOCUS_GAINED) {
                        UnityMain.this.focusState = 3;// have focus
                        onFocus();
                    }
                    return true;
                }
            });
            Looper.myQueue().addIdleHandler(new IdleHandler() {
                public final boolean queueIdle() {
                    UnityPlayer.this.executeGLThreadJobs();
                    if (UnityMain.this.playing && UnityMain.this.haveSurface) {
                        /* splash
                        if (UnityMain.this.splashDuration >= 0) {
                            if (UnityMain.this.splashDuration == 0 && UnityPlayer.this.needSplash()) {
                                UnityPlayer.this.m145a();
                            }
                            UnityMain.this.splashDuration--;
                        }*/
                        if (!UnityPlayer.this.isFinishing() && !UnityPlayer.this.nativeRender()) {
                            UnityPlayer.this.finish();
                        }
                        Message.obtain(UnityMain.this.messageHandler, 2269, UnityState.NEXT_FRAME).sendToTarget();
                    }
                    return true;
                }
            });
            Looper.loop();
        }
    }

    private abstract class JobAtWork implements Runnable {

        public abstract void mo13185a();

        public final void run() {
            if (!UnityPlayer.this.isFinishing()) {
                mo13185a();
            }
        }
    }

    static {
        (new ExceptionHandler()).init();
        isMainLoaded = false;
        isMainLoaded = loadNative("main");
    }

    public UnityPlayer(Context context) {
        super(context);
        if (context instanceof Activity) {
            currentActivity = (Activity) context;
            //this.userOrient = currentActivity.getRequestedOrientation();
        }
        this.context = context;
        if (currentActivity != null && needSplash()) {
            //this.splash = new SplashView(this.context, C0574a.m217a()[getSplashMode()]);
            //addView(this.splash);
        }
        if (PermissionUtil.manualAsk) {
            if (currentActivity != null) {
                PermissionUtil.helper.mo13243a(currentActivity, new Runnable() {
                    public final void run() {
                        runOnUI((Runnable) new Runnable() {
                            public final void run() {
                                gameState.mo13264d();
                                onResume();
                            }
                        });
                    }
                });
            } else {
                this.gameState.mo13264d();
            }
        }
        loadLibraries(this.context.getApplicationInfo());
        if (!GameState.isInitDone()) {
            AlertDialog create = new Builder(this.context)
                    .setTitle("Failure to initialize!")
                    .setPositiveButton("OK", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            UnityPlayer.this.finish();
                        }
                    })
                    .setMessage("Your hardware does not support this application, sorry!")
                    .create();
            create.setCancelable(false);
            create.show();
            return;
        }
        initJni(context);
        this.rootSurface = getSurfaceView();
        this.rootSurface.setContentDescription(getGameDescription(context));
        addView(this.rootSurface);
        //bringChildToFront(this.splash);
        this.quiting = false;
        nativeInitWebRequest(UnityWebRequest.class);
        m177k();
        this.phone = (TelephonyManager) this.context.getSystemService(Context.TELEPHONY_SERVICE);
        this.unityMain = new UnityMain();
        this.unityMain.start();
    }

    public static void UnitySendMessage(String str, String str2, String str3) {
        if (!GameState.isInitDone()) {
            MyLog.Log(5, "Native libraries not loaded - dropping message for " + str + "." + str2);
            return;
        }
        try {
            nativeUnitySendMessage(str, str2, str3.getBytes("UTF-8"));
        } catch (UnsupportedEncodingException e) {
        }
    }

    private static String getGameDescription(Context context) {
        return context.getResources().getString(context.getResources().getIdentifier("game_view_content_description", "string", context.getPackageName()));
    }


    public void onSurfaceChanged(int i, Surface surface) {
        if (!this.hasSurface) {
            onSurfaceChange(0, surface);
        }
    }

    private static void loadLibraries(ApplicationInfo applicationInfo) {
        if (isMainLoaded && NativeLoader.load(applicationInfo.nativeLibraryDir)) {
            GameState.onInitDone();
        }
    }

    private void m150a(JobAtWork fVar) {
        if (!isFinishing()) {
            queueJob((Runnable) fVar);
        }
    }

    public SurfaceView getSurfaceView() {
        SurfaceView surfaceView = new SurfaceView(this.context);
        surfaceView.getHolder().setFormat(-3);
        surfaceView.getHolder().addCallback(new SurfaceHolder.Callback() {
            public final void surfaceChanged(SurfaceHolder surfaceHolder, int i, int i2, int i3) {
                UnityPlayer.this.onSurfaceChanged(0, surfaceHolder.getSurface());
            }

            public final void surfaceCreated(SurfaceHolder surfaceHolder) {
                UnityPlayer.this.onSurfaceChanged(0, surfaceHolder.getSurface());
            }

            public final void surfaceDestroyed(SurfaceHolder surfaceHolder) {
                UnityPlayer.this.onSurfaceChanged(0, (Surface) null);
            }
        });
        surfaceView.setFocusable(true);
        surfaceView.setFocusableInTouchMode(true);
        return surfaceView;
    }

    private void queueJob(Runnable runnable) {
        if (GameState.isInitDone()) {
            if (Thread.currentThread() == this.unityMain) {
                runnable.run();
            } else {
                this.jobs.add(runnable);
            }
        }
    }

    private boolean onSurfaceChange(final int i, final Surface surface) {
        if (!GameState.isInitDone()) {
            return false;
        }
        final Semaphore semaphore = new Semaphore(0);
        Runnable r0 = new Runnable() {
            public final void run() {
                UnityPlayer.this.nativeRecreateGfxState(i, surface);
                semaphore.release();
            }
        };
        if (i != 0) {
            r0.run();
        } else if (surface == null) {
            this.unityMain.lostSurface(r0);
        } else {
            this.unityMain.acuireSurface(r0);
        }
        if (surface == null && i == 0) {
            try {
                if (!semaphore.tryAcquire(4, TimeUnit.SECONDS)) {
                    MyLog.Log(5, "Timeout while trying detaching primary window.");
                }
            } catch (InterruptedException e) {
                MyLog.Log(5, "UI thread got interrupted while trying to detach the primary window from the Unity Engine.");
            }
        }
        return true;
    }

    public void finish() {
        if ((this.context instanceof Activity) && !((Activity) this.context).isFinishing()) {
            ((Activity) this.context).finish();
        }
    }

    private void pauseUnity() {
        reportSoftInputStr(null, 1, true);
        if (this.gameState.mo13267g()) {
            if (GameState.isInitDone()) {
                final Semaphore semaphore = new Semaphore(0);
                this.unityMain.mo13191a(isFinishing() ? new Runnable() {
                    public final void run() {
                        stop();
                        semaphore.release();
                    }
                } : new Runnable() {
                    public final void run() {
                        if (UnityPlayer.this.nativePause()) {
                            UnityPlayer.this.quiting = true;
                            stop();
                            semaphore.release(2);
                            return;
                        }
                        semaphore.release();
                    }
                });
                try {
                    if (!semaphore.tryAcquire(4, TimeUnit.SECONDS)) {
                        MyLog.Log(5, "Timeout while trying to pause the Unity Engine.");
                    }
                } catch (InterruptedException e) {
                    MyLog.Log(5, "UI thread got interrupted while trying to pause the Unity Engine.");
                }
                if (semaphore.drainPermits() > 0) {
                    quit();
                }
            }
            this.gameState.mo13263c(false);
            this.gameState.mo13262b(true);
            if (this.f154i) {
                this.phone.listen(this.phoneListner, 0);
            }
        }
    }

    public void start() {

    }
    
    public void stop() {
        nativeDone();
    }

    public void onResume() {
        if (this.gameState.mo13266f()) {
            this.gameState.mo13263c(true);
            queueJob((Runnable) new Runnable() {
                public final void run() {
                    UnityPlayer.this.nativeResume();
                }
            });
            this.unityMain.onResume();
        }
    }

    private static void unload() {
        if (GameState.isInitDone()) {
            if (!NativeLoader.unload()) {
                throw new UnsatisfiedLinkError("Unable to unload libraries from libmain.so");
            }
            else {
                Log.d("hanoivip", "unload libraries from libmain.so success");
            }
            GameState.reset();
        }
    }

    private ApplicationInfo appInfo() throws PackageManager.NameNotFoundException {
        return this.context.getPackageManager().getApplicationInfo(this.context.getPackageName(), PackageManager.GET_META_DATA );
    }

    public boolean needSplash() {
        try {
            return appInfo().metaData.getBoolean("unity.splash-enable");
        } catch (Exception e) {
            return false;
        }
    }

    private final native void initJni(Context context);


    private void m177k() {
        if (this.context instanceof Activity) {
            ((Activity) this.context).getWindow().setFlags(1024, 1024);
        }
    }

    protected static boolean loadNative(String str) {
        try {
            Log.d("hanoivip", "load native lib " + str);
            System.loadLibrary(str);
            return true;
        } catch (UnsatisfiedLinkError e) {
            MyLog.Log(6, "Unable to find " + str);
            return false;
        } catch (Exception e2) {
            MyLog.Log(6, "Unknown error " + e2);
            return false;
        }
    }

    private final native void nativeDone();

    /* access modifiers changed from: private */
    public final native void nativeFocusChanged(boolean z);

    private final native void nativeInitWebRequest(Class cls);

    private final native boolean nativeInjectEvent(InputEvent inputEvent);

    /* access modifiers changed from: private */
    public final native boolean nativeIsAutorotationOn();

    /* access modifiers changed from: private */
    public final native void nativeLowMemory();

    /* access modifiers changed from: private */
    public final native void nativeMuteMasterAudio(boolean z);

    /* access modifiers changed from: private */
    public final native boolean nativePause();

    /* access modifiers changed from: private */
    public final native void nativeRecreateGfxState(int i, Surface surface);

    /* access modifiers changed from: private */
    public final native boolean nativeRender();

    private final native void nativeRestartActivityIndicator();

    /* access modifiers changed from: private */
    public final native void nativeResume();

    /* access modifiers changed from: private */
    public final native void nativeSetInputString(String str);

    /* access modifiers changed from: private */
    public final native void nativeSoftInputCanceled();

    /* access modifiers changed from: private */
    public final native void nativeSoftInputClosed();

    private final native void nativeSoftInputLostFocus();

    private static native void nativeUnitySendMessage(String str, String str2, byte[] bArr);

    /* access modifiers changed from: 0000 */
    /* renamed from: a */
    public final void runOnUI(Runnable runnable) {
        if (this.context instanceof Activity) {
            ((Activity) this.context).runOnUiThread(runnable);
        } else {
            MyLog.Log(5, "Not running Unity from an Activity; ignored...");
        }
    }

    public void addPhoneCallListener() {
        this.f154i = true;
        this.phone.listen(this.phoneListner, 32);
    }

    public void configurationChanged(Configuration configuration) {
        if (this.rootSurface instanceof SurfaceView) {
            this.rootSurface.getHolder().setSizeFromLayout();
        }
    }

    public void disableLogger() {
        MyLog.disable = true;
    }

    public boolean displayChanged(int i, Surface surface) {
        if (i == 0) {
            this.hasSurface = surface != null;
            runOnUI((Runnable) new Runnable() {
                public final void run() {
                    if (UnityPlayer.this.hasSurface) {
                        UnityPlayer.this.removeView(UnityPlayer.this.rootSurface);
                    } else {
                        UnityPlayer.this.addView(UnityPlayer.this.rootSurface);
                    }
                }
            });
        }
        return onSurfaceChange(i, surface);
    }

    /* access modifiers changed from: protected */
    public void executeGLThreadJobs() {
        while (true) {
            Runnable runnable = (Runnable) this.jobs.poll();
            if (runnable != null) {
                runnable.run();
            } else {
                return;
            }
        }
    }

    public Bundle getSettings() {
        return Bundle.EMPTY;
    }

    /* access modifiers changed from: protected */
    public int getSplashMode() {
        try {
            return appInfo().metaData.getInt("unity.splash-mode");
        } catch (Exception e) {
            return 0;
        }
    }

    public View getView() {
        return this;
    }

    public void setSoftInputStr(final String str) {
        Log.e("hanoivip", "setSoftInputStr");
        runOnUI((Runnable) new Runnable() {
            public final void run() {
                if (UnityPlayer.this.inputDialog != null && str != null) {
                    UnityPlayer.this.inputDialog.mo13246a(str);
                }
            }
        });
    }

    public void hideSoftInput() {
        Log.e("hanoivip", "hideSoftInput");
        final Runnable r0 = new Runnable() {
            public final void run() {
                if (UnityPlayer.this.inputDialog != null) {
                    UnityPlayer.this.inputDialog.dismiss();
                    UnityPlayer.this.inputDialog = null;
                }
            }
        };
        if (PermissionUtil.f254b) {
            m150a((JobAtWork) new JobAtWork() {
                /* renamed from: a */
                public final void mo13185a() {
                    UnityPlayer.this.runOnUI(r0);
                }
            });
        } else {
            runOnUI((Runnable) r0);
        }
    }


    public boolean injectEvent(InputEvent inputEvent) {
        return nativeInjectEvent(inputEvent);
    }

    public boolean isFinishing() {
        if (!this.quiting) {
            boolean z = (this.context instanceof Activity) && ((Activity) this.context).isFinishing();
            this.quiting = z;
            if (!z) {
                return false;
            }
        }
        return true;
    }

    public void lowMemory() {
        queueJob((Runnable) new Runnable() {
            public final void run() {
                UnityPlayer.this.nativeLowMemory();
            }
        });
    }

    public boolean onGenericMotionEvent(MotionEvent motionEvent) {
        return injectEvent(motionEvent);
    }

    public boolean onKeyDown(int i, KeyEvent keyEvent) {
        return injectEvent(keyEvent);
    }

    public boolean onKeyLongPress(int i, KeyEvent keyEvent) {
        return injectEvent(keyEvent);
    }

    public boolean onKeyMultiple(int i, int i2, KeyEvent keyEvent) {
        return injectEvent(keyEvent);
    }

    public boolean onKeyUp(int i, KeyEvent keyEvent) {
        return injectEvent(keyEvent);
    }

    public boolean onTouchEvent(MotionEvent motionEvent) {
        return injectEvent(motionEvent);
    }

    public void pause() {
        pauseUnity();
    }

    public void quit() {

        this.quiting = true;
        if (!this.gameState.mo13265e()) {
            pause();
        }
        this.unityMain.onStop();
        try {
            this.unityMain.join(4000);
        } catch (InterruptedException e) {
            this.unityMain.interrupt();
        }
        this.unityMain = null;
        //if (this.f153h != null) {
        //    this.context.unregisterReceiver(this.f153h);
        //}
        //this.f153h = null;
        if (GameState.isInitDone()) {
            removeAllViews();
        }
        //unload libmain.so dependencies..
        unload();
    }

    /* access modifiers changed from: protected */
    public void reportSoftInputStr(final String str, final int i, final boolean z) {
        if (i == 1) {
            hideSoftInput();
        }
        m150a((JobAtWork) new JobAtWork() {
            /* renamed from: a */
            public final void mo13185a() {
                if (z) {
                    UnityPlayer.this.nativeSoftInputCanceled();
                } else if (str != null) {
                    UnityPlayer.this.nativeSetInputString(str);
                }
                if (i == 1) {
                    UnityPlayer.this.nativeSoftInputClosed();
                }
            }
        });
    }

    public void resume() {
        this.gameState.mo13262b(false);
        onResume();
        nativeRestartActivityIndicator();
    }

    public void showSoftInput(String str, int i, boolean z, boolean z2, boolean z3, boolean z4, String str2) {
        Log.e("hanoivip", "showSoftInput");
        final String str3 = str;
        final int i2 = i;
        final boolean z5 = z;
        final boolean z6 = z2;
        final boolean z7 = z3;
        final boolean z8 = z4;
        final String str4 = str2;
        runOnUI((Runnable) new Runnable() {
            public final void run() {
                UnityPlayer.this.inputDialog = new TextInputDialog(UnityPlayer.this.context, UnityPlayer.this, str3, i2, z5, z6, z7, str4);
                UnityPlayer.this.inputDialog.show();
            }
        });
    }

    public void windowFocusChanged(boolean z) {
        this.gameState.mo13261a(z);
        if (z && this.inputDialog != null) {
            nativeSoftInputLostFocus();
            reportSoftInputStr(null, 1, false);
        }
        if (z) {
            this.unityMain.onFocus();
        } else {
            this.unityMain.onLostFocus();
        }
        onResume();
    }

    public boolean initializeGoogleAr() {
        return true;
    }

    public boolean initializeGoogleVr() {
        return true;
    }
}
