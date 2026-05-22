# SDK Public API — Types

#concept #project

Source of truth for `packages/sdk-web/src/types.ts` and the mirrored Zod schemas in `packages/shared/src/schemas.ts`. Materializes the contract advertised in [[SDK_README|the README]] and the decisions to be formalized in [[ADR-002-SDK-Public-API]] (drafted Sunday).

**Scope:** only what crosses the SDK's public boundary — function signatures and wire format. Internals (queue, transport, observers, session manager) live in their own modules with no exported types.

## Principles

1. **Zero `any` in the public surface.** `unknown` is allowed where the SDK genuinely cannot constrain the shape (user-provided event properties); everything else is named.
2. **Discriminated unions on a `type` literal**, not shape-based discrimination. Zod parses cleanly and TypeScript narrowing is mechanical.
3. **Generics only where they buy real narrowing.** `WebVital<N>` earns its keep by sharpening `onVital`. A blanket `Event<T>` would not.
4. **Input config and wire format are separate types.** `WebVitalsConfig` is what the consumer hands us. `IngestionPayload` is what hits the network. No shared fields.
5. **No silent drops.** Invalid payloads are rejected at the ingestion boundary with a typed error response, not dropped.

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
  value: number;            // milliseconds, except CLS (unitless)
  rating: WebVitalRating;   // per Google's CWV thresholds
  delta: number;            // change since the previous reading (INP, CLS)
  id: string;               // unique per page load
  navigationType: NavigationType;
}
```

> The `N` generic exists solely so `onVital('LCP', cb)` narrows the callback's argument to `WebVital<'LCP'>`. Without it, the callback would receive `WebVital<WebVitalName>` and the consumer would have to discriminate manually.

---

## User identity

```ts
export interface User {
  id: string;
  email?: string;
  [key: string]: string | number | boolean | undefined;
}
```

`id` is required; additional properties are restricted to scalars by the index signature. This constraint exists at the boundary that the SDK *can* enforce statically; deeper structures (objects, dates) are rejected at compile time before they ever reach the ingestion layer.

---

## Custom event properties

```ts
export type EventProperties = Record<string, unknown>;
```

A generic type parameter on `track<T>(name, props: T)` would push the burden onto every call site and offer no real safety — the runtime ingestion endpoint validates anyway. `unknown` is the honest type: the SDK doesn't know what callers will send. The Zod schema in `packages/shared` is the authoritative validator at the ingestion boundary; the dashboard's query layer reads from the typed ClickHouse projection downstream.

> Trade-off accepted: callers can pass `{ payment: { card: '...' } }` and the SDK will not type-error. The ingestion endpoint will. This is the right place to enforce it: one validator, runtime, with proper error messages.

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
  name: string;         // e.g. 'checkout.completed'
  properties?: EventProperties;
  url: string;
  timestamp: number;
}

export type WebVitalEvent = VitalEvent | CustomEvent;
```

> `url` lives on the event, not on the wrapper. In a SPA, one session may visit many routes; each measurement must carry its own URL. Everything else is session-stable and lives on the wrapper.

---

## Ingestion payload (what `sendBeacon` ships)

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

> An array of events per request, not a single event. This enables the batching that the README advertises without renegotiating the wire format later.

---

## Session lifecycle

`sessionId` is generated and owned by the internal `session.ts` module; it is not configurable and never appears in `WebVitalsConfig`. A session ends — and a fresh `sessionId` is minted on the next event — when any of these holds:

- **Tab close.** The id is stored in `sessionStorage`, so it survives same-tab reloads and SPA navigation but dies when the tab closes.
- **Idle timeout: 30 min.** If no event is recorded for 30 minutes, the next event opens a new session. Tracked via a `lastActivity` timestamp persisted alongside the id.
- **Max duration: 4 h.** A session is capped at 4 hours from creation regardless of activity, so a long-lived tab does not collapse a full day into a single session.

This matches how RUM products (Datadog RUM and similar) scope a session. The bound matters because per-session `sampleRate` and per-session derived metrics both assume a session is a coherent, time-bounded unit; an 8-hour tab counted as one session would skew those aggregates.

Consequence: `sampleRate` is evaluated once at session creation, so a session that rolls over via idle timeout or max duration is re-sampled independently of the previous one.

---

## Init config (consumer input)

```ts
export type MaybePromise<T> = T | Promise<T>;

export interface WebVitalsConfig {
  projectId: string;
  endpoint: string;
  release?: string;
  environment?: string;
  sampleRate?: number;   // 0..1, default 1. Applied per session (see below).
  debug?: boolean;       // default false
  beforeSend?: (event: WebVitalEvent) => MaybePromise<WebVitalEvent | null>;
}
```

No `transport`, `batchSize`, `flushInterval`, or `maxQueueSize` in v0.1. They become public surface only when a real consumer asks for them. Sensible defaults and silence.

### `sampleRate` semantics

Sampling is applied **per session**, not per event. The decision is made once when the session is created; either every event from that session is sent, or none are. Per-event sampling would yield partial CWV (e.g. LCP but no CLS for the same page load), which produces noisy aggregates and breaks per-session derived metrics.

### `beforeSend` semantics

`beforeSend` may return synchronously or asynchronously. It is awaited before the event is queued. The main thread must never be blocked, so the contract is:

- During normal operation, the SDK awaits `beforeSend` and queues the resolved (or transformed) event.
- During `visibilitychange` flush (page hide), the SDK awaits `beforeSend` with a **50ms timeout per pending event**. Events that exceed the budget are dropped. This is the documented trade-off: async transforms cannot fully participate in the unload-time flush, because the browser will not wait.
- Callers performing async PII redaction or remote lookups should be aware that high-latency `beforeSend` reduces the chance of capture on tab close. The SDK logs a `debug`-level warning when a flush drops events due to budget.

---

## Public function signatures

```ts
export type InitFn      = (config: WebVitalsConfig) => void;
export type IdentifyFn  = (user: User | null) => void;   // null clears identity (logout)
export type TrackFn     = (name: string, properties?: EventProperties) => void;
export type FlushFn     = () => Promise<void>;

export type VitalCallback<N extends WebVitalName> = (vital: WebVital<N>) => void;
export type OnVitalFn = <N extends WebVitalName>(name: N, callback: VitalCallback<N>) => void;
```

These signatures are imported and bound to implementations in `index.ts`:

```ts
// packages/sdk-web/src/index.ts
import type { InitFn, IdentifyFn, TrackFn, FlushFn, OnVitalFn } from './types';

export const init:     InitFn     = (config) => { /* ... */ };
export const identify: IdentifyFn = (user)   => { /* ... */ };
export const track:    TrackFn    = (name, props) => { /* ... */ };
export const flush:    FlushFn    = ()       => { /* ... */ };
export const onVital:  OnVitalFn  = (name, cb) => { /* ... */ };
```

> Declaring the type once and binding it with `: Fn = (...) => {}` gives a single place to evolve the signature and produces a TypeScript error in `index.ts` if the implementation drifts from the contract.

---

## Design decisions worth flagging

| Decision | Rationale |
|---|---|
| `WebVital<N>` generic | Sole generic in the public API. Enables narrowing in `onVital('LCP', cb)`. |
| `EventProperties = Record<string, unknown>` | A `T extends Record<string, unknown>` generic on `track` would inflate every call site without adding real safety. Validation belongs at the ingestion boundary, once. |
| `IngestionPayload.events: WebVitalEvent[]` | Batching is built into the wire format from day one. No breaking change later. |
| `url` on the event, not the wrapper | SPA sessions span multiple routes; each measurement needs its own URL. |
| Single `beforeSend` extension point | One public hook instead of `onBeforeSend / onError / transformer`. Minimizes breaking surface in future versions. |
| `beforeSend` accepts async | Real-world PII redaction often requires async lookups. The cost (a 50ms-budget flush on visibility change) is documented and bounded. |
| Sampling per session, not per event | Partial CWV from per-event sampling is unusable for aggregates. |
| Session: `sessionStorage` + 30 min idle + 4 h max | Bounds a session as a coherent, time-limited unit. Per-session sampling and derived metrics assume that bound; an all-day tab as one session would skew aggregates. |
| `sdk: { name, version }` in the payload | Lets the backend reject ancient clients later without renegotiating headers. |
| `identify(null)` instead of `clearUser()` | One fewer public function. Same signal. |

## Deliberately excluded from v0.1

- **`Severity` / `Level`** — this is not Sentry; no error tracking.
- **`Breadcrumb`** — same reasoning.
- **`Tags`** — duplicate `properties`. If faceting is needed, columns already exist.
- **Enriched `Context` (device, OS, locale)** — derived server-side from `userAgent` and HTTP headers. Keeps the payload minimal.
- **Configurable transport** — `sendBeacon` → `fetch keepalive` fallback is internal logic, not public surface.

## Schema drift detection

Each interface above has a mirrored Zod schema in `packages/shared/src/schemas.ts`. The ingestion endpoint parses with `IngestionPayloadSchema.parse(body)`; invalid shapes return HTTP 422 with field-level detail.

To keep the hand-written TypeScript types and the Zod schemas in sync, CI runs a generator-and-diff step using [`zod-to-ts`](https://github.com/sachinraja/zod-to-ts):

```ts
// scripts/check-schema-drift.ts (runs in CI)
import { zodToTs, printNode } from 'zod-to-ts';
import { IngestionPayloadSchema, WebVitalSchema /* ... */ } from '@track-vitals/shared';
import { readFileSync, writeFileSync } from 'node:fs';

const generated = [
  printNode(zodToTs(WebVitalSchema, 'WebVital').node),
  printNode(zodToTs(IngestionPayloadSchema, 'IngestionPayload').node),
  // ... one entry per public type
].join('\n\n');

const expectedPath = 'packages/sdk-web/src/types.generated.ts';
const existing = readFileSync(expectedPath, 'utf8');

if (existing !== generated) {
  writeFileSync(expectedPath, generated);
  console.error('Schema drift detected. Run pnpm sync-types and commit the diff.');
  process.exit(1);
}
```

The generated file lives alongside the hand-written `types.ts` and is checked in. The hand-written types are the public API surface (richer JSDoc, generics like `WebVital<N>`); the generated file is the canonical shape the wire format must conform to. Any divergence — adding a field to Zod without updating the public types, or vice versa — fails CI.

## Open questions

None open for v0.1. All three public-boundary decisions — `sampleRate` granularity, `beforeSend` sync/async, and `sessionId` lifecycle — are closed and documented above. They will be formalized in [[ADR-002-SDK-Public-API]].

## Links

- [[SDK_README]]
- [[00_Project_Overview]]
- [[ADR-001-Monorepo-Structure]]
- [[ADR-002-SDK-Public-API]] (pending, target: Sunday 2026-05-24)
- `web-vitals` library (canonical `WebVital` shape reference): https://github.com/GoogleChrome/web-vitals
- `zod-to-ts`: https://github.com/sachinraja/zod-to-ts
