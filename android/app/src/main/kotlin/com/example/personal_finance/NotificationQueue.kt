package com.example.personal_finance

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * Antrean notifikasi bank di penyimpanan native (SharedPreferences), supaya
 * notifikasi yang datang saat aplikasi tertutup total tetap tersimpan dan
 * dibaca Flutter begitu aplikasi dibuka lagi.
 *
 * Hanya notifikasi dari paket yang diizinkan Flutter ([setAllowed]) yang
 * disimpan, dan hanya dalam jumlah terbatas ([MAX]).
 */
object NotificationQueue {
    private const val PREFS = "moneta_notif_queue"
    private const val KEY_ALLOWED = "allowed"
    private const val KEY_ITEMS = "items"
    private const val MAX = 300
    private val lock = Any()

    private fun prefs(ctx: Context) =
        ctx.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun setAllowed(ctx: Context, packages: List<String>) {
        synchronized(lock) {
            prefs(ctx).edit().putStringSet(KEY_ALLOWED, packages.toSet()).commit()
        }
    }

    fun isAllowed(ctx: Context, pkg: String): Boolean =
        prefs(ctx).getStringSet(KEY_ALLOWED, emptySet())?.contains(pkg) == true

    fun add(ctx: Context, item: JSONObject) {
        synchronized(lock) {
            val p = prefs(ctx)
            val arr = JSONArray(p.getString(KEY_ITEMS, "[]"))
            val key = item.optString("key")
            for (i in 0 until arr.length()) {
                if (arr.getJSONObject(i).optString("key") == key) return
            }
            arr.put(item)
            // Buang yang terlama bila melebihi batas.
            val out = JSONArray()
            val start = maxOf(0, arr.length() - MAX)
            for (i in start until arr.length()) out.put(arr.get(i))
            p.edit().putString(KEY_ITEMS, out.toString()).commit()
        }
    }

    /** Jumlah notifikasi yang menunggu dibaca Flutter. */
    fun count(ctx: Context): Int = synchronized(lock) {
        JSONArray(prefs(ctx).getString(KEY_ITEMS, "[]")).length()
    }

    /** Ambil semua item lalu kosongkan antrean. */
    fun drain(ctx: Context): List<Map<String, Any?>> {
        synchronized(lock) {
            val p = prefs(ctx)
            val arr = JSONArray(p.getString(KEY_ITEMS, "[]"))
            val list = ArrayList<Map<String, Any?>>(arr.length())
            for (i in 0 until arr.length()) {
                val o = arr.getJSONObject(i)
                list.add(
                    mapOf(
                        "id" to o.optInt("id"),
                        "packageName" to o.optString("packageName"),
                        "title" to o.optString("title"),
                        "content" to o.optString("content"),
                        "postTime" to o.optLong("postTime"),
                    )
                )
            }
            p.edit().remove(KEY_ITEMS).commit()
            return list
        }
    }
}
