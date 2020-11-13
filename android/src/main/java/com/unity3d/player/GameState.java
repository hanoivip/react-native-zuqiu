package com.unity3d.player;

/* renamed from: com.unity3d.player.l */
final class GameState {

    /* renamed from: a */
    private static boolean f276a = false;

    /* renamed from: b */
    private boolean f277b;

    /* renamed from: c */
    private boolean f278c;

    /* renamed from: d */
    private boolean f279d;

    /* renamed from: e */
    private boolean f280e;

    GameState() {
        this.f277b = !PermissionUtil.manualAsk;
        this.f278c = false;
        this.f279d = false;
        this.f280e = true;
    }

    /* renamed from: a */
    static void onInitDone() {
        f276a = true;
    }

    /* renamed from: b */
    static void reset() {
        f276a = false;
    }

    /* renamed from: c */
    static boolean isInitDone() {
        return f276a;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: a */
    public final void mo13261a(boolean z) {
        this.f278c = z;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: b */
    public final void mo13262b(boolean z) {
        this.f280e = z;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: c */
    public final void mo13263c(boolean z) {
        this.f279d = z;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: d */
    public final void mo13264d() {
        this.f277b = true;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: e */
    public final boolean mo13265e() {
        return this.f280e;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: f */
    public final boolean mo13266f() {
        return f276a && this.f278c && this.f277b && !this.f280e && !this.f279d;
    }

    /* access modifiers changed from: 0000 */
    /* renamed from: g */
    public final boolean mo13267g() {
        return this.f279d;
    }

    public final String toString() {
        return super.toString();
    }
}
