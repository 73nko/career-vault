# STAR Stories - Master List

#behavioral #moc

Lista maestra de historias STAR a desarrollar. Mínimo 15-20 historias sólidas para Q4. Cada una en su archivo dentro de `06_Interviews/Behavioral/`.

Regla desde Q1: cada Weekly Review captura una historia cruda. No hace falta pulirla; sí hace falta dejar hechos, mi acción concreta y una métrica candidata. Q4 queda para convertirlas en versiones de 30s y 2min.

## Señales que necesito cubrir para Staff

| Señal | Historias necesarias |
|---|---|
| Leadership técnico | 3+ |
| Decisión técnica con trade-offs | 3+ |
| Impacto cross-team | 2+ |
| Mentoring / desarrollo de otros | 2+ |
| Resolución de conflicto | 2+ |
| Manejo de ambigüedad | 2+ |
| Falla / lección aprendida | 2+ |
| Influencia sin autoridad | 2+ |

## Pool de historias candidatas (Awtomic)

Brainstorming inicial. Refinar cada una en su archivo.

### Técnicas
- [ ] [[STAR_Brian_Decision_X]] - Decisión técnica importante con Brian
- [ ] [[STAR_Refactor_Mayor]] - Algún refactor grande que lideré
- [ ] [[STAR_Adrian_Architectural_Push]] - Cuándo empujé arquitectura
- [ ] [[STAR_Subscription_Edge_Case]] - Bug complejo en subscriptions
- [ ] [[STAR_Performance_Optimization]] - Optimización de performance significativa
- [ ] [[STAR_Bundle_System]] - Decisiones técnicas en bundle products

### Cross-team / Producto
- [ ] [[STAR_Product_Push_Back]] - Empujar back en una decisión de producto
- [ ] [[STAR_Cross_Functional_Initiative]] - Iniciativa que cruzó áreas
- [ ] [[STAR_Customer_Issue_Critical]] - Issue crítico con cliente

### Liderazgo / influencia
- [ ] [[STAR_Onboarding_Emily]] - Onboarding/mentoring de Emily
- [ ] [[STAR_Convince_Team_Of_X]] - Convencer al equipo de algo
- [ ] [[STAR_Standards_Push]] - Empujar standards o convenciones

### Fallas
- [ ] [[STAR_Production_Incident]] - Algún incident en producción
- [ ] [[STAR_Wrong_Architectural_Choice]] - Decisión que salió mal
- [ ] [[STAR_Slow_Realization]] - Algo que tardé en darme cuenta

### Conflicto
- [ ] [[STAR_Disagreement_With_X]] - Desacuerdo con compañero
- [ ] [[STAR_Pushing_Back_Manager]] - Push back con manager

## Patrón de ejecución (Q4)

Cada semana de Q4: redactar 2 historias completas y practicar en voz alta 2 historias ya escritas.

## Captura semanal mínima

```dataview
TASK
FROM "06_Interviews/Behavioral"
WHERE contains(text, "metric")
```

Preguntas de cierre:
- ¿Qué hice yo, no el equipo?
- ¿Qué cambió por mi acción?
- ¿Qué número puedo defender sin exagerar?

## Recurso clave
- [[Books/Staff Engineer]] - cap sobre comunicar impacto
- "Behavioral Interview" videos de Jackson Gabbard en YouTube
- "STAR method" framework
