package com.launcher.os

import android.app.role.RoleManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.compose.setContent
import com.launcher.os.data.AppRepository
import com.launcher.os.feature.home.HomeScreen
import com.launcher.os.ui.theme.LauncherTheme

class MainActivity : ComponentActivity() {
    private val roleLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val repository = AppRepository(applicationContext)

        setContent {
            LauncherTheme {
                HomeScreen(
                    repository = repository,
                    onRequestDefaultLauncher = ::requestDefaultLauncher
                )
            }
        }
    }

    private fun requestDefaultLauncher() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return

        val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
        if (roleManager.isRoleAvailable(RoleManager.ROLE_HOME) &&
            !roleManager.isRoleHeld(RoleManager.ROLE_HOME)
        ) {
            roleLauncher.launch(
                roleManager.createRequestRoleIntent(RoleManager.ROLE_HOME)
            )
        }
    }
}
