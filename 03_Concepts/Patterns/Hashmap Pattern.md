# Hashmap Pattern

#concept #pattern/hash-map #status/draft

## Definición
Usar una estructura de lookup en O(1) (`Map`, `Set`, o array de tamaño acotado como contador) para evitar recorrer la entrada más de una vez.

## Por qué importa
Convierte O(n²) (búsqueda anidada) en O(n) tiempo a costa de O(n) espacio. Es la primera optimización a considerar cuando el brute force es "para cada elemento, buscar en el resto".

## Variantes que ya he resuelto
- **Store-as-you-scan + complement lookup** → [[Two Sum]]
  Guardas lo visto en `Map<valor, índice>` y, antes de insertar el actual, preguntas si el complementario ya está.
- **"Seen before" / dedupe** → [[Duplicate Integer]]
  `Set` plano; si el elemento ya está, listo.
- **Frequency counter de dominio acotado** → [[Is Anagram]]
  Cuando las keys son finitas (26 letras, dígitos), un `Array(N)` sustituye al `Map` con O(1) espacio real y mejor constante.

## Cuándo evitar (challenge antes de coger Map por reflejo)
- Si los datos están **ordenados** → two pointers o binary search probablemente ganan en espacio.
- Si el dominio es **acotado y pequeño** → counter array (no Map).
- Si necesitas **orden de inserción + lookup** → Map preserva inserción, pero piensa si realmente lo necesitas.
- Si te importa **memoria** y la entrada es enorme → el coste O(n) en espacio puede ser inaceptable.

## Tips concretos (W20)
- En TS, `Map<K,V>` es más idiomático que `Record<string, V>` cuando las keys no son strings literales.
- `for (const [i, n] of arr.entries())` cuando necesitas índice + valor en el scan.
- `seen.get(x)!` con non-null assertion solo después de comprobar `seen.has(x)`.
- Decide al principio: ¿necesitas el **índice** del elemento visto (Two Sum) o solo saber **si existió** (Duplicate Integer)? Map vs Set.

## Trade-offs
- Pro: convierte O(n²) en O(n) tiempo; código directo.
- Contra: O(n) espacio extra; sensible a colisiones en hashes pobres (no relevante en TS estándar).
- Cuándo evitar: ver sección arriba.

## Relacionado
- [[Two Pointers Pattern]] — alternativa O(1) espacio cuando hay orden o simetría
- [[Sliding Window Pattern]] — a menudo combina hashmap + ventana

## Preguntas que respondería en entrevista
- ¿Por qué hash map y no two pointers o sort?
- ¿Qué key estás usando y por qué? ¿Y el valor?
- ¿Qué pasa con el peor caso de hashing? (en lenguajes con hash adversarial)

## Fuente
- 
