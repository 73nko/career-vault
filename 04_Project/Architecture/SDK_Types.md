# SDK Public API — Types

#concept #project

Source of truth for `packages/sdk-web/src/types.ts` y los esquemas Zod paralelos en `packages/shared/src/schemas.ts`. Materializa el contrato vendido en [[SDK_README|README]] y la decisión formalizada en [[ADR-002-SDK-Public-API]].

**Scope:** sólo lo que cruza el límite público del SDK (signatures + wire format). Internals (queue, transport, observers) viven en sus propios módulos sin tipos exportados.

## Principios

1. **Cero `any`, cero `unknown` en superficie pública.** Si no puedo nombrarlo, no se expone.
2. **Discriminated unions con `type` literal**, no shape-based discrimination. Zod parsea limpio, narrowing es trivial.
3. **Propiedades de eventos = escalares.** Nada de objetos anidados en `properties`. ClickHouse vive en columnas; lo plano gana.
4. **Generics sólo donde aporten narrowing real.** `WebVital<N>` sí (afila `onVital`). Un `Event<T>` genérico no.
5. **Lo capturado por el SDK ≠ lo configurado por el usuario.** `WebVitalsConfig` es input. `IngestionPayload` es output. Sin solapar campos.

---

## Vital metrics

```ts
export type WebVitalName = 'CLS' | 'LCP' | 'INP' | 'FCP' | 'TTFB';

export type WebVitalRating = 'good' | 'needs-improvement' | 'poor';

export type NavigationType =
  | 'navigate'
  | 'reload'
  | 'back-forward'
  | 'back-forward-cache'
  | 'prerender'
  | 'restore';

export interface WebVital<N extends WebVitalName = WebVitalName> {
  name: N;
  value: number;            // ms, salvo CLS (unitless)
  rating: WebVitalRating;   // per Google thresholds
  delta: number;             // cambio desde la última lectura (INP, CLS)
  id: string;                // único por page load
  navigationType: NavigationType;
}
```

> El genérico `N` no se usa en el SDK casi nunca: existe para que `onVital('LCP', cb)` narrowee `cb`'s arg a `WebVital<'LCP'>`. Sin él, el callback recibiría `WebVital<WebVitalName>` y el `metric.name === 'LCP'` quedaría a cargo del usuario.

---

## User identity

```ts
export interface User {
  id: string;
  email?: string;
  [key: string]: string | number | boolean | undefined;
}
```

`id` obligatorio. El resto, propiedades escalares libres. Index signature constrained — `string | number | boolean` deja claro qué cabe sin abrir la puerta a `Date` o nested objects que romperían el storage.

---

## Custom event properties

```ts
export type EventProperties = Record<string, string | number | boolean | null>;
```

`null` distingue "explícitamente vacío" de "no enviado" (campo opcional ausente). Igual que SQL.

---

## Events (wire format)

```ts
export interface VitalEvent {
  type: 'vital';
  vital: WebVital;
  url: string;          // captured at measurement time (SPA-safe)
  timestamp: number;    // epoch ms
}

export interface CustomEvent {
  type: 'custom';
  name: string;         // ej: 'checkout.completed'
  properties?: EventProperties;
  url: string;
  timestamp: number;
}

export type WebVitalEvent = VitalEvent | CustomEvent;
```

> `url` vive en el evento, no en el wrapper. En un SPA, una sesión visita N rutas; cada medición debe conocer la suya. El resto del contexto es estable por sesión y va al wrapper.

---

## Ingestion payload (lo que sale por sendBeacon)

```ts
export interface IngestionPayload {
  projectId: string;
  sessionId: string;
  release?: string;
  environment?: string;
  user?: User;
  userAgent: string;
  sdk: { name: '@track-vitals/sdk'; version: string };
  events: WebVitalEvent[];
}
```

> Array de eventos, no uno por request. Habilita el batching que vende el README sin renegociar el wire format.

---

## Init config (input del usuario)

```ts
export interface WebVitalsConfig {
  projectId: string;
  endpoint: string;
  release?: string;
  environment?: string;
  sampleRate?: number;                                          // 0..1, default 1
  debug?: boolean;                                              // default false
  beforeSend?: (event: WebVitalEvent) => WebVitalEvent | null;  // mutate or drop
}
```

> Nada de `transport`, `batchSize`, `flushInterval`, `maxQueueSize` en v0.1. Son knobs que sólo importan cuando alguien los pide. Defaults sensatos y silencio.

---

## Public function signatures

```ts
export type InitFn      = (config: WebVitalsConfig) => void;
export type IdentifyFn  = (user: User | null) => void;   // null = logout
export type TrackFn     = (name: string, properties?: EventProperties) => void;
export type FlushFn     = () => Promise<void>;

export type VitalCallback<N extends WebVitalName> = (vital: WebVital<N>) => void;
export type OnVitalFn = <N extends WebVitalName>(name: N, callback: VitalCallback<N>) => void;
```

Estas signatures se importan tal cual desde el `index.ts` que las implementa:

```ts
// packages/sdk-web/src/index.ts
import type { InitFn, IdentifyFn, TrackFn, FlushFn, OnVitalFn } from './types';

export const init:     InitFn     = (config) => { /* ... */ };
export const identify: IdentifyFn = (user)   => { /* ... */ };
export const track:    TrackFn    = (name, props) => { /* ... */ };
export const flush:    FlushFn    = ()       => { /* ... */ };
export const onVital:  OnVitalFn  = (name, cb) => { /* ... */ };
```

> Separar el tipo de la implementación con `: Fn = (...) => {}` da: (a) un único sitio donde cambiar la signature, (b) errores de TS en `index.ts` si la implementación se desalinea del contrato.

---

## Decisiones no-obvias

| Decisión | Por qué |
|---|---|
| `WebVital<N>` genérico | Permite que `onVital('LCP', cb)` narrowee el callback. Único genérico de la API. |
| `properties` plano y escalar | ClickHouse es columnar; objetos nested no caben sin JSON-typed columns, que son lentos a query. |
| `IngestionPayload.events: WebVitalEvent[]` | Habilita batching sin breaking change futuro. Una sola request con N eventos. |
| `url` en el evento, no en el wrapper | SPAs cambian de ruta dentro de una sesión. Cada medición debe llevar su URL. |
| `beforeSend` único hook | Una sola extension point pública. Cero `onBeforeSend / onError / transformer`. Menos breaking surface. |
| `sdk: { name, version }` en payload | El backend puede rechazar SDKs antiguos en el futuro sin renegociar headers. |
| `identify(null)` en vez de `clearUser()` | Una función menos en la API pública. Mismo signal. |

## Lo que NO está en estos tipos (y por qué)

- **`Severity` / `Level`** — no es Sentry. No hay errores aquí.
- **`Breadcrumb`** — no es Sentry (bis).
- **`Tags`** — duplican `properties`. Si necesito facetear, ya hay columnas.
- **`Context` enriquecido (device, OS, locale)** — el backend lo deriva del `userAgent` y headers HTTP. Mantener el payload mínimo.
- **`Transport` configurable** — sendBeacon → fetch keepalive es lógica interna, no superficie pública.

## Validación server-side

Cada interface aquí tiene su Zod schema espejado en `packages/shared/src/schemas.ts`. El servidor parsea con `IngestionPayloadSchema.parse(body)`; cualquier shape inválida → 422 con detalle del campo. Sin drops silenciosos.

```ts
// packages/shared/src/schemas.ts (esqueleto)
import { z } from 'zod';

export const WebVitalNameSchema = z.enum(['CLS','LCP','INP','FCP','TTFB']);
// ... resto espejando 1:1 los tipos.
export const IngestionPayloadSchema = z.object({ /* ... */ });

// Sanity check: el tipo inferido coincide con el tipado a mano.
type _Check = z.infer<typeof IngestionPayloadSchema> extends IngestionPayload ? true : false;
```

## Open questions

- **`sessionId` lifecycle:** ¿reset en pestaña nueva o persiste en `sessionStorage`? Probable: `sessionStorage` (sobrevive navegación same-tab, muere en cierre). Decidir antes de escribir el módulo `session.ts`.
- **`sampleRate` granularity:** ¿sample por sesión o por evento? Por sesión es más útil para CWV (no quieres CLS parcial). Probable default: sesión.
- **`beforeSend` async:** ¿`(e) => WebVitalEvent | null | Promise<...>`? Async complica el flush en `visibilitychange`. v0.1: síncrono only. Documentar.

## Links

- [[SDK_README]]
- [[00_Project_Overview]]
- [[ADR-001-Monorepo-Structure]]
- [[ADR-002-SDK-Public-API]]
- web-vitals lib (referencia para `WebVital` shape): https://github.com/GoogleChrome/web-vitals
