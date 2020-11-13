package bitter.jnibridge;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class JNIBridge {

    /* renamed from: bitter.jnibridge.JNIBridge$a */
    private static class C0228a implements InvocationHandler {

        /* renamed from: a */
        private Object f11a = new Object[0];

        /* renamed from: b */
        private long f12b;

        public C0228a(long j) {
            this.f12b = j;
        }

        /* renamed from: a */
        public final void mo5668a() {
            synchronized (this.f11a) {
                this.f12b = 0;
            }
        }

        public final void finalize() {
            synchronized (this.f11a) {
                if (this.f12b != 0) {
                    JNIBridge.delete(this.f12b);
                }
            }
        }

        public final Object invoke(Object obj, Method method, Object[] objArr) {
            Object invoke;
            synchronized (this.f11a) {
                invoke = this.f12b == 0 ? null : JNIBridge.invoke(this.f12b, method.getDeclaringClass(), method, objArr);
            }
            return invoke;
        }
    }

    static native void delete(long j);

    static void disableInterfaceProxy(Object obj) {
        ((C0228a) Proxy.getInvocationHandler(obj)).mo5668a();
    }

    static native Object invoke(long j, Class cls, Method method, Object[] objArr);

    static Object newInterfaceProxy(long j, Class[] clsArr) {
        return Proxy.newProxyInstance(JNIBridge.class.getClassLoader(), clsArr, new C0228a(j));
    }
}
