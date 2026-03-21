# Boardo Android (base)

Proyecto base Android para iniciar el port de Boardo a Kotlin + Jetpack Compose.

## Requisitos

- Android Studio (recomendado) con SDK Android 35
- JDK 17

## Probar en Android Studio

1. Abre Android Studio.
2. `Open` y selecciona la carpeta `app_android`.
3. Deja que sincronice Gradle.
4. Ejecuta en un emulador o dispositivo con el botón `Run`.

## Probar por CLI (opcional)

Si tienes `gradle` instalado globalmente:

1. Entra en `app_android`.
2. Ejecuta `gradle assembleDebug`.
3. Instala el APK generado en `app/build/outputs/apk/debug/`.

## Estado actual

- Estructura base lista.
- `MainActivity` en Compose funcionando como punto de arranque.
- Tema inicial con paleta inspirada en Boardo.
