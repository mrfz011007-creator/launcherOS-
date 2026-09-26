package com.launcher.os.ui.components

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.launcher.os.data.AppItem

@Composable
fun AppIconView(item: AppItem, size: Dp = 42.dp, showLabel: Boolean = true) {
    val context = LocalContext.current
    val packageManager = context.packageManager
    val bitmap = remember(item.info.activityInfo.packageName) {
        item.info.loadIcon(packageManager).toBitmapCompat()
    }
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.clickable {
            packageManager.getLaunchIntentForPackage(item.info.activityInfo.packageName)
                ?.let(context::startActivity)
        }
    ) {
        Image(bitmap, item.label, Modifier.size(size))
        if (showLabel) {
            Spacer(Modifier.height(4.dp))
            Text(item.label, Color.White.copy(alpha = 0.9f), fontSize = 10.sp,
                maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

private fun Drawable.toBitmapCompat(): ImageBitmap {
    val bitmap = Bitmap.createBitmap(maxOf(1, intrinsicWidth), maxOf(1, intrinsicHeight), Bitmap.Config.ARGB_8888)
    val canvas = Canvas(bitmap)
    setBounds(0, 0, canvas.width, canvas.height)
    draw(canvas)
    return bitmap.asImageBitmap()
}
