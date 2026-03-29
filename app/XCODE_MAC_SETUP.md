# Xcode Mac Setup (publicar en TestFlight/App Store)

Este repo ya incluye:
- Codigo SwiftUI en `Sources/app`
- Localizacion en `Sources/app/Resources/*.lproj`
- Iconos completos en `Sources/app/Resources/Assets.xcassets/AppIcon.appiconset`

## Pasos en Mac

1. Crea un proyecto nuevo en Xcode: `iOS > App`.
2. En el proyecto nuevo, elimina `ContentView.swift` y `*App.swift` creados por plantilla.
3. Click derecho sobre el grupo del proyecto -> `Add Files to "<TuApp>"...`.
4. Selecciona `Sources/app` de este repo.
5. En el dialogo:
- `Added folders`: `Create groups`
- Marca tu target de app
- `Copy items if needed`: opcional (recomendado desmarcado)
6. En `TARGETS > <TuApp> > Build Settings`:
- `Asset Catalog App Icon Set Name` = `AppIcon`
7. En `TARGETS > <TuApp> > General`:
- `App Icons Source` = `AppIcon`
8. En `Signing & Capabilities`:
- `Automatically manage signing` ON
- Selecciona tu `Team`
- Bundle Identifier unico

## Si no arranca a la primera

1. `Product > Clean Build Folder`
2. Cambia destino a un iPhone simulator (no `My Mac`)
3. Verifica Target Membership de todos los archivos de `Sources/app`

## Publicacion

1. Selecciona `Any iOS Device (arm64)`
2. `Product > Archive`
3. Organizer -> `Distribute App` -> `App Store Connect` -> `Upload`
