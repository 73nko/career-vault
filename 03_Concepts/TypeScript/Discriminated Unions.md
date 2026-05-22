# Discriminated Unions

#concept #status/done

## Definición

Unión de tipos donde cada variante comparte una propiedad literal común, el discriminante, que identifica inequívocamente qué forma tiene el valor y permite a TypeScript hacer narrowing seguro.

```typescript
type Result<T, E> =
  | { ok: true; value: T }
  | { ok: false; error: E };
```

Aquí `ok` es el discriminante. En la rama `if (result.ok)`, TypeScript sabe que existe `value`; en la otra, sabe que existe `error`.

## Por qué importa

Modela estados mutuamente excluyentes sin caer en interfaces gordas llenas de opcionales. En sistemas grandes, esto cambia la categoría de error: de "recordar mentalmente qué campos existen en cada caso" a "el compilador te obliga a cubrir el caso correcto".

Lo uso cuando:

- Hay variantes finitas y conocidas: estados de una request, eventos de SDK, acciones de reducer, errores de dominio, mensajes de un protocolo.
- Cada variante tiene payload distinto y quiero narrowing automático.
- Quiero exhaustiveness checks con `never` al añadir una nueva variante.

NO lo uso cuando:

- Los casos no son finitos o vienen de un vocabulario abierto controlado por terceros.
- Las variantes son casi idénticas y un campo opcional no introduce ambigüedad real.
- La unión crece tanto que cada consumidor arrastra un `switch` gigante. Ahí conviene un handler map, visitor o separar subdominios.

## Cómo funciona

### 1. Discriminante literal común

Para que TypeScript discrimine bien, todas las variantes deben compartir una propiedad con valores literales distintos:

```typescript
type Loading = { status: "loading" };
type Success = { status: "success"; data: User };
type Failure = { status: "failure"; error: Error };

type LoadState = Loading | Success | Failure;
```

`status: string` no sirve. Tiene que ser `"loading" | "success" | "failure"` como singleton literal types.

### 2. Narrowing por `if` o `switch`

Cuando compruebas el discriminante, TypeScript reduce la unión a la variante compatible:

```typescript
function render(state: LoadState): string {
  switch (state.status) {
    case "loading":
      return "Loading";
    case "success":
      return state.data.name;
    case "failure":
      return state.error.message;
  }
}
```

Dentro de `case "success"`, `state` ya no es `LoadState`; es `Success`.

### 3. Exhaustiveness con `never`

El patrón canónico para que añadir variantes rompa compile-time donde falte manejo:

```typescript
function assertNever(value: never): never {
  throw new Error(`Unhandled case: ${JSON.stringify(value)}`);
}

function render(state: LoadState): string {
  switch (state.status) {
    case "loading":
      return "Loading";
    case "success":
      return state.data.name;
    case "failure":
      return state.error.message;
    default:
      return assertNever(state);
  }
}
```

Si mañana añades `{ status: "refreshing"; previousData: User }`, `state` en el `default` deja de ser `never` y TypeScript falla.

### 4. Shape-based narrowing es más frágil

También puedes narrowear con `"error" in value`, pero eso acopla el narrowing a campos incidentales. Si dos variantes comparten campo, si un campo se vuelve opcional, o si cambia el payload, el narrowing deja de expresar la intención. Un discriminante estable expresa protocolo, no forma accidental.

## Ejemplo

Wire format de un SDK de web vitals: eventos discriminados por `type`.

```typescript
type WebVitalName = "LCP" | "INP" | "CLS" | "FCP" | "TTFB";

type VitalEvent = {
  type: "vital";
  name: WebVitalName;
  value: number;
  rating: "good" | "needs-improvement" | "poor";
  id: string;
};

type CustomEvent = {
  type: "custom";
  name: string;
  payload: Record<string, unknown>;
};

type ErrorEvent = {
  type: "error";
  message: string;
  stack?: string;
};

type SdkEvent = VitalEvent | CustomEvent | ErrorEvent;

function serializeEvent(event: SdkEvent): string {
  switch (event.type) {
    case "vital":
      return JSON.stringify({
        t: event.type,
        n: event.name,
        v: event.value,
        r: event.rating,
        id: event.id,
      });
    case "custom":
      return JSON.stringify({
        t: event.type,
        n: event.name,
        p: event.payload,
      });
    case "error":
      return JSON.stringify({
        t: event.type,
        m: event.message,
        s: event.stack,
      });
    default:
      return assertNever(event);
  }
}
```

Contraste con una interfaz gorda:

```typescript
type BadSdkEvent = {
  type: "vital" | "custom" | "error";
  name?: string;
  value?: number;
  rating?: "good" | "needs-improvement" | "poor";
  payload?: Record<string, unknown>;
  message?: string;
};
```

Este modelo permite estados imposibles: `{ type: "vital", message: "boom" }`, `{ type: "custom", value: 123 }`, `{ type: "error" }`. El discriminated union hace esos estados irrepresentables.

Handler map cuando la unión crece:

```typescript
type EventType = SdkEvent["type"];
type EventByType<T extends EventType> = Extract<SdkEvent, { type: T }>;

const handlers: {
  [T in EventType]: (event: EventByType<T>) => string;
} = {
  vital: (event) => event.name,
  custom: (event) => event.name,
  error: (event) => event.message,
};

function getEventLabel(event: SdkEvent): string {
  return handlers[event.type](event as never);
}
```

El `Record<Tag, Handler>` fuerza cobertura de todos los tags. El cast final es una limitación práctica de TS al correlacionar indexed access con un union narrowed dinámicamente; en muchos casos un `switch` es más claro.

## Trade-offs

- Pro: hace estados imposibles irrepresentables. Cada variante declara exactamente qué datos existen.
- Pro: narrowing automático sin type predicates manuales.
- Pro: exhaustiveness checks robustos con `never`, especialmente útiles en reducers, protocolos y SDKs versionados.
- Contra: unions grandes generan ruido en errores y pueden ralentizar el compilador si se combinan con mapped/conditional types complejos.
- Contra: acopla consumidores al set de variantes. Añadir una variante puede romper muchos `switch`, que a veces es exactamente lo que quieres.
- Contra: requiere diseñar bien el discriminante. Cambiar `type` en un wire format público es un breaking change.
- Cuándo evitar: vocabularios abiertos, plugins de terceros, payloads homogéneos o APIs donde el consumidor no debe conocer todas las variantes.

## Relacionado

- [[Generics]]
- [[Conditional Types]]
- [[Template Literal Types]]
- [[Literal Types]] — el discriminante es un literal type; sin literales no hay narrowing
- [[Type Predicates]] — narrowing alternativo cuando no controlas la forma del dato
- [[Tagged Unions]] — mismo concepto, nombre del mundo FP
- [[SDK_Types]] — uso real: `WebVitalEvent = VitalEvent | CustomEvent` discriminado por `type`

## Preguntas que respondería en entrevista

- **¿Por qué discriminar con `type` literal es más robusto que discriminar por forma (`"foo" in obj`)?** Respuesta: porque el discriminante expresa intención de protocolo y no depende de campos incidentales del payload. Shape-based narrowing se rompe si dos variantes comparten campo, si un campo se vuelve opcional, o si el payload cambia por evolución de producto. `type: "vital"` sigue siendo estable aunque el evento añada `debug`, `source` o `metadata`.
- **¿Cómo garantizas en compile-time que ningún `switch` olvida una variante nueva?** Respuesta: con un `assertNever` en el `default` y `strict` activado. Cuando todos los casos están cubiertos, el valor restante es `never`. Si añades una variante y no actualizas el `switch`, el valor del `default` ya no es `never`; es la variante nueva. Pasarlo a `assertNever(value: never)` produce error de compilación.
- **Discriminated union vs interfaz con `type` y campos opcionales. ¿Qué bugs previene el DU?** Respuesta: la interfaz gorda permite combinaciones inválidas: `type: "success"` sin `data`, `type: "error"` con `data`, estados con payload de dos variantes a la vez. El DU codifica correlación: si `type` es `"success"`, `data` existe y `error` no. Esa correlación es lo que los opcionales no pueden expresar bien.
- **¿Qué pasa si dos variantes comparten el mismo valor de discriminante?** Respuesta: TypeScript no puede reducir a una única variante; reduce al subconjunto que comparte ese valor. Si ambos tienen `type: "event"`, dentro del case sigues teniendo una unión de esas variantes y necesitarás otro narrowing. Para detectarlo, puedes escribir tests de tipos, usar un helper que mapee por tag, o revisar que `Extract<Union, { type: "x" }>` no devuelva una unión inesperada.
- **¿Cuándo migrarías de `switch` a `Record<Tag, Handler>` o visitor?** Respuesta: cuando el número de variantes crece y la operación se repite en muchos sitios con la misma forma: serializar, renderizar, mapear a analytics. `Record<Tag, Handler>` fuerza cobertura de tags y agrupa handlers por operación. Pierdes algo de narrowing ergonómico y puedes necesitar casts por limitaciones de correlación. `switch` gana para lógica local y lineal; handler map gana para tablas de comportamiento extensibles.
- **¿Cómo diseñarías el discriminante en el wire format de un SDK: string literal, número o presencia de campos?** Respuesta: string literal (`type: "vital"`) salvo que haya una restricción extrema de tamaño. Es legible en logs, estable para versionado, fácil de validar con Zod, y autodescriptivo para consumidores externos. Número ahorra bytes pero cuesta debugging y documentación. Presencia de campos es frágil porque payload y protocolo quedan mezclados.
- **¿Qué coste tiene una unión de muchas variantes?** Respuesta: para humanos, errores largos y `switch` pesados; para el compilador, más trabajo de narrowing, especialmente si cada variante tiene generics, mapped types o conditional types. A partir de cierto tamaño, dividir por subdominios (`TransportEvent`, `MetricEvent`, `LifecycleEvent`) o usar un registro de eventos tipado suele ser más mantenible que una mega-unión global.
- **¿Cómo combinas discriminated unions con validación runtime?** Respuesta: el DU protege código TypeScript ya tipado, pero no valida JSON externo. En boundaries uso un schema discriminado, por ejemplo `z.discriminatedUnion("type", [...])`, y `z.infer` produce el DU. Así el mismo diseño existe en runtime y compile time: primero parseo `unknown`; después trabajo con `SdkEvent` seguro.

## Fuente

- TypeScript Handbook, Narrowing / Discriminated unions: https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- TypeScript Handbook, Union Types: https://www.typescriptlang.org/docs/handbook/unions-and-intersections.html
- Zod docs, discriminated unions: https://zod.dev/api?id=discriminated-unions
- Effective TypeScript (Dan Vanderkam), modelar estados con unions e interfaces precisas
