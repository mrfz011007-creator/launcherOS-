package com.launcher.os.data

import android.content.Context
import android.content.Intent

class AppRepository(private val context: Context) {
    fun loadApps(): List<AppItem> {
        val packageManager = context.packageManager
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)

        return packageManager.queryIntentActivities(intent, 0)
            .distinctBy { it.activityInfo.packageName }
            .sortedBy { it.loadLabel(packageManager).toString().lowercase() }
            .map {
                AppItem(
                    label = it.loadLabel(packageManager).toString(),
                    info = it
                )
            }
    }
}
