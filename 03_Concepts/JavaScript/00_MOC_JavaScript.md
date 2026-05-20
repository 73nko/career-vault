# MOC: JavaScript

#moc #javascript

Punto de entrada al área JavaScript del vault. Foco: dominio profundo del lenguaje para entrevistas FE Staff (event loop, prototipos, async, coerción) — no sintaxis básica.

## Tipos y valores

- [[Runtime Type Detection]]
- [[typeof vs instanceof]]
- [[Primitives vs Objects]]
- [[null vs undefined]]
- [[NaN y comparaciones]]
- [[Symbol y usos reales]]
- [[BigInt]]

## Coerción e igualdad

- [[== vs ===]]
- [[ToPrimitive, ToNumber, ToString]]
- [[Truthy y Falsy]]
- [[Object to Primitive conversion]]

## Prototype y herencia

- [[Prototype Chain]]
- [[Object.create vs class vs new]]
- [[__proto__ vs prototype]]
- [[hasOwnProperty y Object.hasOwn]]
- [[class sugar: lo que oculta]]

## Funciones y `this`

- [[Closures]]
- [[this binding rules]]
- [[Arrow vs Regular Functions]]
- [[call, apply, bind]]
- [[Currying y partial application]]
- [[IIFE y module pattern]]

## Async y concurrencia

- [[Event Loop]]
- [[Microtasks vs Macrotasks]]
- [[Promise internals]]
- [[async await desugared]]
- [[Generators e iteradores]]
- [[AbortController]]
- [[Race conditions en JS async]]

## Memoria y rendimiento

- [[Garbage Collection en V8]]
- [[Memory leaks comunes]]
- [[Hidden Classes y shape optimization]]
- [[WeakMap y WeakRef]]
- [[Estructuras nativas: Map vs Object]]

## Módulos

- [[ESM vs CJS]]
- [[Dynamic import]]
- [[Top-level await]]
- [[Tree shaking: qué lo rompe]]

## APIs del navegador

- [[DOM rendering pipeline]]
- [[Fetch API y Request lifecycle]]
- [[Streams API]]
- [[Web Workers vs Service Workers]]
- [[IndexedDB básico]]
- [[Storage: local, session, cookie]]
- [[Intersection y Mutation Observer]]

## Patrones idiomáticos

- [[Debounce y Throttle]]
- [[Observer Pattern en JS]]
- [[Composition vs Inheritance]]
- [[Functional helpers: map, reduce, filter, flat]]
- [[Lazy evaluation con generators]]

## Errores y debugging

- [[Error, custom errors y stack traces]]
- [[try/catch async pitfalls]]
- [[Source maps en producción]]

## Recursos canon

- MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/JavaScript
- You Don't Know JS (Kyle Simpson)
- JavaScript: The Definitive Guide (David Flanagan)
- V8 blog: https://v8.dev/blog
- Jake Archibald — Tasks, microtasks, queues: https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/
