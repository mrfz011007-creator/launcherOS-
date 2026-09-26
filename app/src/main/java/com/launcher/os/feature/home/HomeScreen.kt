package com.launcher.os.feature.home

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Apps
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.launcher.os.data.AppItem
import com.launcher.os.data.AppRepository
import com.launcher.os.ui.components.AppIconView
import com.launcher.os.ui.components.GlassBackground
import com.launcher.os.ui.components.GlassSurface
import com.launcher.os.ui.motion.glassEnter
import com.launcher.os.ui.motion.glassExit
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Composable
fun HomeScreen(
    repository: AppRepository,
    onRequestDefaultLauncher: () -> Unit
) {
    var apps by remember { mutableStateOf(emptyList<AppItem>()) }
    var query by remember { mutableStateOf("") }
    var showDrawer by remember { mutableStateOf(false) }
    var showSettings by remember { mutableStateOf(false) }
    var now by remember { mutableStateOf(Date()) }

    LaunchedEffect(Unit) {
        apps = withContext(Dispatchers.Default) { repository.loadApps() }
    }

    LaunchedEffect(Unit) {
        while (true) {
            now = Date()
            kotlinx.coroutines.delay(1000)
        }
    }

    val time = SimpleDateFormat("HH:mm", Locale.getDefault()).format(now)
    val date = SimpleDateFormat("EEEE, d MMMM", Locale("id", "ID"))
        .format(now)
        .replaceFirstChar { it.uppercase() }

    val filteredApps = remember(apps, query) {
        if (query.isBlank()) apps
        else apps.filter { it.label.contains(query, ignoreCase = true) }
    }

    Box(Modifier.fillMaxSize()) {
        GlassBackground()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 22.dp, vertical = 18.dp)
        ) {
            Text(
                text = "LauncherOS",
                color = Color.White,
                fontSize = 18.sp,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(Modifier.height(48.dp))

            Text(
                text = time,
                color = Color.White,
                fontSize = 62.sp,
                fontWeight = FontWeight.Light
            )
            Text(
                text = date,
                color = Color.White.copy(alpha = 0.72f),
                fontSize = 16.sp
            )

            Spacer(Modifier.height(26.dp))

            GlassSurface(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(54.dp),
                radius = 27.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxSize()
                        .clickable { showDrawer = true }
                        .padding(horizontal = 16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.Search,
                        contentDescription = "Cari",
                        tint = Color.White.copy(alpha = 0.72f)
                    )
                    Spacer(Modifier.size(12.dp))
                    Text(
                        "Cari aplikasi...",
                        color = Color.White.copy(alpha = 0.62f),
                        fontSize = 15.sp
                    )
                }
            }

            Spacer(Modifier.height(20.dp))

            AnimatedVisibility(
                visible = !showDrawer,
                enter = glassEnter(),
                exit = glassExit(),
                modifier = Modifier.weight(1f)
            ) {
                Column(Modifier.fillMaxSize()) {
                    Text(
                        "Aplikasi",
                        color = Color.White.copy(alpha = 0.72f),
                        fontSize = 14.sp
                    )
                    Spacer(Modifier.height(10.dp))
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(4),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(
                            apps.take(8),
                            key = { it.info.activityInfo.packageName }
                        ) {
                            AppIconView(it)
                        }
                    }
                }
            }

            GlassSurface(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(68.dp),
                radius = 30.dp
            ) {
                Row(
                    modifier = Modifier.fillMaxSize(),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    BottomAction(Icons.Default.Apps, "Aplikasi") {
                        showDrawer = !showDrawer
                    }
                    BottomAction(Icons.Default.Search, "Cari") {
                        showDrawer = true
                    }
                    BottomAction(Icons.Default.Settings, "Pengaturan") {
                        showSettings = true
                    }
                }
            }
        }

        AnimatedVisibility(
            visible = showDrawer,
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 22.dp, vertical = 18.dp),
            enter = glassEnter(),
            exit = glassExit()
        ) {
            GlassSurface(
                modifier = Modifier.fillMaxSize(),
                radius = 30.dp,
                alpha = 0.105f
            ) {
                Column(
                    Modifier
                        .fillMaxSize()
                        .padding(18.dp)
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        GlassSurface(
                            modifier = Modifier
                                .weight(1f)
                                .height(54.dp),
                            radius = 27.dp,
                            alpha = 0.09f
                        ) {
                            Row(
                                Modifier
                                    .fillMaxSize()
                                    .padding(horizontal = 16.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    Icons.Default.Search,
                                    contentDescription = "Cari",
                                    tint = Color.White.copy(alpha = 0.75f)
                                )
                                Spacer(Modifier.size(10.dp))
                                BasicTextField(
                                    value = query,
                                    onValueChange = { query = it },
                                    singleLine = true,
                                    textStyle = TextStyle(
                                        color = Color.White,
                                        fontSize = 16.sp
                                    ),
                                    modifier = Modifier.fillMaxWidth(),
                                    decorationBox = { innerTextField ->
                                        Box {
                                            if (query.isEmpty()) {
                                                Text(
                                                    "Cari aplikasi...",
                                                    color = Color.White.copy(alpha = 0.5f)
                                                )
                                            }
                                            innerTextField()
                                        }
                                    }
                                )
                            }
                        }

                        Spacer(Modifier.size(10.dp))

                        GlassSurface(
                            modifier = Modifier.size(54.dp),
                            radius = 27.dp,
                            alpha = 0.09f
                        ) {
                            Box(
                                Modifier.fillMaxSize(),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    Icons.Default.Apps,
                                    contentDescription = "Tutup",
                                    tint = Color.White.copy(alpha = 0.82f),
                                    modifier = Modifier.clickable {
                                        showDrawer = false
                                        query = ""
                                    }
                                )
                            }
                        }
                    }

                    Spacer(Modifier.height(18.dp))

                    Text(
                        text = if (query.isBlank()) "Semua aplikasi" else "Hasil pencarian",
                        color = Color.White.copy(alpha = 0.72f),
                        fontSize = 14.sp
                    )

                    Spacer(Modifier.height(10.dp))

                    LazyVerticalGrid(
                        columns = GridCells.Fixed(4),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        items(
                            filteredApps,
                            key = { it.info.activityInfo.packageName }
                        ) {
                            AppIconView(it)
                        }
                    }
                }
            }
        }

        if (showSettings) {
            AlertDialog(
                onDismissRequest = { showSettings = false },
                title = { Text("LauncherOS V2") },
                text = {
                    Text(
                        "Liquid Glass launcher pribadi tanpa iklan.\n\n" +
                            "Target: TECNO SPARK Go 2024 / BG6.\n" +
                            "V2 memprioritaskan glass, motion ringan, dan respons cepat."
                    )
                },
                confirmButton = {
                    TextButton(
                        onClick = {
                            showSettings = false
                            onRequestDefaultLauncher()
                        }
                    ) {
                        Text("Jadikan launcher utama")
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showSettings = false }) {
                        Text("Tutup")
                    }
                }
            )
        }
    }
}

@Composable
private fun RowScope.BottomAction(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    onClick: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .weight(1f)
            .clickable(onClick = onClick)
    ) {
        Icon(
            icon,
            contentDescription = label,
            tint = Color.White.copy(alpha = 0.86f),
            modifier = Modifier.size(22.dp)
        )
        Spacer(Modifier.height(3.dp))
        Text(
            label,
            color = Color.White.copy(alpha = 0.64f),
            fontSize = 10.sp
        )
    }
}
