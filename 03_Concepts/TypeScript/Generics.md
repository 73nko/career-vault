# Generics

#concept #status/draft

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

Cuatro mecanismos esenciales:

**1. Parámetro de tipo básico.** `<T>` introduce un tipo libre que TS infiere desde los argumentos, o se pasa explícitamente en el call site.

**2. Constraints.** `<T extends U>` restringe qué tipos puede tomar `T`. Sin constraint, dentro del cuerpo de la función `T` se trata como `unknown`: no puedes acceder a propiedades sin haberlas declarado.

**3. Default.** `<T = U>` da un fallback cuando ni la inferencia ni el call site fijan `T`. Útil en tipos públicos de librerías.

**4. Múltiples parámetros con relaciones.** `<T, K extends keyof T>` permite que un parámetro restrinja a otro. Este patrón es el corazón de utility types como `Pick` y de APIs tipo Drizzle.

Sobre inferencia: TS infiere `T` desde el argumento pasado. Si el parámetro de tipo solo aparece en el retorno (no en los argumentos), la inferencia falla y hay que pasarlo explícito: `fn<MyType>(...)`.

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

- Diferencia entre `function identity<T>(x: T): T` y `function identity(x: any): any`. Más allá de la sintaxis: el primero preserva el tipo concreto del call site, el segundo lo borra. `any` desactiva chequeo en ambos lados de la asignación; el generic propaga el tipo.
- ¿Cuándo TS NO puede inferir el tipo genérico y hay que pasarlo explícito? Cuando el parámetro de tipo aparece solo en el retorno y no en los argumentos. Ejemplo clásico: `JSON.parse<T>(s)` requiere pasar `T`.
- ¿Para qué sirve el constraint `<T extends U>`? Para poder usar propiedades de `U` dentro del cuerpo. Sin constraint, `T` se trata como `unknown`.
- ¿Qué problema tiene `<T extends any>`? Mezcla dos cosas distintas: `any` desactiva el chequeo de tipos. Si quieres "cualquier tipo" usa `<T>` sin constraint, o `<T extends unknown>` cuando necesitas el efecto distributivo en conditional types.
- ¿Cuándo eliges generic vs unión de literales? Generic si hay relación entre input y output. Unión literal si los casos son fijos y enumerables.

## Fuente

- TypeScript Handbook, Generics: https://www.typescriptlang.org/docs/handbook/2/generics.html
- Type Challenges: https://github.com/type-challenges/type-challenges
- Effective TypeScript (Dan Vanderkam), capítulos 4 y 5
