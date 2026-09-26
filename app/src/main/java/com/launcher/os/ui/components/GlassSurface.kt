package com.launcher.os.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.LocalContentColor
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun GlassSurface(
    modifier: Modifier = Modifier,
    radius: Dp = 24.dp,
    alpha: Float = 0.12f,
    shadow: Boolean = false,
    content: @Composable () -> Unit
) {
    val shape = RoundedCornerShape(radius)
    Box(
        modifier = modifier
            .then(if (shadow) Modifier.shadow(3.dp, shape, clip = false) else Modifier)
            .background(
                Brush.verticalGradient(
                    listOf(Color.White.copy(alpha = alpha + 0.025f), Color.White.copy(alpha = alpha - 0.015f))
                ), shape
            )
            .border(1.dp, Color.White.copy(alpha = 0.10f), shape)
    ) {
        CompositionLocalProvider(LocalContentColor provides Color.White) { content() }
    }
}
