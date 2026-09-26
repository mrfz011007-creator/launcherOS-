package com.launcher.os.data

import android.content.pm.ResolveInfo

data class AppItem(
    val label: String,
    val info: ResolveInfo
)
