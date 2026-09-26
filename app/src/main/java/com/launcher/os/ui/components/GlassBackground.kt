package com.launcher.os.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp

@Composable
fun GlassBackground() {
    Box(
        Modifier
            .fillMaxSize()
            .background(Color(0xFF05070B))
    ) {
        Box(
            Modifier
                .size(300.dp)
                .offset((-90).dp, (-80).dp)
                .blur(70.dp)
                .background(Color(0xFF2563EB).copy(alpha = 0.62f), CircleShape)
        )
        Box(
            Modifier
                .size(260.dp)
                .align(Alignment.BottomEnd)
                .offset(90.dp, 80.dp)
                .blur(75.dp)
                .background(Color(0xFF7C3AED).copy(alpha = 0.48f), CircleShape)
        )
        Box(
            Modifier
                .size(190.dp)
                .align(Alignment.CenterEnd)
                .offset(55.dp, (-90).dp)
                .blur(60.dp)
                .background(Color(0xFF06B6D4).copy(alpha = 0.48f), CircleShape)
        )
    }
}
