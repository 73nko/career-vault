# Branded Types

#concept #status/done

## Definición

Tipo que intersecta una representación base (`string`, `number`, objeto) con una marca fantasma para que TypeScript lo trate como un tipo distinto aunque en runtime siga siendo exactamente el mismo valor.

```typescript
type Brand<T, B extends string> = T & { readonly __brand: B };
```

Un `UserId` branded y un `OrderId` branded pueden ser ambos `string` en runtime, pero dejan de ser intercambiables en compile time.

## Por qué importa

TypeScript es estructural: si dos tipos tienen la misma forma, son compatibles. Eso es útil para interoperar con JavaScript, pero peligroso cuando dos valores tienen la misma representación y distinto significado de dominio: `UserId`, `ProjectId`, `SessionId`, `Email`, `UsdCents`, `TimestampMs`.

Lo uso cuando:

- Hay strings/numbers primitivos que representan conceptos distintos y mezclarlos sería un bug real.
- Quiero reforzar invariantes después de validar en un boundary: parsear un `unknown` y devolver `SessionId`, no `string`.
- Estoy diseñando una API pública y quiero que el consumidor no pueda pasar cualquier `string` por accidente.

NO lo uso cuando:

- El valor no ha sido validado. Un brand sin validación es solo un cast bonito.
- El coste de fricción para el consumidor supera el riesgo. Brandea IDs, unidades y tokens; no brandees cada string trivial.
- Necesito comportamiento en runtime. Para eso quiero un value object (`class`, objeto explícito) o un schema runtime.

## Cómo funciona

### 1. Structural typing y propiedad fantasma

El brand añade una propiedad que los valores base no tienen:

```typescript
type UserId = string & { readonly __brand: "UserId" };
type ProjectId = string & { readonly __brand: "ProjectId" };
```

Como `UserId` y `ProjectId` tienen marcas distintas, dejan de ser asignables entre sí. La propiedad no existe en runtime: es una intersección a nivel de tipos y TypeScript la borra al emitir JavaScript.

### 2. La marca debe ser imposible de fabricar accidentalmente

Una propiedad tipo `__brand: "UserId"` funciona, pero puede colisionar si dos librerías usan la misma clave. En librerías públicas, prefiero `unique symbol`:

```typescript
declare const brand: unique symbol;

type Brand<T, B> = T & { readonly [brand]: B };
type UserId = Brand<string, "UserId">;
```

`unique symbol` hace que la clave sea **infalsificable**. La marca es puramente type-level: se borra al emitir JavaScript y nunca existe como propiedad en runtime. El consumidor no puede nombrar esa clave ni construir un objeto con ella sin importar el símbolo — y como `brand` es `declare const`, no hay ningún valor en runtime que importar.

### 3. Minting: cast vs smart constructor

Un brand no se "crea" solo. Hay que convertir un valor base a branded. Tres patrones:

```typescript
type SessionId = Brand<string, "SessionId">;

// Cast: barato, peligroso si no está pegado a una validación.
const unsafeSessionId = raw as SessionId;

// Smart constructor: valida y devuelve branded solo si pasa.
function parseSessionId(value: unknown): SessionId {
  if (typeof value !== "string" || !/^sess_[a-zA-Z0-9]+$/.test(value)) {
    throw new Error("Invalid session id");
  }

  return value as SessionId;
}

// Type predicate: útil cuando quieres narrowing sin throw.
function isSessionId(value: unknown): value is SessionId {
  return typeof value === "string" && /^sess_[a-zA-Z0-9]+$/.test(value);
}
```

En una librería pública, expongo smart constructors o parsers. El `as SessionId` debería vivir cerca del boundary validado, no repartido por el código de aplicación.

### 4. El brand no sobrevive a boundaries

Serializar a JSON convierte `SessionId` en `string`. Parsear JSON devuelve `unknown` o `any`, no `SessionId`. Después de red, storage, `postMessage`, DB o env vars, hay que validar otra vez y volver a mintear el brand.

## Ejemplo

Caso del SDK: evitar mezclar IDs que son todos `string`.

```typescript
declare const brand: unique symbol;
type Brand<T, B> = T & { readonly [brand]: B };

type ProjectId = Brand<string, "ProjectId">;
type SessionId = Brand<string, "SessionId">;
type UserId = Brand<string, "UserId">;

type WebVitalMetric = "LCP" | "INP" | "CLS" | "FCP" | "TTFB";

type WebVitalEvent = {
  projectId: ProjectId;
  sessionId: SessionId;
  userId?: UserId;
  metric: WebVitalMetric;
  value: number;
  timestampMs: number;
};

function parseProjectId(value: unknown): ProjectId {
  if (typeof value !== "string" || !value.startsWith("proj_")) {
    throw new Error("Invalid project id");
  }

  return value as ProjectId;
}

function parseSessionId(value: unknown): SessionId {
  if (typeof value !== "string" || !value.startsWith("sess_")) {
    throw new Error("Invalid session id");
  }

  return value as SessionId;
}

function sendEvent(event: WebVitalEvent): void {
  navigator.sendBeacon("/vitals", JSON.stringify(event));
}

const projectId = parseProjectId("proj_123");
const sessionId = parseSessionId("sess_456");

sendEvent({
  projectId,
  sessionId,
  metric: "LCP",
  value: 2400,
  timestampMs: performance.now(),
});

sendEvent({
  projectId: sessionId,
  // Error: SessionId no es asignable a ProjectId.
  sessionId: projectId,
  // Error: ProjectId no es asignable a SessionId.
  metric: "CLS",
  value: 0.12,
  timestampMs: performance.now(),
});
```

Sin brands, ambos errores compilan porque todo es `string`. Con brands, el bug se captura antes de mandar eventos corruptos.

Un brand para unidades es igual de útil:

```typescript
type Milliseconds = Brand<number, "Milliseconds">;
type Seconds = Brand<number, "Seconds">;

function ms(value: number): Milliseconds {
  return value as Milliseconds;
}

function seconds(value: number): Seconds {
  return value as Seconds;
}

function scheduleFlush(delay: Milliseconds): void {
  setTimeout(flush, delay);
}

scheduleFlush(ms(500));      // OK
scheduleFlush(seconds(5));   // Error: segundos no son milisegundos
```

Este bug es común en sistemas distribuidos: mezclar segundos, milisegundos, bytes, cents, percentages. TypeScript no distingue unidades a menos que se las enseñes.

## Trade-offs

- Pro: añade una capa nominal encima de un sistema estructural sin coste runtime.
- Pro: previene bugs de dominio con IDs, unidades y tokens que comparten representación.
- Pro: combina bien con validación en boundary: Zod/Valibot/io-ts parsean, el tipo branded captura "ya validado".
- Contra: requiere minting explícito. Si el consumidor recibe un `string`, no puede pasarlo a la API sin pasar por tu parser.
- Contra: puede degenerar en `as Brand` por todas partes. Eso destruye el valor del patrón.
- Contra: no protege contra datos corruptos en runtime. Si casteas mal, TypeScript te cree.
- Cuándo evitar: objetos con comportamiento real, invariantes complejas o necesidad de serialización explícita suelen merecer un value object. Strings internos de bajo riesgo suelen merecer quedarse como `string`.

## Relacionado

- [[Generics]]
- [[Conditional Types]]
- [[Structural Typing]] — branded types son la derrota deliberada del structural typing; esta es la relación central
- [[Opaque Types]] — concepto vecino: "opaque" es el objetivo, "branded" es la técnica para lograrlo
- [[Type Predicates]] — los smart constructors que mintean valores branded suelen apoyarse en type predicates
- [[Validación en boundary]] — el brand es compile-time; en el boundary de red sigue haciendo falta validación runtime
- [[SDK_Types]] — uso potencial: `sessionId`, `projectId`, `User.id` son candidatos a branding

## Preguntas que respondería en entrevista

- **¿Qué bug previene un `UserId` branded que `type UserId = string` no previene?** Respuesta: evita pasar un `OrderId`, `ProjectId` o `SessionId` a una función que espera `UserId` cuando todos son strings. `type UserId = string` es solo un alias; no crea un tipo nuevo. `type UserId = Brand<string, "UserId">` sí rompe la asignabilidad estructural porque añade una marca fantasma incompatible con otros brands.
- **¿Los branded types existen en runtime? ¿Qué clase de bugs no previenen?** Respuesta: no existen en runtime; TypeScript los borra. No previenen datos inválidos que vienen de red, storage, formularios o JSON parseado. Tampoco previenen un `as UserId` incorrecto. El brand solo dice "en este punto del programa, el compilador cree que esto ya fue validado". La validación real sigue viviendo en el boundary.
- **¿Cómo crearías un valor branded en una librería pública?** Respuesta: con un smart constructor o parser que valide y devuelva el brand: `parseUserId(input: unknown): UserId` o `UserId.safeParse(input): Result<UserId, Error>`. Evitaría exponer `as UserId` como patrón de consumo porque empuja la responsabilidad al usuario y convierte el brand en documentación sin enforcement. Internamente, el parser termina con un cast, pero el cast está encapsulado detrás de una validación.
- **¿Por qué usar `unique symbol` para la marca en vez de `__brand: "UserId"`?** Respuesta: `__brand` funciona en código de aplicación, pero puede colisionar entre librerías y aparece en tooltips como una propiedad rara. `unique symbol` crea una clave nominal que el consumidor no puede reproducir accidentalmente. Eso hace el brand más opaco y reduce colisiones. En un SDK público, `unique symbol` es la opción más robusta.
- **Branded type vs class wrapper vs Zod. ¿Cuándo eliges cada uno?** Respuesta: branded type cuando quiero distinguir conceptos en compile time sin coste runtime ni wrapper de serialización. Class/value object cuando necesito comportamiento, métodos, normalización interna o invariantes que deben viajar con el valor. Zod/Valibot cuando estoy en un boundary runtime y necesito validar datos reales. En sistemas serios suelen combinarse: Zod valida, el resultado se expone como branded.
- **¿Qué pasa con un brand al hacer `JSON.stringify` y luego `JSON.parse`?** Respuesta: el brand desaparece porque nunca estuvo en runtime. `JSON.stringify(userId)` serializa un string. `JSON.parse(...)` devuelve `any` o `unknown`, no `UserId`. Después de parsear tienes que validar otra vez y volver a mintear el brand. Este punto separa a quien entiende TypeScript como sistema de tipos borrado de quien cree que los tipos existen en ejecución.
- **¿Cuál es el coste de branded types a 10x de superficie de API?** Respuesta: fricción de entrada. Cada API que pide un brand obliga al consumidor a pasar por constructores, parsers o casts. Si brandeas demasiado, el SDK se vuelve burocrático. La regla buena es brandea valores con alto riesgo semántico y larga vida (`ProjectId`, `SessionId`, unidades), no strings efímeros que solo cruzan una función local.
- **¿Cómo evitarías que los engineers usen `as UserId` por todas partes?** Respuesta: centralizando minting en módulos pequeños, exportando el tipo y el parser pero no el símbolo de brand, y haciendo que las APIs públicas devuelvan branded values desde el primer boundary validado. En code review, cualquier `as UserId` fuera del módulo de parsing es sospechoso. Si necesitas muchos casts, el diseño está filtrando representación interna.

## Fuente

- TypeScript Handbook, Narrowing: https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- TypeScript Handbook, Symbols: https://www.typescriptlang.org/docs/handbook/symbols.html
- Effective TypeScript (Dan Vanderkam), Items sobre nominal typing y branded types
- Total TypeScript, branded types / opaque types patterns
