# @track-vitals/sdk

> Core Web Vitals monitoring for the rest of us. Type-safe, tiny, self-hostable.

[![npm](https://img.shields.io/npm/v/@track-vitals/sdk?color=black)](https://www.npmjs.com/package/@track-vitals/sdk)
[![bundle](https://img.shields.io/bundlephobia/minzip/@track-vitals/sdk?label=gzip&color=black)](https://bundlephobia.com/package/@track-vitals/sdk)
[![types](https://img.shields.io/npm/types/@track-vitals/sdk?color=black)](https://www.npmjs.com/package/@track-vitals/sdk)
[![license](https://img.shields.io/npm/l/@track-vitals/sdk?color=black)](./LICENSE)

`@track-vitals/sdk` captures **CLS, LCP, INP, FCP, TTFB** and ships them to a backend you control. No vendor lock-in, no 200€/month invoice, no 60kb of analytics shipped to your users.

```ts
import { init, track } from '@track-vitals/sdk';

init({ projectId: 'proj_live_abc', endpoint: 'https://vitals.example.com' });

track('checkout.completed', { cart_value: 8499 });
```

That's it. Core Web Vitals start flowing on the next paint.

---

## Why another one

| | track-vitals | Datadog RUM | Sentry Perf | web-vitals |
|---|---|---|---|---|
| Captures CWV | ✅ | ✅ | ✅ | ✅ |
| Backend you control | ✅ | ❌ | ❌ | — |
| Bundle (gzip) | **~3kb** ¹ | ~70kb | ~50kb | ~2kb |
| Type-safe payload | ✅ | partial | partial | ✅ |
| Self-hostable pipeline | ✅ | ❌ | ✅ ($$$) | — |
| Custom events | ✅ | ✅ | ✅ | ❌ |
| Price | free | $$$ | $$ | free |

¹ Target for v0.1. Measured via `size-limit` in CI.

**This is not Sentry.** No error tracking, no replay, no profiling. It does one thing: measure perceived performance and let you act on it.

---

## Install

```bash
pnpm add @track-vitals/sdk
# or: npm i / yarn add / bun add
```

ESM + CJS. Zero runtime dependencies.

## Quickstart

```ts
import { init } from '@track-vitals/sdk';

init({
  projectId: 'proj_live_abc',
  endpoint: 'https://vitals.your-domain.com',
});
```

That single call wires up:

- `PerformanceObserver` for **LCP, FCP, CLS, INP, TTFB**
- Batching with `requestIdleCallback`
- Delivery via `navigator.sendBeacon` (falls back to `fetch keepalive`)
- Visibility-change flush so nothing is lost on tab close

## API

### `init(config)`

```ts
init({
  projectId: string,          // required
  endpoint: string,           // required, your ingestion URL
  release?: string,           // e.g. process.env.GIT_SHA
  environment?: string,       // 'production' | 'staging' | ...
  sampleRate?: number,        // 0..1, default 1
  debug?: boolean,            // logs every event to console
  beforeSend?: (e) => Event | null, // mutate or drop
});
```

`init()` is idempotent. Calling it twice with the same `projectId` is a no-op; with a different one it re-initialises and warns.

### `identify(user)`

```ts
import { identify } from '@track-vitals/sdk';

identify({ id: 'usr_42', email: 'a@b.com', plan: 'pro' });
```

Attaches a stable user reference to every subsequent event. Call once after login. Pass `null` to clear (e.g. logout).

### `track(name, properties?)`

```ts
track('checkout.completed', { cart_value: 8499, items: 3 });
```

Custom event. Names are free-form strings; the recommended convention is `<surface>.<verb>` (`checkout.completed`, `signup.failed`).

Properties are validated server-side against the Zod schema in `@track-vitals/shared`. Invalid payloads are rejected with a typed error — not dropped silently.

### `onVital(name, callback)`

```ts
import { onVital } from '@track-vitals/sdk';

onVital('LCP', (metric) => {
  if (metric.value > 4000) console.warn('LCP regression', metric);
});
```

Subscribe to a metric as it's measured. Useful for in-app warnings, A/B test gates, or feeding your own dashboards alongside track-vitals.

### `flush()`

```ts
await flush();
```

Forces the in-memory queue to be sent immediately. Returns a `Promise<void>`. You almost never need this — `init()` already flushes on `visibilitychange`. Use it before navigating away in SPAs that suppress the browser unload event.

## Framework recipes

<details>
<summary><b>Next.js (App Router)</b></summary>

```tsx
// app/track-vitals.tsx
'use client';
import { useEffect } from 'react';
import { init } from '@track-vitals/sdk';

export function TrackVitals() {
  useEffect(() => {
    init({
      projectId: process.env.NEXT_PUBLIC_TRACK_VITALS_PROJECT!,
      endpoint:  process.env.NEXT_PUBLIC_TRACK_VITALS_ENDPOINT!,
      release:   process.env.NEXT_PUBLIC_GIT_SHA,
    });
  }, []);
  return null;
}
```

Mount once in `app/layout.tsx`.
</details>

<details>
<summary><b>Vite / SPA</b></summary>

```ts
// src/main.ts
import { init } from '@track-vitals/sdk';

init({
  projectId: import.meta.env.VITE_TV_PROJECT,
  endpoint:  import.meta.env.VITE_TV_ENDPOINT,
  release:   import.meta.env.VITE_GIT_SHA,
});
```
</details>

<details>
<summary><b>Plain HTML</b></summary>

```html
<script type="module">
  import { init } from 'https://esm.sh/@track-vitals/sdk';
  init({ projectId: 'proj_live_abc', endpoint: 'https://vitals.example.com' });
</script>
```
</details>

## Self-hosting

The SDK is one half of the story. The ingestion endpoint, storage, and dashboard live in the same repo:

```
track-vitals/
├── packages/
│   ├── sdk-web/          ← you are here
│   └── shared/           ← Zod schemas shared with the backend
└── apps/
    ├── ingestion/        ← Fastify endpoint
    └── dashboard/        ← Next.js 15 dashboard
```

Spin the stack up locally:

```bash
pnpm install
pnpm -r dev
```

Detailed self-host docs: [`apps/ingestion/README.md`](../../apps/ingestion/README.md).

## Type safety, end to end

The payload shape is defined once in `@track-vitals/shared` and consumed by:

1. The SDK's `track()` signature (compile-time)
2. The ingestion endpoint's Zod parser (run-time)
3. The dashboard's query layer (compile-time again)

Add a field in `shared`, the SDK type-errors until you provide it, the backend rejects old shapes with a 422, the dashboard surfaces the new field. No drift.

## Privacy

- No cookies. No fingerprinting. No third-party calls.
- IP addresses are dropped at the ingestion layer (not stored).
- `identify()` is opt-in; without it, events are anonymous.
- GDPR-friendly out of the box because **you are the backend**.

## Status

`v0.1` — `sdk-web`, ingestion endpoint, ephemeral Postgres storage. Functional, not yet stable. Expect breaking changes until `v1.0`.

See [`ROADMAP.md`](./ROADMAP.md) for what's next.

## Contributing

This is a learning project as much as a tool. PRs welcome — read [`CONTRIBUTING.md`](../../CONTRIBUTING.md) first. Architecture decisions are documented as ADRs in [`docs/decisions/`](../../docs/decisions/).

## License

MIT © [73nko](https://github.com/73nko)
