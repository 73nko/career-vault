# Conditional Types

#concept #status/done

## Definición

Tipo que se evalúa a uno u otro resultado según una comprobación de asignabilidad: `T extends U ? X : Y`. Es la lógica `if/else` del sistema de tipos.

## Por qué importa

Es la base sobre la que están construidos `ReturnType`, `Parameters`, `Awaited`, `Exclude`, `Extract` y prácticamente toda librería con type safety profunda: Zod, tRPC, Drizzle, Hono. Sin conditional types, expresar cosas como "el tipo que devuelve esta función" o "el tipo desempaquetado de esta Promise" sería imposible.

Lo uso cuando:

- Necesito derivar un tipo a partir de otro siguiendo una regla. Ejemplos: extraer el retorno de una función, desempaquetar una Promise, transformar un objeto.
- Quiero que la API de una librería se adapte al input. Ejemplo: un `query()` que devuelve `Row` si no llamas a `.limit(1)` y `Row | undefined` si lo llamas.

NO lo uso cuando:

- Una unión literal o un genérico simple resuelven el caso. Los conditional types son densos y los errores se vuelven crípticos rápido.
- Quiero lógica en runtime. Esto solo existe en tiempo de compilación.

## Cómo funciona

### 1. Forma básica

`T extends U ? X : Y` se evalúa cuando `T` se conoce concretamente. Mientras `T` sea un parámetro genérico no resuelto, la evaluación queda diferida.

### 2. Distributividad

Si `T` es un parámetro de tipo "naked" (aparece directamente, sin envoltorios), el conditional type distribuye sobre uniones:

```typescript
type ToArray<T> = T extends any ? T[] : never;
type R = ToArray<string | number>; // string[] | number[]
```

Para desactivar la distribución, se envuelve en tupla:

```typescript
type ToArrayNoDist<T> = [T] extends [any] ? T[] : never;
type R2 = ToArrayNoDist<string | number>; // (string | number)[]
```

### 3. `infer`

Dentro de la rama `extends`, `infer` declara una variable de tipo cuyo valor TS deduce por unificación. Es la herramienta que permite "extraer" tipos. Ver [[Infer Keyword]] para el detalle.

### 4. Recursividad

Un conditional type puede referirse a sí mismo en sus ramas. Hay un límite de profundidad (50 niveles por defecto) que sube a ~1000 con la **tail recursion optimization** introducida en TS 4.5. Solo se optimiza si la llamada recursiva está en posición de cola: el último paso de la rama, sin transformación adicional encima. Patrón común al parsear template literals largas.

### 5. Asignabilidad estructural, no igualdad

`T extends U` no comprueba "T es igual a U", comprueba "T es asignable a U" siguiendo las reglas estructurales de TS. `{ a: string; b: number }` extends `{ a: string }` es `true` (la primera satisface el contrato de la segunda). Al revés es `false`. Esto pilla a gente en entrevistas que esperan igualdad y reciben asignabilidad. Para igualdad estricta hace falta el truco de `Equal<X, Y>` (ver ejemplos).

## Ejemplo

Implementar `ReturnType` desde cero, y después `Awaited`:

```typescript
// 1. ReturnType: extrae el tipo de retorno de cualquier función.
type MyReturnType<T extends (...args: any[]) => any> =
  T extends (...args: any[]) => infer R ? R : never;

type A = MyReturnType<() => string>;            // string
type B = MyReturnType<(x: number) => boolean>;  // boolean

// 2. Awaited: desempaqueta Promises recursivamente.
type MyAwaited<T> =
  T extends Promise<infer U> ? MyAwaited<U> : T;

type C = MyAwaited<Promise<Promise<number>>>; // number
type D = MyAwaited<string>;                   // string
```

Distributividad en acción, implementando `Exclude`:

```typescript
type MyExclude<T, U> = T extends U ? never : T;

type Color = "red" | "blue" | "green";
type NotRed = MyExclude<Color, "red">; // "blue" | "green"
```

Funciona porque `T` es naked: la evaluación se hace miembro a miembro de la unión. Si envolvieras `T` en tupla (`[T] extends [U]`), `Exclude` dejaría de funcionar.

`Equal<X, Y>` (igualdad estricta), patrón que aparece en type-challenges y en librerías que necesitan diferenciar tipos estructuralmente compatibles pero no idénticos:

```typescript
type Equal<X, Y> =
  (<T>() => T extends X ? 1 : 2) extends
  (<T>() => T extends Y ? 1 : 2) ? true : false;

type E1 = Equal<string, string>;                  // true
type E2 = Equal<string, "hello">;                 // false
type E3 = Equal<{ a: 1 }, { a: 1; b?: never }>;   // false (estructura distinta)
type E4 = Equal<any, unknown>;                    // false (que extends sí daría true)
```

El truco: comparar dos funciones genéricas idénticas excepto en `X`/`Y`. TS solo las considera mutuamente asignables si los tipos son estructuralmente equivalentes en TODAS las posiciones del cuerpo. Es el único patrón en TS puro que da igualdad real en lugar de asignabilidad.

Un caso menos académico, sacado del estilo de tRPC o Drizzle. La firma se adapta al input:

```typescript
type QueryResult<T, Single extends boolean> =
  Single extends true ? T | undefined : T[];

declare function query<T, S extends boolean = false>(
  table: T,
  opts?: { single?: S },
): QueryResult<T, S>;

const many = query(users);                  // User[]
const one = query(users, { single: true }); // User | undefined
```

## Trade-offs

- Pro: lógica de tipos compleja sin coste en runtime.
- Pro: habilita APIs que se sienten "mágicas". La respuesta del endpoint se infiere del schema, los joins se reflejan en el row type.
- Contra: legibilidad cae rápido. Tres niveles anidados de `extends` y `infer` y solo lo entiende quien lo escribió.
- Contra: mensajes de error notoriamente difíciles. Cuando algo no asigna dentro de un conditional type, TS suele apuntar al call site sin decir qué rama falló.
- Contra: hit del límite de recursión. Si necesitas recursión profunda (parsear strings largas con template literals, por ejemplo), TS aborta con error.
- Cuándo evitar: si `Pick`, `Omit`, `Partial`, un mapped type simple o una unión hace el trabajo, eso gana en legibilidad.

## Relacionado

- [[Generics]]
- [[Mapped Types]]
- [[Template Literal Types]]
- [[Utility Types]]

## Preguntas que respondería en entrevista

- **Implementa `ReturnType<T>` desde cero.** Respuesta:
  ```typescript
  type MyReturnType<T extends (...args: any[]) => any> =
    T extends (...args: any[]) => infer R ? R : never;
  ```
  Tres piezas críticas: **(1)** constraint `T extends (...args: any[]) => any` para que TS rechace no-funciones en compile time. **(2)** `infer R` en posición del retorno para capturar el tipo. **(3)** rama `false` con `never` aunque sea inalcanzable bajo el constraint (TS la exige sintácticamente). Si quitas el constraint, pasar un `string` devuelve `never` silenciosamente.
- **¿Qué es la distributividad en conditional types y cuándo me beneficia?** Respuesta: cuando `T` es un **parámetro "naked"** (aparece sin envoltorios en la cláusula `extends`), el conditional se aplica **miembro a miembro** sobre cada elemento de una unión, y los resultados se unen. Me beneficia cuando quiero **aplicar una transformación a cada miembro por separado**: `Exclude<T, U>` filtra miembros de una unión, `NonNullable<T>` elimina `null` y `undefined`, `ToArray<T>` envuelve cada miembro en `T[]`. Sin distributividad, estos utility types no funcionarían.
- **¿Cómo desactivo la distributividad?** Respuesta: envolviendo el parámetro en una **tupla**: `[T] extends [U] ? ... : ...`. La razón es que el comportamiento distributivo solo aplica a parámetros **naked**. Al envolver `T` en `[T]`, TS evalúa el conditional con la unión completa como un solo tipo. Cuándo querer desactivar: cuando comparas dos uniones como conjuntos (`[A] extends [B]` pregunta "¿A es subconjunto de B?"), o cuando el resultado debe depender del tipo completo, no de sus miembros individuales.
- **Implementa `Awaited<T>` y explica por qué necesita ser recursivo.** Respuesta:
  ```typescript
  type MyAwaited<T> = T extends Promise<infer U>
    ? U extends Promise<unknown>
      ? MyAwaited<U>
      : U
    : T;
  ```
  Necesita recursión porque `Promise<Promise<T>>` aparece en código real cuando devuelves una `Promise` dentro de un `.then`, o haces `Promise.resolve(otherPromise)`. Sin la llamada recursiva te quedarías con `Promise<T>` después de un solo unwrap. La recursión desempaqueta hasta llegar a un no-Promise. Bonus: la llamada está en posición de cola, así que TS 4.5+ la optimiza y permite profundidad alta sin estallar.
- **Diferencia entre `T extends U` dentro de un conditional type vs `T extends U` como constraint de un generic.** Respuesta: el primero es una **pregunta evaluable** en tiempo de chequeo: "¿es T asignable a U? Si sí, da X; si no, da Y". El segundo es una **restricción** que el call site debe satisfacer: si pasas un `T` que no extiende `U`, no compila. Mismo operador, dos semánticas. Truco mnemónico: dentro del cuerpo de un tipo, `extends` es `if`; en la firma genérica, `extends` es `requires`.
- **¿Por qué `T extends U` y `U extends T` ambos `true` no implican `T = U`?** Respuesta: porque `extends` es **asignabilidad estructural**, no igualdad. `any` extends `unknown` y `unknown` extends `any`, pero son tipos distintos (el primero desactiva chequeo, el segundo requiere narrowing). Otro ejemplo: `{ a: 1 }` extends `{ a: 1; b?: never }` y viceversa, pero la presencia opcional de `b` los diferencia estructuralmente. Para igualdad real necesitas el patrón `Equal<X, Y>` que compara funciones genéricas idénticas excepto en `X`/`Y`. Es el único truco en TS puro que da igualdad estricta en lugar de asignabilidad.
- **¿Qué pasa con `T extends any ? T[] : never` cuando `T = never`?** Respuesta: devuelve `never`, **no `never[]`**. Porque `never` es la **unión vacía** y los conditional types distributivos se aplican miembro a miembro: cero miembros en la unión, cero resultados, `never`. Es fuente común de bugs en utility types donde un input vacío silenciosamente desaparece y no te enteras hasta que algo en runtime falla. Si quieres evitar la distribución sobre `never`, envuelve en tupla: `[T] extends [any] ? T[] : never` devuelve `never[]` cuando `T = never`.
- **¿Cuándo conviene usar `T extends unknown` en lugar de `T extends any` para forzar distribución?** Respuesta: **funcionalmente son equivalentes** en este uso (ambos hacen la condición trivialmente cierta y distribuyen). La diferencia es **ergonómica**: `T extends unknown` es más explícito sobre la intención ("acepto cualquier tipo, quiero distribuir") y **no introduce `any` en el código**, lo que ayuda en code reviews y con linters estrictos (typescript-eslint con `no-explicit-any` no se queja). En código de librería público, prefiero `unknown` por esa señal de intención.

## Fuente

- TypeScript Handbook, Conditional Types: https://www.typescriptlang.org/docs/handbook/2/conditional-types.html
- Type Challenges, niveles Medium y Hard: https://github.com/type-challenges/type-challenges
- Total TypeScript (Matt Pocock), módulo de Type Transformations
