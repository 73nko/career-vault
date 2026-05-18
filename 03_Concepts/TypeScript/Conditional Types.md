# Conditional Types

#concept #status/draft

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

Cuatro piezas:

**1. Forma básica.** `T extends U ? X : Y` se evalúa cuando `T` se conoce concretamente. Mientras `T` sea un parámetro genérico no resuelto, la evaluación queda diferida.

**2. Distributividad.** Si `T` es un parámetro de tipo "naked" (aparece directamente, sin envoltorios), el conditional type distribuye sobre uniones:

```typescript
type ToArray<T> = T extends any ? T[] : never;
type R = ToArray<string | number>; // string[] | number[]
```

Para desactivar la distribución, se envuelve en tupla:

```typescript
type ToArrayNoDist<T> = [T] extends [any] ? T[] : never;
type R2 = ToArrayNoDist<string | number>; // (string | number)[]
```

**3. `infer`.** Dentro de la rama `extends`, `infer` declara una variable de tipo cuyo valor TS deduce por unificación. Es la herramienta que permite "extraer" tipos.

**4. Recursividad.** Un conditional type puede referirse a sí mismo en sus ramas. Tiene un límite de profundidad alto pero finito; pasarlo es un error de compilación.

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

- Implementa `ReturnType<T>` desde cero. Pista: necesitas `infer` y un constraint sobre `T` para que solo acepte funciones.
- ¿Qué es la distributividad en conditional types y cuándo me beneficia? Cuando quiero aplicar una transformación a cada miembro de una unión por separado. `Exclude` y `NonNullable` dependen de ella.
- ¿Cómo desactivo la distributividad? Envolviendo en tupla: `[T] extends [U]`. La razón es que el comportamiento distributivo solo aplica a parámetros "naked".
- Implementa `Awaited<T>` y explica por qué necesita ser recursivo. Porque `Promise<Promise<T>>` ocurre cuando devuelves una Promise dentro de un `then`, o haces `Promise.resolve(otherPromise)`. La recursión desempaqueta hasta llegar a un no-Promise.
- Diferencia entre `T extends U` dentro de un conditional type vs `T extends U` como constraint de un generic. El primero es una pregunta evaluable. El segundo es una restricción que el call site debe satisfacer.

## Fuente

- TypeScript Handbook, Conditional Types: https://www.typescriptlang.org/docs/handbook/2/conditional-types.html
- Type Challenges, niveles Medium y Hard: https://github.com/type-challenges/type-challenges
- Total TypeScript (Matt Pocock), módulo de Type Transformations
