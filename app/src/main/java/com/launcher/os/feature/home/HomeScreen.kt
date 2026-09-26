package com.launcher.os.feature.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.launcher.os.data.AppItem
import com.launcher.os.data.AppRepository
import com.launcher.os.ui.components.AppIconView
import com.launcher.os.ui.components.GlassSurface
import com.launcher.os.ui.components.WallpaperBackground
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Composable
fun HomeScreen(repository: AppRepository, onRequestDefaultLauncher: () -> Unit) {
    var apps by remember { mutableStateOf(emptyList<AppItem>()) }
    var showLibrary by remember { mutableStateOf(false) }
    var query by remember { mutableStateOf("") }

    LaunchedEffect(Unit) {
        apps = withContext(Dispatchers.IO) {
            runCatching { repository.loadApps() }.getOrDefault(emptyList())
        }
    }

    Box(Modifier.fillMaxSize()) {
        WallpaperBackground()
        Box(Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.28f)))

        if (!showLibrary) {
            HomeContent(
                apps = apps,
                onOpenLibrary = { showLibrary = true }
            )
        } else {
            AppLibrary(
                apps = apps,
                query = query,
                onQueryChange = { query = it },
                onClose = { query = ""; showLibrary = false }
            )
        }
    }
}

@Composable
private fun HomeContent(apps: List<AppItem>, onOpenLibrary: () -> Unit) {
    Column(
        Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 18.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(Modifier.height(74.dp))

        GlassSurface(
            Modifier.width(300.dp).height(126.dp),
            radius = 24.dp, alpha = 0.08f, shadow = false
        ) {
            Column(
                Modifier.fillMaxSize().padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text("Foto", color = Color.White, fontSize = 22.sp, fontWeight = FontWeight.Medium)
            }
        }

        Spacer(Modifier.weight(1f))

        GlassSurface(
            Modifier.fillMaxWidth().height(92.dp),
            radius = 28.dp, alpha = 0.12f, shadow = false
        ) {
            Row(
                Modifier.fillMaxSize().padding(horizontal = 12.dp),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                val groups = apps.take(16).chunked(4)
                repeat(4) { index ->
                    FolderPreview(groups.getOrNull(index).orEmpty(), onOpenLibrary)
                }
            }
        }

        Spacer(Modifier.height(22.dp))
    }
}

@Composable
private fun FolderPreview(apps: List<AppItem>, onClick: () -> Unit) {
    Box(
        Modifier.size(58.dp)
            .clip(RoundedCornerShape(17.dp))
            .background(Color.Black.copy(alpha = 0.18f))
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        if (apps.isEmpty()) return@Box
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(2.dp)
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                apps.take(2).forEach { AppIconView(it, 22.dp, false) }
            }
            Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                apps.drop(2).take(2).forEach { AppIconView(it, 22.dp, false) }
            }
        }
    }
}

@Composable
private fun AppLibrary(
    apps: List<AppItem>,
    query: String,
    onQueryChange: (String) -> Unit,
    onClose: () -> Unit
) {
    val filtered = remember(apps, query) {
        if (query.isBlank()) apps else apps.filter { it.label.contains(query, ignoreCase = true) }
    }
    val grouped = remember(filtered) {
        filtered.groupBy { it.label.firstOrNull()?.uppercase() ?: "#" }.toSortedMap()
    }

    Column(Modifier.fillMaxSize().padding(horizontal = 24.dp, vertical = 18.dp)) {
        Spacer(Modifier.height(10.dp))

        GlassSurface(
            Modifier.fillMaxWidth().height(54.dp),
            radius = 27.dp, alpha = 0.11f, shadow = false
        ) {
            Row(
                Modifier.fillMaxSize().padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Default.Search, "Cari", tint = Color.White.copy(alpha = 0.78f))
                Spacer(Modifier.width(10.dp))
                BasicTextField(
                    value = query,
                    onValueChange = onQueryChange,
                    singleLine = true,
                    textStyle = TextStyle(color = Color.White, fontSize = 16.sp),
                    modifier = Modifier.weight(1f),
                    decorationBox = { inner ->
                        Box {
                            if (query.isEmpty()) {
                                Text("Perpustakaan Aplikasi", color = Color.White.copy(alpha = 0.55f))
                            }
                            inner()
                        }
                    }
                )
                Text(
                    "Batal",
                    color = Color.White.copy(alpha = 0.75f),
                    fontSize = 12.sp,
                    modifier = Modifier.clickable(onClick = onClose)
                )
            }
        }

        Spacer(Modifier.height(16.dp))

        LazyVerticalGrid(
            columns = GridCells.Fixed(1),
            verticalArrangement = Arrangement.spacedBy(2.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            grouped.forEach { (letter, items) ->
                item {
                    Text(
                        letter,
                        color = Color.White.copy(alpha = 0.72f),
                        fontSize = 12.sp,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )
                }
                items(items, key = { it.info.activityInfo.packageName }) { app ->
                    Box(
                        Modifier.fillMaxWidth().height(54.dp),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        AppIconView(app, 34.dp, true)
                    }
                }
            }
        }
    }
}
