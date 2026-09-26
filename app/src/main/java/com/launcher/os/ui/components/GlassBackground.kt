package com.launcher.os.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

@Composable
fun GlassBackground() {
    Canvas(Modifier.fillMaxSize()) {
        drawRect(Color(0xFF05070B))

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color(0xFF2563EB).copy(alpha = 0.72f),
                    Color(0xFF2563EB).copy(alpha = 0.22f),
                    Color.Transparent
                ),
                center = Offset(size.width * 0.12f, size.height * 0.08f),
                radius = size.minDimension * 0.48f
            ),
            radius = size.minDimension * 0.48f,
            center = Offset(size.width * 0.12f, size.height * 0.08f)
        )

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color(0xFF06B6D4).copy(alpha = 0.58f),
                    Color(0xFF06B6D4).copy(alpha = 0.16f),
                    Color.Transparent
                ),
                center = Offset(size.width * 0.92f, size.height * 0.34f),
                radius = size.minDimension * 0.40f
            ),
            radius = size.minDimension * 0.40f,
            center = Offset(size.width * 0.92f, size.height * 0.34f)
        )

        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    Color(0xFF7C3AED).copy(alpha = 0.60f),
                    Color(0xFF7C3AED).copy(alpha = 0.18f),
                    Color.Transparent
                ),
                center = Offset(size.width * 0.84f, size.height * 0.88f),
                radius = size.minDimension * 0.48f
            ),
            radius = size.minDimension * 0.48f,
            center = Offset(size.width * 0.84f, size.height * 0.88f)
        )
    }
}
