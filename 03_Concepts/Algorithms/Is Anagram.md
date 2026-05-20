# Is Anagram

#algorithm #status/accepted

**Pattern:** #pattern/hash-map
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #242
**Fecha:** 2026-05-14

## Problema
Given two strings `s` and `t`, return `true` if the two strings are anagrams of each other, otherwise return `false`.

An **anagram** is a string that contains the exact same characters as another string, but the order of the characters can be different.

## Input / Output
```javascript
Input: s = "racecar", t = "carrace"
Output: true
```

## Mi primera intuición (antes de mirar nada)
- My first approach was sort both strings and compare them.
- Complejidad estimada (sort approach): O(n log n) time / O(n) space (split + sort genera arrays nuevos).
- Luego me di cuenta de que existe la versión O(n) con un counter de frecuencias (array[26] o `Map`), que además es O(1) space si fijo el alfabeto a `a-z`.

## Solución óptima
- Complejidad time: Best solution is O(n)
- Complejidad space: O(1) // String of 26 elements

```typescript
export function isAnagram(s: string, t: string): boolean {
  if (s.length !== t.length) return false;

  const counts = new Array(26).fill(0);

  const A = "a".charCodeAt(0);
  for (let i = 0; i < s.length; i++) {
    counts[s.charCodeAt(i) - A]++;
    counts[t.charCodeAt(i) - A]--;
  }

  return counts.every((c) => c === 0);
}
```

## Por qué funciona
La clave: dos strings son anagramas si y solo si tienen **exactamente las mismas frecuencias por carácter**. Eso lo puedo medir en una sola pasada manteniendo un contador.

El truco elegante es **incrementar para `s` y decrementar para `t` en el mismo bucle**: si los dos strings tienen las mismas frecuencias, al final todos los contadores quedan en 0. Si en algún punto difieren, algún contador queda distinto de 0.

Ventajas vs sort:
- O(n) en lugar de O(n log n).
- O(1) space (alfabeto fijo de 26 letras minúsculas).
- Una sola pasada en lugar de dos sorts + comparación.

El early-exit `if (s.length !== t.length) return false` ahorra el bucle entero cuando las longitudes ya descartan ser anagramas.

## Trampas / edge cases
- **Longitudes distintas** -> false inmediato. Sin ese check el counter quedaría desbalanceado, daría false igualmente, pero malgastas O(n) por nada.
- **Strings vacíos** (`"", ""`) -> true (ambos son anagrama trivial el uno del otro). Mi código lo maneja porque el bucle no entra y `counts.every(c => c === 0)` es true.
- **Mayúsculas y minúsculas**: LeetCode asume lowercase. Si el contrato cambiara a case-insensitive, habría que normalizar con `.toLowerCase()` antes (O(n) extra constante).
- **Unicode**: la solución de `Array(26)` asume alfabeto `a-z`. Si el input puede tener caracteres unicode, hay que usar `Map<string, number>` (O(k) space donde k es el tamaño del alfabeto efectivo).

## Aprendizajes
- El patrón **frequency counter** es la versión hash-map para "compara composiciones de dos colecciones". Reutilizable en muchos problemas (Group Anagrams, Find All Anagrams in a String, Valid Sudoku).
- El truco de **incrementar/decrementar en el mismo bucle** es elegante. Evita mantener dos contadores y compararlos al final. Funciona porque la propiedad "todos los contadores son 0" es equivalente a "las frecuencias son iguales".
- Cuando el alfabeto es fijo y pequeño (26 letras), un `Array(26)` indexado por charcode es **O(1) space efectivo**. Esa optimización solo aplica si el contrato del problema fija el alfabeto. Si no, vuelve a `Map<string, number>`.
- Lección estratégica: "simpler" no es lo mismo que "best". El sort-and-compare es más corto pero peor por Big O. En entrevista, el counter es la respuesta esperada; mencionar sort como alternativa "para producción donde la legibilidad pesa más" suma signal.

## Variaciones que existen
- [[Anagram Groups]] (Group Anagrams, NC #4) - extiende el patrón: agrupar strings por su firma de frecuencias.
- [[Top K Elements In List]] (Top K Frequent Elements, NC #5) - mismo counter pero ahora pides los K más frecuentes.
- "Find All Anagrams in a String" (no en NC150 core) - sliding window de counters comparados con el target.

## Patrón aplicado
- [[Hashmap Pattern]] (en su forma específica de "frequency counter", con array fijo cuando el alfabeto lo permite)
