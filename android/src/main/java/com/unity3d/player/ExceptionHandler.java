package com.unity3d.player;

import android.os.Build;
import java.lang.Thread.UncaughtExceptionHandler;

/* renamed from: com.unity3d.player.k */
final class ExceptionHandler implements UncaughtExceptionHandler {

    /* renamed from: a */
    private volatile UncaughtExceptionHandler f275a;

    ExceptionHandler() {
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: a */
    public final synchronized boolean init() {
        boolean z;
        UncaughtExceptionHandler defaultUncaughtExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();
        if (defaultUncaughtExceptionHandler == this) {
            z = false;
        } else {
            this.f275a = defaultUncaughtExceptionHandler;
            Thread.setDefaultUncaughtExceptionHandler(this);
            z = true;
        }
        return z;
    }

    public final synchronized void uncaughtException(Thread thread, Throwable th) {
        try {
            Error error = new Error(String.format("FATAL EXCEPTION [%s]\n", new Object[]{thread.getName()}) + String.format("Unity version     : %s\n", new Object[]{"2017.4.35f1"}) + String.format("Device model      : %s %s\n", new Object[]{Build.MANUFACTURER, Build.MODEL}) + String.format("Device fingerprint: %s\n", new Object[]{Build.FINGERPRINT}));
            error.setStackTrace(new StackTraceElement[0]);
            error.initCause(th);
            this.f275a.uncaughtException(thread, error);
        } catch (Throwable th2) {
            this.f275a.uncaughtException(thread, th);
        }
        return;
    }
}
