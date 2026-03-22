package com.beedev.boardo.android

import android.content.Context
import android.graphics.Typeface
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.itemsIndexed
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import com.beedev.boardo.android.ui.theme.BoardoTheme
import org.json.JSONArray
import org.json.JSONObject
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.time.temporal.TemporalAdjusters
import java.util.Locale
import java.util.UUID

data class TaskCategoryUi(
    val id: String,
    val label: String,
    val icon: String,
    val color: Color
) {
    val boardTag: String
        get() = label.trim().ifBlank { "TAG" }.uppercase().take(10)
}

data class BoardTaskUi(
    val id: String = UUID.randomUUID().toString(),
    val title: String,
    val notes: String,
    val categoryId: String,
    val dueDate: LocalDate?,
    val isCompleted: Boolean
)

private val StickyFont = FontFamily(Typeface.create("casual", Typeface.NORMAL))
private val SpanishMonthFormatter = DateTimeFormatter.ofPattern("MMMM yyyy", Locale("es", "ES"))

private val defaultCategories = listOf(
    TaskCategoryUi("personal", "Personal", "📌", Color(0xFFF1E27B)),
    TaskCategoryUi("routine", "Rutina", "↻", Color(0xFFB8C9E8)),
    TaskCategoryUi("work", "Trabajo", "✂", Color(0xFFBFE6C4)),
    TaskCategoryUi("family", "Familia", "❤", Color(0xFFE4BCD8)),
    TaskCategoryUi("urgent", "Urgente", "⚡", Color(0xFFFFD2A0))
)

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
    val context = LocalContext.current
    val categoriesById = remember { defaultCategories.associateBy { it.id } }

    val tasks = remember {
        mutableStateListOf<BoardTaskUi>().apply {
            addAll(BoardLocalStore.loadTasks(context))
        }
    }

    var selectedDate by remember { mutableStateOf(LocalDate.now()) }
    var showAddDialog by remember { mutableStateOf(false) }
    var editingTaskId by remember { mutableStateOf<String?>(null) }

    val tasksForSelectedDay = tasks.filter { it.dueDate == selectedDate }
    val taskDates = tasks.mapNotNull { it.dueDate }.toSet()
    val streakCount = computeStreak(tasks)
    val editingTask = tasks.firstOrNull { it.id == editingTaskId }

    fun persist() {
        BoardLocalStore.saveTasks(context, tasks)
    }

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
            MonthCalendarCard(
                selectedDate = selectedDate,
                taskDates = taskDates,
                onSelectDate = { selectedDate = it },
                onMovePreviousWeek = { selectedDate = selectedDate.minusWeeks(1) },
                onMoveNextWeek = { selectedDate = selectedDate.plusWeeks(1) }
            )

            Spacer(modifier = Modifier.height(10.dp))
            StreakCard(days = streakCount)
            Spacer(modifier = Modifier.height(12.dp))

            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                contentPadding = PaddingValues(bottom = 118.dp)
            ) {
                itemsIndexed(tasksForSelectedDay, key = { _, task -> task.id }) { index, task ->
                    val category = categoriesById[task.categoryId] ?: defaultCategories.first()
                    StickyNoteCard(
                        task = task,
                        category = category,
                        rotation = if (index % 2 == 0) -1.3f else 1f,
                        onOpen = { editingTaskId = task.id }
                    )
                }

                item {
                    AddNoteCard(onClick = { showAddDialog = true })
                }
            }
        }

        BottomBoardNav(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(horizontal = 12.dp, vertical = 14.dp)
        )

        if (showAddDialog) {
            AddTaskDialog(
                categories = defaultCategories,
                selectedDate = selectedDate,
                onDismiss = { showAddDialog = false },
                onCreate = { title, notes, categoryId, dueDate ->
                    tasks.add(
                        0,
                        BoardTaskUi(
                            title = title.trim(),
                            notes = notes.trim(),
                            categoryId = categoryId,
                            dueDate = dueDate,
                            isCompleted = false
                        )
                    )
                    persist()
                    showAddDialog = false
                }
            )
        }

        if (editingTask != null) {
            ExpandedStickyTaskEditor(
                task = editingTask,
                categories = defaultCategories,
                onDismiss = { editingTaskId = null },
                onSave = { title, notes, categoryId ->
                    val index = tasks.indexOfFirst { it.id == editingTask.id }
                    if (index >= 0) {
                        tasks[index] = editingTask.copy(
                            title = title.trim(),
                            notes = notes.trim(),
                            categoryId = categoryId
                        )
                        persist()
                    }
                },
                onToggleDone = {
                    val index = tasks.indexOfFirst { it.id == editingTask.id }
                    if (index >= 0) {
                        tasks[index] = editingTask.copy(isCompleted = !editingTask.isCompleted)
                        persist()
                    }
                },
                onDelete = {
                    tasks.removeAll { it.id == editingTask.id }
                    persist()
                }
            )
        }
    }
}

@Composable
private fun MonthCalendarCard(
    selectedDate: LocalDate,
    taskDates: Set<LocalDate>,
    onSelectDate: (LocalDate) -> Unit,
    onMovePreviousWeek: () -> Unit,
    onMoveNextWeek: () -> Unit
) {
    val startOfWeek = selectedDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY))
    val weekDates = (0..6).map { startOfWeek.plusDays(it.toLong()) }
    val weekDays = listOf("S", "M", "T", "W", "T", "F", "S")
    val monthTitle = selectedDate.format(SpanishMonthFormatter).replaceFirstChar {
        if (it.isLowerCase()) it.titlecase(Locale("es", "ES")) else it.toString()
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(Color.White)
            .padding(horizontal = 14.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                "‹",
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.clickable(onClick = onMovePreviousWeek)
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                "$monthTitle ⌄",
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.weight(1f)
            )
            Text(
                "›",
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.clickable(onClick = onMoveNextWeek)
            )
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            weekDays.forEach { day ->
                Text(day, color = Color(0xFFC3CAD7), style = MaterialTheme.typography.labelSmall)
            }
        }

        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            weekDates.forEach { date ->
                val selected = date == selectedDate
                Column(
                    modifier = Modifier.clickable { onSelectDate(date) },
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Box(
                        modifier = Modifier
                            .size(30.dp)
                            .background(if (selected) Color(0xFFF87533) else Color.Transparent, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = date.dayOfMonth.toString(),
                            color = if (selected) Color.White else Color(0xFF5C6473),
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Box(
                        modifier = Modifier
                            .size(4.dp)
                            .background(if (taskDates.contains(date)) Color(0xFFF87533) else Color.Transparent, CircleShape)
                    )
                }
            }
        }
    }
}

@Composable
private fun StreakCard(days: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(color = Color(0xFFF1E27B), shape = RoundedCornerShape(12.dp))
            .padding(horizontal = 14.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        Text("🔥")
        Column {
            Text("Racha diaria", style = MaterialTheme.typography.labelMedium, color = Color(0xFF5B6578))
            Text(
                "$days dias seguidos",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF1E2533)
            )
        }
    }
}

@Composable
private fun StickyNoteCard(task: BoardTaskUi, category: TaskCategoryUi, rotation: Float, onOpen: () -> Unit) {
    val shape = RoundedCornerShape(14.dp)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(126.dp)
            .rotate(rotation)
            .shadow(5.dp, shape)
            .clip(shape)
            .background(category.color)
            .clickable(onClick = onOpen)
            .padding(12.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = task.title,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.ExtraBold,
            color = Color(0xFF30384A),
            textDecoration = if (task.isCompleted) TextDecoration.LineThrough else TextDecoration.None,
            fontFamily = StickyFont
        )

        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = category.boardTag,
                style = MaterialTheme.typography.labelSmall,
                color = Color(0xFF8C96A8),
                fontWeight = FontWeight.Black,
                fontFamily = StickyFont
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(if (task.isCompleted) "✓" else category.icon, color = Color(0xFF8C96A8))
        }
    }
}

@Composable
private fun AddNoteCard(onClick: () -> Unit) {
    val shape = RoundedCornerShape(14.dp)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .height(126.dp)
            .clip(shape)
            .background(Color(0xFFF9F9FA))
            .clickable(onClick = onClick)
            .drawBehind {
                drawRoundRect(
                    color = Color(0xFFD8D8DC),
                    cornerRadius = CornerRadius(14.dp.toPx(), 14.dp.toPx()),
                    style = Stroke(width = 1.8.dp.toPx(), pathEffect = PathEffect.dashPathEffect(floatArrayOf(10f, 8f), 0f))
                )
            }
            .padding(12.dp),
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
            fontWeight = FontWeight.Black,
            fontFamily = StickyFont
        )
    }
}

@Composable
private fun AddTaskDialog(
    categories: List<TaskCategoryUi>,
    selectedDate: LocalDate,
    onDismiss: () -> Unit,
    onCreate: (title: String, notes: String, categoryId: String, dueDate: LocalDate?) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var selectedCategoryId by remember { mutableStateOf(categories.first().id) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Nueva tarea") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Titulo") },
                    singleLine = true
                )
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Notas") },
                    minLines = 3,
                    maxLines = 4
                )
                Text("Sticker", style = MaterialTheme.typography.labelMedium)
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(categories) { category ->
                        val selected = selectedCategoryId == category.id
                        Row(
                            modifier = Modifier
                                .clip(RoundedCornerShape(999.dp))
                                .background(if (selected) category.color else Color(0xFFEAEAF0))
                                .clickable { selectedCategoryId = category.id }
                                .padding(horizontal = 10.dp, vertical = 6.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Text(category.icon)
                            Text(category.label, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }
                Text("Fecha: ${selectedDate.dayOfMonth}/${selectedDate.monthValue}/${selectedDate.year}")
            }
        },
        confirmButton = {
            TextButton(
                onClick = { onCreate(title, notes, selectedCategoryId, selectedDate) },
                enabled = title.isNotBlank()
            ) {
                Text("Pin")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancelar")
            }
        }
    )
}

@Composable
private fun ExpandedStickyTaskEditor(
    task: BoardTaskUi,
    categories: List<TaskCategoryUi>,
    onDismiss: () -> Unit,
    onSave: (title: String, notes: String, categoryId: String) -> Unit,
    onToggleDone: () -> Unit,
    onDelete: () -> Unit
) {
    var title by remember(task.id) { mutableStateOf(task.title) }
    var notes by remember(task.id) { mutableStateOf(task.notes) }
    var categoryId by remember(task.id) { mutableStateOf(task.categoryId) }
    val activeCategory = categories.firstOrNull { it.id == categoryId } ?: categories.first()
    val visibleState = remember(task.id) { MutableTransitionState(false).apply { targetState = true } }
    var pendingAction by remember(task.id) { mutableStateOf<(() -> Unit)?>(null) }

    fun dismissSmooth(afterDismiss: (() -> Unit)? = null) {
        pendingAction = afterDismiss
        visibleState.targetState = false
    }

    BackHandler(enabled = visibleState.targetState) {
        dismissSmooth()
    }

    if (!visibleState.currentState && !visibleState.targetState) {
        pendingAction?.invoke()
        onDismiss()
        return
    }

    AnimatedVisibility(
        visibleState = visibleState,
        enter = fadeIn() + scaleIn(initialScale = 0.9f),
        exit = fadeOut() + scaleOut(targetScale = 0.96f)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(Color.Black.copy(alpha = 0.32f))
                .clickable { dismissSmooth() },
            contentAlignment = Alignment.Center
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 14.dp)
                    .clip(RoundedCornerShape(24.dp))
                    .background(Color(0xFFF7F7F9))
                    .clickable { }
                    .padding(horizontal = 14.dp, vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Spacer(modifier = Modifier.weight(1f))
                    Text(
                        text = "✕",
                        color = Color(0xFF8B95A8),
                        style = MaterialTheme.typography.titleLarge,
                        modifier = Modifier.clickable { dismissSmooth() }
                    )
                }

                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(260.dp)
                        .clip(RoundedCornerShape(10.dp))
                        .background(activeCategory.color)
                        .clickable(enabled = false) {}
                        .padding(horizontal = 12.dp, vertical = 10.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        "PARA HOY",
                        style = MaterialTheme.typography.labelMedium,
                        color = Color(0xFFF87533),
                        fontWeight = FontWeight.ExtraBold
                    )

                    BasicTextField(
                        value = title,
                        onValueChange = { title = it },
                        textStyle = MaterialTheme.typography.headlineMedium.copy(
                            color = Color(0xFF202633),
                            fontFamily = StickyFont,
                            fontWeight = FontWeight.ExtraBold
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )

                    BasicTextField(
                        value = notes,
                        onValueChange = { notes = it },
                        textStyle = MaterialTheme.typography.bodyLarge.copy(
                            color = Color(0xFF3A4356),
                            fontFamily = StickyFont
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .weight(1f)
                    )

                    Text(
                        "adjunto",
                        style = MaterialTheme.typography.labelSmall,
                        color = Color(0xFF8B95A8),
                        fontFamily = StickyFont
                    )
                }

                LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    items(categories) { category ->
                        val selected = category.id == categoryId
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(4.dp),
                            modifier = Modifier
                                .clip(RoundedCornerShape(12.dp))
                                .clickable { categoryId = category.id }
                                .padding(horizontal = 4.dp, vertical = 4.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(40.dp)
                                    .background(category.color, CircleShape),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = if (selected) "•" else category.icon,
                                    style = MaterialTheme.typography.titleMedium,
                                    color = Color(0xFF4D5566)
                                )
                            }
                            Text(
                                text = category.label,
                                style = MaterialTheme.typography.labelSmall,
                                color = if (selected) Color(0xFFF87533) else Color(0xFF8792A6),
                                fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium
                            )
                        }
                    }
                }

                Text(
                    "HAS TERMINADO?",
                    style = MaterialTheme.typography.labelMedium,
                    color = Color(0xFF9AA4B7),
                    fontWeight = FontWeight.ExtraBold,
                    modifier = Modifier.align(Alignment.CenterHorizontally)
                )

                TextButton(
                    onClick = { dismissSmooth { onToggleDone() } },
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(12.dp))
                        .background(Color(0xFFF87533))
                ) {
                    Text(
                        text = if (task.isCompleted) "Marcar pendiente" else "Completar tarea",
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }

                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    TextButton(
                        onClick = { dismissSmooth { onDelete() } },
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Eliminar", color = Color(0xFFF25C5C))
                    }
                    TextButton(
                        onClick = { dismissSmooth { onSave(title, notes, categoryId) } },
                        enabled = title.isNotBlank(),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Guardar cambios", color = Color(0xFFF87533), fontWeight = FontWeight.ExtraBold)
                    }
                }
            }
        }
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

private fun computeStreak(tasks: List<BoardTaskUi>, referenceDate: LocalDate = LocalDate.now()): Int {
    val completedDays = tasks.asSequence()
        .filter { it.isCompleted && it.dueDate != null }
        .mapNotNull { it.dueDate }
        .toSet()

    var anchor = referenceDate
    if (!completedDays.contains(anchor)) {
        val yesterday = referenceDate.minusDays(1)
        if (!completedDays.contains(yesterday)) return 0
        anchor = yesterday
    }

    var streak = 0
    var day = anchor
    while (completedDays.contains(day)) {
        streak += 1
        day = day.minusDays(1)
    }

    return streak
}

private object BoardLocalStore {
    private const val prefsName = "boardo_android"
    private const val keyTasks = "board_tasks_v1"

    fun loadTasks(context: Context): List<BoardTaskUi> {
        val prefs = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
        val raw = prefs.getString(keyTasks, null) ?: return emptyList()
        val json = try {
            JSONArray(raw)
        } catch (_: Throwable) {
            return emptyList()
        }

        val output = mutableListOf<BoardTaskUi>()
        for (i in 0 until json.length()) {
            val item = json.optJSONObject(i) ?: continue
            output.add(
                BoardTaskUi(
                    id = item.optString("id", UUID.randomUUID().toString()),
                    title = item.optString("title", ""),
                    notes = item.optString("notes", ""),
                    categoryId = item.optString("categoryId", "personal"),
                    dueDate = if (item.has("dueDateEpochDay") && !item.isNull("dueDateEpochDay")) {
                        LocalDate.ofEpochDay(item.optLong("dueDateEpochDay"))
                    } else {
                        null
                    },
                    isCompleted = item.optBoolean("isCompleted", false)
                )
            )
        }
        return output
    }

    fun saveTasks(context: Context, tasks: List<BoardTaskUi>) {
        val payload = JSONArray()
        tasks.forEach { task ->
            payload.put(
                JSONObject().apply {
                    put("id", task.id)
                    put("title", task.title)
                    put("notes", task.notes)
                    put("categoryId", task.categoryId)
                    put("dueDateEpochDay", task.dueDate?.toEpochDay() ?: Long.MIN_VALUE)
                    put("isCompleted", task.isCompleted)
                }
            )
        }

        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putString(keyTasks, payload.toString())
            .apply()
    }
}
