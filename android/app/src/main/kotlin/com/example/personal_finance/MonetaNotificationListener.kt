package com.example.personal_finance

import android.app.Notification
import android.content.ComponentName
import android.os.Build
import android.service.notification.StatusBarNotification
import android.util.Log
import notification.listener.service.NotificationListener
import org.json.JSONObject

/**
 * Listener notifikasi milik aplikasi. Dijalankan sistem Android walau
 * aplikasi tertutup total, sehingga setiap notifikasi dari aplikasi bank yang
 * dipantau langsung disimpan ke [NotificationQueue] tanpa menunggu Flutter.
 * Event live ke plugin tetap diteruskan lewat super.
 */
class MonetaNotificationListener : NotificationListener() {

    override fun onNotificationPosted(notification: StatusBarNotification?) {
        try {
            capture(notification)
        } catch (e: Exception) {
            Log.e(TAG, "Gagal menyimpan notifikasi: ${e.message}")
        }
        super.onNotificationPosted(notification)
    }

    private fun capture(sbn: StatusBarNotification?) {
        if (sbn == null) return
        val pkg = sbn.packageName ?: return
        if (!NotificationQueue.isAllowed(this, pkg)) return
        val n = sbn.notification ?: return
        if ((n.flags and Notification.FLAG_ONGOING_EVENT) != 0) return

        val extras = n.extras ?: return
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
            ?: extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()
            ?: ""
        if (title.isEmpty() && text.isEmpty()) return

        val item = JSONObject()
            .put("key", "$pkg|${sbn.postTime}|${sbn.id}")
            .put("id", sbn.id)
            .put("packageName", pkg)
            .put("title", title)
            .put("content", text)
            .put("postTime", sbn.postTime)
        NotificationQueue.add(this, item)
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        // Minta sistem menyambungkan ulang listener milik kita.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try {
                requestRebind(ComponentName(this, MonetaNotificationListener::class.java))
            } catch (e: Exception) {
                Log.e(TAG, "requestRebind gagal: ${e.message}")
            }
        }
    }

    companion object {
        private const val TAG = "MonetaNotifListener"
    }
}
