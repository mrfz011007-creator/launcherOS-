package com.launcher.os.ui.components

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
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
    val drawable = remember { WallpaperManager.getInstance(context).drawable }
    val bitmap = remember(drawable) { drawable?.toBitmapCompat() }
    if (bitmap != null) {
        Image(
            bitmap = bitmap,
            contentDescription = null,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize().background(Color.Black)
        )
    } else {
        androidx.compose.foundation.layout.Box(
            Modifier.fillMaxSize().background(Color.Black)
        )
    }
}

private fun Drawable.toBitmapCompat(): androidx.compose.ui.graphics.ImageBitmap {
    val w = intrinsicWidth.coerceIn(1, 1440)
    val h = intrinsicHeight.coerceIn(1, 2560)
    val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    setBounds(0, 0, w, h)
    draw(canvas)
    return bitmap.asImageBitmap()
}
