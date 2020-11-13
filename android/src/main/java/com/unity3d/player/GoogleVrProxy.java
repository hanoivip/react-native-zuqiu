package com.unity3d.player;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build.VERSION;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.view.Surface;
import android.view.SurfaceView;

import java.lang.reflect.Array;
import java.util.Iterator;
import java.util.Vector;

class GoogleVrProxy {

    /* renamed from: f */
    private boolean f109f = false;

    /* renamed from: g */
    private boolean f110g = false;
    /* access modifiers changed from: private */

    /* renamed from: h */
    public Runnable f111h = null;
    /* access modifiers changed from: private */

    /* renamed from: i */
    public Vector f112i = new Vector();

    /* renamed from: j */
    private SurfaceView f113j = null;
    /* access modifiers changed from: private */

    /* renamed from: k */
    public C0526a f114k = new C0526a();

    /* renamed from: l */
    private Thread f115l = null;

    /* renamed from: m */
    private Handler f116m = new Handler(Looper.getMainLooper()) {
        public final void handleMessage(Message message) {
            switch (message.what) {

                default:
                    super.handleMessage(message);
                    return;
            }
        }
    };

    /* renamed from: com.unity3d.player.GoogleVrProxy$a */
    class C0526a {

        /* renamed from: a */
        public boolean f128a = false;

        /* renamed from: b */
        public boolean f129b = false;

        /* renamed from: c */
        public boolean f130c = false;

        /* renamed from: d */
        public boolean f131d = false;

        /* renamed from: e */
        public boolean f132e = true;

        /* renamed from: f */
        public boolean f133f = false;

        C0526a() {
        }

        /* renamed from: a */
        public final boolean mo13118a() {
            return this.f128a && this.f129b;
        }

        /* renamed from: b */
        public final void mo13119b() {
            this.f128a = false;
            this.f129b = false;
            this.f131d = false;
            this.f132e = true;
            this.f133f = false;
        }
    }

    public GoogleVrProxy() {

    }

    /* access modifiers changed from: private */
    /* renamed from: a */
    public void m120a(boolean z) {
        this.f114k.f131d = z;
    }

    /* renamed from: a */
    private static boolean m121a(int i) {
        return VERSION.SDK_INT >= i;
    }

    /* renamed from: a */
    private boolean m122a(ClassLoader classLoader) {
        return false;
    }

    /* access modifiers changed from: private */
    /* renamed from: d */
    public boolean m125d() {
        return this.f114k.f131d;
    }

    /* renamed from: e */
    private void m127e() {

    }

    private final native void initVrJni();

    private final native boolean isQuiting();

    private final native void setVrVideoTransform(float[][] fArr);

    /* renamed from: a */
    public final void mo13099a(Intent intent) {
        if (intent != null && intent.getBooleanExtra("android.intent.extra.VR_LAUNCH", false)) {
            this.f110g = true;
        }
    }

    /* renamed from: a */
    public final boolean mo13100a() {
        return this.f114k.f128a;
    }

    /* renamed from: a */
    public final boolean mo13101a(Activity activity, Context context, SurfaceView surfaceView, Runnable runnable) {
        return false;
    }

    /* renamed from: b */
    public final void mo13102b() {
        resumeGvrLayout();
    }

    /* renamed from: c */
    public final void mo13103c() {
        if (this.f113j != null) {
            this.f113j.getHolder().setSizeFromLayout();
        }
    }



    /* access modifiers changed from: protected */
    public Object getVideoSurface() {
        return null;
    }

    /* access modifiers changed from: protected */
    public int getVideoSurfaceId() {
        return -1;
    }

    /* access modifiers changed from: protected */
    public long loadGoogleVr(boolean z, boolean z2, boolean z3, boolean z4, boolean z5) {
        return 0;
    }

    /* access modifiers changed from: protected */
    public void pauseGvrLayout() {

    }


    /* access modifiers changed from: protected */
    public void resumeGvrLayout() {

    }

    /* access modifiers changed from: protected */
    public void setGoogleVrModeEnabled(final boolean z) {

    }

    public void setVideoLocationTransform(float[] fArr) {
        float[][] fArr2 = (float[][]) Array.newInstance(Float.TYPE, new int[]{4, 4});
        for (int i = 0; i < 4; i++) {
            for (int i2 = 0; i2 < 4; i2++) {
                fArr2[i][i2] = fArr[(i * 4) + i2];
            }
        }
        setVrVideoTransform(fArr2);
    }

    /* access modifiers changed from: protected */
    public void unloadGoogleVr() {
        if (this.f114k.f131d) {
            setGoogleVrModeEnabled(false);
        }
        if (this.f114k.f130c) {
            this.f114k.f130c = false;
        }
        this.f113j = null;

    }
}
