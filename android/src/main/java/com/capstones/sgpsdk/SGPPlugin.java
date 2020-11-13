package com.capstones.sgpsdk;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Process;
import android.util.Log;
import com.capstones.luaext.EventPlugin;

//TODO: Change default package name
import com.reactlibrary.R;

import java.io.File;
import java.io.FileInputStream;
import java.security.MessageDigest;

public class SGPPlugin {
    /* access modifiers changed from: private */
    public static String EventCall = "Call!";
    /* access modifiers changed from: private */
    public static int LoginStatus = 0;
    /* access modifiers changed from: private */
    public static String TAG = "SGPSDK";
    //public static InitCallback initCallback;
    public static Activity mainActivity;
    /* access modifiers changed from: private */
    public static boolean sdkReadyToStart = false;
    public static String strSDKReady = "ready";
    public static String strSDKUnReady = "unready";
    /* access modifiers changed from: private */
    public static int trigSDKReadyStartCount = 0;

    public static void OnCreate() {
        PostUserExtData("game_init", "4", "");
        sdkReadyToStart = true;
        Log.d(SGPPlugin.TAG, "onInitSuccess");
    }

    public static void loginCallback() {
        try {
            Log.d("SGPPlugin", "Login status:" + LoginStatus);
            if (SGPPlugin.LoginStatus == 1) {
                final Integer productId = 1;//FastSdk.getChannelInfo().getProductId();
                final String accessToken = EventPlugin.userToken;//userLoginResponse.getAccessToken();
                final Long uid = EventPlugin.userId;//userLoginResponse.getUid();
                final String channel = "hoolai_global";//userLoginResponse.getChannel();
                final String channelUid = String.valueOf(uid);//userLoginResponse.getChannelUid();
                boolean isBindEmail = false;
                boolean isBindPhone = false;
                boolean isQQ = false;
				Log.e("hanoivip", "login as:" + channelUid);

                final boolean bBindEmail = isBindEmail;
                final boolean bBindPhone = isBindPhone;
                final boolean bQQ = isQQ;
                EventPlugin.RegHandler(SGPPlugin.EventCall, new Runnable() {
                    public void run() {
                        int token = EventPlugin.NewCallToken();
                        EventPlugin.SetParamCount(token, 9);
                        EventPlugin.SetValStr(String.valueOf(productId));
                        EventPlugin.SetParam(token, 0);
                        EventPlugin.SetValStr(accessToken);
                        EventPlugin.SetParam(token, 1);
                        EventPlugin.SetValStr(String.valueOf(uid));
                        EventPlugin.SetParam(token, 2);
                        EventPlugin.SetValStr(channel);
                        EventPlugin.SetParam(token, 3);
                        EventPlugin.SetValStr(channelUid);
                        EventPlugin.SetParam(token, 4);
                        EventPlugin.SetValBool(bBindPhone);
                        EventPlugin.SetParam(token, 5);
                        EventPlugin.SetValBool(bBindEmail);
                        EventPlugin.SetParam(token, 6);
                        EventPlugin.SetValBool(bQQ);
                        EventPlugin.SetParam(token, 7);
                        EventPlugin.SetValBool(bQQ);
                        EventPlugin.SetParam(token, 8);
                        EventPlugin.TrigEvent("Dist_LoginSuccess_SGP", token);
                    }
                });
                SGPPlugin.LoginStatus = 2;
                return;
            }
            SGPPlugin.LoginStatus = -1;
        } catch (Exception e) {
            Log.e(SGPPlugin.TAG, "验证access出现异常", e);
        }
    }

    public static void DoPay(String priceLocal, String productName, String productId, double amount, String callbackInfo) {
        Log.e("hanoivip", "DoPay");
    }

    public static void OnStart() {
        Log.e("hanoivip", "SGPPlugin OnStart");
    }

    public static void OnRestart() {
        Log.e("hanoivip", "SGPPlugin OnRestart");
    }

    public static void OnStop() {
        Log.e("hanoivip", "SGPPlugin OnStop");
    }

    public static void OnConfigurationChanged(Configuration newConfig) {
        Log.e("hanoivip", "OnConfigurationChanged");
    }

    public static void PostUserExtData(String action, String phylum, String classfield) {
        Log.d("SGPPlugin", "Post user ext data " + action + ": " + classfield);
    }

    public static void OnActivityResult(int requestCode, int resultCode, Intent data) {
        Log.e("hanoivip", "OnActivityResult");
    }

    public static void OnNewIntent(Intent intent) {
        Log.e("hanoivip", "OnNewIntent");
    }

    public static void OnSaveInstanceState(Bundle outState) {
        Log.e("hanoivip", "OnSaveInstanceState");

    }

    public static void OnBackPressed() {
        Log.e("hanoivip", "OnBackPressed");
    }

    public static String getMd5ByFile(File file) {
        System.out.print("getMd5ByFile step 1");
        if (!file.isFile()) {
            return "";
        }
        byte[] buffer = new byte[1024];
        try {
            MessageDigest digest = MessageDigest.getInstance("MD5");
            FileInputStream in = new FileInputStream(file);
            while (true) {
                try {
                    int len = in.read(buffer, 0, 1024);
                    if (len == -1) {
                        break;
                    }
                    digest.update(buffer, 0, len);
                } catch (Exception e) {
                    e = e;
                    FileInputStream fileInputStream = in;
                    e.printStackTrace();
                    return "";
                }
            }
            in.close();
            byte[] md5Bytes = digest.digest();
            StringBuffer hexValue = new StringBuffer();
            for (byte b : md5Bytes) {
                int val = b & 255;
                if (val < 16) {
                    hexValue.append("0");
                }
                hexValue.append(Integer.toHexString(val));
            }
            return hexValue.toString();
        } catch (Exception e2) {
            e2.printStackTrace();
            return "";
        }
    }

    public static String getObbPath() {
        String path = null;
        try {
            int code = mainActivity.getPackageManager().getPackageInfo(mainActivity.getPackageName(), 0).versionCode;
            String obb_package = mainActivity.getPackageName();
            return String.format("%s/main.%d.%s.obb", new Object[]{mainActivity.getObbDir().getAbsolutePath(), Integer.valueOf(code), obb_package});
        } catch (NameNotFoundException e) {
            e.printStackTrace();
            return path;
        }
    }

    public static void Init() {
        EventPlugin.RegHandler("SDK_HasAccountSystem", new Runnable() {
            public void run() {
                EventPlugin.SetParamCount(1, 1);
                EventPlugin.SetValBool(true);
                EventPlugin.SetParam(1, 0);
            }
        });
        EventPlugin.RegHandler("SDK_READY_TO_START", new Runnable() {
            public void run() {
                EventPlugin.SetParamCount(1, 1);
                EventPlugin.SetValStr(SGPPlugin.sdkReadyToStart ? SGPPlugin.strSDKReady : SGPPlugin.strSDKUnReady);
                EventPlugin.SetParam(1, 0);
                SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                    public void run() {
                        SGPPlugin.trigSDKReadyStartCount = SGPPlugin.trigSDKReadyStartCount + 1;
                        if (!SGPPlugin.sdkReadyToStart && SGPPlugin.trigSDKReadyStartCount > 150) {
                            //FastSdk.onCreate(SGPPlugin.mainActivity, SGPPlugin.initCallback);
                        }
                    }
                });
            }
        });
        EventPlugin.RegHandler("SDK_Login", RunOnUIThread(new Runnable() {
            public void run() {
                SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                    public void run() {
                        EventPlugin.TrigEvent("Dist_SGPSDK_Close", EventPlugin.NewCallToken());
                        SGPPlugin.LoginStatus = 1;
                        //FastSdk.login(SGPPlugin.mainActivity, null);
                        //hanoivip
                        SGPPlugin.loginCallback();
                    }
                });
            }
        }));
        EventPlugin.RegHandler("SDK_Logout", new Runnable() {
            public void run() {
                if (SGPPlugin.LoginStatus != 0) {
                    SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                        public void run() {
                            //FastSdk.logout(SGPPlugin.mainActivity, null);
                            Log.e("hanoivip", "SDK_Logout");
                        }
                    });
                }
                EventPlugin.SetParamCount(1, 1);
                EventPlugin.SetValBool(true);
                EventPlugin.SetParam(1, 0);
            }
        });
        EventPlugin.RegHandler("SDK_Pay", new Runnable() {
            public void run() {
                EventPlugin.GetParam(0, 0);
                final String productName = EventPlugin.GetValStr();
                EventPlugin.GetParam(0, 1);
                final String productId = EventPlugin.GetValStr();
                EventPlugin.GetParam(0, 2);
                double GetValNum = EventPlugin.GetValNum();
                EventPlugin.GetParam(0, 3);
                final String callbackInfo = EventPlugin.GetValStr();

                EventPlugin.TrigEvent("Dist_PayFail", EventPlugin.NewCallToken());
            }
        });
        EventPlugin.RegHandler("SDK_GetProducts", new Runnable() {
            public void run() {
                Log.e("hanoivip", "SDK_GetProducts");
            }
        });
        EventPlugin.RegHandler("SDK_Exit", RunOnUIThread(new Runnable() {
            public void run() {
                Log.e("hanoivip", "SDK_Exit");
                SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                    public void run() {
                        AlertDialog.Builder builder = new AlertDialog.Builder(SGPPlugin.mainActivity);
                        builder.setTitle(R.string.app_name);
                        builder.setMessage("Do you want to stop ?");
                        builder.setIcon(R.drawable.ic_launcher);
                        builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.dismiss();

                                SGPPlugin.mainActivity.moveTaskToBack(true);
                                SGPPlugin.mainActivity.finish();
                                //hanoivip: do not kill wrapper app
                                //Intent intent = new Intent("android.intent.action.MAIN");
                                //intent.addCategory("android.intent.category.HOME");
                                //intent.setFlags(Intent.CATEGORY_LAUNCHER);
                                //SGPPlugin.mainActivity.startActivity(intent);
                                //Process.killProcess(Process.myPid());
                            }
                        });
                        builder.setNegativeButton("No", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.dismiss();
                            }
                        });
                        AlertDialog alert = builder.create();
                        alert.show();
                    }
                });
                EventPlugin.TrigEvent("Dist_CanShowSDKExit", EventPlugin.NewCallToken());
            }
        }));
        EventPlugin.RegHandler("SDK_HasAccountManage", new Runnable() {
            public void run() {
                EventPlugin.SetParamCount(1, 1);
                EventPlugin.SetValBool(false);
                EventPlugin.SetParam(1, 0);
            }
        });
        EventPlugin.RegHandler("SDK_ShowAccountManage", RunOnUIThread(new Runnable() {
            public void run() {
                SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                    public void run() {
                        Log.e("hanoivip", "SDK_ShowAccountManage");
                        //FastSdk.accountManage(SGPPlugin.mainActivity, null);
                    }
                });
            }
        }));
        EventPlugin.RegHandler("SDK_SharePhotoToFacebook", new Runnable() {
            public void run() {
                EventPlugin.GetParam(0, 0);
                final String photoUrl = EventPlugin.GetValStr();

            }
        });
        EventPlugin.RegHandler("SDK_HoolaiBIReport", new Runnable() {
            public void run() {
                EventPlugin.GetParam(0, 0);
                final String metric = EventPlugin.GetValStr();
                EventPlugin.GetParam(0, 1);
                final String jsonString = EventPlugin.GetValStr();
                SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                    public void run() {
                        /*
                        FastSdk.getBiInterface(SGPPlugin.mainActivity).sendBIData(metric, jsonString, new SendBICallback() {
                            public void onResult(String s) {
                                System.out.println("cap sendBIData : " + s);
                            }
                        });*/
                    }
                });
            }
        });
        EventPlugin.RegHandler("SDK_HoolaiADReport", new Runnable() {
            public void run() {
                EventPlugin.GetParam(0, 0);
                final String eventName = EventPlugin.GetValStr();
                EventPlugin.GetParam(0, 1);
                String GetValStr = EventPlugin.GetValStr();
                EventPlugin.GetParam(0, 2);
                String GetValStr2 = EventPlugin.GetValStr();
                System.out.println("SDK_HoolaiADReport ： " + eventName + "\n |");
                SGPPlugin.mainActivity.runOnUiThread(new Runnable() {
                    public void run() {

                    }
                });
            }
        });
        EventPlugin.RegHandler("SDK_PushUserOp", new Runnable() {
            public void run() {
                Log.e("hanoivip", "SDK_PushUserOp");
            }
        });
        EventPlugin.RegHandler("GET_MAIN_OBB_PATH", new Runnable() {
            public void run() {
                String result = null;
                try {
                    String isObb = SGPPlugin.mainActivity.getPackageManager().getApplicationInfo(SGPPlugin.mainActivity.getPackageName(), PackageManager.GET_META_DATA).metaData.get("IS_OBB").toString();
                    System.out.println("GET_MAIN_OBB_PATH step 1");
                    if ("true".equals(isObb)) {
                        System.out.println("isObb equals = true");
                        String path = SGPPlugin.getObbPath();
                        result = path;
                        System.out.println("GET_MAIN_OBB_PATH step 2 path = " + path);
                    }
                    final String ret = result;
                    EventPlugin.RegHandler(SGPPlugin.EventCall, new Runnable() {
                        public void run() {
                            EventPlugin.SetParamCount(1, 1);
                            EventPlugin.SetValStr(ret);
                            EventPlugin.SetParam(1, 0);
                        }
                    });
                } catch (NameNotFoundException e) {
                    e.printStackTrace();
                } catch (Exception e2) {
                    e2.printStackTrace();
                }
            }
        });
        EventPlugin.RegHandler("CHECK_MAIN_OBB", new Runnable() {
            public void run() {
                try {
                    String path = SGPPlugin.getObbPath();
                    System.out.println("CHECK_MAIN_OBB step 1 path = " + path);
                    boolean ret = false;
                    File file = new File(path);
                    if (file.exists()) {
                        String md5 = SGPPlugin.mainActivity.getPackageManager().getApplicationInfo(SGPPlugin.mainActivity.getPackageName(), PackageManager.GET_META_DATA).metaData.get("OBB_CHECK_MD5").toString();
                        String fileMd5 = SGPPlugin.getMd5ByFile(file);
                        System.out.println("CHECK_MAIN_OBB step 2 md5 = " + md5 + " fileMd5 = " + fileMd5);
                        if (fileMd5.equals(md5)) {
                            ret = true;
                        }
                    }
                    EventPlugin.SetParamCount(1, 1);
                    EventPlugin.SetValBool(ret);
                    EventPlugin.SetParam(1, 0);
                } catch (NameNotFoundException e) {
                    e.printStackTrace();
                }
            }
        });
        EventPlugin.RegHandler("SDK_Report", new Runnable() {
            public void run() {
                System.out.println("SDK_Report");

            }
        });
        EventPlugin.RegHandler("ObbZipArchiveIsNone", new Runnable() {
            public void run() {
                System.out.println("ObbZipArchiveIsNone !");

            }
        });
    }

    public static void OnDestroy() {
        Log.e("hanoivip", "SGPPLugin onDestroy");
    }

    public static void OnResume() {
        Log.e("hanoivip", "SGPPLugin onResume");
    }

    public static void OnPause() {
        Log.e("hanoivip", "SGPPLugin onPause");
    }

    public static Runnable RunOnUIThread(final Runnable raw) {
        return new Runnable() {
            public void run() {
                SGPPlugin.mainActivity.runOnUiThread(raw);
            }
        };
    }
}
