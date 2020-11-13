package com.unity3d.player;

import android.app.Dialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup.LayoutParams;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.TextView.OnEditorActionListener;

import com.reactlibrary.R;

/* renamed from: com.unity3d.player.i */
public final class TextInputDialog extends Dialog implements TextWatcher, OnClickListener {

    /* renamed from: c */
    private static int f257c = 1627389952;

    /* renamed from: d */
    private static int f258d = -1;

    /* renamed from: e */
    private static int f259e = 134217728;

    /* renamed from: f */
    private static int f260f = 67108864;
    /* access modifiers changed from: private */

    /* renamed from: a */
    public Context f261a = null;

    /* renamed from: b */
    private UnityPlayer f262b = null;

    public TextInputDialog(Context context, UnityPlayer unityPlayer, String str, int i, boolean z, boolean z2, boolean z3, String str2) {
        super(context);
        this.f261a = context;
        this.f262b = unityPlayer;
        getWindow().setGravity(80);
        getWindow().requestFeature(1);
        getWindow().setBackgroundDrawable(new ColorDrawable(0));
        setContentView(createSoftInputView());
        getWindow().setLayout(-1, -2);
        getWindow().clearFlags(2);
        if (PermissionUtil.f253a) {
            getWindow().clearFlags(f259e);
            getWindow().clearFlags(f260f);
        }
        EditText editText = (EditText) findViewById(R.id.hl_item_line);
        Button button = (Button) findViewById(R.id.hl_pwd_btn010);
        m212a(editText, str, i, z, z2, z3, str2);
        button.setOnClickListener(this);
        editText.setOnFocusChangeListener(new OnFocusChangeListener() {
            public final void onFocusChange(View view, boolean z) {
                if (z) {
                    TextInputDialog.this.getWindow().setSoftInputMode(5);
                }
            }
        });
        editText.requestFocus();
    }

    /* renamed from: a */
    private static int m209a(int i, boolean z, boolean z2, boolean z3) {
        int i2 = 0;
        int i3 = (z2 ? 131072 : 0) | (z ? 32768 : 524288);
        if (z3) {
            i2 = 128;
        }
        int i4 = i2 | i3;
        if (i < 0 || i > 10) {
            return i4;
        }
        int[] iArr = {1, 16385, 12290, 17, 2, 3, 8289, 33, 1, 16417, 17};
        return (iArr[i] & 2) != 0 ? iArr[i] : i4 | iArr[i];
    }

    /* access modifiers changed from: private */
    /* renamed from: a */
    public String m210a() {
        EditText editText = (EditText) findViewById(R.id.hl_item_line);
        if (editText == null) {
            return null;
        }
        return editText.getText().toString().trim();
    }

    /* renamed from: a */
    private void m212a(EditText editText, String str, int i, boolean z, boolean z2, boolean z3, String str2) {
        editText.setImeOptions(6);
        editText.setText(str);
        editText.setHint(str2);
        editText.setHintTextColor(f257c);
        editText.setInputType(m209a(i, z, z2, z3));
        editText.setImeOptions(33554432);
        editText.addTextChangedListener(this);
        editText.setClickable(true);
        if (!z2) {
            editText.selectAll();
        }
    }

    /* access modifiers changed from: private */
    /* renamed from: a */
    public void m214a(String str, boolean z) {
        ((EditText) findViewById(R.id.hl_item_line)).setSelection(0, 0);
        this.f262b.reportSoftInputStr(str, 1, z);
    }

    /* renamed from: a */
    public final void mo13246a(String str) {
        EditText editText = (EditText) findViewById(R.id.hl_item_line);
        if (editText != null) {
            editText.setText(str);
            editText.setSelection(str.length());
        }
    }

    public final void afterTextChanged(Editable editable) {
        this.f262b.reportSoftInputStr(editable.toString(), 0, false);
    }

    public final void beforeTextChanged(CharSequence charSequence, int i, int i2, int i3) {
    }

    public final View createSoftInputView() {
        RelativeLayout relativeLayout = new RelativeLayout(this.f261a);
        relativeLayout.setLayoutParams(new LayoutParams(-1, -1));
        relativeLayout.setBackgroundColor(f258d);
        EditText r0 = new EditText(this.f261a);
        r0.setOnFocusChangeListener(new OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                TextInputDialog.super.onWindowFocusChanged(hasFocus);
                if (hasFocus) {
                    ((InputMethodManager) TextInputDialog.this.f261a.getSystemService(Context.INPUT_METHOD_SERVICE)).showSoftInput(v, 0);
                }
            }
        });
        /*
            public final boolean onKeyPreIme(int i, KeyEvent keyEvent) {
                if (i == 4) {
                    TextInputDialog.this.m214a(TextInputDialog.this.m210a(), true);
                    return true;
                } else if (i != 84) {
                    return super.onKeyPreIme(i, keyEvent);
                } else {
                    return true;
                }
            }

            public final void onWindowFocusChanged(boolean z) {
                super.onWindowFocusChanged(z);
                if (z) {

                }
            }
        };*/
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(-1, -2);
        layoutParams.addRule(15);
        layoutParams.addRule(0, R.id.hl_pwd_btn010);
        r0.setLayoutParams(layoutParams);
        r0.setId(R.id.hl_item_line);
        relativeLayout.addView(r0);
        Button button = new Button(this.f261a);
        button.setText(this.f261a.getResources().getIdentifier("ok", "string", "android"));
        RelativeLayout.LayoutParams layoutParams2 = new RelativeLayout.LayoutParams(-2, -2);
        layoutParams2.addRule(15);
        layoutParams2.addRule(11);
        button.setLayoutParams(layoutParams2);
        button.setId(R.id.hl_pwd_btn010);
        button.setBackgroundColor(0);
        relativeLayout.addView(button);
        ((EditText) relativeLayout.findViewById(R.id.hl_item_line)).setOnEditorActionListener(new OnEditorActionListener() {
            public final boolean onEditorAction(TextView textView, int i, KeyEvent keyEvent) {
                if (i == 6) {
                    TextInputDialog.this.m214a(TextInputDialog.this.m210a(), false);
                }
                return false;
            }
        });
        relativeLayout.setPadding(16, 16, 16, 16);
        return relativeLayout;
    }

    public final void onBackPressed() {
        m214a(m210a(), true);
    }

    public final void onClick(View view) {
        m214a(m210a(), false);
    }

    public final void onTextChanged(CharSequence charSequence, int i, int i2, int i3) {
    }
}
