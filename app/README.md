# Boardo App (MVP)

Todo list en formato calendario con tarjetas estilo post-it sobre pizarra, inspirado en tus mockups.

## Objetivo del MVP
- Sin login, sin sincronizacion.
- Todo local (por ahora con datos mock en memoria).
- Flujo principal: ver calendario, ver tareas del dia, crear tarea, marcar completada.

## Estructura del proyecto

```text
Sources/app
├── App
│   └── AppRootView.swift
├── Core
│   ├── Extensions
│   │   └── Date+Board.swift
│   └── Theme
│       └── AppTheme.swift
├── Data
│   └── Mock
│       └── BoardMockData.swift
├── Features
│   └── Board
│       ├── Components
│       │   ├── AddTaskSheet.swift
│       │   ├── BoardHeader.swift
│       │   ├── CompactMonthCalendar.swift
│       │   ├── InboxCard.swift
│       │   ├── StickyTaskCard.swift
│       │   └── TaskSectionHeader.swift
│       ├── Models
│       │   ├── BoardTask.swift
│       │   └── TaskCategory.swift
│       ├── ViewModels
│       │   └── BoardViewModel.swift
│       └── Views
│           └── BoardScreen.swift
├── Shared
│   └── Components
│       ├── BoardSurface.swift
│       └── BottomNavigationBar.swift
├── ContentView.swift
└── appApp.swift
```

## De donde viene cada cosa

### Inspiracion visual (mockups del usuario)
- Tarjetas pastel tipo post-it con sombra y ligera inclinacion.
- Jerarquia: encabezado, calendario compacto arriba, lista de tareas abajo.
- Boton flotante para crear nueva tarea.
- Barra inferior estilo app mobile.

### Implementacion del estilo
- `Core/Theme/AppTheme.swift`:
  - Paleta principal (grises suaves + acento naranja).
  - Colores de post-it (amarillo, azul, rosa, menta).
  - Radios y sombras para un look de tarjeta/papel.

### Pantalla principal
- `Features/Board/Views/BoardScreen.swift`:
  - Orquesta la vista completa.
  - Muestra calendario, tareas del dia, inbox, barra inferior y boton flotante.

### Componentes del tablero
- `BoardHeader.swift`: cabecera "My Workspace" + indicador de streak.
- `CompactMonthCalendar.swift`: selector compacto de dias.
- `StickyTaskCard.swift`: tarjeta post-it por tarea.
- `TaskSectionHeader.swift`: encabezado reutilizable de seccion.
- `InboxCard.swift`: bloque de tareas sin fecha.
- `AddTaskSheet.swift`: modal de creacion de nueva tarea.

### Datos y logica
- `Models/BoardTask.swift`: entidad tarea.
- `Models/TaskCategory.swift`: categorias + color asociado.
- `ViewModels/BoardViewModel.swift`: estado de pantalla y acciones (crear, completar, mover).
- `Data/Mock/BoardMockData.swift`: datos iniciales de ejemplo para prototipado.

### Infraestructura de app
- `App/AppRootView.swift`: punto de entrada visual para escalar navegacion futura.
- `appApp.swift`: arranque de la app.
- `Shared/Components/BoardSurface.swift`: fondo estilo pizarra.
- `Shared/Components/BottomNavigationBar.swift`: navegacion inferior reutilizable.

## Siguiente evolucion recomendada
1. Persistencia local real (SwiftData o UserDefaults codificado).
2. Vista semanal/mensual completa con drag & drop entre fechas.
3. Inbox interactivo para asignar fecha rapidamente.
4. Filtros por categoria y prioridad.
