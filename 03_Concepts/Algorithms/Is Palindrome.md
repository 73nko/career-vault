# Is Palindrome

#algorithm #status/accepted

**Pattern:** #pattern/two-pointers
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #125
**Fecha:** 2026-05-19

## Problema
Dado un string, devuelve si es o no un palindromo.

## Input / Output
```
Input: "Was it a car or a cat I saw?")
Output: true
```

## Mi primera intuición (antes de mirar nada)
- La primera intuición obvia: copias el string, le quitas los no-alfanuméricos, lo pones en minúsculas, le haces reverse y comparas con el original. Es la opción de brute force por defecto.
- Complejidad estimada (brute force): O(n) time / O(n) space (el reverse genera un string nuevo).
- La optimización es two pointers in-place: misma O(n) time, pero O(1) space porque no se copia el string.

## Solución óptima
- Complejidad time: O(n)
- Complejidad space: O(1)

```typescript
export function isPalindrome(s: string): boolean {
  let left = 0;
  let right = s.length - 1;

  while (left < right) {
    while (left < right && !isAlphaNum(s[left]!)) left++;
    while (left < right && !isAlphaNum(s[right]!)) right--;
    if (s[left]!.toLowerCase() !== s[right]!.toLowerCase()) return false;
    right--;
    left++;
  }

  return true;
}

function isAlphaNum(c: string): boolean {
  const code = c.charCodeAt(0);
  return (
    (code >= 48 && code <= 57) ||  // 0-9
    (code >= 65 && code <= 90) ||  // A-Z
    (code >= 97 && code <= 122)    // a-z
  );
}
```

## Por qué funciona
Tres ventajas sobre el brute force "reverse and compare":

1. **Ahorra espacio.** No clono el string ni creo una versión limpiada/reversada. Los dos punteros caminan sobre el string original; solo necesito dos índices (O(1) space real).
2. **Early-exit y short-circuit.** En cuanto los dos caracteres comparados difieren, devuelvo `false` sin terminar de recorrer. El brute force tiene que reversar el string entero antes de empezar a comparar, no puede salir antes.
3. **Salta los no-alfanuméricos in-place.** Los dos `while` internos avanzan los punteros sobre caracteres irrelevantes sin tocar memoria nueva. Es el equivalente "in-place" del `replace(/[^a-z0-9]/gi, "")` que haría el brute force.

## Trampas / edge cases
- **El regex `\W` incluye el guion bajo `_`**. Es decir, `\w` matchea `[A-Za-z0-9_]`. Si quieres "alfanumérico estricto" la única opción correcta es `/[^a-z0-9]/gi` con rangos explícitos. Esto me hizo perder tiempo en mi primer intento.
- **String vacío** (`""`) -> true. El loop no entra (left = 0, right = -1, `left < right` falso) y devuelve true. Correcto: un string vacío es trivialmente palíndromo.
- **String con solo caracteres no-alfanuméricos** (`" "`, `".,!"`) -> true. Los dos `while` internos avanzan los punteros hasta cruzarse, el `if` no se evalúa, devuelve true. Correcto: tras limpiar queda vacío.
- **Punteros se cruzan dentro de los `while` de skip**. La guarda `left < right` dentro de los while internos es crítica: sin ella, podrías terminar con `left > right` y comparar caracteres fuera de la sección válida.
- **Case sensitivity**: aplicar `toLowerCase()` solo al comparar (carácter por carácter) en lugar de al string entero es lo que mantiene O(1) space.

## Aprendizajes
- **Trap del regex `\W`**: no sabía que incluye el guion bajo. Lección permanente: cuando quiera "alfanumérico estricto" usar rangos explícitos `[a-z0-9]`. `\w` y `\W` siempre incluyen `_`.
- **Two pointers convergentes** es el patrón base para muchos problemas. Aprenderse la silueta `while (left < right) { ...; left++; right--; }` porque vuelve en Two Sum II, 3Sum, Container With Most Water, etc.
- **El skip in-place de caracteres irrelevantes** es la técnica que convierte un O(n) space en O(1) space. Reutilizable cuando el problema permite "saltar" elementos durante el recorrido.
- Reflejo a interiorizar: cuando declares O(1) space, audita el código: ¿estoy creando algún string/array/map de tamaño n? Si la respuesta es sí, es O(n) space, no O(1).

## Variaciones que existen
- [[Two Integer Sum II]] (Two Sum II, NC #11) - mismo patrón two pointers convergentes sobre array ordenado.
- [[Three Integer Sum]] (3Sum, NC #12) - extensión a triples con un puntero fijo + dos convergentes.
- [[Max Water Container]] (Container With Most Water, NC #13) - two pointers convergentes optimizando área.
- "Valid Palindrome II" (LC, no en NC150) - extensión: ¿es palíndromo si puedes borrar **un** carácter? Sigue siendo two pointers, pero con backtracking limitado cuando hay mismatch.

## Patrón aplicado
- [[Two Pointers Pattern]]
