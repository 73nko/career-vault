# Duplicate Integer

#concept #status/draft

## Definición
[Una frase clara que explique el concepto.]
Buscar duplicados en un listado desordenado de arrays.

## Por qué importa
[Cuándo lo uso, qué problema resuelve, cuándo NO lo uso.]
Nos permite mejorar muchísimo la complejidad del algoritmo por fuerza bruta. Si queremos resolverlo por fuerza bruta, la única solución es ir mirando de 1 en uno y comprobar atrás todos los anteriores. 
Con la solución de un Set, pasamos a una solución lineal de O(n).

## Cómo funciona
[Detalle técnico. Diagramas si hace falta.]

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
- Pro: 
- Contra: 
- Cuándo evitar: 

## Relacionado
- [[]]
- [[]]

## Preguntas que respondería en entrevista
- 
- 

## Fuente
- [Duplicate Integer](https://neetcode.io/problems/duplicate-integer/solution)