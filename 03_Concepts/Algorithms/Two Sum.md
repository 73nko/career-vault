# Two Sum

#algorithm #status/accepted

**Pattern:** #pattern/hash-map
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #
**Fecha:** 2026-05-16

## Problema
Dado un array de números, encontrar los dos números que sumen un target específico.

## Input / Output
```
Input: [4,5,6,7], 10
Output: [0,2]
```

## Mi primera intuición (antes de mirar nada)
- Aquí tenía ya una idea aproximada de qué hacer, era claramente un hash map donde ir guardando las soluciones. Esto en cierto modo me ha perjudicado porque como mi idea era aproximada, no tenía una solución clara, y no he seguido los pasos habituales de empezar con un bruteforce e ir optimizando, eso al final me ha relentizado.
  Al final he sacado una solución óptima.
- Complejidad estimada: O(n) time / O(n) space

## Solución óptima
- Complejidad time: O(n)
- Complejidad space: O(n)

```typescript
function twoSum() {
   const seen = new Map<number, number>();

  for (const [i, n] of nums.entries()) {
    const complement = target - n;

    if (seen.has(complement)) {
      return [seen.get(complement)!, i];
    }

    seen.set(n, i);
  }

  throw new Error("No solution found, contract violation");

}
```

## Por qué funciona
Mola mucho la idea de ir guardando resultados y después buscar directamente en un hash map. Esto va a ser muy útil en el futuro. Por ejemplo en [[group anagrams]], [[Longest consecutive sequence]] o [[Top k Frequent elements]]
## Trampas / edge cases
- Era sencillo y las restricciones hacían que no hubiera muchas trampas posibles.

## Aprendizajes
- El uso de map cuándo necesitamos un hash map normal. Los métodos de map hacen todo mucho más idiomático. También el for of con entries para tener el key y valor, ya había olvidado eso. 

## Variaciones que existen
- [[Problema similar 1]]
- [[Problema similar 2]]

## Patrón aplicado
- [[Patrón X]]
