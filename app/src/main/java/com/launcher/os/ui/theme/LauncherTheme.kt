package com.launcher.os.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LauncherColors = darkColorScheme(
    background = Color(0xFF05070B),
    surface = Color(0xFF10141A),
    onBackground = Color.White,
    onSurface = Color.White
)

@Composable
fun LauncherTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LauncherColors,
        content = content
    )
}
