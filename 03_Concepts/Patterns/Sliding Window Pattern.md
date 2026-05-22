# Sliding Window Pattern

#concept #pattern/sliding-window #status/done

## Definición

Mantener una subestructura contigua (ventana) sobre una secuencia lineal mediante dos punteros (`left` y `right`) que delimitan sus límites. En lugar de recalcular la propiedad de la ventana desde cero en cada paso, se actualiza de manera incremental eliminando el elemento que sale por la izquierda e incluyendo el que entra por la derecha.

## Por qué importa

Reduce la complejidad temporal de O(n²) o O(n³) (generar todas las subcadenas o subarreglos posibles) a O(n) lineal. Transforma operaciones repetitivas en un único pase continuo aprovechando la información del estado inmediatamente anterior.

**Argumento de complejidad amortizada:** cada elemento del array entra y sale de la ventana como máximo una vez en las variantes dinámicas, o no se reprocesa nunca en la variante fija. El coste total amortizado es O(n) incluso si en una iteración concreta el puntero `left` avanza varias posiciones. Esta es la respuesta a "demuéstrame que es O(n) y no O(n²)" cuando lo apriete el entrevistador.

## Variantes

### 1. Ventana de tamaño fijo (Fixed Size)

El tamaño de la ventana `k` es constante. `right` avanza y `left` le sigue a distancia fija (`left = right - k + 1`). Útil para promedios móviles, subarreglos de tamaño exacto, K-análisis.

```typescript
// Maximum sum of k consecutive elements.
function maxSumOfK(arr: number[], k: number): number {
  let windowSum = 0;
  for (let i = 0; i < k; i++) windowSum += arr[i];

  let best = windowSum;
  for (let right = k; right < arr.length; right++) {
    windowSum += arr[right] - arr[right - k];
    best = Math.max(best, windowSum);
  }
  return best;
}
```

Problemas canónicos: Maximum Average Subarray I, Find All Anagrams in a String, Contains Duplicate II.

### 2. Ventana dinámica con expansión / contracción continua

El tamaño cambia según se cumpla o no una restricción. El bucle externo expande `right`; cuando la condición se rompe, un bucle interno contrae `left` hasta restablecerla. La ventana puede crecer y decrecer libremente.

```typescript
// Longest substring without repeating characters (forma canonica).
function lengthOfLongestSubstring(s: string): number {
  const inWindow = new Set<string>();
  let left = 0;
  let best = 0;

  for (let right = 0; right < s.length; right++) {
    while (inWindow.has(s[right])) {
      inWindow.delete(s[left]);
      left++;
    }
    inWindow.add(s[right]);
    best = Math.max(best, right - left + 1);
  }
  return best;
}
```

Problemas canónicos: Longest Substring Without Repeating Characters, Minimum Window Substring, Fruit Into Baskets, Longest Substring with At Most K Distinct Characters.

### 3. Ventana dinámica con tamaño máximo histórico (Shrink-free)

La ventana crece cuando la condición es válida, pero cuando se invalida **no se contrae hasta ser válida**: simplemente se desplaza manteniendo el tamaño máximo alcanzado. La respuesta sale de `arr.length - left` al final, o se trackea con `best` durante el loop.

Funciona porque solo te interesa el **máximo histórico**, no contar todas las ventanas válidas. Es la optimización que la mayoría de gente no ve al resolver "Longest Repeating Character Replacement", y es exactamente el tipo de detalle que un entrevistador staff te va a empujar a encontrar.

```typescript
// Longest Repeating Character Replacement.
function characterReplacement(s: string, k: number): number {
  const count = new Map<string, number>();
  let left = 0;
  let maxFreq = 0;

  for (let right = 0; right < s.length; right++) {
    count.set(s[right], (count.get(s[right]) ?? 0) + 1);
    maxFreq = Math.max(maxFreq, count.get(s[right])!);

    // Si la ventana excede el presupuesto, deslizamos sin encoger.
    if (right - left + 1 - maxFreq > k) {
      count.set(s[left], count.get(s[left])! - 1);
      left++;
    }
  }
  return s.length - left;
}
```

Problemas canónicos: Longest Repeating Character Replacement, Permutation in String, Max Consecutive Ones III.

## Cuándo aplicar (trigger verbal)

Si el enunciado contiene alguna de estas formas, piensa sliding window antes que nada:

- "Longest / shortest **substring** o **subarray** que..."
- "Maximum / minimum **sum of k consecutive**..."
- "All **anagrams** of P in S" / "**Permutations** in a string..."
- "At most K distinct..." / "At least K of..."
- "**Contiguous** subarray con propiedad X"

Si en lugar de "contiguo" lees "subsecuencia" o "cualquier combinación", no es sliding window: probablemente sea DP o backtracking.

## Cuándo evitar (Challenge antes de usar por reflejo)

- Si los elementos requeridos **no son contiguos**. Si el problema permite saltarse elementos o exige subsecuencias dispersas, este patrón no sirve.
- Si el arreglo **no está ordenado pero el resultado depende del orden numérico de los valores** y no de sus posiciones originales.
- Si necesitas evaluar combinaciones de pares que no forman un rango intermedio (ahí buscas Two Pointers convergentes o Hash Map).

## Tips concretos

- **Cálculo de longitud:** el tamaño de la ventana actual siempre se calcula como `right - left + 1`. Grábatelo a fuego para evitar errores de *off-by-one*.
- **Combinación con Hash Maps:** las ventanas dinámicas complejas suelen necesitar un `Map` o un array contador para registrar las frecuencias de los elementos *dentro* de la ventana actual.
- **Evita mutaciones costosas:** si necesitas verificar si la ventana es válida, no uses `slice()` o `substring()` dentro del bucle. Eso destruye el beneficio de rendimiento transformando el algoritmo en O(n * k). Modifica variables de estado numéricas o contadores en su lugar.
- **Motor principal:** usa `for (let right = 0; right < arr.length; right++)` y maneja el puntero `left` de manera reactiva.

## Bugs típicos

- **Olvidar actualizar el estado al contraer.** Cuando `left` avanza, hay que decrementar o eliminar la frecuencia de `arr[left]` del map. Olvidarlo es la causa #1 de soluciones que dan respuestas mayores que la real.
- **`>` vs `>=` en la condición de contracción.** Una iteración de más o de menos cambia totalmente el resultado. Si el problema permite "exactamente K" vs "como máximo K", revisa el operador.
- **Estado mutado antes de validar.** Si añades `arr[right]` al map y luego validas con `right - left + 1`, asegúrate de que la validación se hace después de la inserción, no antes.
- **No vaciar entradas con valor 0.** En `Map`, una clave con valor 0 sigue ocupando el `size`. Si tu condición depende de `map.size`, hay que `delete` cuando el contador llega a 0.

## Trade-offs

- **Pro:** optimiza radicalmente el tiempo a O(n) manteniendo un control estricto sobre rangos contiguos.
- **Contra:** puede aumentar la complejidad cognitiva del código debido a la gestión simultánea de dos punteros y condiciones de parada. Si se combina con estructuras auxiliares para el estado de la ventana, puede requerir hasta O(n) de espacio.

## Relacionado

- [[Two Pointers Pattern]]: la ventana deslizante es técnicamente una variante de dos punteros que se mueven en la misma dirección, a diferencia de los punteros convergentes (extremos al centro).
- [[Hash Map Pattern]]: frecuentemente usado como la estructura que valida el estado interno de la ventana.
- [[Longest Substring Without Duplicates]]: ejemplo canónico de la variante 2.

## Preguntas que respondería en entrevista

- **Implementa Longest Substring Without Repeating Characters y justifica por qué tu solución es O(n) y no O(n²).** Respuesta: amortización. Cada carácter entra y sale del set como máximo una vez, así que el trabajo total a lo largo del loop es lineal aunque haya un `while` anidado.
- **En Longest Repeating Character Replacement, ¿por qué la ventana no necesita contraerse cuando deja de ser válida?** Respuesta: solo nos interesa el máximo histórico, no enumerar ventanas válidas. Mantener el tamaño máximo y deslizar es suficiente, porque ninguna ventana más pequeña va a mejorar el resultado.
- **Si te piden devolver el substring real y no solo su longitud, ¿qué cambia en tu solución?** Respuesta: guardar `(left, right)` cuando se actualiza el máximo, y al final hacer `s.slice(savedLeft, savedRight + 1)`. El loop principal no cambia.
- **¿Cómo cambia tu solución de "at most K distinct" para responder "exactly K distinct"?** Respuesta: `atMost(K) - atMost(K - 1)`. Truco clásico que aparece en variantes (Subarrays with K Different Integers).
- **¿Cuál es la condición exacta que determina que tu ventana se expanda o se contraiga, y cómo eliges entre las dos variantes dinámicas?** Meta: depende de si buscas máximo o mínimo, y de si la restricción se viola al añadir o al quitar. Para máximo histórico sin necesidad de enumerar válidas, shrink-free. Para mínimo o para enumerar ventanas, expand / contract.

## Fuente

- NeetCode 150: Sliding Window playlist ([neetcode.io/practice](https://neetcode.io/practice))
- LeetCode editorials de los problemas canónicos listados en cada variante
- *Algorithm Design Manual* (Skiena), capítulos de strings y arrays
- Educative.io: Grokking the Coding Interview, módulo "Sliding Window"
