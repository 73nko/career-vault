# MOC: Algoritmos

#moc #algorithms

Punto de entrada al área Algoritmos del vault. Aquí van patrones y los problemas resueltos referenciados.

## Foco Q1

- Arrays / strings hasta que los patrones salgan sin mirar.
- Hash map, two pointers, sliding window y binary search antes de tocar grafos/DP.
- Cada problema debe tener: primera intuición, solución óptima, complejidad, edge cases y "qué diría en entrevista".

## Patrones (foco en estos)

### Ordenación / Sorting
- [[ Merge Sort]]
- [[Quick Sort]]

### Arrays / Strings
- [[Two Pointers Pattern]]
- [[Sliding Window Pattern]]
- [[Prefix Sum Pattern]]
- [[Hashmap Pattern]]

### Búsqueda
- [[Binary Search Pattern]]
- [[Binary Search on Answer]]

### Recursión
- [[Backtracking Pattern]]
- [[Memoization]]

### Árboles
- [[Tree Traversal]]
- [[BFS Pattern]]
- [[DFS Pattern]]
- [[Tree DP]]

### Grafos
- [[BFS Graphs]]
- [[DFS Graphs]]
- [[Topological Sort]]
- [[Union Find]]
- [[Dijkstra]]

### Programación dinámica
- [[1D DP Pattern]]
- [[2D DP Pattern]]
- [[Knapsack Pattern]]
- [[LCS Pattern]]

### Heap / Stack / Queue
- [[Monotonic Stack]]
- [[Top K Pattern]]
- [[Priority Queue]]

## Tracker de progreso

```dataview
TABLE 
  filter(file.tags, (t) => startswith(t, "#pattern/")) as "Patrón",
  filter(file.tags, (t) => startswith(t, "#difficulty/")) as "Dificultad",
  file.ctime as "Fecha"
FROM "03_Concepts/Algorithms"
WHERE contains(file.tags, "#algorithm")
SORT file.ctime DESC
```

## Meta-notas
- [[Cómo abordar un problema desconocido]]
- [[Cómo calcular complejidad en una entrevista]]
- [[Errores típicos que cometo]]
