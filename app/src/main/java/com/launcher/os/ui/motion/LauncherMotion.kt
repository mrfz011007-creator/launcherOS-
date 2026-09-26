package com.launcher.os.ui.motion

import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut

fun glassEnter(): EnterTransition =
    fadeIn(tween(180)) + scaleIn(
        initialScale = 0.96f,
        animationSpec = tween(220)
    )

fun glassExit(): ExitTransition =
    fadeOut(tween(140)) + scaleOut(
        targetScale = 0.98f,
        animationSpec = tween(160)
    )
