# Template Literal Types

#concept #status/done

## Definición

Los Template Literal Types (tipos de plantillas literales) son una de las características más potentes de TypeScript: te permiten usar la misma sintaxis de los strings de JavaScript (los backticks `` ` `` y `${}`) pero a nivel de tipos. El resultado es un tipo string compuesto por interpolación de otros tipos.

## Por qué importa

Permiten construir nuevos tipos de texto combinando tipos existentes, lo que es increíblemente útil para definir patrones de texto exactos: rutas de routers, nombres de eventos, propiedades CSS dinámicas, claves de objetos derivadas. En lugar de tipar como `string` y rezar, capturas la forma exacta del literal.

## Cómo funciona

### 1. Distribución sobre uniones (producto cartesiano)

Cuando pasas una unión de tipos (un *union type*) dentro de una plantilla literal, TypeScript genera automáticamente todas las combinaciones posibles. Es como hacer una multiplicación de conjuntos.

### 2. Transformación de texto (utility types nativos)

TypeScript incluye cuatro utility types intrínsecos para modificar el texto de estos tipos en tiempo de compilación:

- `Uppercase<T>`: todo a mayúsculas.
- `Lowercase<T>`: todo a minúsculas.
- `Capitalize<T>`: primera letra en mayúscula.
- `Uncapitalize<T>`: primera letra en minúscula.

Son intrínsecos (no se pueden replicar a mano en TS puro): el compilador los implementa internamente.

### 3. Pattern matching con `infer`

Cuando se combinan con conditional types e `infer`, los template literal types permiten **parsear strings a nivel de tipo**: extraer parámetros de rutas, nombres de eventos, prefijos, etc. Aquí dejan de ser azúcar sintáctico y se convierten en herramienta de librería.

## Ejemplo

```typescript
// 1) Caso basico: concatenacion con union.
type Entorno = "staging" | "production";
type URL_Api = `https://api.${Entorno}.com`;
// "https://api.staging.com" | "https://api.production.com"

// 2) Distribucion sobre uniones: producto cartesiano explicito.
type Variant = "primary" | "secondary";
type Size = "sm" | "md" | "lg";
type ButtonClass = `btn-${Variant}-${Size}`;
// "btn-primary-sm" | "btn-primary-md" | "btn-primary-lg"
// | "btn-secondary-sm" | "btn-secondary-md" | "btn-secondary-lg"

// 3) Propiedades CSS dinamicas (el caso clasico).
type Side = "top" | "right" | "bottom" | "left";
type PaddingProp = `padding-${Side}`;
// "padding-top" | "padding-right" | "padding-bottom" | "padding-left"

// 4) Combinacion con los 4 utility types nativos.
type Event = "click" | "hover" | "focus";
type Handler = `on${Capitalize<Event>}`;
// "onClick" | "onHover" | "onFocus"

// 5) Pattern matching con infer: extraer parametros de una ruta.
type ExtractParam<Route extends string> =
  Route extends `${string}:${infer Param}/${infer Rest}`
    ? Param | ExtractParam<`/${Rest}`>
    : Route extends `${string}:${infer Param}`
      ? Param
      : never;

type RouteParams = ExtractParam<"/users/:id/posts/:postId">;
// "id" | "postId"

// 6) Constraint con `extends string` para forzar narrowing.
type WithPrefix<S extends string> = `prefix_${S}`;
type Bad = WithPrefix<number>;  // Error: number no es asignable a string
type Good = WithPrefix<"user">; // "prefix_user"
```

## Trade-offs

### Pro

- **Seguridad milimétrica:** permite tipar strings dinámicos exactos (rutas, propiedades CSS, claves de objetos) evitando errores de dedo.
- **Sincronización automática:** si cambia la base de datos o el mapa de webhooks, los strings compuestos se actualizan solos.
- **Excelente autocompletado:** el IDE sugiere exactamente las cadenas válidas mientras escribes.

### Contra

- **Sintaxis compleja:** mezclar plantillas literales con `infer` y conditional types crea código difícil de leer para developers junior.
- **Límite de recursión / unión:** TypeScript tiene un límite estricto para generar combinaciones (por defecto en torno a 100.000 miembros de unión). Si lo pasas, el compilador falla con `"Expression produces a union type that is too complex to represent"`.
- **Solo tiempo de compilación:** no validan datos reales en runtime (JSON de una API, input de usuario). Para eso necesitas Zod o similar.

### Cuándo evitar

- **Datos dinámicos del usuario o APIs:** si el string viene de un formulario o una base de datos externa, este tipo no te protege en ejecución. Ahí necesitas validación runtime.
- **Combinatorias masivas:** evita unir múltiples listas grandes (por ejemplo `Grid_${Columnas}_${Filas}` con muchas columnas y filas). TypeScript arrojará el error *"Expression produces a union type that is too complex to represent"*.
- **Strings simples sin formato:** si un string no sigue un patrón estricto, un `string` genérico o un `enum` tradicional es más que suficiente. No todo necesita ser un template literal type.

## Relacionado

- [[Generics]]
- [[Conditional Types]]
- [[Infer Keyword]]
- [[Discriminated Unions]]
- [[Branded Types]]

## Preguntas que respondería en entrevista

- **¿Cuántas posibilidades genera `` `${A}-${B}` `` si `A` tiene 4 miembros y `B` tiene 3? ¿Por qué TypeScript impone un límite?** Respuesta: **12** (producto cartesiano, 4 × 3). TS impone un límite (~100.000 miembros de unión por defecto) porque cada tipo añadido consume memoria y tiempo en el compilador, y porque las uniones masivas hacen los mensajes de error inmanejables. Pasarlo lanza `"Expression produces a union type that is too complex to represent"`. El motivo es práctico, no teórico: el algoritmo de tipos seguiría siendo correcto, pero el compilador se vuelve insoportablemente lento.
- **¿Cómo extraerías los parámetros de una ruta como `"/users/:id/posts/:postId"` solo a nivel de tipo, sin código en runtime?** Respuesta:
  ```typescript
  type ExtractParams<Route extends string> =
    Route extends `${string}:${infer Param}/${infer Rest}`
      ? Param | ExtractParams<`/${Rest}`>
      : Route extends `${string}:${infer Param}`
        ? Param
        : never;

  type P = ExtractParams<"/users/:id/posts/:postId">; // "id" | "postId"
  ```
  Combinación de template literal type + `infer` + recursión en posición de cola. Es exactamente el patrón detrás de las rutas tipo-seguras en Hono, tRPC y Next.js typed routes.
- **¿Qué hace `Capitalize<T>` por debajo? ¿Por qué los 4 utility types son intrínsecos al compilador?** Respuesta: `Capitalize<T>` toma el primer carácter del string literal y lo pone en mayúscula, dejando el resto intacto. Son **intrínsecos** porque el sistema de tipos de TS no expone primitivas para operar sobre caracteres individuales de un string: no hay `CharAt<S, N>`, no hay `ToUpperCase<C>` para un solo char, no hay iteración carácter a carácter. La transformación tiene que estar implementada en C++/JS dentro del compilador, no en TypeScript puro. Los otros tres (`Uppercase`, `Lowercase`, `Uncapitalize`) tienen la misma razón. Es lo que diferencia "limitación arbitraria" de "decisión deliberada del lenguaje".
- **Dado `` type T = "foo" extends `f${infer X}` ? X : never ``, ¿qué es `T`?** Respuesta: `T = "oo"`. TS unifica `"foo"` con el patrón `` `f${something}` ``, y `X` captura todo lo que sigue a la `f` literal, que es `"oo"`. Si fuera `"foobar"`, `T = "oobar"`. La regla: cuando `infer` aparece en una posición no delimitada por más texto, hace **greedy match** hasta el final del string. Si el patrón fuera `` `f${infer X}b${infer Y}` `` aplicado a `"foobar"`, entonces `X = "oo"`, `Y = "ar"` (matching delimitado).
- **¿Por qué un template literal type sigue siendo solo compile-time? ¿Cuándo conviene complementarlo con validación runtime (Zod)?** Respuesta: porque TS aplica **type erasure**: en runtime los tipos no existen, solo queda JS plano. Un template literal type **no puede** validar un string que entra de fuera (API, formulario, env var, query param). Para eso necesitas validación runtime: Zod, Yup, Valibot, ArkType. Regla práctica: **template literal types para datos internos a la app** (rutas hardcoded, mapas de eventos tipados, claves de objetos derivadas), **Zod (o equivalente) para fronteras de runtime** (input de usuario, network, DB, env). En SDKs públicos serios, usas ambos: el tipo a nivel de TS para el contrato compile-time + un parser Zod cuyo `z.infer<typeof schema>` produce ese mismo tipo. Single source of truth: el schema.

## Fuente

- TypeScript Handbook: [Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
- Total TypeScript Essentials, módulo Template Literal Types
- TypeScript 4.1 release notes (donde se introdujeron)
- type-challenges repo (ejercicios con tag `#template-literal`)
