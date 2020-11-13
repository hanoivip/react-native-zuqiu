package com.unity3d.player;

import android.os.Build.VERSION;

import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.security.NoSuchAlgorithmException;

import javax.net.ssl.HandshakeCompletedEvent;
import javax.net.ssl.HandshakeCompletedListener;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLPeerUnverifiedException;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;

/* renamed from: com.unity3d.player.a */
public final class MySSLSocketFactory extends SSLSocketFactory {

    /* renamed from: c */
    private static volatile SSLSocketFactory f237c;

    /* renamed from: d */
    private static final Object[] f238d = new Object[0];

    /* renamed from: e */
    private static final boolean f239e;

    /* renamed from: a */
    private final SSLSocketFactory f240a;

    /* renamed from: b */
    private final C0559a f241b = new C0559a();

    /* renamed from: com.unity3d.player.a$a */
    class C0559a implements HandshakeCompletedListener {
        C0559a() {
        }

        public final void handshakeCompleted(HandshakeCompletedEvent handshakeCompletedEvent) {
            SSLSession session = handshakeCompletedEvent.getSession();
            session.getCipherSuite();
            session.getProtocol();
            try {
                session.getPeerPrincipal().getName();
            } catch (SSLPeerUnverifiedException e) {
            }
        }
    }

    static {
        boolean z = false;
        if (VERSION.SDK_INT >= 16 && VERSION.SDK_INT < 20) {
            z = true;
        }
        f239e = z;
    }

    private MySSLSocketFactory() throws Exception {
        SSLContext instance = SSLContext.getInstance("TLS");
        instance.init(null, null, null);
        this.f240a = instance.getSocketFactory();
    }

    /* renamed from: a */
    private static Socket m204a(Socket socket) throws IOException, UnknownHostException {
        if (socket != null && (socket instanceof SSLSocket) && f239e) {
            ((SSLSocket) socket).setEnabledProtocols(((SSLSocket) socket).getSupportedProtocols());
        }
        return socket;
    }

    /* renamed from: a */
    public static SSLSocketFactory m205a() {
        synchronized (f238d) {
            if (f237c != null) {
                SSLSocketFactory sSLSocketFactory = f237c;
                return sSLSocketFactory;
            }
            try {
                MySSLSocketFactory aVar = new MySSLSocketFactory();
                f237c = aVar;
                return aVar;
            } catch (Exception e) {
                MyLog.Log(5, "CustomSSLSocketFactory: Failed to create SSLSocketFactory (" + e.getMessage() + ")");
                return null;
            }
        }
    }

    public final Socket createSocket() throws IOException {
        return m204a(this.f240a.createSocket());
    }

    public final Socket createSocket(String str, int i) throws IOException, UnknownHostException {
        return m204a(this.f240a.createSocket(str, i));
    }

    public final Socket createSocket(String str, int i, InetAddress inetAddress, int i2) throws IOException, UnknownHostException {
        return m204a(this.f240a.createSocket(str, i, inetAddress, i2));
    }

    public final Socket createSocket(InetAddress inetAddress, int i) throws IOException, UnknownHostException {
        return m204a(this.f240a.createSocket(inetAddress, i));
    }

    public final Socket createSocket(InetAddress inetAddress, int i, InetAddress inetAddress2, int i2) throws IOException, UnknownHostException {
        return m204a(this.f240a.createSocket(inetAddress, i, inetAddress2, i2));
    }

    public final Socket createSocket(Socket socket, String str, int i, boolean z) throws IOException, UnknownHostException {
        return m204a(this.f240a.createSocket(socket, str, i, z));
    }

    public final String[] getDefaultCipherSuites() {
        return this.f240a.getDefaultCipherSuites();
    }

    public final String[] getSupportedCipherSuites() {
        return this.f240a.getSupportedCipherSuites();
    }
}
