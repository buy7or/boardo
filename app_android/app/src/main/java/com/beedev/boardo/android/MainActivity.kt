package com.beedev.boardo.android

import android.graphics.Typeface
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.beedev.boardo.android.ui.theme.BoardoTheme

data class StickyNoteUi(
    val title: String,
    val tag: String,
    val color: Color,
    val accentSymbol: String
)

private val StickyFont = FontFamily(Typeface.create("casual", Typeface.NORMAL))

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            BoardoTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                    BoardHomeScreen()
                }
            }
        }
    }
}

@Composable
private fun BoardHomeScreen() {
    val notes = listOf(
        StickyNoteUi("Comentar \"alfarero\"", "TODAY", Color(0xFFF1E27B), "📌"),
        StickyNoteUi("Dar like", "ROUTINE", Color(0xFFB8C9E8), "↻"),
        StickyNoteUi("Suscribirse", "FAMILY", Color(0xFFE4BCD8), "❤")
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF3F3F5))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .padding(horizontal = 12.dp)
                .padding(top = 8.dp)
        ) {
            MonthCalendarCard()
            Spacer(modifier = Modifier.height(14.dp))

            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                contentPadding = PaddingValues(bottom = 118.dp)
            ) {
                itemsIndexed(notes) { index, note ->
                    StickyNoteCard(
                        note = note,
                        rotation = if (index % 2 == 0) -1.3f else 1f
                    )
                }
                item { AddNoteCard() }
            }
        }

        BottomBoardNav(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(horizontal = 12.dp, vertical = 14.dp)
        )
    }
}

@Composable
private fun MonthCalendarCard() {
    val weekDays = listOf("S", "M", "T", "W", "T", "F", "S")
    val dayNumbers = listOf("23", "24", "25", "26", "27", "28", "1")

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(Color.White)
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("‹", color = Color(0xFF8B95A8), style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                "Febrero 2026 ⌄",
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.weight(1f)
            )
            Text("›", color = Color(0xFF8B95A8), style = MaterialTheme.typography.titleLarge)
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            weekDays.forEach { day ->
                Text(day, color = Color(0xFFC3CAD7), style = MaterialTheme.typography.labelSmall)
            }
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            dayNumbers.forEachIndexed { index, day ->
                val selected = index == 4
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        modifier = Modifier
                            .size(30.dp)
                            .background(if (selected) Color(0xFFF87533) else Color.Transparent, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            day,
                            color = if (selected) Color.White else Color(0xFF5C6473),
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Box(
                        modifier = Modifier
                            .size(4.dp)
                            .background(if (selected || index == 2) Color(0xFFF87533) else Color.Transparent, CircleShape)
                    )
                }
            }
        }
    }
}

@Composable
private fun StickyNoteCard(note: StickyNoteUi, rotation: Float) {
    val shape = RoundedCornerShape(14.dp)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(126.dp)
            .rotate(rotation)
            .shadow(5.dp, shape)
            .clip(shape)
            .background(note.color)
            .padding(12.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = note.title,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.SemiBold,
            color = Color(0xFF30384A),
            fontFamily = StickyFont
        )

        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = note.tag,
                style = MaterialTheme.typography.labelSmall,
                color = Color(0xFF8C96A8),
                fontWeight = FontWeight.Bold,
                fontFamily = StickyFont
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(note.accentSymbol, color = Color(0xFF8C96A8))
        }
    }
}

@Composable
private fun AddNoteCard() {
    val shape = RoundedCornerShape(14.dp)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(126.dp)
            .clip(shape)
            .background(Color(0xFFF9F9FA))
            .padding(12.dp)
            .background(Color.Transparent)
            .padding(0.dp)
            .drawBehind {
                drawRoundRect(
                    color = Color(0xFFD8D8DC),
                    cornerRadius = CornerRadius(14.dp.toPx(), 14.dp.toPx()),
                    style = Stroke(width = 1.8.dp.toPx(), pathEffect = PathEffect.dashPathEffect(floatArrayOf(10f, 8f), 0f))
                )
            },
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .size(54.dp)
                .background(Color(0xFFF87533), CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Icon(Icons.Default.Add, contentDescription = null, tint = Color.White)
        }

        Spacer(modifier = Modifier.height(10.dp))
        Text(
            "NEW NOTE",
            color = Color(0xFF8B95A8),
            style = MaterialTheme.typography.labelLarge,
            fontWeight = FontWeight.Bold,
            fontFamily = StickyFont
        )
    }
}

@Composable
private fun BottomBoardNav(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .shadow(8.dp, RoundedCornerShape(20.dp))
            .clip(RoundedCornerShape(20.dp))
            .background(Color(0xFFFCFCFD))
            .padding(vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        BottomNavItem(icon = { Icon(Icons.Default.Home, null) }, label = "Board", selected = true)
        BottomNavItem(icon = { Icon(Icons.Default.CheckCircle, null) }, label = "Schedule", selected = false)
        BottomNavItem(icon = { Icon(Icons.Default.Settings, null) }, label = "Settings", selected = false)
    }
}

@Composable
private fun BottomNavItem(icon: @Composable () -> Unit, label: String, selected: Boolean) {
    val color = if (selected) Color(0xFFF87533) else Color(0xFF9CA5B6)

    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Box(contentAlignment = Alignment.Center) {
            icon()
        }
        Text(label, color = color, style = MaterialTheme.typography.labelMedium, fontWeight = FontWeight.SemiBold)
    }
}
