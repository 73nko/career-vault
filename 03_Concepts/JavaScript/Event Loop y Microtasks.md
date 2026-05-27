# Event Loop y Microtasks

#concept #status/done

## Definición

Modelo de ejecución que coordina **cuándo** corre JavaScript síncrono, callbacks de APIs del host, callbacks de Promises y renderizado. La regla mental: una tarea entra al stack, corre hasta completarse, se drenan las microtasks pendientes, y solo después el runtime puede avanzar a otra tarea o permitir que el navegador pinte.

```javascript
sync code -> task callback -> microtask checkpoint -> maybe render -> next task
```

## Por qué importa

El event loop explica por qué `Promise.then` corre antes que `setTimeout(..., 0)`, por qué `await` no bloquea el thread, por qué una cadena infinita de microtasks congela la UI, y por qué frameworks como React/Vue/Svelte usan colas para batchar trabajo antes del paint.

Lo uso cuando:

- Tengo que predecir el orden real de logs, callbacks, `then`, `await`, timers y eventos DOM.
- Quiero diseñar una API que sea siempre async, incluso si algunos datos vienen de cache síncrona.
- Necesito batchar cambios durante el mismo tick sin esperar a otro task completo.
- Estoy investigando jank: input delay, paints bloqueados, Promises que se encadenan demasiado, handlers largos.

NO lo uso así:

- No uso microtasks para trabajo pesado. Si una tarea tarda, sigue bloqueando el main thread.
- No uso `queueMicrotask` como "setTimeout más rápido". Su prioridad puede retrasar input, timers y paint.
- No confundo el modelo del browser con Node: comparten Promise jobs y `queueMicrotask`, pero Node añade fases de libuv y `process.nextTick`.

## Cómo funciona

### 1. Engine vs host

JavaScript no tiene timers, DOM, red ni event loop "de navegador" dentro del lenguaje ECMAScript puro. El motor ejecuta el lenguaje: call stack, heap, Promises, jobs. El **host** aporta el entorno: HTML en browser, Node.js en backend, Deno, workers, etc.

En browser:

- El motor JS ejecuta código hasta que el stack queda vacío.
- El host HTML decide qué task source entrega el siguiente callback: timers, eventos de usuario, parser, networking, IndexedDB, etc.
- El host también decide cuándo puede renderizar, normalmente entre tasks y después de drenar microtasks.

Esta separación importa porque "event loop" no es una única cola global mágica. El browser puede tener varias fuentes de tasks y elegir entre ellas para priorizar input o rendering. Dentro de una fuente, el orden es FIFO; entre fuentes, el host tiene margen.

### 2. Run-to-completion

Cada fragmento de JS corre hasta terminar. No hay preemption dentro de una función:

```javascript
button.addEventListener("click", () => {
  state.count += 1;
  expensiveWork();
  state.count += 1;
});
```

Mientras ese handler está ejecutando, otro click, un timer o un `then` no interrumpe a mitad de `expensiveWork`. Es bueno para razonar sobre invariantes locales, pero malo para latencia: si bloqueas 200 ms, bloqueas input, microtasks y paint durante esos 200 ms.

### 3. Tasks, o "macrotasks"

Una **task** es una entrada grande desde el host hacia JS. "Macrotask" es el nombre informal que se usa en entrevistas; la spec HTML habla de tasks.

Ejemplos típicos:

- Ejecutar el script inicial.
- Un callback de `setTimeout` o `setInterval`.
- Un evento de usuario como `click`.
- Callbacks de APIs del host, como I/O, parser, IndexedDB o mensajes.

Regla práctica: en una iteración del event loop el browser toma una task runnable, ejecuta su callback hasta que el stack queda vacío, hace un microtask checkpoint, puede pintar, y luego toma otra task.

`setTimeout(fn, 0)` no significa "corre inmediatamente". Significa: cuando el timer cumpla su umbral mínimo, encola `fn` como task. Esa task solo corre cuando le llegue turno después del script actual, microtasks y cualquier otra task que el host priorice.

### 4. Microtasks

Una **microtask** es trabajo que debe correr después de que el stack actual se vacíe, pero antes de que el runtime continúe con la siguiente task.

Fuentes comunes:

- Reacciones de Promises: `.then`, `.catch`, `.finally`.
- Continuaciones de `await`.
- `queueMicrotask(callback)`.
- `MutationObserver` en browser.

Dos reglas son las que rompen intuiciones:

1. El runtime drena **todas** las microtasks pendientes cuando llega a un checkpoint.
2. Si una microtask encola otra microtask, la nueva también corre en el mismo checkpoint antes de la siguiente task.

Por eso esto puede congelar la página:

```javascript
function spin() {
  queueMicrotask(spin);
}

spin();
```

No hay stack overflow inmediato porque cada callback termina antes de encolar el siguiente paso, pero el event loop nunca llega a la siguiente task ni al paint.

### 5. Checkpoints: no solo "al final de la task"

La versión simple dice "microtasks al final de la task". Es útil, pero incompleta. En browser, también se hace un microtask checkpoint después de ciertos callbacks **si no queda JavaScript ejecutándose**.

Esto explica la diferencia entre un click real y un `.click()` programático:

- Click real: el dispatch del evento entra desde el host como task. Después de un listener, si el stack queda vacío, pueden correr microtasks antes del siguiente listener burbujeado.
- `.click()` programático: el dispatch ocurre dentro del script que llamó `.click()`. Como todavía hay JS en el stack, las microtasks esperan hasta que termine el script exterior.

La frase precisa: las microtasks no interrumpen JavaScript que está a mitad de ejecución. Corren cuando el stack de ejecución queda vacío y el host llega a un checkpoint.

### 6. Promises y `async/await`

Una Promise resuelta no llama sus handlers de forma síncrona:

```javascript
console.log("A");

Promise.resolve().then(() => console.log("B"));

console.log("C");
// A, C, B
```

Aunque la Promise ya esté fulfilled, `.then` encola una reaction job. Eso garantiza que el handler sea async y que el código síncrono actual termine primero.

`await` es azúcar sobre el mismo mecanismo:

```javascript
async function run() {
  console.log("A");
  await null;
  console.log("B");
}

run();
console.log("C");
// A, C, B
```

Después del `await`, la continuación de la función async vuelve como microtask. `await` no bloquea el thread; suspende esa función y devuelve control al caller.

Detalle importante en cadenas:

```javascript
Promise.resolve()
  .then(() => {
    console.log("A");
  })
  .then(() => {
    console.log("B");
  });
```

El segundo `.then` no se encola al mismo tiempo que el primero. Se registra como reacción de la Promise devuelta por el primer `.then`; solo se encola cuando el primer handler termina y resuelve esa Promise intermedia.

### 7. `queueMicrotask` vs `Promise.resolve().then`

Antes de `queueMicrotask`, se usaba este truco:

```javascript
Promise.resolve().then(callback);
```

Funciona para encolar una microtask, pero no es equivalente perfecto:

- `queueMicrotask(callback)` expresa la intención directamente.
- Evita crear una Promise solo para usar su cola.
- Si el callback lanza, el error se reporta como excepción normal de la microtask; con el truco de Promise se convierte en una rejection.

Úsalo para trabajo corto de librería o framework: normalizar orden de callbacks, batchar eventos emitidos de forma síncrona, ejecutar cleanup justo antes de devolver control al host.

### 8. Rendering

En browser, el paint no ocurre en medio de una task ni en medio de un microtask checkpoint. El navegador puede renderizar después de que la task actual termine y después de que se drenen las microtasks.

Esto tiene dos consecuencias:

- Microtasks son buenas para dejar el DOM/estado consistente antes del siguiente paint.
- Muchas microtasks son malas para UX: pueden retrasar el paint aunque cada callback individual sea pequeño.

Si quieres partir trabajo para permitir input y paint, usa tasks separadas (`setTimeout`, `MessageChannel`, scheduler APIs cuando existan), `requestAnimationFrame` para coordinar con el frame, o workers para CPU pesado. Una microtask no "cede" al navegador; se cuela antes de que el navegador recupere control.

### 9. Caveat de Node.js

En Node, el modelo base sigue siendo run-to-completion + microtasks, pero encima hay fases de libuv:

- timers
- pending callbacks
- poll
- check (`setImmediate`)
- close callbacks

Además, `process.nextTick` no es una microtask estándar del browser. Node mantiene una next tick queue propia. En CommonJS, suele drenar `process.nextTick` antes que las microtasks de V8 (`Promise.then` y `queueMicrotask`). En ES modules hay un caveat: el top-level module evaluation ya ocurre dentro de la cola de microtasks, así que el orden observable puede invertirse.

Regla para entrevistas: explica primero el modelo browser/HTML. Si aparece Node, separa `process.nextTick`, Promise microtasks, `setImmediate` y timers; no mezcles todo bajo "macrotask".

## Ejemplo

### Caso base: Promise antes que timer

```javascript
console.log("script start");

setTimeout(() => {
  console.log("timeout");
}, 0);

Promise.resolve()
  .then(() => {
    console.log("promise1");
  })
  .then(() => {
    console.log("promise2");
  });

console.log("script end");
```

Orden:

```text
script start
script end
promise1
promise2
timeout
```

Por qué:

1. El script inicial es la primera task.
2. `setTimeout` encola otra task futura.
3. El primer `.then` encola una microtask.
4. `script end` corre antes de cualquier async porque el stack actual no terminó.
5. Se drenan microtasks: `promise1`; al resolver la Promise intermedia, se encola `promise2`; también se drena.
6. Recién entonces el event loop puede tomar la task del timer.

### Caso con microtask encolada durante el drain

```javascript
console.log("A");

setTimeout(() => console.log("B"), 0);

Promise.resolve().then(() => {
  console.log("C");
  queueMicrotask(() => console.log("D"));
});

queueMicrotask(() => console.log("E"));

console.log("F");
```

Orden:

```text
A
F
C
E
D
B
```

Por qué:

- `A` y `F` son síncronos.
- `B` queda como task futura.
- La Promise reaction `C` entra primero en la microtask queue.
- `E` entra después.
- Cuando corre `C`, encola `D` al final de la cola actual. La cola queda `E`, `D`.
- El checkpoint no termina hasta vaciar la cola. Solo después corre el timer.

## Trade-offs

- Pro: run-to-completion simplifica invariantes locales. Si una función empezó, no será interrumpida por otra callback a mitad de mutación.
- Pro: microtasks dan una forma precisa de normalizar orden async sin pagar un task completo.
- Pro: Promises y `await` se integran con la misma cola, así que el modelo mental cubre casi todo JS async moderno.
- Contra: prioridad alta significa riesgo alto de starvation. Una cadena de microtasks puede bloquear timers, input y render.
- Contra: el término "macrotask" es cómodo pero impreciso. En browser hay task sources; en Node hay fases.
- Contra: el orden exacto puede depender del host. Browser, worker y Node no son el mismo runtime.
- Cuándo evitar: CPU pesado, loops largos, scheduling de frames visuales, o cualquier cosa que necesite ceder control real al navegador. Usa tasks, `requestAnimationFrame`, `requestIdleCallback` o workers.

## Relacionado

- [[Promise internals]]
- [[async await desugared]]
- [[DOM rendering pipeline]]
- [[Race conditions en JS async]]
- [[Fetch API y Request lifecycle]]
- [[Web Workers vs Service Workers]]

## Preguntas que respondería en entrevista

- **¿Por qué `Promise.resolve().then(...)` corre antes que `setTimeout(..., 0)`?** Respuesta: porque el timer encola una task futura, mientras que la Promise reaction encola una microtask. Al terminar el script actual, el runtime drena microtasks antes de tomar la siguiente task. `0` en el timer no significa inmediato; significa "eligible lo antes posible como task".
- **¿Qué significa run-to-completion y qué problema causa en UI?** Respuesta: cada callback JS corre hasta vaciar su stack antes de que otro callback lo interrumpa. Esto hace que las mutaciones locales sean razonables de seguir, pero si el callback tarda 200 ms, durante esos 200 ms no hay input, Promise handlers, timers ni paint. El modelo evita data races dentro de un thread, no evita jank.
- **Diferencia entre task, microtask y render.** Respuesta: una task es una entrada grande desde el host a JS: script, timer, click, I/O. Una microtask es trabajo de alta prioridad que se drena cuando el stack queda vacío: Promise reactions, `queueMicrotask`, `MutationObserver`. El render puede ocurrir después de la task y después del microtask checkpoint, no entre microtasks. Por eso microtasks pueden retrasar paint.
- **¿Qué pasa si una microtask encola otra microtask?** Respuesta: se añade al final de la microtask queue actual y corre antes de la siguiente task. El checkpoint se drena hasta quedar vacío. Esto permite batching fino, pero también starvation si la cadena nunca termina.
- **¿`await` bloquea el thread?** Respuesta: no. Suspende la función async y devuelve control al caller. Cuando el valor awaited se resuelve, la continuación se encola como microtask. El código después del `await` corre antes de timers posteriores, pero después de que termine el stack síncrono actual.
- **¿Cuándo usarías `queueMicrotask` en una librería?** Respuesta: cuando necesito ordenar callbacks de forma consistente sin introducir una task completa. Caso típico: una API que a veces responde desde cache síncrona y a veces desde fetch. En la rama síncrona, encolo una microtask para que el evento `load` o callback ocurra async igual que en la rama Promise. No lo usaría para trabajo pesado ni para "hacer algo más rápido".
- **¿Por qué `Promise.resolve().then(callback)` no es idéntico a `queueMicrotask(callback)`?** Respuesta: ambos acaban en la cola de microtasks, pero `queueMicrotask` evita crear una Promise y reporta errores como excepciones normales del callback. Con el truco de Promise, un throw se convierte en una rejected Promise, lo que cambia observabilidad y manejo de errores.
- **¿Qué cambia en Node?** Respuesta: Node añade fases de libuv (`timers`, `poll`, `check`, etc.) y una cola especial de `process.nextTick`. En CommonJS, `nextTick` se drena antes que Promise microtasks; en ESM top-level puede observarse otro orden porque el módulo ya se evalúa dentro del mecanismo de microtasks. Para código portable, prefiero `queueMicrotask` salvo que necesite algo específico de Node.
- **¿Cómo diagnosticarías jank causado por microtasks?** Respuesta: buscaría chains largas de `.then`, loops con `queueMicrotask`, flushes de framework que hacen demasiado trabajo antes del paint, y handlers que mezclan sync heavy work con Promises. La solución no es meter más microtasks, sino partir trabajo en tasks que cedan al browser, mover CPU a workers, o coordinar visualmente con `requestAnimationFrame`.

## Fuente

- Jake Archibald: [Tasks, microtasks, queues and schedules](https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/)
- MDN: [JavaScript execution model](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Execution_model)
- MDN: [Using microtasks in JavaScript with queueMicrotask()](https://developer.mozilla.org/en-US/docs/Web/API/HTML_DOM_API/Microtask_guide)
- MDN: [In depth: Microtasks and the JavaScript runtime environment](https://developer.mozilla.org/en-US/docs/Web/API/HTML_DOM_API/Microtask_guide/In_depth)
- MDN: [Window.queueMicrotask()](https://developer.mozilla.org/en-US/docs/Web/API/Window/queueMicrotask)
- Node.js docs: [When to use queueMicrotask() vs. process.nextTick()](https://nodejs.org/api/process.html#when-to-use-queuemicrotask-vs-processnexttick)
