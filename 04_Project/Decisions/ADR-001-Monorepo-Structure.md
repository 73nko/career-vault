# ADR-001-Monorepo-Structure



#adr #status/accepted

**Fecha:** 2026-05-18
**Status:** Accepted

## Contexto

El proyecto [[00_Project_Overview|track-vitals]] no es un único paquete: ya en la v0.1 tiene tres unidades de despliegue distintas y una librería publicable a npm.

Componentes previstos a 12 meses:

- `sdk-web`: librería TS publicada en npm (consumidores externos, semver estricto, builds ESM+CJS, types).
- `ingestion`: servicio Fastify de ingesta (deploy a Railway/Fly).
- `dashboard`: app Next.js 15 con RSC (deploy a Vercel o equivalente).
- `sdk-react-native`: paquete npm adicional en Q4 que comparte código con `sdk-web`.
- `shared`: tipos, esquemas Zod del payload, constantes, utilidades compartidas entre SDK e ingestion.

La decisión hay que tomarla ahora, en la semana 1, porque condiciona: estructura del repo en GitHub, configuración de CI, estrategia de releases (changelog + versioning del SDK), DX al cambiar el contrato entre SDK e ingestion, y la curva de fricción al añadir el SDK de React Native en Q4.

Coste de equivocarse: aceptable, pero migrar de multi-repo a monorepo (o viceversa) en mes 8 es exactamente el tipo de yak-shaving que mata el plan.

## Opciones consideradas

### Opción A: Multi-repo (un repo por paquete)
- Pro: cada repo tiene su README, su CI, su ciclo de vida. Es lo que un consumidor del SDK espera al aterrizar en GitHub/npm.
- Pro: separación física fuerza interfaces explícitas entre SDK e ingestion.
- Contra: cambiar el contrato del payload exige PR coordinado en 2-3 repos, con publish intermedio del paquete `shared`. Fricción real para un solo desarrollador.
- Contra: cuatro repos a mantener (CI, dependabot, configs, tsconfig base) cuando el equipo es de una persona. Duplicación inútil.
- Contra: imposible refactorizar atómicamente. Cada cambio cross-cutting se convierte en un mini-release.

### Opción B (elegida): Monorepo con pnpm workspaces puro
- Pro: un solo `pnpm install`, un solo `tsconfig` base, un solo CI. Cambios cross-package en un commit.
- Pro: cero capas adicionales que aprender. `pnpm-workspace.yaml` y filtros `pnpm --filter` cubren el 95% de lo que necesito en v0.1.
- Pro: el `sdk-react-native` de Q4 reutiliza `shared` sin gimnasia de publish ni links manuales.
- Pro: salida fácil. Si más adelante quiero Turborepo, se monta encima sin restructurar. Si quiero extraer `sdk-web` a su repo, `git filter-repo` y listo.
- Contra: sin cache de tareas. `pnpm -r build` reconstruye todo lo tocado. Con 3-4 paquetes y builds rápidos, no duele todavía.
- Contra: releases del SDK manuales al principio (`pnpm publish --filter @track-vitals/sdk` con bump explícito de versión). Cuando empiece a hacer >1 release/semana, dolerá.
- Contra: publicar `sdk-web` desde un monorepo exige disciplina con `publishConfig`, `exports` y `files` para no filtrar internals.

### Opción C: Monorepo con pnpm + Turborepo + Changesets de día uno
- Pro: cache de builds y releases automatizadas desde el primer commit. Setup "completo" tipo tRPC/Astro.
- Pro: señal de Staff legible para un reviewer técnico.
- Contra: tres herramientas nuevas en la semana 1 cuando la prioridad es escribir código del SDK, no decorar el repo.
- Contra: cache de Turborepo no aporta nada con N=3 paquetes y builds <10s. Beneficio teórico, fricción real.
- Contra: contradice la regla "no inflar el proyecto, ship la versión más pequeña útil". Esto es inflar el tooling antes de tener producto.

### Opción D: Monorepo con Nx
- Pro: orquestador potente, generadores, mejor para grafos grandes.
- Contra: ergonomía pensada para equipos y monorepos de apps. Aquí hay 1 persona y 4 paquetes.
- Contra: añade DSL propio (`project.json`, ejecutores). Suma fricción de lectura a quien revise el repo en una entrevista.
- Contra: menos común en el mundo TS-library/SDK puro. Defendible, pero exige justificar la elección.

### Opción E (descartada sin valorar): Lerna clásico
Sin mantenimiento serio post-Nx. No es 2020.

## Decisión

**Monorepo con pnpm workspaces puro.** Layout:

```
track-vitals/
├── apps/
│   ├── ingestion/        # Fastify
│   └── dashboard/        # Next.js 15
├── packages/
│   ├── sdk-web/          # publicado en npm como @track-vitals/sdk
│   └── shared/           # tipos + Zod schemas
├── pnpm-workspace.yaml
├── package.json
└── tsconfig.base.json
```

`sdk-react-native` entrará en `packages/sdk-react-native/` en Q4 sin reestructuración.

Convenciones:

- TypeScript estricto en toda la raíz; cada paquete extiende `tsconfig.base.json`.
- Cada paquete declara `exports` y `types` explícitos. Nada de barrels gigantes.
- Dependencias internas se referencian con `workspace:*` en `package.json`.
- Scripts comunes en la raíz: `pnpm -r --parallel lint`, `pnpm -r build`, `pnpm -r test`. Con filtros `--filter` cuando interese.
- Ramas: trunk-based en `main`.
- CI: GitHub Actions con un workflow que corre `pnpm -r build test lint`. Sin cache distribuida.
- Releases del SDK: manuales al principio. Bump explícito de versión en `packages/sdk-web/package.json` y `pnpm publish --filter @track-vitals/sdk --access public` desde local con OTP de npm.

## Razones principales

1. **Coste de aprendizaje mínimo en semana 1.** El tiempo va al SDK, no al tooling. pnpm workspaces es esencialmente cero conceptos nuevos sobre `package.json`.
2. **El contrato SDK <-> ingestion va a iterar mucho.** En monorepo es un commit; en multi-repo es ceremonia. Para 12 meses iterando solo, esto domina.
3. **Reversibilidad fácil hacia arriba.** Turborepo y Changesets se montan encima sin restructurar. Empezar con la versión más simple y subir cuando duela es estrictamente mejor que predecir mal qué tooling necesito.

## Consecuencias

### Positivas
- Refactorizar el payload SDK -> servidor es un PR único con type-check global.
- El paquete `shared` desaparece del problema: import directo entre paquetes, no publish intermedio.
- Onboarding trivial para colaboradores externos en Q3-Q4: `pnpm install` en la raíz.
- Cero deuda de configuración. Si en Q2 esto se queda corto, añado lo que falte con contexto real.

### Negativas / Trade-offs aceptados
- Sin cache de builds. Aceptable mientras N <= 4 paquetes y builds locales <10s. Si esto cambia, sumo Turborepo (ver "Revisitar si...").
- Releases del SDK manuales. Si publico una versión rota por bump mal hecho, asumo la responsabilidad. Mitigación: `publint` y `arethetypeswrong` en CI antes del publish.
- El repo crece con código que no es del SDK (dashboard, ingestion). Stars y forks del repo no son métrica del SDK aislado. Acepto este coste de marca a cambio de velocidad.
- Si en Q3 quiero mover `sdk-web` a su propio repo para visibilidad pública, hay coste de extracción (historia git, issues). Asumido como reversible con esfuerzo.

## Revisitar si...

- **Añadir Turborepo:** los builds locales superan 30s en frío, o el grafo cruza 5+ paquetes con dependencias entre ellos.
- **Añadir Changesets:** la cadencia de publish del SDK supera 1 release/semana, o me empiezo a equivocar haciendo bumps manuales.
- **Extraer `sdk-web` a su propio repo:** el SDK despega solo (>500 stars, contribuciones externas frecuentes) y la separación de marca respecto al backend empieza a importar.
- **Migrar a Nx:** el monorepo supera 8-10 paquetes y el grafo se vuelve denso (improbable en este plan).
- **Volver a multi-repo:** aparece un consumer empresarial pidiendo el SDK desligado del resto.

## Referencias

- [[00_Project_Overview]]
- pnpm workspaces: https://pnpm.io/workspaces
- pnpm `--filter`: https://pnpm.io/filtering
- publint: https://publint.dev/
- arethetypeswrong: https://arethetypeswrong.github.io/
- Cuando duela, evaluar: Turborepo (https://turborepo.com/docs), Changesets (https://github.com/changesets/changesets)
