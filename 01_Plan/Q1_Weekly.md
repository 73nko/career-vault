# Q1 - Cronograma semanal (12 semanas)

#plan #quarter #weekly-detail

**Inicio:** Semana del 11 de mayo de 2026 **Fin objetivo:** 2 de agosto de 2026 **Compromiso semanal:** 7 horas

## Distribución típica de las 7h

|Bloque|Horas|Cuándo|
|---|---|---|
|Estudio técnico (TS/JS/React/Backend)|2.5h|2 sesiones x 1.25h|
|Algoritmos|2h|2 sesiones x 1h|
|Proyecto SDK|2h|1-2 sesiones|
|Lectura técnica|0.5h|Lecturas cortas|

Ajusta según tu semana. Lo importante es la suma, no el reparto exacto.

## Recursos a tener listos antes de empezar

- Cuenta NeetCode (o LeetCode) + lista NeetCode 150
- "Total TypeScript Essentials" de Matt Pocock (gratuito) o typescript-deep-dive de Basarat
- "Deep JavaScript" de Axel Rauschmayer (gratis online)
- "A Philosophy of Software Design" de Ousterhout (libro físico o ebook)
- Repo nuevo en GitHub para el SDK (decidir nombre semana 1)
- Cuenta Vercel/Railway para deploys posteriores

## Aviso sobre vacaciones

Semanas 10-12 caen en mediados/finales de julio. Si tienes vacaciones, **recorta semana, no estires plan**. Mejor saltar una semana entera limpia que arrastrarla.

---

# Mes 1: Bases recuperadas

## Semana 1 (11-17 mayo)

**Foco:** TypeScript avanzado parte 1 + arranque del repo

### Tareas

- **TS (2.5h):** Generics avanzados (constraints, defaults, inference). Conditional types básicos.
    - Recurso: Total TypeScript "Essentials" módulo Generics
- **Algoritmos (2h):** 3 problemas Arrays & Hashing
    - Two Sum, Contains Duplicate, Valid Anagram
- **Proyecto (2h):** Setup inicial del repo
    - Decidir nombre del proyecto
    - `pnpm init`, tsup, tsconfig estricto, eslint, prettier
    - Estructura: `packages/sdk` y `packages/server` (monorepo simple con pnpm workspaces)
    - Primer commit con README placeholder
- **Lectura (0.5h):** Ousterhout cap 1-2

### Output esperado

- [x] 1 nota atómica: [[Generics]] ✅ 2026-05-18
- [x] 1 nota atómica: [[Conditional Types]] ✅ 2026-05-18
- [x] 3 notas de algoritmos resueltos ✅ 2026-05-16
- [x] Repo público creado con build setup funcional ([track-vitals](https://github.com/73nko/track-vitals), 2026-05-11)
- [x] [[ADR-001-Monorepo-Structure]] ✅ 2026-05-18

---

## Semana 2 (18-24 mayo)

**Foco:** TypeScript avanzado parte 2 + sliding window + tipos del SDK

### Tareas

- **TS (2.5h):** `infer`, template literal types, branded types, discriminated unions
    - Practica con type-challenges del repo FE Interview v2 (Section 3) en lugar de solo leer. Ver [[00_MOC_FE_Practice]]
- **Algoritmos (2h):** 3 problemas Two Pointers + Sliding Window
    - Valid Palindrome, Best Time to Buy/Sell Stock, Longest Substring Without Repeating Characters
- **Proyecto (2h):** Diseño de la API pública del SDK
    - Definir `types.ts`: `WebVitalsConfig`, `WebVitalEvent`, `WebVitalName`, etc.
    - Escribir el "API contract" antes de la implementación
    - Ejemplo de uso en README (vende lo que vas a construir)
- **Lectura (0.5h):** Ousterhout cap 3-4

### Output esperado

- [x] [[Infer Keyword]], [[Template Literal Types]], [[Branded Types]], [[Discriminated Unions]] ✅ 2026-05-22
- [x] 3 notas de algoritmos ✅ 2026-05-22
- [x] `packages/sdk/src/types.ts` con la API tipada ✅ 2026-05-21
- [x] README con sección "Usage" mostrando el código ideal ✅ 2026-05-21
- [ ] [[ADR-002-SDK-Public-API]]
- [ ] 1 captura STAR cruda en [[00_STAR_Master_List]] (sin pulir, sólo hechos + posible métrica)

---

## Semana 3 (25-31 mayo)

**Foco:** JS moderno parte 1 + arranque captura CWV

### Tareas

- **JS (2.5h):** Event loop, microtasks vs macrotasks, AbortController
    - Recurso: Deep JavaScript caps event loop + Jake Archibald talk "In The Loop"
- **Algoritmos (2h):** 2 problemas Two Pointers más
    - Two Sum II (sorted array), Container With Most Water
- **Proyecto (2h):** Implementar captura del primer Web Vital (LCP)
    - Estudiar código de `web-vitals.js` de Google como referencia
    - PerformanceObserver para LCP
    - Demo HTML local que dispare el evento
- **Lectura (0.5h):** Ousterhout cap 5-6

### Output esperado

- [ ] [[Event Loop]], [[Microtasks vs Macrotasks]], [[AbortController]]
- [ ] [[PerformanceObserver]]
- [ ] 2 notas de algoritmos
- [ ] LCP capturándose y logueando en consola

---

## Semana 4 (1-7 junio)

**Foco:** JS moderno parte 2 + capturar resto de CWV + checkpoint mes 1

### Tareas

- **JS (2h):** Streams, generators, ES modules deep
- **Algoritmos (2h):** 2 problemas más
    - Group Anagrams, 3Sum
- **Proyecto (2.5h):** Capturar CLS, INP, FCP, TTFB
    - Implementar buffer interno
    - Tests unitarios básicos
- **Lectura + Monthly Review (0.5h):** Ousterhout cap 7 + revisión mensual

### Output esperado

- [ ] [[Streams]], [[Generators]], [[ES Modules]]
- [ ] [[Core Web Vitals]] (nota MOC con sub-notas por vital)
- [ ] 2 notas de algoritmos
- [ ] SDK capturando los 5 CWV
- [ ] **Monthly Review mes 1 escrita con honestidad**

### Checkpoint mes 1

Debes tener:

- [ ] 10 algoritmos resueltos y documentados
- [ ] ~15 notas atómicas en `03_Concepts/`
- [ ] SDK que captura los 5 CWV en una demo local
- [ ] Build setup robusto
- [ ] Repo público presentable

Si fallas el checkpoint, **para y diagnostica**. ¿Falta tiempo? ¿Falta foco? ¿El plan es irreal?

---

# Mes 2: React moderno + SDK funcional

## Semana 5 (8-14 junio)

**Foco:** React 19 + Server Components

### Tareas

- **React/Next (2.5h):** React 19 fundamentals (use, useOptimistic, useActionState). RSC mental model.
- **Algoritmos (2h):** 2 problemas Binary Search
    - Binary Search, Search 2D Matrix
- **Proyecto (2h):** Implementar batching + sendBeacon en el SDK
    - Buffer con flush configurable
    - sendBeacon como primario, fetch keepalive fallback
- **Lectura (0.5h):** Lo que te quede de Ousterhout o leer post serio sobre RSC

### Output esperado

- [ ] [[React Server Components]], [[use hook]], [[useOptimistic]]
- [ ] [[sendBeacon]] vs [[Fetch Keepalive]] (comparativa)
- [ ] [[Binary Search Pattern]] + 2 notas de problemas

---

## Semana 6 (15-21 junio)

**Foco:** Next.js 15 App Router + Server Actions

### Tareas

- **Next (2.5h):** App router en serio. Layouts, loading, error boundaries, route handlers.
- **Algoritmos (2h):** 2 problemas Stack + Linked List
    - Valid Parentheses, Reverse Linked List
- **Proyecto (2h):** Inicializar `packages/dashboard` con Next.js 15
    - Página inicial vacía pero deployable
    - Estructura de carpetas
- **Lectura (0.5h):** Empezar [[Books/Staff Engineer]] de Larson (intro + cap 1)

### Output esperado

- [ ] [[App Router]], [[Server Actions]], [[Route Handlers]]
- [ ] Dashboard scaffolding deployable a Vercel
- [ ] 2 notas de algoritmos

---

## Semana 7 (22-28 junio)

**Foco:** Streaming SSR + recursión + integración dashboard ↔ SDK

### Tareas

- **Next (2.5h):** Streaming, Suspense boundaries, parallel routes
- **Algoritmos (2h):** 3 problemas Linked List + Recursion
    - Merge Two Sorted Lists, Linked List Cycle, Reverse Linked List II
- **Proyecto (2h):** Dashboard recibe datos del SDK (en memoria de momento)
    - SDK envía a endpoint dummy del dashboard
    - Visualización básica de eventos (lista plana, sin chart aún)
- **Lectura (0.5h):** Staff Engineer cap 2

### Output esperado

- [ ] [[Streaming SSR]], [[Suspense Boundaries]]
- [ ] [[Linked List Patterns]]
- [ ] Pipe completo SDK → endpoint → dashboard (mock, sin storage real)

---

## Semana 8 (29 junio - 5 julio)

**Foco:** Cierre mes 2 + checkpoint

### Tareas

- **React/Next (2h):** TanStack Query setup en el dashboard
- **Algoritmos (2h):** 3 problemas Backtracking
    - Generate Parentheses, Combinations, Permutations
- **Proyecto (2.5h):** Pulir el SDK
    - Tests unitarios coherentes (Vitest)
    - Workflow CI básico (GitHub Actions)
- **Monthly Review (0.5h)**

### Output esperado

- [ ] [[TanStack Query]]
- [ ] [[Backtracking Pattern]] + 3 notas de problemas
- [ ] SDK con CI verde, tests pasando
- [ ] **Monthly Review mes 2**

### Checkpoint mes 2

Debes tener:

- [ ] 20 algoritmos acumulados
- [ ] Next.js 15 dominado a nivel app router + RSC + Server Actions
- [ ] Dashboard scaffolded y recibiendo datos del SDK
- [ ] Tests + CI en el SDK
- [ ] Conexión SDK ↔ Dashboard funcionando end to end (aún sin DB)

---

# Mes 3: Endpoint + Postgres + Dashboard

## Semana 9 (6-12 julio)

**Foco:** Endpoint serio con Fastify + Zod

### Tareas

- **Backend (2.5h):** Fastify, Zod, plugins, error handling, logging estructurado
- **Algoritmos (2h):** 2 problemas Trees
    - Invert Binary Tree, Maximum Depth of Binary Tree
- **Proyecto (2h):** Endpoint `/events` real
    - Validación con Zod
    - Rate limiting básico
    - CORS configurado
- **Lectura (0.5h):** Staff Engineer cap 3

### Output esperado

- [ ] [[Fastify]], [[Zod]]
- [ ] [[Tree Traversal]] + 2 notas
- [ ] Endpoint productivo (en local de momento) con validación

---

## Semana 10 (13-19 julio)

**Foco:** Postgres + persistencia

### Tareas

- **Backend (2.5h):** Postgres setup, Drizzle ORM, índices básicos
- **Algoritmos (1.5h):** 1 problema Tree + repaso
    - Same Tree
- **Proyecto (2.5h):** Schema de eventos en Postgres
    - Tabla `events` con columnas para metadata + payload JSONB
    - Endpoint guarda eventos
    - Dashboard lee últimos N eventos
- **Lectura (0.5h):** Staff Engineer cap 4

### Output esperado

- [ ] [[Postgres Setup]], [[Drizzle ORM]], [[JSONB en Postgres]]
- [ ] Pipe completo end to end con persistencia
- [ ] [[ADR-003-Storage-Choice-Postgres-Temporary]]

---

## Semana 11 (20-26 julio)

**Foco:** Pulido del MVP + npm publish

### Tareas

- **React/Next (1.5h):** Dashboard con visualización mejorada (Tremor o Recharts)
- **Algoritmos (2h):** 2 problemas BFS/DFS
    - Balanced Binary Tree, Binary Tree Level Order Traversal
- **Proyecto (3h):** Pulir antes de publicar
    - README en condiciones (instalación, uso, screenshots)
    - LICENSE (MIT recomendado)
    - Demo deployada a Vercel
    - Considerar publicar a npm (scope privado o público)
- **Lectura (0.5h):** Staff Engineer cap 5

### Output esperado

- [ ] [[BFS Pattern]], [[DFS Pattern]]
- [ ] Dashboard con al menos 1 chart real
- [ ] README serio
- [ ] Demo deployada accesible públicamente

---

## Semana 12 (27 julio - 2 agosto)

**Foco:** Checkpoint Q1 + buffer + retrospectiva grande

### Tareas

- **Buffer técnico (3h):** Terminar lo que se haya quedado pendiente. NO añadir cosas nuevas.
- **Algoritmos (1h):** Revisar las 25 notas de algoritmos creadas, identificar patrones débiles
- **Proyecto (2h):** Si todo está, publicar paquete a npm (o decidir mantener interno)
- **Quarterly Review (1h):** **Crítico. No saltársela.**

### Output esperado

- [ ] **Quarterly Review Q1 escrita con honestidad brutal**
- [ ] Decisión: ¿avanzo a Q2 según plan o ajusto?

### Checkpoint Q1 / mes 3

Debes tener:

- [ ] 25 algoritmos resueltos, todos con nota
- [ ] ~35-40 notas atómicas en concepts
- [ ] SDK publicable (npm o privado), capturando 5 CWV, con tests y CI
- [ ] Endpoint con Postgres y validación Zod
- [ ] Dashboard funcional con al menos 1 chart
- [ ] Repo con README serio y demo deployada
- [ ] 3 ADRs escritos
- [ ] "A Philosophy of Software Design" terminado
- [ ] "Staff Engineer" cap 1-5 leídos
- [ ] Monthly reviews 1, 2, 3 escritas
- [ ] Quarterly Review Q1 escrita

---

## Reglas de ejecución para Q1

1. **Si una semana cae <50% (3.5h o menos), no se compensa la siguiente. La pierdes.**
2. **El proyecto manda sobre los algoritmos.** Si una semana tienes que elegir, sacrificas algoritmos.
3. **Los algoritmos mandan sobre la lectura.** Si tienes que elegir, sacrificas Ousterhout antes que problemas.
4. **La lectura manda sobre tirar de horas extra.** No hagas 10h una semana. Mantén el ritmo.
5. **Toda decisión técnica del proyecto va a un ADR.** Sí, aunque parezca tonto. Practicar es el punto.

## Métricas a trackear semanalmente

En cada Weekly Review:

- Horas reales vs 7h
- Algoritmos resueltos esta semana
- Notas atómicas creadas
- Commits al proyecto
- Energy + foco (1-5)
- 1 historia STAR cruda capturada (10-15 min, aunque no se redacte completa)

---

[[00_Master_Plan]] | [[Q1_Plan]] | [[Q2_Plan]]
