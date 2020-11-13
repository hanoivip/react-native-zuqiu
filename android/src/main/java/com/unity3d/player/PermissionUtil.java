package com.unity3d.player;

import android.os.Build.VERSION;

/* renamed from: com.unity3d.player.h */
public final class PermissionUtil {

    /* renamed from: a */
    static final boolean f253a = (VERSION.SDK_INT >= 19);

    /* renamed from: b */
    static final boolean f254b = (VERSION.SDK_INT >= 21);

    /* renamed from: c */
    static final boolean manualAsk;

    /* renamed from: d */
    static final C0562c helper;

    static {
        boolean z = true;
        if (VERSION.SDK_INT < 23) {
            z = false;
        }
        manualAsk = z;
        helper = z ? new PermissionHelper() : null;
    }
}
