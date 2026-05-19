# Is Anagram

#algorithm #status/accepted

**Pattern:** #pattern/hash-map
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #
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
- My first approach was sort both strings and compare them
- Complejidad estimada: O(n log n) and 

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
That's a great idea; it doesn't matter what the lengths of the two strings are; you only need to run through them once, and the amount of memory used is always the same. Then you check that array just once. 

## Trampas / edge cases
- 

## Aprendizajes
- 

## Variaciones que existen
- [[Problema similar 1]]
- [[Problema similar 2]]

## Patrón aplicado
- [[Patrón X]]
