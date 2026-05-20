# Two Sum

#algorithm #status/accepted

**Pattern:** #pattern/hash-map **Difficulty:** #difficulty/easy **Source:** NeetCode 150 / LeetCode #1 **Fecha:** 2026-05-16

## Problema

Dado un array de números, encontrar los dos números que sumen un target específico.

## Input / Output

```
Input:  nums = [4, 5, 6, 7], target = 10
Output: [0, 2]
```

## Mi primera intuición (antes de mirar nada)

- Aquí tenía ya una idea aproximada de qué hacer, era claramente un hash map donde ir guardando las soluciones. Esto en cierto modo me ha perjudicado porque, como mi idea era aproximada, no tenía una solución clara, y no he seguido los pasos habituales de empezar con un brute force e ir optimizando. Eso al final me ha ralentizado.
- Al final he sacado una solución óptima.
- Complejidad estimada: O(n) time / O(n) space

## Solución óptima

- Complejidad time: O(n)
- Complejidad space: O(n)

```typescript
function twoSum(nums: number[], target: number): number[] {
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

Mola mucho la idea de ir guardando resultados y después buscar directamente en un hash map. Esto va a ser muy útil en el futuro. Por ejemplo en [[Group Anagrams]], [[Longest Consecutive Sequence]] o [[Top K Frequent Elements]].

## Trampas / edge cases

- Era sencillo y las restricciones hacían que no hubiera muchas trampas posibles.
- Caso sutil con duplicados que suman el target (`[3, 3]`, target = 6): guardar primero `n` y comprobar el complemento DESPUÉS funciona naturalmente porque al ver el segundo `3`, `seen.has(3)` ya es `true`.

## Aprendizajes

- El uso de `Map` cuando necesitamos un hash map normal. Los métodos de `Map` (`.has`, `.get`, `.set`) hacen todo mucho más idiomático que un objeto plano con `Record`.
- El `for...of` con `entries()` para tener el índice y el valor en el mismo bucle. Ya había olvidado ese patrón en TS.
- Reflejo a interiorizar: aunque "ya intuya" la solución, no saltarme el paso de articular el brute force. El primer ejercicio donde lo salté me costó tiempo, no me lo ahorró.

## Variaciones que existen

- [[Two Integer Sum II]] (input ordenado, permite resolver con two pointers en O(1) space)
- [[Three Integer Sum]] (3Sum, generaliza a triples)

## Patrón aplicado

- [[Hashmap Pattern]]