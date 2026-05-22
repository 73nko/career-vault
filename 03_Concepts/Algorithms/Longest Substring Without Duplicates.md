# Longest Substring Without Duplicates

#algorithm #status/accepted

**Pattern:** #pattern/sliding-window
**Difficulty:** #difficulty/medium
**Source:** NeetCode 150 / LeetCode #3
**Fecha:** 2026-05-22

## Problema
Dado un string `s`, devolver la longitud del substring contiguo más largo que no contiene caracteres repetidos. Primer Medium del NC150.

## Input / Output
```
Input:  s = "abcabcbb"
Output: 3   // "abc"

Input:  s = "bbbbb"
Output: 1   // "b"

Input:  s = "pwwkew"
Output: 3   // "wke" - "pwke" no vale, no es contiguo
```

## Mi primera intuición (antes de mirar nada)
- Brute force: doble bucle generando todos los substrings (`start`, `end`) y, para cada uno, comprobar con un `Set` si tiene duplicados.
- Complejidad brute force: cuidado, **no es O(n^2)**. Hay O(n^2) substrings y verificar cada uno cuesta O(n) (el `slice` mas recorrerlo con el `Set`). Total **O(n^3) time / O(n) space**. En mi primer intento lo declaré O(n^2): el `slice` y el escaneo del substring son dos factores de `n` escondidos.
- El enunciado pide "substring contiguo más largo con propiedad X" -> trigger casi automático de sliding window.
- Complejidad estimada del óptimo: O(n) time / O(n) space.

## Solución óptima
- Complejidad time: O(n) - cada carácter se procesa una vez.
- Complejidad space: O(n) en el peor caso, realmente O(min(n, m)) con `m` = tamaño del alfabeto (el `Map` no crece más allá de caracteres distintos).

```typescript
export function lengthOfLongestSubstring(s: string): number {
  const lastSeenIndex = new Map<string, number>();

  let left = 0;
  let right = 0;
  let maxLength = 0;
  for (const char of s) {
    const previousIndex = lastSeenIndex.get(char);

    if (previousIndex !== undefined && previousIndex >= left) {
      left = previousIndex + 1;
    }

    lastSeenIndex.set(char, right);

    const currentLength = right - left + 1;
    maxLength = Math.max(maxLength, currentLength);

    right++;
  }

  return maxLength;
}
```

Variante con `for` indexado, sin contador manual:

```typescript
export function lengthOfLongestSubstring(s: string): number {
  const lastSeenIndex = new Map<string, number>();
  let left = 0;
  let maxLength = 0;

  for (let right = 0; right < s.length; right++) {
    const char = s[right]!;
    const previousIndex = lastSeenIndex.get(char);

    if (previousIndex !== undefined && previousIndex >= left) {
      left = previousIndex + 1;
    }

    lastSeenIndex.set(char, right);
    maxLength = Math.max(maxLength, right - left + 1);
  }

  return maxLength;
}
```

Usé `for...of` en mi versión porque con `noUncheckedIndexedAccess` el `char` viene tipado como `string` garantizado, sin tener que poner `s[right]!`. El precio es llevar `right` como contador manual al lado del iterador: dos mecanismos de iteración para una sola pasada. La versión indexada elimina ese ruido a costa del `!`. Es decisión de tipos, no de rendimiento: ambas son O(n) y un `for` indexado no es más lento en V8 (sobre strings, `for...of` hace incluso trabajo extra porque itera por code point).

## Las dos variantes del sliding window
Este problema tiene dos soluciones O(n) y conviene conocer las dos:

1. **Set + `while` que encoge (forma canónica).** Mantienes un `Set` de los caracteres en la ventana. Cuando `s[right]` ya está dentro, encoges `left` de uno en uno (`set.delete(s[left]); left++`) hasta que el duplicado salga. Es la variante 2 de [[Sliding Window Pattern]].
2. **Map de último índice + salto (la que usé).** Guardas el último índice visto de cada carácter. Cuando reaparece, `left` **salta** directamente a `previousIndex + 1` en vez de avanzar de uno en uno.

Las dos son O(n) amortizado. La del `Map` ahorra el `while` interno: `left` nunca re-escanea posiciones. Es la sub-variante "optimizada" y la respuesta preferida si el entrevistador pregunta "¿puedes evitar el bucle anidado?".

## Por qué funciona
La ventana `[left, right]` mantiene siempre el invariante "ningún carácter repetido dentro". `right` la expande un carácter por iteración. Cuando el carácter entrante ya estaba en la ventana, hay que recolocar `left` justo después de su aparición anterior para restaurar el invariante.

El `Map` da en O(1) la última posición de cualquier carácter, así que reajustar `left` es un salto directo, no una búsqueda.

## Trampas / edge cases
- **El guard `previousIndex >= left` es LA dificultad del problema.** Un carácter puede haberse visto antes pero **fuera** de la ventana actual (a la izquierda de `left`). Sin el guard harías `left = previousIndex + 1` incondicionalmente y moverías `left` **hacia atrás**, reintroduciendo caracteres ya descartados.
  - Traza `"abba"`: al llegar a la segunda `'a'` (índice 3), el `previousIndex` de `'a'` es 0, pero `left` ya está en 2 (lo movió la segunda `'b'`). `0 >= 2` es falso -> `left` no se mueve -> resultado 2. Correcto.
  - Sin el guard: `left` saltaría a 1, la ventana sería `"bba"` con la `'b'` repetida -> resultado 3. **Mal.**
- **Tests que no ejercen el guard.** `"abcabcbb"`, `"bbbbb"`, `"AaBbCcDd"`, `""`, `"a"` dan el mismo resultado con guard y sin guard. Una suite hecha solo con esos pasa en verde aunque borres el guard. Los tests que de verdad lo protegen: `"abba"` -> 2, `"tmmzuxt"` -> 5, `"pwwkew"` -> 3.
- **String vacío** (`""`) -> 0. El bucle no entra, `maxLength` se queda en 0.
- **Un solo carácter** (`"a"`) -> 1.
- **Case sensitivity.** La solución distingue mayúsculas de minúsculas: `"AaBbCcDd"` -> 8 (las 8 son distintas). No es case-insensitive.

## Aprendizajes
- **El guard contra el retroceso de `left`.** En cualquier sliding window con "salto" (no con encogido incremental), hay que verificar que la posición a la que saltas cae **dentro** de la ventana actual. Reflejo a interiorizar: cuando muevas un puntero con un salto calculado, pregúntate "¿puede este salto ir hacia atrás?".
- **Complejidad declarada distinta de la implementada.** Declaré el brute force O(n^2) cuando era O(n^3): el `slice` y el escaneo del substring son factores de `n` ocultos. Auditar: contar los bucles anidados Y cada operación O(n) dentro de ellos (`slice`, `includes`, otro recorrido).
- **`for...of` vs `for` indexado es decisión de tipos, no de rendimiento.** `for...of` ahorra el `!` con `noUncheckedIndexedAccess`. No es "más rápido": en V8 un `for` indexado es igual o más rápido, y sobre strings `for...of` hace trabajo extra (itera por code point, decodifica UTF-16). El motivo legítimo para elegirlo aquí es ergonomía de tipos.
- **Conocer las dos variantes** (Set-encoge vs Map-salta) es señal. Resolver es la mitad; saber que existe una versión sin el bucle anidado y por qué es equivalente en Big-O es la otra mitad.

## Variaciones que existen
- [[Longest Repeating Character Replacement]] (NC, sliding window con presupuesto de `k` reemplazos; usa la variante "shrink-free").
- [[Permutation In String]] (NC, ventana de tamaño fijo comparando contadores de frecuencia).
- [[Minimum Window Substring]] (NC, ventana dinámica buscando el **mínimo** que cubre un target).
- [[Buy and Sell Crypto]] (NC, el sliding window más simple: sin estructura auxiliar).
- "Longest Substring with At Most K Distinct Characters" (LC, no en NC150 core) - misma silueta, la restricción es "≤ k caracteres distintos".

## Patrón aplicado
- [[Sliding Window Pattern]] (variante 2: ventana dinámica con expansión/contracción; mi solución es la sub-variante "Map de último índice + salto").
