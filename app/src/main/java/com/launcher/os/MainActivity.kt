package com.launcher.os

import android.content.Intent
import android.content.pm.ResolveInfo
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Apps
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Wifi
import androidx.compose.material.icons.filled.BatteryFull
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.graphics.asImageBitmap
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent { LauncherOSApp() }
    }
}

data class AppItem(val label: String, val info: ResolveInfo)

@Composable
fun LauncherOSApp() {
    val context = LocalContext.current
    var apps by remember { mutableStateOf(emptyList<AppItem>()) }
    var query by remember { mutableStateOf("") }
    var showDrawer by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }
    var now by remember { mutableStateOf(Date()) }

    LaunchedEffect(Unit) {
        while (true) { now = Date(); kotlinx.coroutines.delay(1000) }
    }
    LaunchedEffect(Unit) {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        apps = context.packageManager.queryIntentActivities(intent, 0)
            .distinctBy { it.activityInfo.packageName }
            .sortedBy { it.loadLabel(context.packageManager).toString().lowercase() }
            .map { AppItem(it.loadLabel(context.packageManager).toString(), it) }
    }

    val filtered = apps.filter { it.label.contains(query, true) }
    val time = SimpleDateFormat("HH:mm", Locale.getDefault()).format(now)
    val date = SimpleDateFormat("EEEE, d MMMM", Locale("id", "ID")).format(now)

    Box(modifier = Modifier.fillMaxSize().background(Color(0xFF071018))) {
        // Liquid-glass color blobs
        Box(Modifier.size(300.dp).offset((-80).dp, (-60).dp).blur(70.dp).background(Color(0xFF3B82F6), RoundedCornerShape(50)))
        Box(Modifier.size(260.dp).align(Alignment.BottomEnd).offset(70.dp, 60.dp).blur(80.dp).background(Color(0xFF8B5CF6), RoundedCornerShape(50)))
        Box(Modifier.size(180.dp).align(Alignment.CenterEnd).offset(40.dp, (-100).dp).blur(60.dp).background(Color(0xFF06B6D4), RoundedCornerShape(50)))

        Column(Modifier.fillMaxSize().padding(horizontal = 22.dp, vertical = 18.dp)) {
            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Text("LauncherOS", color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = 18.sp)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Wifi, null, tint = Color.White.copy(.85f), modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(10.dp))
                    Icon(Icons.Default.BatteryFull, null, tint = Color.White.copy(.85f), modifier = Modifier.size(20.dp))
                }
            }
            Spacer(Modifier.height(54.dp))
            Text(time, color = Color.White, fontSize = 62.sp, fontWeight = FontWeight.Light)
            Text(date.replaceFirstChar { it.uppercase() }, color = Color.White.copy(.72f), fontSize = 16.sp)
            Spacer(Modifier.height(28.dp))

            GlassCard(Modifier.fillMaxWidth().height(54.dp).clickable { showDrawer = true }) {
                Icon(Icons.Default.Search, null, tint = Color.White.copy(.7f))
                Spacer(Modifier.width(12.dp))
                Text("Cari aplikasi...", color = Color.White.copy(.62f), fontSize = 15.sp)
            }
            Spacer(Modifier.height(20.dp))

            if (!showDrawer) {
                Text("Favorit", color = Color.White.copy(.75f), fontSize = 14.sp)
                Spacer(Modifier.height(10.dp))
                val favorites = filtered.take(8)
                LazyVerticalGrid(columns = GridCells.Fixed(4), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.weight(1f)) {
                    items(favorites) { AppIcon(it) }
                }
            } else {
                AnimatedVisibility(true) {
                    Column(Modifier.weight(1f)) {
                        GlassCard(Modifier.fillMaxWidth().height(54.dp)) {
                            Icon(Icons.Default.Search, null, tint = Color.White.copy(.75f))
                            Spacer(Modifier.width(10.dp))
                            androidx.compose.foundation.text.BasicTextField(value = query, onValueChange = { query = it }, singleLine = true, textStyle = androidx.compose.ui.text.TextStyle(color = Color.White, fontSize = 16.sp), modifier = Modifier.fillMaxWidth())
                        }
                        Spacer(Modifier.height(14.dp))
                        LazyVerticalGrid(columns = GridCells.Fixed(4), horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) { items(filtered) { AppIcon(it) } }
                    }
                }
            }

            GlassCard(Modifier.fillMaxWidth().height(68.dp)) {
                BottomAction(Icons.Default.Apps, "Aplikasi") { showDrawer = !showDrawer }
                BottomAction(Icons.Default.Search, "Cari") { showDrawer = true }
                BottomAction(Icons.Default.Settings, "Pengaturan") { showSettings = true }
            }
        }

        if (showSettings) {
            AlertDialog(onDismissRequest = { showSettings = false }, title = { Text("LauncherOS") }, text = { Text("Liquid Glass • v1.0\n\nGunakan LauncherOS sebagai aplikasi Home untuk menjadikannya launcher utama Android.") }, confirmButton = { TextButton(onClick = { showSettings = false }) { Text("Tutup") } })
        }
    }
}

@Composable
fun GlassCard(modifier: Modifier = Modifier, content: @Composable RowScope.() -> Unit) {
    Row(modifier.background(Color.White.copy(alpha = .12f), RoundedCornerShape(22.dp)).padding(horizontal = 16.dp), verticalAlignment = Alignment.CenterVertically, content = content)
}

@Composable
fun AppIcon(item: AppItem) {
    val context = LocalContext.current
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.clickable {
        val intent = context.packageManager.getLaunchIntentForPackage(item.info.activityInfo.packageName)
        if (intent != null) context.startActivity(intent)
    }) {
        Surface(shape = RoundedCornerShape(18.dp), color = Color.White.copy(.13f), modifier = Modifier.size(58.dp)) {
            Box(contentAlignment = Alignment.Center) {
                androidx.compose.foundation.Image(bitmap = item.info.loadIcon(context.packageManager).toBitmapCompat(), contentDescription = item.label, modifier = Modifier.size(38.dp))
            }
        }
        Spacer(Modifier.height(5.dp))
        Text(item.label.take(13), color = Color.White.copy(.88f), fontSize = 11.sp, maxLines = 1)
    }
}

@Composable
fun RowScope.BottomAction(icon: ImageVector, label: String, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.weight(1f).clickable(onClick = onClick)) {
        Icon(icon, null, tint = Color.White.copy(.85f), modifier = Modifier.size(22.dp))
        Spacer(Modifier.height(3.dp))
        Text(label, color = Color.White.copy(.65f), fontSize = 10.sp)
    }
}

private fun android.graphics.drawable.Drawable.toBitmapCompat(): androidx.compose.ui.graphics.ImageBitmap {
    val d = this
    val w = maxOf(1, d.intrinsicWidth)
    val h = maxOf(1, d.intrinsicHeight)
    val bmp = android.graphics.Bitmap.createBitmap(w, h, android.graphics.Bitmap.Config.ARGB_8888)
    val c = android.graphics.Canvas(bmp)
    d.setBounds(0, 0, c.width, c.height); d.draw(c)
    return bmp.asImageBitmap()
}
