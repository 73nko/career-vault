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

- ¿Cuántas posibilidades genera `` `${A}-${B}` `` si `A` tiene 4 miembros y `B` tiene 3? ¿Por qué TypeScript impone un límite a esta multiplicación?
- ¿Cómo extraerías los parámetros de una ruta como `"/users/:id/posts/:postId"` solo a nivel de tipo, sin código en runtime?
- ¿Qué hace `Capitalize<T>` por debajo? ¿Por qué los 4 utility types de transformación de texto son intrínsecos al compilador y no se pueden replicar en TS puro?
- Dado `` type T = "foo" extends `f${infer X}` ? X : never ``, ¿qué es `T`? ¿Y si fuera `"foobar"`?
- ¿Por qué un template literal type sigue siendo solo compile-time? ¿Cuándo conviene complementarlo con validación runtime (Zod) y por qué?

## Fuente

- TypeScript Handbook: [Template Literal Types](https://www.typescriptlang.org/docs/handbook/2/template-literal-types.html)
- Total TypeScript Essentials, módulo Template Literal Types
- TypeScript 4.1 release notes (donde se introdujeron)
- type-challenges repo (ejercicios con tag `#template-literal`)
