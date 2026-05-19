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

**Reglas:**

1. `infer` **solo** aparece dentro de la cláusula `extends` de un conditional type. Fuera de ahí es error de sintaxis.
2. TypeScript intenta unificar el tipo de entrada con el patrón. Si encaja, la variable inferida queda disponible en la rama `true`.
3. Si no encaja, se evalúa la rama `false` (donde la variable inferida ya no existe).
4. **Múltiples `infer X` en la misma posición** producen una unión (`X = A | B`).
5. **Múltiples `infer X` en posiciones contravariantes** (parámetros de función) producen una intersección (`X = A & B`).
6. Sobre uniones, el conditional **se distribuye** sobre cada miembro. Para desactivar la distribución envuelve el tipo en una tupla: `[T] extends [U] ? ... : ...`.
7. **Desde TS 4.7:** `infer X extends Y` añade una constraint al tipo inferido, lo que estrecha el resultado y mejora los errores.

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

- ¿Cómo extraerías el tipo de retorno de una función pasada como genérico sin usar `ReturnType`?
- ¿Qué pasa si declaro `infer U` dos veces dentro del mismo conditional, una en posición de parámetro y otra en posición de retorno? ¿Por qué?
- ¿Por qué `T extends any ? ... : ...` se distribuye sobre uniones, y cómo lo desactivo?
- Implementa `Awaited<T>` a mano usando `infer`, soportando promesas anidadas.
- ¿Qué aporta `infer X extends Y` frente a `infer X` y un check posterior?

## Fuente

- Total TypeScript Essentials, módulo Conditional Types & Infer
- TypeScript Handbook: Conditional Types > Inferring Within Conditional Types
- TypeScript 4.7 release notes (`infer extends`)
- type-challenges repo (ejercicios `medium` y `hard` clasificados como `#infer`)
