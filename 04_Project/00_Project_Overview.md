# Project: Web Vitals SDK + Pipeline

#project #status/draft

**Nombre tentativo:** (decidir Q1)
**Tipo:** Open Source
**Inspiración:** Sentry Performance, Datadog RUM, Grafana Faro, Plausible

## Tesis del proyecto

Una herramienta open source para que developers monitoreen Core Web Vitals de sus aplicaciones sin pagar 200€/mes a Datadog. Stack moderno, self-hostable, con dashboard simple y alertas básicas.

No estoy construyendo Sentry. Estoy construyendo algo enfocado que demuestre:
- Diseño de SDK con DX excelente
- Type safety end-to-end
- Pipeline de ingesta a escala pequeña
- Time-series storage real (ClickHouse)
- Dashboard funcional
- Alertas con thresholds

## Roadmap

### v0.1 (final Q1)
- [ ] SDK web capturando CWV (CLS, LCP, INP, FCP, TTFB)
- [ ] API surface ergonómica (init, identify, custom events)
- [ ] Batching + sendBeacon
- [ ] Endpoint Fastify de ingesta con Zod validation
- [ ] Storage Postgres temporal
- [ ] README inicial

### v0.2 (final Q2)
- [ ] Migración storage a ClickHouse
- [ ] Schema time-series bien diseñado
- [ ] Processing job (windowing, agregaciones)
- [ ] Dashboard Next.js con métricas básicas
- [ ] Dogfooding en mi sitio propio

### v0.3 (final Q3)
- [ ] Sistema de alertas (threshold + cooldown)
- [ ] Webhook genérico (Slack/Discord/HTTP)
- [ ] Multi-proyecto en una instancia
- [ ] Auth básica para dashboard
- [ ] Lanzamiento público

### v1.0 (final Q4)
- [ ] SDK React Native
- [ ] Multi-tenancy real
- [ ] Compatibilidad OTel (exporter)
- [ ] Docs serias en docs site
- [ ] Anuncios en HN / Twitter / blog

## Stack técnico

| Capa | Tecnología | Razón |
|---|---|---|
| SDK | TypeScript + tsup | Type safety, build moderno |
| Ingestion | Node + Fastify | Performance, ecosistema |
| Validación | Zod | Type safety runtime |
| Storage | ClickHouse | Time series, alineado con target |
| Dashboard | Next.js 15 + RSC | Moderno, mi área de profundidad |
| Charts | Tremor o Recharts | Rápido, suficiente |
| Hosting SDK | npm | Standard |
| Hosting BE | Railway o Fly.io | Simple, barato |
| Hosting DB | ClickHouse Cloud o self-hosted | Decidir Q2 |

## Decisiones arquitecturales (ADRs)

A medida que vaya tomando decisiones, crear ADR en `04_Project/Decisions/`:
- [[ADR-001-Storage-Choice]]
- [[ADR-002-SDK-API-Surface]]
- [[ADR-003-Ingestion-Endpoint-Design]]

## Métricas de éxito del proyecto

- Funcional: el SDK captura datos reales y los muestra en dashboard.
- Calidad: tests, types, docs, CI. Código que no me daría vergüenza enseñar en una entrevista.
- Lanzamiento: 50+ stars en GitHub no es el objetivo. El objetivo es enseñarlo en entrevistas.
- Aprendizaje: las notas en `03_Concepts/` reflejan lo aprendido construyendo.

## Lo que NO es el proyecto

- No es Sentry. No intento reemplazarlos.
- No es business. No voy a monetizarlo (al menos en estos 12 meses).
- No es un side project para dormir poco. Es vehículo de aprendizaje y señal.

## Links

- [[Architecture/SDK_Design]]
- [[Architecture/Ingestion_Pipeline]]
- [[Architecture/Storage_Schema]]
- [[Decisions/]]
