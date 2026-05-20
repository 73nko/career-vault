# Infer Keyword

#concept #status/done

## Definición

`infer` declara una variable de tipo dentro de la cláusula `extends` de un conditional type. Captura, por pattern matching, una parte del tipo que se está comparando para poder reutilizarla en la rama `true` del conditional.

## Por qué importa

Sin `infer` no hay forma de **extraer** tipos de estructuras existentes sin volver a tiparlas a mano. Es la herramienta detrás de casi todos los utility types nativos: `ReturnType`, `Parameters`, `Awaited`, `InstanceType`, `ConstructorParameters`. En código de librería con APIs flexibles (SDK públicos, ORMs, builders), `infer` evita escribir N variantes del mismo helper.

**Cuándo lo uso:**
- Extraer el tipo de retorno o los parámetros de una función pasada como genérico.
- Desestructurar tipos: primer elemento de una tupla, claves de un objeto, payload de una Promise.
- Parsear template literal types (rutas, queries, eventos tipados).
- Construir helpers genéricos que se adaptan al tipo del consumidor sin pedirle anotaciones extra.

**Cuándo NO lo uso:**
- Si el tipo es conocido y fijo, una alias directo es más legible que `infer`.
- Si el pattern matching no aporta extracción real (caer al default en el else es señal de que estás abusando del conditional).
- Si el tipo final tarda más en leerse que el dato que extrae: usa un type explícito.

## Cómo funciona

### 1. Sintaxis y posición

`infer` **solo** aparece dentro de la cláusula `extends` de un conditional type. Fuera de ahí es error de sintaxis.

### 2. Unificación

TypeScript intenta unificar el tipo de entrada con el patrón. Si encaja, la variable inferida queda disponible en la rama `true`. Si no encaja, se evalúa la rama `false` (donde la variable inferida ya no existe).

### 3. Múltiples `infer` en posiciones múltiples

- En la **misma posición** producen una unión (`X = A | B`).
- En **posiciones contravariantes** (parámetros de función) producen una intersección (`X = A & B`).

### 4. Distributividad sobre uniones

Sobre uniones, el conditional **se distribuye** sobre cada miembro. Para desactivar la distribución envuelve el tipo en una tupla: `[T] extends [U] ? ... : ...`.

### 5. Constraints (TS 4.7+)

`infer X extends Y` añade una constraint al tipo inferido, lo que estrecha el resultado y mejora los errores.

## Ejemplo

```typescript
// 1) ReturnType a mano. El caso mas clasico.
type MyReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

type R1 = MyReturnType<() => number>;           // number
type R2 = MyReturnType<(x: string) => boolean>; // boolean
type R3 = MyReturnType<string>;                 // never (no matchea el patron)

// 2) Awaited recursivo. Util para tipar Promise<Promise<T>>.
type MyAwaited<T> =
  T extends Promise<infer U>
    ? U extends Promise<unknown>
      ? MyAwaited<U>
      : U
    : T;

type A1 = MyAwaited<Promise<Promise<string>>>; // string
type A2 = MyAwaited<number>;                   // number

// 3) Primer elemento de una tupla. Pattern matching estructural.
type First<T extends readonly unknown[]> =
  T extends readonly [infer Head, ...unknown[]] ? Head : never;

type F1 = First<[1, 2, 3]>;   // 1
type F2 = First<readonly []>; // never

// 4) Posiciones contravariantes: interseccion, no union.
type ParamIntersection<T> = T extends {
  a: (x: infer U) => void;
  b: (x: infer U) => void;
} ? U : never;

type P1 = ParamIntersection<{
  a: (x: string) => void;
  b: (x: number) => void;
}>; // string & number  =>  never (porque son incompatibles)

// 5) infer con constraint (TS 4.7+). Estrecha el resultado.
type FirstNumber<T> =
  T extends [infer Head extends number, ...unknown[]] ? Head : never;

type N1 = FirstNumber<[42, "x"]>; // 42
type N2 = FirstNumber<["x", 42]>; // never (Head no es number)

// 6) Template literal parsing. Donde infer brilla de verdad.
type ParseRoute<S extends string> =
  S extends `/${infer Segment}/${infer Rest}`
    ? Segment | ParseRoute<`/${Rest}`>
    : S extends `/${infer Segment}`
      ? Segment
      : never;

type Segments = ParseRoute<"/users/:id/posts/:postId">;
// "users" | ":id" | "posts" | ":postId"
```

## Trade-offs

- **Pro:** tipos extraídos en lugar de duplicados; APIs públicas que se adaptan al consumidor sin pedir anotaciones extra; consistencia entre el tipo declarado y el inferido.
- **Contra:** los errores cuando `infer` no matchea son crípticos (`never` silencioso o caída al default); el debugging requiere desplegar el conditional paso a paso en el TS playground.
- **Cuándo evitar:** si el tipo final tarda más en leerse que el dato que extrae; si el patrón requiere tres conditionals anidados solo para llegar al `infer`; si un type explícito es igual de mantenible.

## Relacionado

- [[Conditional Types]]
- [[Generics]]
- [[Template Literal Types]]
- [[Discriminated Unions]]
- [[Branded Types]]

## Preguntas que respondería en entrevista

- **¿Cómo extraerías el tipo de retorno de una función pasada como genérico sin usar `ReturnType`?** Respuesta:
  ```typescript
  type MyReturn<T> = T extends (...args: any[]) => infer R ? R : never;
  ```
  La clave es el `infer R` en la posición del retorno. Si quieres rechazar no-funciones en compile time, añade el constraint: `T extends (...args: any[]) => any`. Sin el constraint, pasarle `string` simplemente devuelve `never`; con él, ya no compila.
- **¿Qué pasa si declaro `infer U` dos veces dentro del mismo conditional, una en posición de parámetro y otra en posición de retorno?** Respuesta: depende de la **varianza** de la posición. En posiciones **covariantes** (como dos retornos), TS toma la **unión**: `U = A | B`. En posiciones **contravariantes** (parámetros de función), TS toma la **intersección**: `U = A & B`. La razón es semántica: en covariante, "cualquiera de los dos" satisface; en contravariante, debe satisfacer "ambos". Por eso `ParamUnion<{ a: (x: string) => void; b: (x: number) => void }>` da `string & number` = `never`, no `string | number`.
- **¿Por qué `T extends any ? ... : ...` se distribuye sobre uniones, y cómo lo desactivo?** Respuesta: se distribuye porque cuando `T` es un parámetro de tipo **naked** (no envuelto en otra estructura), TS aplica el conditional **miembro a miembro** de la unión y reúne los resultados. Para desactivar, envuelves en tupla: `[T] extends [any] ? ... : ...`. La tupla fuerza a TS a evaluar el conditional con la unión completa como un solo tipo, no miembro a miembro. Esto importa cuando quieres comparar dos uniones como conjuntos (`[A] extends [B]`) en lugar de aplicar una transformación a cada miembro.
- **Implementa `Awaited<T>` a mano usando `infer`, soportando promesas anidadas.** Respuesta:
  ```typescript
  type MyAwaited<T> = T extends Promise<infer U>
    ? U extends Promise<unknown>
      ? MyAwaited<U>
      : U
    : T;
  ```
  Recursión: si el inner `U` es a su vez una Promise, llamada recursiva; si no, return `U`. Si `T` no era Promise para empezar, return `T`. La llamada recursiva está en **posición de cola**, así que TS 4.5+ la optimiza y permite anidamiento profundo sin estallar el límite de recursividad.
- **¿Qué aporta `infer X extends Y` frente a `infer X` y un check posterior?** Respuesta: `infer X extends Y` (TS 4.7+) **estrecha el tipo inferido en el momento del matching**, no después. Sin el constraint, `X` sería el tipo amplio y un check posterior dentro de la rama `true` te daría errores crípticos si no matchea, o un cast forzado. Con `infer X extends Y`: si `X` no satisface `Y`, el conditional cae a la rama `false` directamente, y en la rama `true` queda tipado como `Y` sin más narrowing. Mejor tipo, mejores errores, menos branching anidado. Ejemplo: `[infer Head extends number, ...unknown[]]` rechaza tuplas cuyo primer elemento no sea numérico, sin necesidad de un segundo conditional dentro.

## Fuente

- Total TypeScript Essentials, módulo Conditional Types & Infer
- TypeScript Handbook: Conditional Types > Inferring Within Conditional Types
- TypeScript 4.7 release notes (`infer extends`)
- type-challenges repo (ejercicios `medium` y `hard` clasificados como `#infer`)
