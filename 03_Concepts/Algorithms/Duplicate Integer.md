# Duplicate Integer

#algorithm #status/accepted

**Pattern:** #pattern/hash-set
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #217
**Fecha:** 2026-05-12

## Definición
[Una frase clara que explique el concepto.]
Buscar duplicados en un listado desordenado de arrays.

## Por qué importa
[Cuándo lo uso, qué problema resuelve, cuándo NO lo uso.]
Nos permite mejorar muchísimo la complejidad del algoritmo por fuerza bruta. Si queremos resolverlo por fuerza bruta, la única solución es ir mirando de 1 en uno y comprobar atrás todos los anteriores. 
Con la solución de un Set, pasamos a una solución lineal de O(n).

## Cómo funciona
Recorremos el array de izquierda a derecha manteniendo un `Set` con todos los números vistos. Para cada nuevo `n`:

1. Si `seen.has(n)` -> ya lo habíamos visto antes -> hay duplicado -> `return true`.
2. Si no -> `seen.add(n)` y seguimos.

Si terminamos el bucle sin encontrar ninguno -> `return false`.

La clave es que `Set.has` y `Set.add` son O(1) amortizado en V8, lo que convierte el clásico "buscar entre los anteriores" (O(n²)) en una sola pasada O(n). El precio es O(n) de espacio extra para el Set.

**Importante:** usar `Set`, no `Map`. Si solo te interesa la pertenencia (no el índice ni el conteo), `Set` es la estructura correcta. Usar `Map<number, number>` aquí es over-engineering y sugiere modelo mental confuso en review.

## Ejemplo
```typescript
export function containsDuplicate(nums: number[]): boolean {
  const seen = new Set<number>();
  for (const n of nums) {
    if (seen.has(n)) {
      return true;
    }
    seen.add(n);
  }
  return false;
}

export default containsDuplicate;
```

## Trade-offs
- **Pro:** O(n) tiempo, early-exit en el primer duplicado encontrado. La mejor solución asintótica cuando puedes usar memoria extra.
- **Contra:** O(n) espacio. No funciona en streams infinitos donde no cabe el Set en memoria.
- **Cuándo evitar:**
  - Si necesitas O(1) espacio y puedes mutar el input -> ordenar in-place y comparar adyacentes (O(n log n) tiempo, O(1) espacio).
  - Si el rango de valores es pequeño y conocido -> bitset (array de booleans de tamaño fijo, O(1) espacio efectivo).
  - Si el array ya está ordenado -> comparar adyacentes en una pasada (O(n) tiempo, O(1) espacio).

## Relacionado
- [[Find the Duplicate Number]] (misma intención, restricciones más duras: O(1) espacio sin mutar input -> requiere Floyd's cycle detection)
- [[Longest Consecutive Sequence]] (también usa `Set` para checks O(1) de pertenencia)
- [[Hashmap Pattern]]

## Preguntas que respondería en entrevista

- **¿Qué complejidad temporal y espacial tiene tu solución y por qué?** Respuesta: **Tiempo O(n)**: un solo pase sobre `nums`. **Espacio O(n)** en el peor caso (todos elementos únicos hasta el final del array, así que el `Set` crece hasta `n`). Las operaciones `Set.has` y `Set.add` son **O(1) amortizado** en V8 (TypeScript / Node) gracias al hashing randomizado interno. Total: O(n) tiempo, O(n) espacio.
- **¿Cómo cambia tu solución si no puedes usar memoria extra?** Respuesta: dos opciones según las restricciones. **(a) Si puedes mutar el input**: ordenar in-place con `nums.sort()` en O(n log n) y comparar pares adyacentes en O(n). Total **O(n log n) tiempo, O(1) espacio extra**. **(b) Si no puedes mutar el input**: brute force con dos bucles anidados, O(n²) tiempo, O(1) espacio. Es el trade-off clásico tiempo vs espacio: sin estructura auxiliar pierdes el O(n).
- **¿Qué cambia si el array ya está sorted?** Respuesta: cambia radicalmente. Con array ordenado basta comparar elementos adyacentes en un solo pase: si `nums[i] === nums[i + 1]` para algún `i`, hay duplicado. **O(n) tiempo, O(1) espacio**. Es uno de los casos donde **two pointers / single pass gana al hash map** porque la estructura ya tiene el invariante que necesitas (elementos iguales están necesariamente contiguos).
- **¿Qué cambia si te piden devolver los duplicados, no solo si existen?** Respuesta: usas un `Set<number>` para los "visited" y otro `Set<number>` para los duplicados encontrados:
  ```typescript
  function findDuplicates(nums: number[]): number[] {
    const seen = new Set<number>();
    const dupes = new Set<number>();
    for (const n of nums) {
      if (seen.has(n)) dupes.add(n);
      else seen.add(n);
    }
    return [...dupes];
  }
  ```
  Si te piden el **conteo** de cada duplicado, cambias el `Set` por `Map<number, number>` con la frecuencia. Misma complejidad: O(n) tiempo, O(n) espacio.
- **¿Por qué `Set` y no `Array.includes`?** Respuesta: porque `arr.includes(x)` es **O(n)** (escanea el array entero), y dentro del bucle eso te llevaría a **O(n²)** total. `Set.has` es O(1) amortizado. Detalle que pilla a junior: "uso un array para no añadir dependencias" sin darse cuenta de que ha matado la complejidad.

## Fuente
- [Duplicate Integer](https://neetcode.io/problems/duplicate-integer/solution)