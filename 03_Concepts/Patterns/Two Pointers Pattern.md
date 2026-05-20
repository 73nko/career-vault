# Two Pointers Pattern

#concept #pattern/two-pointers #status/done

## Definición
Dos índices recorren una estructura (normalmente un array o string) en paralelo o en direcciones opuestas, evitando crear estructuras auxiliares.

## Por qué importa
Convierte muchos problemas de O(n) espacio o O(n²) tiempo en O(1) espacio / O(n) tiempo cuando hay un invariante que permite moverse desde fuera hacia dentro (o ambos hacia delante) sin perder información.

## Cómo funciona
- **Convergente:** `left` empieza en 0, `right` en `n-1`. Se acercan al centro. Útil cuando la estructura tiene simetría o un orden que permite descartar la mitad.
- **Paralelo / mismo sentido:** ambos avanzan, uno marca la frontera "válida" y el otro explora. Base del sliding window.

## Ejemplo
```typescript
// Convergente: ver Is Palindrome
// Skip + comparar + avanzar ambos
```

## Trade-offs
- Pro: O(1) espacio extra; código compacto.
- Contra: requiere que el problema tenga estructura aprovechable (sorted, palíndromo, particionable).
- Cuándo evitar: cuando necesitas acceso aleatorio o tracking de estado complejo entre punteros.

## Trampas recurrentes
- Olvidar el guard `left < right` dentro de los `while` internos de skip → overshoot.
- Off-by-one al avanzar después de comparar.

## Problemas que aplican este patrón
- [[Is Palindrome]]

## Relacionado
- [[Sliding Window Pattern]]

## Preguntas que respondería en entrevista

- **¿Por qué dos punteros y no hash map?** Respuesta: dos punteros gana cuando hay **orden o simetría** aprovechable en la estructura. Hash map cuesta O(n) espacio; dos punteros, O(1). En un array sorted, los punteros convergentes resuelven "encontrar par con suma X" en O(n) sin estructura auxiliar. En un palíndromo, convergentes comparan extremos sin necesidad de almacenar el reverso. Regla práctica: si los datos **NO tienen orden ni simetría**, hash map. Si **SÍ**, dos punteros suele ganar en espacio y a menudo en constante.
- **¿Qué invariante mantienes mientras avanzan?** Respuesta: depende de la variante. **Convergentes:** "todos los pares (i, j) con i fuera de [left, right] o j fuera de [left, right] ya han sido considerados y descartados". Cada movimiento de un puntero descarta una región del espacio de búsqueda sin recorrerla. **Mismo sentido (sliding window):** "la ventana [left, right] satisface la propiedad P en todo momento" (variante expand/contract), o "[left, right] es el mejor candidato observado hasta aquí" (shrink-free). Articular el invariante en voz alta durante la entrevista es la señal de que entiendes **por qué** el algoritmo funciona, no solo cómo. Sin invariante claro, es búsqueda exhaustiva disfrazada.

## Fuente
- 
