package com.unity3d.player;

import android.app.Activity;
import android.app.FragmentTransaction;
import android.content.pm.ActivityInfo;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageItemInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Bundle;
import java.util.LinkedList;

/* renamed from: com.unity3d.player.f */
public final class PermissionHelper implements C0562c {
    /* renamed from: a */
    private static boolean m207a(PackageItemInfo packageItemInfo) {
        try {
            return packageItemInfo.metaData.getBoolean("unityplayer.SkipPermissionsDialog");
        } catch (Exception e) {
            return false;
        }
    }

    /* renamed from: a */
    public final void mo13243a(Activity activity, Runnable runnable) {
        String[] strArr;
        if (activity != null) {
            PackageManager packageManager = activity.getPackageManager();
            try {
                ActivityInfo activityInfo = packageManager.getActivityInfo(activity.getComponentName(), PackageManager.GET_META_DATA);
                ApplicationInfo applicationInfo = packageManager.getApplicationInfo(activity.getPackageName(), PackageManager.GET_META_DATA);
                if (m207a(activityInfo) || m207a(applicationInfo)) {
                    runnable.run();
                    return;
                }
            } catch (Exception e) {
            }
            try {
                PackageInfo packageInfo = packageManager.getPackageInfo(activity.getPackageName(), PackageManager.GET_PERMISSIONS);
                if (packageInfo.requestedPermissions == null) {
                    packageInfo.requestedPermissions = new String[0];
                }
                LinkedList linkedList = new LinkedList();
                for (String str : packageInfo.requestedPermissions) {
                    try {
                        if (!((packageManager.getPermissionInfo(str, PackageManager.GET_META_DATA).protectionLevel & 1) == 0 || activity.checkCallingOrSelfPermission(str) == PackageManager.PERMISSION_GRANTED)) {
                            linkedList.add(str);
                        }
                    } catch (NameNotFoundException e2) {
                        MyLog.Log(5, "Failed to get permission info for " + str + ", manifest likely missing custom permission declaration");
                        MyLog.Log(5, "Permission " + str + " ignored");
                    }
                }
                if (linkedList.isEmpty()) {
                    runnable.run();
                    return;
                }
                RequestPermissionFragment gVar = new RequestPermissionFragment(runnable);
                Bundle bundle = new Bundle();
                bundle.putStringArray("PermissionNames", (String[]) linkedList.toArray(new String[0]));
                gVar.setArguments(bundle);
                FragmentTransaction beginTransaction = activity.getFragmentManager().beginTransaction();
                beginTransaction.add(0, gVar);
                beginTransaction.commit();
            } catch (Exception e3) {
                MyLog.Log(6, "Unable to query for permission: " + e3.getMessage());
            }
        }
    }
}
