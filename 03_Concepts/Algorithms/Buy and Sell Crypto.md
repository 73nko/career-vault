# Buy and Sell Crypto

#algorithm #status/accepted

**Pattern:** #pattern/sliding-window
**Difficulty:** #difficulty/easy
**Source:** NeetCode 150 / LeetCode #121
**Fecha:** 2026-05-20

## Problema
Dado un array de precios donde cada elemento es el precio de un activo en un día consecutivo, encontrar el beneficio máximo posible comprando en un día y vendiendo en otro día **posterior**. Si no hay beneficio posible (los precios solo bajan), devolver 0.

## Input / Output
```
Input:  prices = [10, 1, 5, 6, 7, 1]
Output: 6
// Comprar en día 1 (precio = 1), vender en día 4 (precio = 7), profit = 6

Input:  prices = [10, 8, 7, 5, 2]
Output: 0
// Estrictamente decreciente, no hay trade posible
```

## Mi primera intuición (antes de mirar nada)
- Identifiqué que tenía que encontrar la mayor diferencia entre dos puntos del array donde el segundo viene **después** del primero. Reconocí el patrón de two pointers / sliding window expandiendo desde la izquierda.
- La idea: mantener un puntero al "mejor día de compra hasta ahora" y otro avanzando como candidato de venta. Si encuentro un precio menor al de compra actual, reseteo el puntero de compra a ese día.
- Brute force sería el doble bucle clásico: para cada día `i` como compra, recorrer todos los días `j > i` como venta, calcular `prices[j] - prices[i]`, quedarme con el máximo. O(n²) time, O(1) space.
- Complejidad estimada del óptimo: O(n) time / O(1) space

## Solución óptima
- Complejidad time: O(n)
- Complejidad space: O(1)

```typescript
function maxProfit(prices: number[]): number {
  let best = 0;
  let left = 0;

  for (let right = 1; right < prices.length; right++) {
    if (prices[left] < prices[right]) {
      const currentProfit = prices[right] - prices[left];
      if (currentProfit > best) best = currentProfit;
    } else {
      left = right;
    }
  }

  return best;
}
```

## Por qué funciona
La clave es que en cada momento solo necesito saber dos cosas: cuál es el **mejor día de compra hasta ahora** (el precio más bajo visto) y cuál es el **mejor profit hasta ahora**. No necesito guardar todo el historial.

El loop hace exactamente eso:
- Si `prices[right] > prices[left]`: hay potencial profit, lo calculo y actualizo `best` si supera al actual.
- Si `prices[right] <= prices[left]`: encontré un precio más bajo o igual, así que actualizo `left = right` (a partir de aquí, este día es un mejor candidato de compra).

El "sliding window" aquí es: `left` marca el inicio de la ventana (mejor día de compra), `right` la expande hacia la derecha. La ventana se "resetea" cuando aparece un precio más bajo.

Equivalente más limpio, tracking el valor directamente en vez del índice:

```typescript
function maxProfit(prices: number[]): number {
  let minPrice = Infinity;
  let best = 0;
  for (const price of prices) {
    if (price < minPrice) minPrice = price;
    else if (price - minPrice > best) best = price - minPrice;
  }
  return best;
}
```

## Trampas / edge cases
- Array vacío -> 0 (mi loop arranca en `right = 1`, así que no entra y devuelve `best = 0`). Correcto por construcción.
- Single element -> 0 (no hay día de venta posible). Idem.
- Strictly descending (`[10, 8, 7, 5, 2]`) -> 0. El `else left = right` se ejecuta en cada iteración, nunca calculamos profit positivo.
- All equal prices (`[5, 5, 5]`) -> 0. Mi condición es `<` (strict), así que el caso de igualdad cae en el `else` y resetea. No produce profit. Correcto.
- Trampa conceptual: no puedo vender el mismo día que compro. El loop arranca en `right = 1` precisamente para forzar esa separación.

## Aprendizajes
- Patrón **"running minimum + best so far en una sola pasada"** para problemas de "máxima ganancia entre dos puntos con orden temporal". Se aplica a:
  - Maximum Subarray (Kadane es la misma silueta: running sum + best sum)
  - Buy and Sell con cooldown / multiple transactions (variantes con DP)
- La diferencia entre **two pointers** y **sliding window** en este problema es fina: la ventana es `[left, right]`, el invariante es "left es el mejor día de compra dentro de la ventana actual". Se "desliza" reseteando `left` cuando aparece un precio menor.
- Reflejo a interiorizar: cuando un problema pide "max diff entre dos puntos donde A < B en posición", la respuesta casi nunca es double-loop. Es siempre **una pasada con running stats**.

## Variaciones que existen
- [[Buy and Sell Crypto with Cooldown]] (variante con DP, no puedes comprar el día después de vender)
- [[Maximum Subarray]] (Kadane's, mismo patrón aplicado a suma de subarrays)
- Best Time to Buy and Sell Stock II (transacciones ilimitadas, greedy - no está en NC150)

## Patrón aplicado
- [[Sliding Window Pattern]]
