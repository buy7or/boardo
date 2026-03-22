package com.beedev.boardo.android

import android.content.Context
import android.graphics.Typeface
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.MutableTransitionState
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
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
import androidx.compose.material.icons.outlined.Apps
import androidx.compose.material.icons.outlined.Autorenew
import androidx.compose.material.icons.outlined.BarChart
import androidx.compose.material.icons.outlined.BookmarkBorder
import androidx.compose.material.icons.outlined.Bolt
import androidx.compose.material.icons.outlined.ContentCut
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.LocalFireDepartment
import androidx.compose.material.icons.outlined.PushPin
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
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
import java.time.YearMonth
import java.time.temporal.TemporalAdjusters
import java.util.Locale
import java.util.UUID

data class TaskCategoryUi(
    val id: String,
    val label: String,
    val icon: ImageVector,
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

private enum class BoardTab {
    Board,
    Stats,
    Saved,
    Settings
}

private enum class AppLanguage {
    Es,
    En
}

private fun i18n(language: AppLanguage, es: String, en: String): String {
    return if (language == AppLanguage.Es) es else en
}

private val StickyFont = FontFamily(Typeface.create("casual", Typeface.NORMAL))
private val defaultCategories = listOf(
    TaskCategoryUi("personal", "Personal", Icons.Outlined.PushPin, Color(0xFFF1E27B)),
    TaskCategoryUi("routine", "Rutina", Icons.Outlined.Autorenew, Color(0xFFB8C9E8)),
    TaskCategoryUi("work", "Trabajo", Icons.Outlined.ContentCut, Color(0xFFBFE6C4)),
    TaskCategoryUi("family", "Familia", Icons.Outlined.FavoriteBorder, Color(0xFFE4BCD8)),
    TaskCategoryUi("urgent", "Urgente", Icons.Outlined.Bolt, Color(0xFFFFD2A0))
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
    var showMonthPicker by remember { mutableStateOf(false) }
    var selectedTab by remember { mutableStateOf(BoardTab.Board) }
    var appLanguage by remember { mutableStateOf(BoardLocalStore.loadLanguage(context)) }
    var screenDragX by remember { mutableStateOf(0f) }
    var tabDirection by remember { mutableStateOf(1) }

    val tasksForSelectedDay = tasks.filter { it.dueDate == selectedDate }
    val taskDates = tasks.mapNotNull { it.dueDate }.toSet()
    val streakCount = computeStreak(tasks)
    val editingTask = tasks.firstOrNull { it.id == editingTaskId }
    val weekStart = selectedDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY))
    val weekEnd = weekStart.plusDays(6)
    val weekTasks = tasks.filter { task ->
        val dueDate = task.dueDate ?: return@filter false
        !dueDate.isBefore(weekStart) && !dueDate.isAfter(weekEnd)
    }
    val weeklyTotal = weekTasks.size
    val weeklyCompleted = weekTasks.count { it.isCompleted }

    fun persist() {
        BoardLocalStore.saveTasks(context, tasks)
    }

    val tabOrder = listOf(BoardTab.Board, BoardTab.Stats, BoardTab.Saved, BoardTab.Settings)
    fun navigateToTab(target: BoardTab) {
        val currentIndex = tabOrder.indexOf(selectedTab)
        val targetIndex = tabOrder.indexOf(target)
        if (currentIndex == -1 || targetIndex == -1 || currentIndex == targetIndex) return
        tabDirection = if (targetIndex > currentIndex) 1 else -1
        selectedTab = target
    }

    fun moveTab(offset: Int) {
        val current = tabOrder.indexOf(selectedTab)
        if (current < 0) return
        val target = (current + offset).coerceIn(0, tabOrder.lastIndex)
        if (target == current) return
        tabDirection = if (target > current) 1 else -1
        selectedTab = tabOrder[target]
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(if (selectedTab == BoardTab.Settings) Color(0xFFF9FAFC) else Color(0xFFF3F3F5))
            .pointerInput(selectedTab, showAddDialog, editingTaskId, showMonthPicker) {
                detectHorizontalDragGestures(
                    onHorizontalDrag = { _, amount ->
                        screenDragX += amount
                    },
                    onDragEnd = {
                        if (!showAddDialog && editingTaskId == null && !showMonthPicker) {
                            when {
                                screenDragX <= -90f -> moveTab(+1)
                                screenDragX >= 90f -> moveTab(-1)
                            }
                        }
                        screenDragX = 0f
                    },
                    onDragCancel = { screenDragX = 0f }
                )
            }
    ) {
        AnimatedContent(
            targetState = selectedTab,
            transitionSpec = {
                val slideIn = slideInHorizontally(
                    animationSpec = tween(280),
                    initialOffsetX = { fullWidth -> if (tabDirection > 0) fullWidth / 3 else -fullWidth / 3 }
                ) + fadeIn(animationSpec = tween(220))
                val slideOut = slideOutHorizontally(
                    animationSpec = tween(280),
                    targetOffsetX = { fullWidth -> if (tabDirection > 0) -fullWidth / 4 else fullWidth / 4 }
                ) + fadeOut(animationSpec = tween(220))
                slideIn togetherWith slideOut
            },
            label = "tab_switch"
        ) { tab ->
            when (tab) {
                BoardTab.Board -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .statusBarsPadding()
                            .padding(horizontal = 12.dp)
                            .padding(top = 8.dp)
                    ) {
                        MonthCalendarCard(
                            language = appLanguage,
                            selectedDate = selectedDate,
                            taskDates = taskDates,
                            weeklyCompleted = weeklyCompleted,
                            weeklyTotal = weeklyTotal,
                            onSelectDate = { selectedDate = it },
                            onMovePreviousWeek = { selectedDate = selectedDate.minusWeeks(1) },
                            onMoveNextWeek = { selectedDate = selectedDate.plusWeeks(1) },
                            onOpenMonthPicker = { showMonthPicker = true }
                        )

                        Spacer(modifier = Modifier.height(10.dp))
                        StreakCard(days = streakCount, language = appLanguage)
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
                                    rotation = if (index % 2 == 0) -0.2f else 0.2f,
                                    onOpen = { editingTaskId = task.id }
                                )
                            }

                            item {
                                AddNoteCard(onClick = { showAddDialog = true }, language = appLanguage)
                            }
                        }
                    }
                }

                BoardTab.Settings -> {
                    SettingsScreen(
                        language = appLanguage,
                        onLanguageChange = {
                            appLanguage = it
                            BoardLocalStore.saveLanguage(context, it)
                        },
                        modifier = Modifier
                            .fillMaxSize()
                            .statusBarsPadding()
                            .padding(horizontal = 12.dp)
                            .padding(top = 8.dp, bottom = 108.dp)
                    )
                }

                BoardTab.Stats -> {
                    PlaceholderScreen(
                        title = i18n(appLanguage, "Estadisticas", "Statistics"),
                        subtitle = i18n(
                            appLanguage,
                            "Desliza para cambiar entre pantallas.",
                            "Swipe to move between screens."
                        ),
                        modifier = Modifier
                            .fillMaxSize()
                            .statusBarsPadding()
                            .padding(horizontal = 12.dp)
                            .padding(top = 8.dp, bottom = 108.dp)
                    )
                }

                BoardTab.Saved -> {
                    PlaceholderScreen(
                        title = i18n(appLanguage, "Guardados", "Saved"),
                        subtitle = i18n(
                            appLanguage,
                            "Desliza para cambiar entre pantallas.",
                            "Swipe to move between screens."
                        ),
                        modifier = Modifier
                            .fillMaxSize()
                            .statusBarsPadding()
                            .padding(horizontal = 12.dp)
                            .padding(top = 8.dp, bottom = 108.dp)
                    )
                }
            }
        }

        BottomBoardNav(
            selectedTab = selectedTab,
            onSelectTab = { navigateToTab(it) },
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(horizontal = 12.dp, vertical = 14.dp)
        )

        AnimatedVisibility(
            visible = showAddDialog && selectedTab == BoardTab.Board,
            enter = fadeIn(animationSpec = tween(220)) + scaleIn(
                animationSpec = tween(220),
                initialScale = 0.96f
            ),
            exit = fadeOut(animationSpec = tween(180)) + scaleOut(
                animationSpec = tween(180),
                targetScale = 0.98f
            )
        ) {
            AddTaskDialog(
                language = appLanguage,
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
                language = appLanguage,
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

        if (showMonthPicker && selectedTab == BoardTab.Board) {
            MonthPickerOverlay(
                language = appLanguage,
                selectedDate = selectedDate,
                taskDates = taskDates,
                onDismiss = { showMonthPicker = false },
                onSelectDate = {
                    selectedDate = it
                    showMonthPicker = false
                }
            )
        }
    }
}

@Composable
private fun MonthCalendarCard(
    language: AppLanguage,
    selectedDate: LocalDate,
    taskDates: Set<LocalDate>,
    weeklyCompleted: Int,
    weeklyTotal: Int,
    onSelectDate: (LocalDate) -> Unit,
    onMovePreviousWeek: () -> Unit,
    onMoveNextWeek: () -> Unit,
    onOpenMonthPicker: () -> Unit
) {
    val previousInteraction = remember { MutableInteractionSource() }
    val nextInteraction = remember { MutableInteractionSource() }
    val monthInteraction = remember { MutableInteractionSource() }
    val startOfWeek = selectedDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.SUNDAY))
    val weekDates = (0..6).map { startOfWeek.plusDays(it.toLong()) }
    val weekDays = listOf("S", "M", "T", "W", "T", "F", "S")
    val weeklyProgress = if (weeklyTotal > 0) weeklyCompleted.toFloat() / weeklyTotal.toFloat() else 0f
    val animatedWeeklyProgress by animateFloatAsState(
        targetValue = weeklyProgress.coerceIn(0f, 1f),
        animationSpec = tween(durationMillis = 450),
        label = "weekly_progress"
    )
    val weeklyPercent = (weeklyProgress * 100).toInt()
    val monthLocale = if (language == AppLanguage.Es) Locale("es", "ES") else Locale.US
    val monthFormatter = DateTimeFormatter.ofPattern("MMMM yyyy", monthLocale)
    val monthTitle = selectedDate.format(monthFormatter).replaceFirstChar {
        if (it.isLowerCase()) it.titlecase(monthLocale) else it.toString()
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
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable(
                    interactionSource = previousInteraction,
                    indication = null,
                    onClick = onMovePreviousWeek
                )
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                "$monthTitle ⌄",
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier
                    .weight(1f)
                    .clickable(
                        interactionSource = monthInteraction,
                        indication = null,
                        onClick = onOpenMonthPicker
                    )
            )
            Text(
                "›",
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.clickable(
                    interactionSource = nextInteraction,
                    indication = null,
                    onClick = onMoveNextWeek
                )
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
                val dayInteraction = remember(date) { MutableInteractionSource() }
                Column(
                    modifier = Modifier.clickable(
                        interactionSource = dayInteraction,
                        indication = null
                    ) { onSelectDate(date) },
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

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(1.dp)
                .background(Color(0xFFE8EBF1))
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                i18n(language, "Progreso semanal", "Weekly progress"),
                style = MaterialTheme.typography.labelMedium,
                color = Color(0xFF8E99AE),
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.width(8.dp))
            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(4.dp)
                    .clip(RoundedCornerShape(999.dp))
                    .background(Color(0xFFE2E6EE))
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth(animatedWeeklyProgress)
                        .height(4.dp)
                        .background(Color(0xFFF87533))
                )
            }
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                "$weeklyCompleted/$weeklyTotal",
                style = MaterialTheme.typography.labelMedium,
                color = Color(0xFFF87533),
                fontWeight = FontWeight.Bold
            )
        }

        Text(
            i18n(language, "$weeklyPercent% completado esta semana", "$weeklyPercent% completed this week"),
            style = MaterialTheme.typography.labelSmall,
            color = Color(0xFFB0B8C7),
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
private fun MonthPickerOverlay(
    language: AppLanguage,
    selectedDate: LocalDate,
    taskDates: Set<LocalDate>,
    onDismiss: () -> Unit,
    onSelectDate: (LocalDate) -> Unit
) {
    var visibleMonth by remember(selectedDate) { mutableStateOf(YearMonth.from(selectedDate)) }
    var dragX by remember { mutableStateOf(0f) }
    val weekDays = listOf("S", "M", "T", "W", "T", "F", "S")
    val monthLocale = if (language == AppLanguage.Es) Locale("es", "ES") else Locale.US
    val monthTitle = visibleMonth.format(DateTimeFormatter.ofPattern("MMMM yyyy", monthLocale))
        .replaceFirstChar { if (it.isLowerCase()) it.titlecase(monthLocale) else it.toString() }

    val firstDayOffset = visibleMonth.atDay(1).dayOfWeek.value % 7
    val totalDays = visibleMonth.lengthOfMonth()
    val cells = buildList<LocalDate?> {
        repeat(firstDayOffset) { add(null) }
        (1..totalDays).forEach { day -> add(visibleMonth.atDay(day)) }
        while (size % 7 != 0) add(null)
    }

    BackHandler(onBack = onDismiss)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.25f))
            .clickable { onDismiss() },
        contentAlignment = Alignment.Center
    ) {
        val leftInteraction = remember { MutableInteractionSource() }
        val rightInteraction = remember { MutableInteractionSource() }
        val closeInteraction = remember { MutableInteractionSource() }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .clip(RoundedCornerShape(24.dp))
                .background(Color(0xFFF8F9FB))
                .clickable { }
                .pointerInput(Unit) {
                    detectHorizontalDragGestures(
                        onHorizontalDrag = { _, amount ->
                            dragX += amount
                        },
                        onDragEnd = {
                            when {
                                dragX <= -80f -> visibleMonth = visibleMonth.plusMonths(1)
                                dragX >= 80f -> visibleMonth = visibleMonth.minusMonths(1)
                            }
                            dragX = 0f
                        },
                        onDragCancel = { dragX = 0f }
                    )
                }
                .padding(horizontal = 14.dp, vertical = 12.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                repeat(4) {
                    Box(
                        modifier = Modifier
                            .width(8.dp)
                            .height(22.dp)
                            .clip(RoundedCornerShape(999.dp))
                            .background(Color(0xFFDDE1EA))
                    )
                }
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    "✕",
                    color = Color(0xFF9CA5B6),
                    style = MaterialTheme.typography.titleLarge,
                    modifier = Modifier.clickable(
                        interactionSource = closeInteraction,
                        indication = null
                    ) { onDismiss() }
                )
            }

            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "‹",
                    color = Color(0xFF8B95A8),
                    style = MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable(
                        interactionSource = leftInteraction,
                        indication = null
                    ) {
                        visibleMonth = visibleMonth.minusMonths(1)
                    }
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    monthTitle,
                    color = Color(0xFF2D374B),
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.ExtraBold,
                    modifier = Modifier.weight(1f)
                )
                Text(
                    "›",
                    color = Color(0xFF8B95A8),
                    style = MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable(
                        interactionSource = rightInteraction,
                        indication = null
                    ) {
                        visibleMonth = visibleMonth.plusMonths(1)
                    }
                )
            }

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                weekDays.forEach { day ->
                    Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                        Text(day, color = Color(0xFFB2BAC9), style = MaterialTheme.typography.labelSmall)
                    }
                }
            }

            cells.chunked(7).forEach { week ->
                Row(modifier = Modifier.fillMaxWidth()) {
                    week.forEach { date ->
                        val selected = date == selectedDate
                        val hasTask = date != null && taskDates.contains(date)
                        val dayInteraction = remember(date) { MutableInteractionSource() }

                        Column(
                            modifier = Modifier
                                .weight(1f)
                                .clickable(
                                    enabled = date != null,
                                    interactionSource = dayInteraction,
                                    indication = null
                                ) {
                                    if (date != null) onSelectDate(date)
                                },
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(34.dp)
                                    .background(
                                        if (selected) Color(0xFFF87533) else Color.Transparent,
                                        CircleShape
                                    ),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = date?.dayOfMonth?.toString() ?: "",
                                    color = if (selected) Color.White else Color(0xFF30384A),
                                    style = MaterialTheme.typography.titleMedium,
                                    fontWeight = FontWeight.Bold,
                                    fontFamily = StickyFont
                                )
                            }

                            Spacer(modifier = Modifier.height(3.dp))
                            Box(
                                modifier = Modifier
                                    .size(4.dp)
                                    .background(
                                        if (hasTask) Color(0xFFF87533) else Color.Transparent,
                                        CircleShape
                                    )
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun StreakCard(days: Int, language: AppLanguage) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color(0xFFF1E27B))
    ) {
        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .width(28.dp)
                .height(5.dp)
                .clip(RoundedCornerShape(999.dp))
                .background(Color.White.copy(alpha = 0.5f))
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(34.dp)
                    .clip(CircleShape)
                    .background(Color(0xFFFFE6A6))
                    .drawBehind {
                        drawCircle(
                            color = Color(0xFFF39B5F),
                            style = Stroke(
                                width = 1.8.dp.toPx(),
                                pathEffect = PathEffect.dashPathEffect(floatArrayOf(8f, 6f), 0f)
                            )
                        )
                    },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Outlined.LocalFireDepartment,
                    contentDescription = "Racha",
                    tint = Color(0xFFF87533),
                    modifier = Modifier.size(20.dp)
                )
            }
            Column {
                Text(
                    i18n(language, "Racha diaria", "Daily streak"),
                    style = MaterialTheme.typography.labelMedium,
                    color = Color(0xFF7A889D),
                    fontWeight = FontWeight.Bold
                )
                Text(
                    i18n(language, "Racha de $days dias", "$days-day streak"),
                    style = MaterialTheme.typography.headlineSmall,
                    fontWeight = FontWeight.ExtraBold,
                    color = Color(0xFF2F3A4E),
                    fontFamily = StickyFont
                )
            }
        }
    }
}

@Composable
private fun StickyNoteCard(task: BoardTaskUi, category: TaskCategoryUi, rotation: Float, onOpen: () -> Unit) {
    val shape = RoundedCornerShape(14.dp)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(126.dp)
            .rotate(rotation)
            .shadow(5.dp, shape)
            .clip(shape)
            .background(category.color)
            .clickable(onClick = onOpen)
    ) {
        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .padding(top = 2.dp)
                .width(30.dp)
                .height(6.dp)
                .clip(RoundedCornerShape(999.dp))
                .background(Color.White.copy(alpha = 0.45f))
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
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
                if (task.isCompleted) {
                    Text("✓", color = Color(0xFF8C96A8))
                } else {
                    Icon(
                        imageVector = category.icon,
                        contentDescription = category.label,
                        tint = Color(0xFF7E8899),
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun AddNoteCard(onClick: () -> Unit, language: AppLanguage) {
    val shape = RoundedCornerShape(14.dp)

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(126.dp)
            .clip(shape)
            .background(Color(0xFFF9F9FA))
            .clickable(onClick = onClick)
            .drawBehind {
                drawRoundRect(
                    color = Color(0xFFD4D8E0),
                    cornerRadius = CornerRadius(14.dp.toPx(), 14.dp.toPx()),
                    style = Stroke(width = 1.7.dp.toPx(), pathEffect = PathEffect.dashPathEffect(floatArrayOf(9f, 7f), 0f))
                )
            },
    ) {
        Box(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .padding(top = 2.dp)
                .width(30.dp)
                .height(6.dp)
                .clip(RoundedCornerShape(999.dp))
                .background(Color.White.copy(alpha = 0.65f))
        )

        Column(
            modifier = Modifier.fillMaxSize().padding(12.dp),
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
                i18n(language, "NUEVA NOTA", "NEW NOTE"),
                color = Color(0xFF8B95A8),
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.Black,
                fontFamily = StickyFont
            )
        }
    }
}

@Composable
private fun AddTaskDialog(
    language: AppLanguage,
    categories: List<TaskCategoryUi>,
    selectedDate: LocalDate,
    onDismiss: () -> Unit,
    onCreate: (title: String, notes: String, categoryId: String, dueDate: LocalDate?) -> Unit
) {
    var title by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var selectedCategoryId by remember { mutableStateOf(categories.first().id) }
    val selectedCategory = categories.firstOrNull { it.id == selectedCategoryId } ?: categories.first()

    BackHandler(onBack = onDismiss)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF3F3F5))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = {}
            )
            .statusBarsPadding()
            .padding(horizontal = 14.dp, vertical = 10.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    "✕",
                    color = Color(0xFF9CA5B6),
                    style = MaterialTheme.typography.displaySmall,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable(onClick = onDismiss)
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    i18n(language, "Nueva nota", "New note"),
                    color = Color(0xFFF87533),
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.weight(1f))
                Spacer(modifier = Modifier.width(18.dp))
            }

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(410.dp)
                    .clip(RoundedCornerShape(14.dp))
                    .background(selectedCategory.color)
                    .border(1.dp, Color.White.copy(alpha = 0.55f), RoundedCornerShape(14.dp))
                    .padding(horizontal = 14.dp, vertical = 10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                Box(
                    modifier = Modifier
                        .align(Alignment.CenterHorizontally)
                        .width(54.dp)
                        .height(6.dp)
                        .clip(RoundedCornerShape(999.dp))
                        .background(Color.White.copy(alpha = 0.35f))
                )

                BasicTextField(
                    value = title,
                    onValueChange = { title = it },
                    textStyle = MaterialTheme.typography.headlineMedium.copy(
                        color = Color(0xFF202633),
                        fontFamily = StickyFont,
                        fontWeight = FontWeight.ExtraBold
                    ),
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth(),
                    decorationBox = { innerTextField ->
                        if (title.isBlank()) {
                            Text(
                                i18n(language, "Tarea", "Task"),
                                style = MaterialTheme.typography.headlineMedium,
                                color = Color(0xFF202633),
                                fontFamily = StickyFont,
                                fontWeight = FontWeight.ExtraBold
                            )
                        }
                        innerTextField()
                    }
                )

                BasicTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    textStyle = MaterialTheme.typography.headlineSmall.copy(
                        color = Color(0xFF8A845F),
                        fontFamily = StickyFont,
                        fontWeight = FontWeight.SemiBold
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f),
                    decorationBox = { innerTextField ->
                        if (notes.isBlank()) {
                            Text(
                                i18n(language, "Descripcion", "Description"),
                                style = MaterialTheme.typography.headlineSmall,
                                color = Color(0xFF9A9570),
                                fontFamily = StickyFont,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                        innerTextField()
                    }
                )
            }

            Text(
                text = i18n(language, "Elige una pegatina", "Choose a sticker"),
                color = Color(0xFF8E99AE),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.align(Alignment.CenterHorizontally)
            )

            LazyRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp, Alignment.CenterHorizontally)
            ) {
                items(categories) { category ->
                    val selected = category.id == selectedCategoryId
                    val stickerInteraction = remember(category.id) { MutableInteractionSource() }
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(4.dp),
                        modifier = Modifier.clickable(
                            interactionSource = stickerInteraction,
                            indication = null
                        ) { selectedCategoryId = category.id }
                    ) {
                        Box(
                            modifier = Modifier
                                .size(44.dp)
                                .clip(CircleShape)
                                .background(category.color)
                                .drawBehind {
                                    if (selected) {
                                        drawCircle(
                                            color = Color(0xFFF87533),
                                            style = Stroke(
                                                width = 2.dp.toPx(),
                                                pathEffect = PathEffect.dashPathEffect(floatArrayOf(8f, 6f), 0f)
                                            )
                                        )
                                    }
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = category.icon,
                                contentDescription = category.label,
                                tint = Color(0xFF667084),
                                modifier = Modifier.size(18.dp)
                            )
                        }
                        Text(
                            text = category.label,
                            style = MaterialTheme.typography.labelSmall,
                            color = Color(0xFF8E99AE)
                        )
                    }
                }
            }

            TextButton(
                onClick = { onCreate(title, notes, selectedCategoryId, selectedDate) },
                enabled = title.isNotBlank(),
                modifier = Modifier
                    .align(Alignment.CenterHorizontally)
                    .clip(RoundedCornerShape(999.dp))
                    .background(if (title.isNotBlank()) Color(0xFFF58A55) else Color(0xFFF3B99D))
                    .padding(horizontal = 22.dp, vertical = 4.dp)
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Outlined.PushPin,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(17.dp)
                    )
                    Text(
                        i18n(language, "Fijar en tablero", "Pin to board"),
                        color = Color.White,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

@Composable
private fun ExpandedStickyTaskEditor(
    language: AppLanguage,
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
                        i18n(language, "PARA HOY", "FOR TODAY"),
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
                        i18n(language, "adjunto", "attachment"),
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
                                if (selected) {
                                    Text(
                                        text = "•",
                                        style = MaterialTheme.typography.titleMedium,
                                        color = Color(0xFF4D5566)
                                    )
                                } else {
                                    Icon(
                                        imageVector = category.icon,
                                        contentDescription = category.label,
                                        tint = Color(0xFF4D5566),
                                        modifier = Modifier.size(20.dp)
                                    )
                                }
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
                    i18n(language, "HAS TERMINADO?", "ARE YOU DONE?"),
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
                        text = if (task.isCompleted) {
                            i18n(language, "Marcar pendiente", "Mark pending")
                        } else {
                            i18n(language, "Completar tarea", "Complete task")
                        },
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }

                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    TextButton(
                        onClick = { dismissSmooth { onDelete() } },
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(i18n(language, "Eliminar", "Delete"), color = Color(0xFFF25C5C))
                    }
                    TextButton(
                        onClick = { dismissSmooth { onSave(title, notes, categoryId) } },
                        enabled = title.isNotBlank(),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(
                            i18n(language, "Guardar cambios", "Save changes"),
                            color = Color(0xFFF87533),
                            fontWeight = FontWeight.ExtraBold
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SettingsScreen(
    language: AppLanguage,
    onLanguageChange: (AppLanguage) -> Unit,
    modifier: Modifier = Modifier
) {
    var dailyNotificationEnabled by remember { mutableStateOf(false) }
    var notificationTime by remember { mutableStateOf("09:00") }

    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Spacer(modifier = Modifier.height(10.dp))
        Text(
            i18n(language, "Ajustes", "Settings"),
            color = Color(0xFF2E374C),
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.ExtraBold,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )
        Text(
            i18n(
                language,
                "Configura la notificacion diaria y activa el\nrecordatorio.",
                "Set up your daily notification and enable\nthe reminder."
            ),
            color = Color(0xFF9AA4B8),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        )

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(Color.White)
                .border(1.dp, Color(0xFFF0F2F6), RoundedCornerShape(16.dp))
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Row(verticalAlignment = Alignment.Top) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        i18n(language, "Notificacion diaria", "Daily notification"),
                        color = Color(0xFF2E374C),
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.ExtraBold
                    )
                    Text(
                        i18n(
                            language,
                            "Recibe un recordatorio cada dia a la\nhora elegida.",
                            "Receive a reminder every day at\nthe selected time."
                        ),
                        color = Color(0xFF9CA6B9),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.SemiBold
                    )
                }
                Switch(
                    checked = dailyNotificationEnabled,
                    onCheckedChange = { dailyNotificationEnabled = it }
                )
            }

            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(8.dp))
                    .background(Color(0xFFF6F7FA))
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) {
                Text(
                    notificationTime,
                    color = Color(0xFF7F899E),
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(16.dp))
                .background(Color.White)
                .border(1.dp, Color(0xFFF0F2F6), RoundedCornerShape(16.dp))
                .padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                i18n(language, "Idioma de la app", "App language"),
                color = Color(0xFF2E374C),
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.ExtraBold
            )
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(Color(0xFFF1F3F7))
                    .padding(2.dp)
            ) {
                val esSelected = language == AppLanguage.Es
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (esSelected) Color.White else Color.Transparent)
                        .clickable { onLanguageChange(AppLanguage.Es) }
                        .padding(vertical = 7.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text("Espanol", fontWeight = FontWeight.Bold, color = Color(0xFF3B4457))
                }
                val enSelected = language == AppLanguage.En
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(8.dp))
                        .background(if (enSelected) Color.White else Color.Transparent)
                        .clickable { onLanguageChange(AppLanguage.En) }
                        .padding(vertical = 7.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text("English", fontWeight = FontWeight.Bold, color = Color(0xFF3B4457))
                }
            }
        }

        TextButton(
            onClick = {},
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(14.dp))
                .background(Color(0xFFF7F8FA))
                .drawBehind {
                    drawRoundRect(
                        color = Color(0xFFF0CFC2),
                        cornerRadius = CornerRadius(14.dp.toPx(), 14.dp.toPx()),
                        style = Stroke(width = 1.5.dp.toPx())
                    )
                }
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(Icons.Outlined.Apps, contentDescription = null, tint = Color(0xFFF07640), modifier = Modifier.size(18.dp))
                Text(
                    i18n(language, "Gestionar categorias", "Manage categories"),
                    color = Color(0xFFF07640),
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.ExtraBold
                )
            }
        }
    }
}

@Composable
private fun PlaceholderScreen(title: String, subtitle: String, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = title,
            color = Color(0xFF2E374C),
            style = MaterialTheme.typography.displaySmall,
            fontWeight = FontWeight.ExtraBold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = subtitle,
            color = Color(0xFF9AA4B8),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.SemiBold
        )
    }
}

@Composable
private fun BottomBoardNav(selectedTab: BoardTab, onSelectTab: (BoardTab) -> Unit, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .shadow(10.dp, RoundedCornerShape(22.dp))
            .clip(RoundedCornerShape(22.dp))
            .background(Color(0xFFF7F8FA))
            .padding(horizontal = 10.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        BottomNavItem(
            icon = Icons.Outlined.Apps,
            selected = selectedTab == BoardTab.Board,
            onClick = { onSelectTab(BoardTab.Board) }
        )
        BottomNavItem(
            icon = Icons.Outlined.BarChart,
            selected = selectedTab == BoardTab.Stats,
            onClick = { onSelectTab(BoardTab.Stats) }
        )
        BottomNavItem(
            icon = Icons.Outlined.BookmarkBorder,
            selected = selectedTab == BoardTab.Saved,
            onClick = { onSelectTab(BoardTab.Saved) }
        )
        BottomNavItem(
            icon = Icons.Outlined.Settings,
            selected = selectedTab == BoardTab.Settings,
            onClick = { onSelectTab(BoardTab.Settings) }
        )
    }
}

@Composable
private fun BottomNavItem(icon: ImageVector, selected: Boolean, onClick: () -> Unit) {
    val iconTint = if (selected) Color(0xFFF87533) else Color(0xFF8F99AC)
    val itemBackground = if (selected) Color(0xFFFBE7DD) else Color.Transparent

    Box(
        modifier = Modifier
            .size(width = 78.dp, height = 44.dp)
            .clip(RoundedCornerShape(18.dp))
            .background(itemBackground)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconTint,
            modifier = Modifier.size(22.dp)
        )
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
    private const val keyLanguage = "app_language_v1"

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

    fun loadLanguage(context: Context): AppLanguage {
        val raw = context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .getString(keyLanguage, "es")
        return if (raw == "en") AppLanguage.En else AppLanguage.Es
    }

    fun saveLanguage(context: Context, language: AppLanguage) {
        val value = if (language == AppLanguage.En) "en" else "es"
        context.getSharedPreferences(prefsName, Context.MODE_PRIVATE)
            .edit()
            .putString(keyLanguage, value)
            .apply()
    }
}
