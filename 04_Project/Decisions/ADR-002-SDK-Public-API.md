# ADR-002-SDK-Public-API

#adr #status/accepted

**Fecha:** 2026-05-25
**Status:** Accepted

## Contexto

`track-vitals` necesita fijar la API pública del SDK antes de implementar la captura real de Core Web Vitals. En Q1 el objetivo no es construir un RUM completo: es tener un SDK pequeño, tipado y publicable que capture `CLS`, `LCP`, `INP`, `FCP` y `TTFB`, permita eventos custom, y envíe un payload validable por el backend.

Esta decisión convierte [[SDK_Types]] y [[SDK_README]] en contrato arquitectural. Lo que se decide aquí afecta a:

- La superficie publicada por `@track-vitals/sdk`.
- El wire format que enviará el SDK al endpoint de ingesta.
- Los schemas Zod que vivan en el paquete compartido.
- La semántica de sesiones, sampling y hooks antes de que haya usuarios reales.

Estado actual del repo: `track-vitals` ya existe como monorepo con `packages/sdk` y `packages/server`. El contrato de este ADR gobierna la implementación que entra ahora; algunos nombres de carpeta en las notas (`sdk-web`, `shared`, `ingestion`) son el layout objetivo descrito por [[ADR-001-Monorepo-Structure]], no todo existe todavía.

Coste de equivocarse: medio. Cambiar la API antes de publicar `v1.0` es aceptable, pero cambiarla después de escribir README, tipos, ingestion y dashboard genera drift y rompe la narrativa del proyecto.

## Opciones consideradas

### Opción A: API mínima sólo para Core Web Vitals

```ts
init(config);
onMetric(callback);
```

- Pro: menor superficie pública.
- Pro: más rápida de implementar.
- Contra: no cubre eventos custom, que son parte del valor diferencial frente a usar `web-vitals` directamente.
- Contra: obliga a meter un breaking change temprano en cuanto el dashboard necesite correlacionar CWV con acciones del usuario.
- Contra: no fuerza todavía el diseño del payload entre SDK e ingestion.

### Opción B: API pequeña con cinco funciones públicas (elegida)

```ts
init(config);
identify(userOrNull);
track(name, properties);
onVital(name, callback);
flush();
```

- Pro: cubre el flujo principal sin convertir el proyecto en Sentry.
- Pro: separa bien configuración, identidad, eventos custom, suscripción local y envío forzado.
- Pro: deja una API demostrable en README y entrevistas.
- Pro: permite un único wire format para eventos `vital` y `custom`.
- Contra: más trabajo que la API mínima.
- Contra: `identify` introduce una responsabilidad explícita de privacidad.

### Opción C: API tipo RUM completo

```ts
init({
  transport,
  plugins,
  hooks,
  batchSize,
  retryPolicy,
  context,
  tags,
});
```

- Pro: flexible.
- Pro: familiar para usuarios de Sentry, Datadog o Grafana Faro.
- Contra: contradice el scope Q1. Esto es inflar el SDK antes de capturar una métrica real.
- Contra: cada knob público crea deuda de soporte y semver.
- Contra: oculta la señal Staff que interesa aquí: buen criterio de producto técnico, no más opciones.

## Decisión

Elegir la opción B: una API pública pequeña, con cinco funciones y un wire format preparado para batching desde `v0.1`.

```ts
export type InitFn = (config: WebVitalsConfig) => void;
export type IdentifyFn = (user: User | null) => void;
export type TrackFn = (name: string, properties?: EventProperties) => void;
export type FlushFn = () => Promise<void>;

export type OnVitalFn = <N extends WebVitalName>(
  name: N,
  callback: (vital: WebVital<N>) => void,
) => void;
```

El contrato de tipos queda así:

- `WebVitalsConfig` es input del consumidor. No se reutiliza como wire format.
- `IngestionPayload` es lo que sale por `sendBeacon` o `fetch keepalive`.
- `WebVitalEvent` es una union discriminada entre `VitalEvent` y `CustomEvent`.
- `IngestionPayload.events` es un array desde el día uno para soportar batching sin breaking change.
- `url` vive en cada evento, no en el wrapper, porque una SPA puede cambiar de ruta dentro de la misma sesión.
- `User` requiere `id` y restringe propiedades extra a escalares.
- `EventProperties` queda como `Record<string, unknown>`; validación profunda ocurre en ingestion con Zod.

Configuración pública aceptada:

```ts
export interface WebVitalsConfig {
  projectId: string;
  endpoint: string;
  release?: string;
  environment?: string;
  sampleRate?: number;
  debug?: boolean;
  beforeSend?: (event: WebVitalEvent) => WebVitalEvent | null | Promise<WebVitalEvent | null>;
}
```

Decisiones cerradas dentro de esta API:

- `sampleRate` se aplica por sesión, no por evento.
- `sessionId` lo genera el SDK internamente y no es configurable.
- Una sesión vive en `sessionStorage`, sobrevive reloads y navegación SPA, caduca tras 30 minutos de inactividad o 4 horas de duración máxima.
- `beforeSend` puede ser sync o async. En operación normal se espera antes de encolar. En flush por `visibilitychange`, cada evento tiene un presupuesto de 50ms; si el hook no responde, el evento se descarta y se emite warning en `debug`.
- `identify(null)` limpia la identidad; no se añade `clearUser()`.

Quedan fuera de `v0.1`:

- Transporte configurable.
- `batchSize`, `flushInterval`, `maxQueueSize` públicos.
- Plugins.
- Breadcrumbs, severity/level, error tracking o replay.
- Tags dedicados; para `v0.1`, `properties` cubre el caso.
- Contexto enriquecido de dispositivo, OS o locale en el SDK. Se deriva server-side desde `userAgent` y headers cuando haga falta.

## Razones principales

1. **Superficie pública defendible.** Cinco funciones bastan para vender el SDK y escribir una demo real sin abrir knobs prematuros.
2. **Contrato preparado para SPAs y batching.** `events[]` y `url` por evento evitan renegociar el payload cuando entren `sendBeacon`, route changes y flush real.
3. **Type safety donde aporta.** `WebVital<N>` mejora `onVital('LCP', cb)`; `track<T>()` genérico no aporta seguridad real porque el SDK no puede conocer el schema de eventos custom.
4. **Validación en el boundary correcto.** TypeScript ayuda al consumidor, pero ingestion con Zod es la autoridad para rechazar payloads inválidos con errores claros.
5. **Privacidad explícita sin feature creep.** No cookies, no fingerprinting, identidad opt-in, y `identify(null)` para logout.

## Consecuencias

### Positivas

- La implementación de Q1 queda acotada.
- El README puede mostrar una API realista desde el principio.
- El backend recibe un payload uniforme y validable.
- El dashboard podrá consultar métricas por sesión, usuario opcional, release, environment y URL sin inferencias raras.
- El SDK mantiene una historia clara para entrevistas: contrato público pequeño, wire format separado, runtime validation y trade-offs documentados.

### Negativas / Trade-offs aceptados

- `beforeSend` async puede perder eventos al cerrar pestaña si tarda más de 50ms por evento. Aceptado porque bloquear unload no es fiable y el coste queda documentado.
- `EventProperties = Record<string, unknown>` permite pasar estructuras que TypeScript no rechazará. Aceptado porque la validación centralizada vive en ingestion.
- Sin knobs públicos para batching o transporte. Si los defaults fallan, habrá que abrir API nueva.
- `identify` puede inducir mal uso con PII. Mitigación: documentación clara, opt-in, no cookies y no fingerprinting.
- La decisión de session lifecycle afecta métricas agregadas. Cambiarla más tarde puede romper comparabilidad histórica.

## Revisitar si...

- Un usuario real necesita configurar transporte, batch size o retry policy.
- `beforeSend` async causa pérdida frecuente de eventos en unload.
- Ingestion necesita rechazar SDKs antiguos por versión o migrar payloads por semver.
- El dashboard necesita propiedades custom indexables y `Record<string, unknown>` se queda corto.
- La implementación de sesiones en `sessionStorage` produce métricas engañosas en tabs de larga vida o multi-tab.
- El paquete `shared` todavía no existe cuando se implemente ingestion; en ese caso, crear el paquete antes de duplicar schemas.

## Referencias

- [[SDK_Types]]
- [[SDK_README]]
- [[00_Project_Overview]]
- [[ADR-001-Monorepo-Structure]]
- Repo local: `/Users/73nko/Projects/track-vitals`
- `web-vitals`: https://github.com/GoogleChrome/web-vitals
- `zod-to-ts`: https://github.com/sachinraja/zod-to-ts
