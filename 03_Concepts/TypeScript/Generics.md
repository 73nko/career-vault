# Generics

#concept #status/done

## Definición

Mecanismo de TypeScript para parametrizar funciones, clases y tipos con uno o más "parámetros de tipo" que se resuelven en el sitio de uso, preservando la relación entre el tipo de entrada y el tipo de salida.

## Por qué importa

Sin generics, mantener la relación entre el tipo que entra y el tipo que sale obliga a una de tres rutas malas: `any` (pierdes type safety), `unknown` con narrowing manual (verboso en cada call site), o N overloads (no escala). Los generics resuelven esto en un solo lugar.

Lo uso cuando:

- El tipo de salida depende del tipo de entrada. Ejemplo: `parse(schema, value)` devuelve el shape inferido del schema.
- Una estructura reutilizable es polimórfica por naturaleza. Ejemplo: `Result<T, E>`, `Cache<K, V>`, `Either<L, R>`.
- Una función trabaja con varias formas de un mismo contrato.

NO lo uso cuando:

- El tipo de retorno es siempre el mismo, independientemente del input. Eso es un `any` disfrazado de generic.
- El parámetro de tipo aparece solo una vez en la firma y no se relaciona con nada. Síntoma claro: el `<T>` no sirve para correlacionar nada. Es ruido.

## Cómo funciona

### 1. Parámetro de tipo básico

`<T>` introduce un tipo libre que TS infiere desde los argumentos, o se pasa explícitamente en el call site.

### 2. Constraints

`<T extends U>` restringe qué tipos puede tomar `T`. Sin constraint, dentro del cuerpo de la función `T` se trata como `unknown`: no puedes acceder a propiedades sin haberlas declarado.

### 3. Default

`<T = U>` da un fallback cuando ni la inferencia ni el call site fijan `T`. Útil en tipos públicos de librerías.

### 4. Múltiples parámetros con relaciones

`<T, K extends keyof T>` permite que un parámetro restrinja a otro. Este patrón es el corazón de utility types como `Pick` y de APIs tipo Drizzle.

### 5. Modificadores modernos (TS 5.x)

- `<const T>` (TS 5.0+): preserva tipos literales en la inferencia, sin que el consumidor tenga que poner `as const` en el call site.
- `NoInfer<T>` (TS 5.4+): inhibe la inferencia desde una posición concreta. Útil cuando un mismo parámetro de tipo aparece en varias posiciones y solo quieres que infiera desde una.

```typescript
// const modifier: la API decide preservar literales.
function literal<const T>(value: T): T { return value; }
const x = literal({ kind: "dog" });
// x: { readonly kind: "dog" }, no { kind: string }

// NoInfer: decidir desde qué posición se infiere T.
function clamp<T extends number>(value: T, min: NoInfer<T>, max: NoInfer<T>): T {
  return value;
}
clamp(5 as 5, 0, 10); // T se infiere a 5, no a 0 | 5 | 10
```

### 6. Inferencia y posición

TS infiere `T` desde el argumento pasado. Si el parámetro de tipo solo aparece en el retorno (no en los argumentos), la inferencia falla y hay que pasarlo explícito: `fn<MyType>(...)`.

## Ejemplo

Un `Result<T, E>` realista, del estilo que vas a usar en el SDK para diferenciar éxito de fallo sin throws:

```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

function safeParse<T>(
  schema: { parse: (input: unknown) => T },
  input: unknown,
): Result<T, Error> {
  try {
    return ok(schema.parse(input));
  } catch (e) {
    return err(e instanceof Error ? e : new Error(String(e)));
  }
}

// El tipo de r.value se infiere desde userSchema sin anotar nada.
const r = safeParse(userSchema, raw);
if (r.ok) {
  r.value; // tipo: lo que devuelva userSchema.parse
}
```

Constraint con `keyof`, el patrón que está detrás de `Pick`, `Omit` y librerías de query:

```typescript
function pick<T, K extends keyof T>(obj: T, keys: K[]): Pick<T, K> {
  const out = {} as Pick<T, K>;
  for (const k of keys) out[k] = obj[k];
  return out;
}

const user = { id: 1, name: "Alex", email: "a@b.com" };
pick(user, ["id", "name"]);   // OK
pick(user, ["id", "phone"]);  // Error: "phone" no es keyof user
```

`K extends keyof T` es lo que hace que TS rechace claves inexistentes en el momento de compilación.

## Trade-offs

- Pro: type safety sin duplicación. Una sola firma cubre N tipos concretos y la información de tipo fluye end-to-end.
- Pro: habilita APIs "mágicas" tipo tRPC, Zod, Drizzle, donde el tipo de salida se deduce del input sin anotaciones.
- Contra: la firma se vuelve densa. `function fn<T, K extends keyof T, V extends T[K]>(...)` solo es legible si conoces el patrón.
- Contra: los mensajes de error de TS sobre generics son notoriamente malos. "Type 'X' is not assignable to type 'T'" con un stack de 6 niveles es habitual.
- Cuándo evitar: si hay un solo caso de uso real, una unión literal o un overload pueden ser más legibles. Generics premature optimization existe y se nota en las code reviews.

## Relacionado

- [[Conditional Types]]
- [[Mapped Types]]
- [[Type Inference]]
- [[Utility Types]]

## Preguntas que respondería en entrevista

- **Diferencia entre `function identity<T>(x: T): T` y `function identity(x: any): any`.** Respuesta: más allá de la sintaxis, el primero **preserva** el tipo concreto del call site (si entra `42`, sale tipado como `42`); el segundo lo **borra** (sale como `any`). `any` desactiva el chequeo en ambos lados de la asignación, así que pierdes type safety en cascada en quien consume el retorno. El generic propaga el tipo end-to-end sin perder información. Es la diferencia entre una API segura y un foot-gun.
- **¿Cuándo TS NO puede inferir el tipo genérico y hay que pasarlo explícito?** Respuesta: cuando el parámetro de tipo aparece **solo en el retorno** y no en los argumentos. Ejemplo clásico: `JSON.parse<T>(s)` no puede inferir `T` desde `s: string`, hay que pasarlo. Lo mismo con `Array.from<T>(iterable)` cuando el iterable no aporta tipo. Si lo ves en tu propia firma, considera: (a) requiere call site explícito, o (b) reformular para que `T` aparezca en argumentos (típicamente pasando un schema o un sample value tipado).
- **¿Para qué sirve el constraint `<T extends U>`?** Respuesta: dos propósitos. **(1) Acceso:** poder usar las propiedades/métodos de `U` dentro del cuerpo de la función o tipo. Sin constraint, `T` se trata como `unknown` y no puedes hacer `t.foo`. **(2) Filtrado:** rechazar tipos que no satisfacen `U` en compile time, sin tener que validar en runtime. `<K extends keyof T>` en `pick` es el ejemplo clásico: rechaza claves inexistentes antes de ejecutar.
- **¿Qué problema tiene `<T extends any>`?** Respuesta: mezcla dos conceptos distintos. `any` **desactiva el chequeo de tipos**, no significa "cualquier tipo". Si quieres "cualquier tipo" (sin restricción real), usa `<T>` sin constraint. Si necesitas el efecto **distributivo** sobre uniones en conditional types, usa `<T extends unknown>`: misma semántica que `<T>` pero más explícito sobre la intención de distribuir. `<T extends any>` queda en tierra de nadie y los linters estrictos (typescript-eslint con `no-explicit-any`) lo van a marcar.
- **¿Cuándo eliges generic vs unión de literales?** Respuesta: **generic** si hay relación entre input y output que quieres preservar (`Result<T, E>`, `Cache<K, V>`, función que pasa el tipo). **Unión literal** si los casos son **fijos y enumerables** (estados de un finite state machine, niveles de log, variantes de UI). Síntoma de que has elegido mal: si tu generic está siempre instanciado con los mismos 3 tipos, era una unión disfrazada. Al revés: si tu unión literal explota en 12 variantes cada vez que añades un caso, debería haber sido un generic.
- **¿Por qué `(x: Dog) => void` no es asignable a `(x: Animal) => void` pero sí al revés?** Respuesta: **varianza**. Los parámetros de función son **contravariantes** (aceptan tipos más generales, no más específicos), los retornos son **covariantes** (devuelven tipos más específicos, no más generales). Si una función espera `(x: Animal) => void`, le puedes pasar una que acepte `(x: Animal) => void` o cualquier supertipo de `Animal` en el parámetro (más genérico = OK), pero NO una que acepte solo `Dog` (más específico = puede romper si le llega `Cat`). Esto importa cuando un generic aparece en posición de parámetro vs retorno: TS decide la varianza por posición y a veces la inferencia se siente "rara" por eso (típico al wrapear callbacks o al componer funciones genéricas).
- **¿Para qué sirve `<const T>` y qué problema resuelve frente a pedirle al usuario que escriba `as const`?** Respuesta: `<const T>` (TS 5.0+) hace que **la API decida** preservar tipos literales en la inferencia, sin trasladar esa carga ergonómica al consumidor. Sin `const T`: `infer({ kind: "dog" })` infiere `{ kind: string }`. Con `const T`: infiere `{ readonly kind: "dog" }`. Patrón común en Zod, tRPC, neverthrow y cualquier librería que infiera el shape literal del argumento. El usuario escribe código natural; la magia ocurre en la firma.
- **¿TypeScript soporta higher-kinded types (HKT)?** Respuesta: **no de forma nativa**. Un HKT sería algo como `<F<_>>` (un parámetro de tipo que es a su vez un constructor de tipos genérico). Sin esto, no puedes escribir un `Functor<F>` o `Monad<M>` genérico sobre cualquier `F` o `M`. Existen workarounds (fp-ts con `URI2HKT`, hkt-toolbelt, ts-toolbelt) que simulan HKTs vía interface registry y lookup, pero son **trucos**, no soporte real del lenguaje. Es la razón principal por la que las librerías FP "puras" en TS resultan más torpes que en Haskell, Scala o PureScript. Saber que no existen, y por qué los workarounds son trucos, es más valioso que conocer los workarounds: te ahorra cinco horas intentando implementar uno antes de aceptar el límite.

## Fuente

- TypeScript Handbook, Generics: https://www.typescriptlang.org/docs/handbook/2/generics.html
- Type Challenges: https://github.com/type-challenges/type-challenges
- Effective TypeScript (Dan Vanderkam), capítulos 4 y 5
