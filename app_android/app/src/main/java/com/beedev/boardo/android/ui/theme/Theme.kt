package com.beedev.boardo.android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val BoardoColors = lightColorScheme(
    primary = Color(0xFFEE6A35),
    secondary = Color(0xFF5B6578),
    background = Color(0xFFF8E8C4),
    surface = Color(0xFFFFF8EA),
    onPrimary = Color.White,
    onSecondary = Color.White,
    onBackground = Color(0xFF1E2533),
    onSurface = Color(0xFF1E2533)
)

@Composable
fun BoardoTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = BoardoColors,
        typography = Typography,
        content = content
    )
}
