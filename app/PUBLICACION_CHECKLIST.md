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

- [ ] Probar instalacion limpia en dispositivo real (sin datos previos).
- [ ] Validar flujos principales:
  - [ ] Crear tarea
  - [ ] Editar tarea
  - [ ] Completar/descompletar tarea
  - [ ] Mover fecha
  - [ ] Notificacion diaria (si esta habilitada)
- [ ] Revisar localizacion ES/EN (sin textos rotos o truncados).
- [ ] Revisar accesibilidad basica:
  - [ ] Tamaños de fuente (Dynamic Type)
  - [ ] Contraste
  - [ ] Labels de controles importantes

## Recomendado para reducir riesgo de rechazo

- [ ] Añadir una politica de privacidad publica (URL) aunque no recojas datos personales.
- [ ] Revisar permisos y textos mostrados al usuario (notificaciones claras y coherentes).
- [ ] Eliminar restos de desarrollo/documentacion interna no necesaria para release.

## Estado actual rapido

- [x] App funciona sin login y sin backend (esto **si** es publicable).
- [x] Datos locales en dispositivo (sin sincronizacion).
- [x] Arranque sin datos mock por defecto.

