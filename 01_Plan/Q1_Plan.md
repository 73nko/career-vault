# Q1: Reactivación + arranque SDK (Mes 1-3)

#plan #quarter

**Objetivo:** Recuperar bases técnicas, tener SDK funcional capturando Core Web Vitals.

## Distribución de las 7h/semana en Q1

| Bloque | Horas/semana |
|---|---|
| TS/JS profundo (mes 1), Frontend moderno (mes 2-3) | 2-2.5 |
| Algoritmos | 1.5-2 |
| Proyecto SDK | 2-3 |
| Lectura | 1 |

## Mes 1: Bases recuperadas

### Foco
- TypeScript profundo: generics, conditional types, infer, branded types, template literal types
- JavaScript moderno: event loop, microtasks vs macrotasks, AbortController, streams, generators, módulos ESM
- Diseño inicial del SDK (API surface, types públicos)
- 10 problemas algoritmos: arrays, two pointers, sliding window

### Recursos
- "Total TypeScript" de Matt Pocock (módulos fundamentales)
- typescript-deep-dive de Basarat (capítulos selectos)
- "A Philosophy of Software Design" de John Ousterhout
- NeetCode 150 (arrays/strings + sliding window)

### Hito mes 1
- [ ] Notas de 15+ conceptos clave de TS/JS en `03_Concepts/TypeScript` y `03_Concepts/Frontend`
- [ ] 10 algoritmos resueltos y documentados
- [ ] SDK con API diseñada (archivo `types.ts` + README inicial)
- [ ] Build setup con tsup funcionando

## Mes 2: SDK funcional + React 19

### Foco
- React 19, Server Components, Next.js 15 app router
- Capturar Core Web Vitals (CLS, LCP, INP, FCP, TTFB) en el SDK
- API de envío (sendBeacon + fallback fetch keepalive)
- Buffer + batching de eventos
- 10 problemas: binary search, recursión, backtracking

### Recursos
- Documentación oficial React 19 + Next 15
- web.dev sobre Core Web Vitals
- Código de web-vitals.js (Google) como referencia
- NeetCode 150 (binary search + backtracking)

### Hito mes 2
- [ ] SDK capturando los 5 CWV en demo local
- [ ] Endpoint dummy de ingesta funcionando (Fastify)
- [ ] 20 algoritmos acumulados
- [ ] Demo Next 15 con RSC funcional

## Mes 3: Endpoint serio + dashboard inicial

### Foco
- Endpoint de ingesta robusto (validación con Zod, rate limit, error handling)
- Postgres como storage temporal (antes de ClickHouse en Q2)
- Dashboard mínimo en Next.js que lea de Postgres
- 5 problemas: árboles, BFS, DFS

### Recursos
- Fastify docs + plugins
- Zod docs
- Postgres tutorial (Use The Index, Luke!)
- NeetCode 150 (trees)

### Hito mes 3 / Checkpoint Q1
- [ ] SDK instalable vía npm (puede ser scope local primero)
- [ ] Endpoint recibiendo eventos reales, almacenando en Postgres
- [ ] Dashboard básico mostrando últimos N eventos
- [ ] 25 algoritmos resueltos en total
- [ ] Repositorio público con README serio
- [ ] Primera Monthly Review trimestral honesta

## Riesgos identificados en Q1

- **Subestimar el TS profundo.** Cinco años de TS no implican TS avanzado. Si paso por encima, lo lamento en Q3.
- **Overengineering el SDK.** Tentación de meter mil features. NO. Solo CWV en Q1.
- **Algoritmos como excusa para no proyecto.** Si los algoritmos comen demasiado, los recorto, no recorto el proyecto.

## Conceptos a dominar (notas atómicas a crear)

### TypeScript
- [[Generics]]
- [[Conditional Types]]
- [[Infer]]
- [[Template Literal Types]]
- [[Branded Types]]
- [[Discriminated Unions]]

### JavaScript
- [[Event Loop]]
- [[Microtasks vs Macrotasks]]
- [[AbortController]]
- [[Streams]]
- [[Generators]]
- [[ES Modules]]

### Frontend
- [[Core Web Vitals]]
- [[sendBeacon]]
- [[PerformanceObserver]]
- [[Layout Shift Detection]]
- [[INP measurement]]

### Algoritmos
- [[Two Pointers Pattern]]
- [[Sliding Window Pattern]]
- [[Binary Search Pattern]]
- [[Backtracking Pattern]]
- [[Tree Traversal]]

---
[[00_Master_Plan]] | [[Q2_Plan]]
