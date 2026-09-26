package com.launcher.os.ui.components

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext

@Composable
fun WallpaperBackground() {
    val context = LocalContext.current
    val bitmap = remember {
        runCatching {
            WallpaperManager.getInstance(context).drawable?.toBitmapCompat()
        }.getOrNull()
    }

    if (bitmap != null) {
        Image(
            bitmap = bitmap,
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )
    } else {
        Box(Modifier.fillMaxSize().background(Color(0xFF10141C)))
    }
}

private fun Drawable.toBitmapCompat(): androidx.compose.ui.graphics.ImageBitmap {
    val w = intrinsicWidth.takeIf { it > 0 }?.coerceAtMost(1080) ?: 720
    val h = intrinsicHeight.takeIf { it > 0 }?.coerceAtMost(1920) ?: 1280
    val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.RGB_565)
    val canvas = Canvas(bitmap)
    setBounds(0, 0, w, h)
    draw(canvas)
    return bitmap.asImageBitmap()
}
