# Continuous.js

Streams for JavaScript, also known as lazy sequences.

**Support:** NodeJS, IE9+.
**License:** [MIT](http://opensource.org/licenses/MIT)

## How to

NodeJS:

```javascript
var Continuous = require('./continuous.js');

// Constructor for chaining
var Stream = Continuous.Stream;

// Functions for composition
var StreamI = Continuous.StreamI;
```

Browser:

```html
<script src="continuous.js"></script>
<script>
// Now you can use Stream and StreamI
</script>
```

Continuous can be used with chaining:

```javascript
var result = new Stream(1,2,3,4,5)
  .filter(function(x){return x > 3})
  .map(function(x){return x * 2})
  .toArray();
```

And composition:

```javascript
// Add functions to global scope
// using an "extend" helper
$.extend(window, StreamI);

var result = toArray(
  map(function(x){return x * 2},
  filter(function(x){return x > 3},  
  stream(1,2,3,4,5))));
```

## Functions/Methods

**StreamI:** head, tail, stream, toStream, iterate, map, pluck, filter, unique, reject, without, take, takeWhile, takeWhere, drop, dropWhile, zipWith, interleave, fold, fold1, toArray, toObject, doStream, each, find, some, every, append, union, accumulate, join, flatMap, repeat, ints, rand, chars, rand, memo.

### head

First item

```javascript
new Stream(1,2,3).head(); //=> 1
```

### tail

Eveything but the first item

```javascript
new Stream(1,2,3).tail(); //=> thunk (2 3)
```

### stream

**# function only**

Create a stream

```javascript
stream(1,2,3); //=> thunk (1 2 3)
```

### toStream

**# function only**

Get a stream from an array

```javascript
toStream([1,2,3]); //=> thunk (1 2 3)
```

### iterate

**# function only**

Takes a function and an accumulator to generate an infinite stream.

```javascript
ones = iterate(function(x){return x}, 1);
ones(); //=> thunk (1 1 1 ...)
```

### map

Apply a function to every item of the stream

```javascript
new Stream(1,2,3).map(function(x){return x + 1}); //=> thunk (2 3 4)
```

### pluck

Create a new stream of property values from a collection

```javascript
var people = [
  {name: 'Peter'},
  {name: 'Mike'}
];

new Stream(toStream(people)).pluck('name'); //=> thunk ('Peter' 'Mike')
```

### filter

Keep items that pass the test

```javascript
new Stream(1,2,3).filter(function(x){return x % 2 !== 0}); //=> thunk (1 3)
```

### unique

Remove duplicates from the stream

```javascript
new Stream(1,1,2,2,3,3).unique(); //=> thunk (1 2 3)
```

### reject

Remove items that pass the test

```javascript
new Stream(1,2,3).reject(function(x){return x < 2}); //=> thunk (2 3)
```

### without

Remove the given items

```javascript
new Stream(1,2,3,4).without(2,3); //=> thunk (1 4)
```

### take

Take n items

```javascript
new Stream(1,2,3).take(2); //=> thunk (1 2)
```

### takeWhile

Take items while they pass the test

```javascript
new Stream(1,2,3).takeWhile(function(x){return x < 3}); //=> thunk (1 2)
```

### takeWhere
  
Take items where property and value match

```javascript
var people = [
  {name: 'Peter', age: 24},
  {name: 'Mike', age: 15}
  {name: 'Mike', age: 42}
];

new Stream(toStream(people)).takeWhere({name: 'Mike'});
//^ thunk ({name: 'Mike', age: 15} {name: 'Mike', age: 15})
```

### drop

Remove n items from the head of the stream

```javascript
new Stream(1,2,3).drop(2); //=> thunk (3)
```

### dropWhile

Drop items until the condition is met

```javascript
new Stream(1,2,3).dropWhile(function(x){return x < 2}); //=> thunk (3)
```

### zipWith

Merge two streams with function

```javascript
new Stream(1,2,3).zipWith(function(x,y){return x + y}, stream(4,5,6));
//^ thunk (5 7 9)
```

### interleave

Merge two streams lazily by interleaving their items. Useful for infinite lazy streams.

```javascript
new Stream(ints(0)).interleave(chars('a','z')); //=> thunk ('a' 0 'b' 1 'c' 2 ...)
```

### fold

Reduce items in the stream with a function and an accumulator

```javascript
new Stream(1,2,3).fold(0, function(acc,x){return acc + x}); //=> 6
```

### fold1

Same as fold but where the accumulator is the first item

```javascript
new Stream(1,2,3).fold(function(x,y){return x + y}); //=> 6
```

### toArray

Process the stream into an array

```javascript
new Stream(1,2,3).toArray(); //=> [1, 2, 3]
```

### toObject

Process the stream into an object

```javascript
new Stream('a',1,'b',2,'c',3).toObject(); //=> {a:1, b:2, c:3}
```

### doStream

Process the stream up to n items to do side effects

```javascript
new Stream(1,2,3).doStream(2, function(x){console.log(x)});
//> 1 .. 2
```

### each

Same as `doStream` but til `Infinity`. Do not use with infite streams unless you `take` items first.

```javascript
new Stream(1,2,3).each(function(x){console.log(x)});
//> 1 .. 2 .. 3
```

### find

Return the index of the item if found otherwise return `false`

```javascript
new Stream(1,2,3).find(2); //=> 1
new Stream(1,2,3).find(5); //=> false
```

### some

Check if at least one item passes the test

```javascript
new Stream(1,2,3).some(function(x){return x > 0}); //=> true
```

### every

Check if all items pass the test

```javascript
new Stream(1,2,3).every(function(x){return x < 3}); //=> false
```

### append

Append items at the end of the stream

```javascript
new Stream(1,2,3).append(stream(4,5,6)); //=> thunk (1 2 3 4 5 6)
```

### union

Append only unique items

```javascript

new Stream(1,2,3).append(stream(2,3,4)); //=> thunk (1 2 3 4)
```

### accumulate

Fold a stream of streams with a function tha operates on streams

```javascript
streamOfStreams = new Stream(stream(stream(1, 2), stream(3, 4)));
streamOfStreams.accumulate(interleave); //=> thunk (1 3 2 4)
```

### join

Accumulates a stream of stream by interleaving items

```javascript
streamOfStreams = new Stream(stream(stream(1, 2), stream(3, 4)));
streamOfStreams.join(); //=> thunk (1 3 2 4)
```

### flatMap

Monadic "bind"

```javascript
var result = toArray(
  flatMap(stream(1,2), function(x) {
    return flatMap(stream(3,4), function(y) {
      return stream(x + y);
    });
  });
);
//^ [4,5,5,6]
```

### repeat

Repeat item infinitely

```javascript
repeat(1); //=> thunk (1 1 1 ...)
```

### ints

Infinites stream of integers from n

```javascript
ints(5); //=> thunk (5 6 7 ...)
```

### rand

Infinite stream of random numbers between 0 and 1

```javascript
rand(); //=> thunk (0.12321313576, 0.87603421337, 0.91267844482 ...)
```

### chars

Infinite stream of characters from start to end

```javascript
chars('a', 'c'); //=> thunk ('a' 'b' 'c' 'a' 'b' 'c' ...)
```

### memo

Continuous doesn't memoize by default but you can use `memo` if you need to:

```javascript
memo(fibonacciStream);
```
