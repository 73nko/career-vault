# MOC: Frontend Interview Practice

#moc #frontend-interview

Banco de problemas de formato entrevista frontend. **No es un curso a consumir** — es una fuente de la que se tira para llenar slots ya presupuestados del plan (algoritmos, semanas de React, system design FE). Si no estoy practicando, no estoy aprendiendo.

## Fuente
- Repo: [preparing-for-ui-interview-v2](https://github.com/EvgeniiRay/preparing-for-ui-interview-v2)
- Curso original (NO ver vídeos linealmente): [Interviewing for Frontend Engineers v2](https://frontendmasters.com/courses/interviewing-frontend-v2/)

## Reglas
1. **Resolver antes de mirar la solución.** Cronómetro según dificultad del repo.
2. **Una nota por problema resuelto** en `06_Interviews/FE_Practice/<Problema>.md`. Plantilla: copiar estructura de `99_Templates/Algorithm_Problem.md`.
3. **No añadir problemas al banco curado sin recortar otro.** El budget no crece.
4. **No mirar los vídeos** salvo que esté atascado 2 nudges después de intentar.

## Banco curado (12 problemas — los demás del repo se ignoran)

### Classic JS — usar como slot algoritmo alterno (Q1-Q2)
Cuando NeetCode toca un patrón ya cubierto, sustituir por uno de estos. Es lo que pregunta un live coding FE en Datadog/Linear/Vercel.

- [ ] **Debounce** 🟢 — closures + setTimeout
- [ ] **Throttle** 🟢 — rate limiting
- [ ] **Deep Equals** 🟡 — recursión + type checking
- [ ] **Promise (implementar)** 🔴 — microtasks + state machine

### UI Components — sustituir demos React genéricas (Q2 Mes 5-8)
Una por semana React. Vanilla primero, React después (refuerza ambos lados).

- [ ] **Tabs** 🟢 — composición + a11y (warmup)
- [ ] **Tooltip** 🟢 — portals + coordinate math
- [ ] **Toast** 🔴 — context + timers + portals
- [ ] **Typeahead** 🔴 — debounce + async + keyboard nav (canónico staff FE)
- [ ] **Table (filter/sort)** 🟡 — dashboard-shape, relevante para Datadog/Grafana

### Extreme — vehículo de Frontend System Design (Q3)
Cada uno emparejado con un writeup de arquitectura en `06_Interviews/SystemDesign/`.

- [ ] **Markdown Editor** 🚀 — text processing + state (formato Linear/Notion)
- [ ] **GPT Chat Interface** 🚀 — streaming + auto-scroll (zeitgeist actual)
- [ ] **Google Sheets: Recompute** 🚀 — graph dependency + full engine (el más duro, último de Q3 o Q4)

## Problemas explícitamente descartados
Para que el "y este por qué no" no se cuele:
- Detect Type, ES5 Extends, Stringify, Tree Select (Classic JS sobrantes) — no aportan sobre los 4 elegidos.
- Accordion, Star Rating, Dialog, Reddit Thread, Gallery, Nested Checkboxes, Calculator, Square Game, Progress Bar, File Upload Hook, Upload Component (UI sobrantes) — solapan en concepto con los 5 elegidos.
- Portfolio Visualizer (UX/Logic), GS:Basic/Compile/Topo/Eval/UX — pasos intermedios del GS Recompute, no se hacen sueltos.

Si al llegar a Q3 el plan va por delante y queda budget, reabrir esta lista. No antes.

## Tracker

```dataview
TABLE
  difficulty as "Dificultad",
  status as "Estado",
  file.cday as "Resuelto"
FROM "06_Interviews/FE_Practice"
WHERE difficulty
SORT file.cday DESC
```

## Relacionado
- [[00_MOC_Algorithms]] — algoritmos DSA (NeetCode)
- [[00_Target_Companies_Tracker]] — qué formato usa cada target

---
[[Q1_Plan]] | [[Q2_Plan]] | [[Q3_Plan]]
