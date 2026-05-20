# Runtime Type Detection

#concept #status/draft

## Definición
Técnica para obtener el nombre exacto del tipo (primitivo o clase) de un valor en runtime, más allá de lo que `typeof` puede distinguir.

```javascript
Object.getPrototypeOf(value)?.constructor?.name
```

## Por qué importa
`typeof` colapsa todo lo que no sea primitivo a `"object"`: arrays, fechas, regex, mapas, instancias de clases — todos son indistinguibles. Para logging, serialización, validadores genéricos o type guards a nivel de librería, necesitas el nombre real (`"Array"`, `"Date"`, `"RegExp"`, `"MyClass"`).

## Cómo funciona
Cada valor (excepto `null`/`undefined`) tiene un prototipo accesible vía `Object.getPrototypeOf`. El `.constructor` de ese prototipo apunta a la función/clase que lo creó, y `.name` es su nombre como string. El optional chaining (`?.`) blinda contra los casos sin prototipo o sin constructor.

Alternativa canónica más antigua y robusta:

```javascript
Object.prototype.toString.call(value).slice(8, -1)
// "Array", "Date", "Null", "Undefined", "RegExp", "Map", ...
```

Esta versión sí maneja `null` y `undefined` sin errores, y devuelve los tags internos `[[Class]]` definidos por la spec — más estables ante código que manipula prototipos.

## Ejemplo
```javascript
const cases = [
  42,                  // "Number"
  "hello",             // "String"
  true,                // "Boolean"
  [],                  // "Array"
  {},                  // "Object"
  new Date(),          // "Date"
  /abc/,               // "RegExp"
  new Map(),           // "Map"
  () => {},            // (Anonymous arrow → "")
  class Foo {},        // "Function"  (la clase como valor)
  new (class Foo {})() // "Foo"
];

for (const v of cases) {
  console.log(Object.getPrototypeOf(v)?.constructor?.name);
}

// null y undefined:
Object.getPrototypeOf(null);              // TypeError
Object.getPrototypeOf(Object.create(null)); // null → ?. previene crash
```

## Trade-offs
- **Pro:** devuelve el nombre de clase del usuario (`"MyClass"`), no sólo built-ins. Útil para logging/debug de instancias.
- **Contra:** se rompe si alguien sobreescribe `constructor` o usa `Object.create(null)`. Falla con `null`/`undefined` sin el `?.`. El `.name` de funciones anónimas es `""`.
- **Cuándo evitar:** validación de inputs no confiables (un atacante puede manipular el prototipo). Para discriminar built-ins prefiere `Object.prototype.toString.call(value)` — más estable y cubre `null`/`undefined`.

## Relacionado
- [[typeof vs instanceof]]
- [[Prototype Chain]]

## Preguntas que respondería en entrevista
- ¿Por qué `typeof []` devuelve `"object"`? ¿Qué alternativas tienes para distinguir un array de un objeto plano?
- Diferencias entre `Object.getPrototypeOf(x).constructor.name` y `Object.prototype.toString.call(x)`. ¿Cuál usarías en una librería pública y por qué?
- ¿Qué pasa si alguien hace `class Foo {}; const f = new Foo(); f.constructor = Bar;`? ¿Sigue siendo fiable `.constructor.name`?

## Fuente
- MDN: [Object.getPrototypeOf](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/getPrototypeOf)
- MDN: [Object.prototype.toString](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/toString)
