# ADR-002-SDK-Public-API

#adr #status/accepted

**Fecha:** 2026-05-21
**Status:** Accepted

## Contexto

`track-vitals` necesita una superficie pública pequeña para Q1: inicializar captura de Core Web Vitals, identificar usuario, enviar eventos custom, suscribirse a métricas y forzar flush cuando haga falta.

Esta decisión fija el contrato entre `packages/sdk-web`, `packages/shared` y `apps/ingestion` antes de implementar. El objetivo es evitar dos errores: copiar la complejidad de Sentry/Datadog y diseñar un wire format que no soporte batching o SPAs.

## Opciones consideradas

### Opción A: API mínima sólo para CWV
- Pro: menos superficie pública; más fácil de implementar en Q1.
- Contra: no cubre eventos custom, que son parte del valor diferencial frente a `web-vitals`.
- Contra: obligaría a un breaking change temprano cuando se añadan eventos custom.

### Opción B: API pequeña con `init`, `identify`, `track`, `onVital`, `flush` (elegida)
- Pro: cubre el flujo principal sin parecer un SDK de observabilidad completo.
- Pro: permite eventos custom y Core Web Vitals con el mismo wire format.
- Pro: mantiene una extensión pública única: `beforeSend`.
- Contra: más trabajo que la opción mínima.
- Contra: `identify` introduce preguntas de privacidad que hay que documentar bien.

### Opción C: API configurable tipo RUM completo
- Pro: flexible para transports, plugins, hooks, contexts, tags y errores.
- Contra: contradice el scope Q1. Esto no es Sentry.
- Contra: aumenta la superficie de soporte antes de tener usuarios reales.

## Decisión

Elegir la opción B:

```ts
init(config);
identify(userOrNull);
track(name, properties);
onVital(name, callback);
flush();
```

El wire format queda documentado en [[SDK_Types]]:

- `WebVitalsConfig` es input del usuario.
- `IngestionPayload` es lo que sale por `sendBeacon`.
- `WebVitalEvent` es una union discriminada entre eventos `vital` y `custom`.
- `IngestionPayload.events` es un array para soportar batching desde v0.1.
- `url` vive en cada evento para soportar SPAs con varias rutas por sesión.

## Razones principales

1. **Superficie pública pequeña.** Cinco funciones son suficientes para vender el SDK sin abrir knobs prematuros.
2. **Wire format preparado para batching.** Un array de eventos evita renegociar el contrato cuando entre `sendBeacon` real.
3. **Type safety end-to-end.** Los tipos del SDK y los schemas Zod de `shared` deben espejarse 1:1.

## Consecuencias

### Positivas
- La implementación de Q1 queda acotada.
- El README puede mostrar una API creíble desde el principio.
- El backend puede validar payloads sin inferir shape por heurística.

### Negativas / Trade-offs aceptados
- `beforeSend` será síncrono en v0.1. Async complica `visibilitychange` y flush antes de cerrar pestaña.
- No habrá configuración pública de transporte, batch size o retry policy en v0.1.
- `identify` obliga a ser explícito en privacidad: opt-in, sin cookies y sin fingerprinting.

## Revisitar si...

- Usuarios piden configurar batching o transporte.
- `beforeSend` síncrono bloquea un caso real.
- El backend necesita rechazar SDKs antiguos por versión.
- El payload empieza a incluir contexto enriquecido que no pueda derivarse server-side.

## Referencias

- [[SDK_Types]]
- [[SDK_README]]
- [[00_Project_Overview]]
- web-vitals: https://github.com/GoogleChrome/web-vitals
