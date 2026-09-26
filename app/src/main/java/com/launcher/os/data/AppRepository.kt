package com.launcher.os.data

import android.content.Context
import android.content.Intent

class AppRepository(private val context: Context) {
    fun loadApps(): List<AppItem> = runCatching {
        val pm = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        pm.queryIntentActivities(intent, 0)
            .distinctBy { it.activityInfo.packageName }
            .sortedBy { it.loadLabel(pm).toString().lowercase() }
            .map {
                AppItem(
                    label = it.loadLabel(pm).toString(),
                    info = it
                )
            }
    }.getOrDefault(emptyList())
}
