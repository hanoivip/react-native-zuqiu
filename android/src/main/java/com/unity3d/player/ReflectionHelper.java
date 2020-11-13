package com.unity3d.player;

import android.util.Log;

import java.lang.reflect.Array;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Member;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Iterator;

final class ReflectionHelper {
    protected static boolean LOG = false;
    protected static final boolean LOGV = false;

    /* renamed from: a */
    private static C0528a[] f135a = new C0528a[4096];
    /* access modifiers changed from: private */

    /* renamed from: b */
    public static long f136b = 0;

    /* renamed from: com.unity3d.player.ReflectionHelper$a */
    private static class C0528a {

        /* renamed from: a */
        public volatile Member f140a;

        /* renamed from: b */
        private Class f141b;

        /* renamed from: c */
        private String f142c;

        /* renamed from: d */
        private String f143d;

        /* renamed from: e */
        private final int f144e = (((((this.f141b.hashCode() + 527) * 31) + this.f142c.hashCode()) * 31) + this.f143d.hashCode());

        C0528a(Class cls, String str, String str2) {
            this.f141b = cls;
            this.f142c = str;
            this.f143d = str2;
        }

        public final boolean equals(Object obj) {
            if (obj == this) {
                return true;
            }
            if (!(obj instanceof C0528a)) {
                return false;
            }
            C0528a aVar = (C0528a) obj;
            return this.f144e == aVar.f144e && this.f143d.equals(aVar.f143d) && this.f142c.equals(aVar.f142c) && this.f141b.equals(aVar.f141b);
        }

        public final int hashCode() {
            return this.f144e;
        }
    }

    ReflectionHelper() {
    }

    /* renamed from: a */
    private static float m135a(Class cls, Class cls2) {
        if (cls.equals(cls2)) {
            return 1.0f;
        }
        if (!cls.isPrimitive() && !cls2.isPrimitive()) {
            try {
                if (cls.asSubclass(cls2) != null) {
                    return 0.5f;
                }
            } catch (ClassCastException e) {
            }
            try {
                if (cls2.asSubclass(cls) != null) {
                    return 0.1f;
                }
            } catch (ClassCastException e2) {
            }
        }
        return 0.0f;
    }

    /* renamed from: a */
    private static float m136a(Class cls, Class[] clsArr, Class[] clsArr2) {
        int i = 0;
        if (clsArr2.length == 0) {
            return 0.1f;
        }
        if ((clsArr == null ? 0 : clsArr.length) + 1 != clsArr2.length) {
            return 0.0f;
        }
        float f = 1.0f;
        if (clsArr != null) {
            int i2 = 0;
            while (i < clsArr.length) {
                f *= m135a(clsArr[i], clsArr2[i2]);
                i++;
                i2++;
            }
        }
        return f * m135a(cls, clsArr2[clsArr2.length - 1]);
    }

    /* renamed from: a */
    private static Class m138a(String str, int[] iArr) {
        while (true) {
            if (iArr[0] >= str.length()) {
                break;
            }
            int i = iArr[0];
            iArr[0] = i + 1;
            char charAt = str.charAt(i);
            if (charAt != '(' && charAt != ')') {
                if (charAt == 'L') {
                    int indexOf = str.indexOf(59, iArr[0]);
                    if (indexOf != -1) {
                        String substring = str.substring(iArr[0], indexOf);
                        iArr[0] = indexOf + 1;
                        try {
                            return Class.forName(substring.replace('/', '.'));
                        } catch (ClassNotFoundException e) {
                        }
                    }
                } else if (charAt == 'Z') {
                    return Boolean.TYPE;
                } else {
                    if (charAt == 'I') {
                        return Integer.TYPE;
                    }
                    if (charAt == 'F') {
                        return Float.TYPE;
                    }
                    if (charAt == 'V') {
                        return Void.TYPE;
                    }
                    if (charAt == 'B') {
                        return Byte.TYPE;
                    }
                    if (charAt == 'S') {
                        return Short.TYPE;
                    }
                    if (charAt == 'J') {
                        return Long.TYPE;
                    }
                    if (charAt == 'D') {
                        return Double.TYPE;
                    }
                    if (charAt == '[') {
                        return Array.newInstance(m138a(str, iArr), 0).getClass();
                    }
                    Log.e("RefectionHelper", "! parseType; " + charAt + " is not known!");
                }
            }
        }
        return null;
    }

    /* renamed from: a */
    private static void m141a(C0528a aVar, Member member) {
        aVar.f140a = member;
        f135a[aVar.hashCode() & (f135a.length - 1)] = aVar;
    }

    /* renamed from: a */
    private static boolean m142a(C0528a aVar) {
        C0528a aVar2 = f135a[aVar.hashCode() & (f135a.length - 1)];
        if (!aVar.equals(aVar2)) {
            return false;
        }
        aVar.f140a = aVar2.f140a;
        return true;
    }

    /* renamed from: a */
    private static Class[] m143a(String str) {
        int[] iArr = {0};
        ArrayList arrayList = new ArrayList();
        while (iArr[0] < str.length()) {
            Class a = m138a(str, iArr);
            if (a == null) {
                break;
            }
            arrayList.add(a);
        }
        Class[] clsArr = new Class[arrayList.size()];
        Iterator it = arrayList.iterator();
        int i = 0;
        while (it.hasNext()) {
            int i2 = i + 1;
            clsArr[i] = (Class) it.next();
            i = i2;
        }
        return clsArr;
    }

    protected static void endUnityLaunch() {
        f136b++;
    }

    protected static Constructor getConstructorID(Class cls, String str) {
        Constructor constructor;
        Constructor constructor2;
        Constructor constructor3;
        Constructor constructor4 = null;
        C0528a aVar = new C0528a(cls, "", str);
        if (m142a(aVar)) {
            constructor2 = (Constructor) aVar.f140a;
        } else {
            Class[] a = m143a(str);
            float f = 0.0f;
            Constructor[] constructors = cls.getConstructors();
            int length = constructors.length;
            int i = 0;
            while (true) {
                if (i >= length) {
                    constructor = constructor4;
                    break;
                }
                constructor = constructors[i];
                float a2 = m136a(Void.TYPE, constructor.getParameterTypes(), a);
                if (a2 > f) {
                    if (a2 == 1.0f) {
                        break;
                    }
                    constructor3 = constructor;
                } else {
                    a2 = f;
                    constructor3 = constructor4;
                }
                i++;
                constructor4 = constructor3;
                f = a2;
            }
            m141a(aVar, (Member) constructor);
            constructor2 = constructor;
        }
        if (constructor2 != null) {
            return constructor2;
        }
        throw new NoSuchMethodError("<init>" + str + " in class " + cls.getName());
    }

    protected static Field getFieldID(Class cls, String str, String str2, boolean z) {
        Field field;
        float f;
        Field field2;
        C0528a aVar = new C0528a(cls, str, str2);
        if (m142a(aVar)) {
            field = (Field) aVar.f140a;
        } else {
            Class[] a = m143a(str2);
            field = null;
            float f2 = 0.0f;
            while (cls != null) {
                Field[] declaredFields = cls.getDeclaredFields();
                int length = declaredFields.length;
                int i = 0;
                Field field3 = field;
                while (true) {
                    if (i >= length) {
                        field = field3;
                        break;
                    }
                    Field field4 = declaredFields[i];
                    if (z == Modifier.isStatic(field4.getModifiers()) && field4.getName().compareTo(str) == 0) {
                        f = m136a(field4.getType(), (Class[]) null, a);
                        if (f > f2) {
                            if (f == 1.0f) {
                                f2 = f;
                                field = field4;
                                break;
                            }
                            field2 = field4;
                            i++;
                            field3 = field2;
                            f2 = f;
                        }
                    }
                    f = f2;
                    field2 = field3;
                    i++;
                    field3 = field2;
                    f2 = f;
                }
                if (f2 == 1.0f || cls.isPrimitive() || cls.isInterface() || cls.equals(Object.class) || cls.equals(Void.TYPE)) {
                    break;
                }
                cls = cls.getSuperclass();
            }
            m141a(aVar, (Member) field);
        }
        if (field != null) {
            return field;
        }
        String str3 = "no %s field with name='%s' signature='%s' in class L%s;";
        Object[] objArr = new Object[4];
        objArr[0] = z ? "static" : "non-static";
        objArr[1] = str;
        objArr[2] = str2;
        objArr[3] = cls.getName();
        throw new NoSuchFieldError(String.format(str3, objArr));
    }

    protected static Method getMethodID(Class cls, String str, String str2, boolean z) {
        Method method;
        float f;
        Method method2;
        C0528a aVar = new C0528a(cls, str, str2);
        if (m142a(aVar)) {
            method = (Method) aVar.f140a;
        } else {
            Class[] a = m143a(str2);
            method = null;
            float f2 = 0.0f;
            while (cls != null) {
                Method[] declaredMethods = cls.getDeclaredMethods();
                int length = declaredMethods.length;
                int i = 0;
                Method method3 = method;
                while (true) {
                    if (i >= length) {
                        method = method3;
                        break;
                    }
                    Method method4 = declaredMethods[i];
                    if (z == Modifier.isStatic(method4.getModifiers()) && method4.getName().compareTo(str) == 0) {
                        f = m136a(method4.getReturnType(), method4.getParameterTypes(), a);
                        if (f > f2) {
                            if (f == 1.0f) {
                                f2 = f;
                                method = method4;
                                break;
                            }
                            method2 = method4;
                            i++;
                            method3 = method2;
                            f2 = f;
                        }
                    }
                    f = f2;
                    method2 = method3;
                    i++;
                    method3 = method2;
                    f2 = f;
                }
                if (f2 == 1.0f || cls.isPrimitive() || cls.isInterface() || cls.equals(Object.class) || cls.equals(Void.TYPE)) {
                    break;
                }
                cls = cls.getSuperclass();
            }
            m141a(aVar, (Member) method);
        }
        if (method != null) {
            return method;
        }
        String str3 = "no %s method with name='%s' signature='%s' in class L%s;";
        Object[] objArr = new Object[4];
        objArr[0] = z ? "static" : "non-static";
        objArr[1] = str;
        objArr[2] = str2;
        objArr[3] = cls.getName();
        throw new NoSuchMethodError(String.format(str3, objArr));
    }

    /* access modifiers changed from: private */
    public static native void nativeProxyFinalize(int i);

    /* access modifiers changed from: private */
    public static native Object nativeProxyInvoke(int i, String str, Object[] objArr);

    protected static Object newProxyInstance(int i, Class cls) {
        return newProxyInstance(i, new Class[]{cls});
    }

    protected static Object newProxyInstance(final int i, final Class[] clsArr) {
        return Proxy.newProxyInstance(ReflectionHelper.class.getClassLoader(), clsArr, new InvocationHandler() {

            /* renamed from: c */
            private long f139c = ReflectionHelper.f136b;

            /* access modifiers changed from: protected */
            public final void finalize() {
                try {
                    if (this.f139c == ReflectionHelper.f136b) {
                        ReflectionHelper.nativeProxyFinalize(i);
                    }
                } finally {
                    //super.finalize();
                }
            }

            public final Object invoke(Object obj, Method method, Object[] objArr) {
                if (this.f139c == ReflectionHelper.f136b) {
                    return ReflectionHelper.nativeProxyInvoke(i, method.getName(), objArr);
                }
                Log.e("RefectionHelper", "Scripting proxy object was destroyed, because Unity player was unloaded.");
                return null;
            }
        });
    }
}
