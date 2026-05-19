# Is Palindrome

#algorithm #status/accepted

**Pattern:** #pattern/
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #
**Fecha:** 2026-05-19

## Problema
Dado un string, devuelve si es o no un palindromo.

## Input / Output
```
Input: "Was it a car or a cat I saw?")
Output: true
```

## Mi primera intuición (antes de mirar nada)
- La primera intuición obvia. Copias, remueves alfanuméricos, le haces un reverse y checkeas. Es la opción de brute force por defecto 
- Complejidad estimada: Complex O(n) / space O(n)

## Solución óptima
- Complejidad time: O(n)
- Complejidad space: O(1)

```typescript
export function isPalindrome(s: string): boolean {
  let left = 0;
  let right = s.length - 1
  
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
Primero que ahorra espacio. Las opciones obvias de fuerza bruta obligan a crear un nuevo string.
Segundo, sale en el momento en que llega al centro y hemos comprobado todo el string. Otras posibilidades obligan a mirar todo el string.

## Trampas / edge cases
- Cuidado con los alfanuméricos. Me ha caído la trampa ahí.
- Cuidado con como los saltamos.

## Aprendizajes
- No sabía que el pattern: "replace(/\W/g, "")" que había usado inicialmente, no funciona con `_`. Muy útil saberlo.

## Variaciones que existen
- [[Problema similar 1]]
- [[Problema similar 2]]

## Patrón aplicado
- [[Two Pointers Pattern]]