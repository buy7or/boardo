# Checklist de Publicacion - Boardo

## Bloqueante (sin esto no publicar)

- [ ] Definir `bundleID` final (unico) en `xtool.yml` (reemplazar `com.example.app`).
- [ ] Configurar firma de **Release/App Store** (certificados, perfil y equipo correctos).
- [ ] Crear app en App Store Connect y vincular el `bundleID`.
- [ ] Completar metadata minima:
  - [ ] Nombre comercial definitivo
  - [ ] Subtitulo
  - [ ] Descripcion
  - [ ] Keywords
  - [ ] Categoria
  - [ ] Copyright
- [ ] Subir capturas reales de la app (iPhone, y iPad si aplica).
- [ ] Completar seccion **App Privacy** en App Store Connect.

## Calidad minima recomendada antes de enviar

- [x] Probar instalacion limpia en dispositivo real (sin datos previos).
- [x] Validar flujos principales:
  - [x] Crear tarea
  - [x] Editar tarea
  - [x] Completar/descompletar tarea
  - [x] Mover fecha
  - [x] Notificacion diaria (si esta habilitada)
- [x] Revisar localizacion ES/EN (sin textos rotos o truncados).
- [x] Revisar accesibilidad basica:
  - [x] Tamaños de fuente (Dynamic Type)
  - [x] Contraste
  - [x] Labels de controles importantes

## Recomendado para reducir riesgo de rechazo

- [x] Añadir una politica de privacidad publica (URL) aunque no recojas datos personales.
- [ ] Revisar permisos y textos mostrados al usuario (notificaciones claras y coherentes).
- [ ] Eliminar restos de desarrollo/documentacion interna no necesaria para release.

## Estado actual rapido

- [x] App funciona sin login y sin backend (esto **si** es publicable).
- [x] Datos locales en dispositivo (sin sincronizacion).
- [x] Arranque sin datos mock por defecto.

