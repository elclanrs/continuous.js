# Test
#
assert = require 'assert'
{StreamI, Stream} = require './continuous.coffee'

log = (x) -> console.log x

odd = (x) -> x % 2 isnt 0
plus1 = (x) -> x + 1
add = (x, y) -> x + y

people = [
  {name: 'Peter'}
  {name: 'Mike'}
]

test = (a, b, c) ->
  assert.deepEqual a, b, "#{c}\ ✘\nExpected #{JSON.stringify b} not #{JSON.stringify a}\n"
  log "#{c} ✔"

log '\n*** Test ***\n'

test (new Stream 1,2,3).head(),
  1, 'head'

test (new Stream 1,2,3).tail().toArray(),
  [2,3], 'tail'

test (new Stream 1,2,3).toArray(),
  [1,2,3], 'toArray'

test (new Stream 1,2,3).map(plus1).toArray(),
  [2,3,4], 'map'

test (new Stream StreamI.toStream people).pluck('name').toArray(),
  ['Peter', 'Mike'], 'pluck'

test (new Stream 1,2,3).filter(odd).toArray(),
  [1,3], 'filter'

test (new Stream 1,2,2,3).unique().toArray(),
  [1,2,3], 'unique'

test (new Stream 1,2,3).reject(odd).toArray(),
  [2], 'reject'

test (new Stream 1,2,3).without(2).toArray(),
  [1,3], 'without'

test (new Stream 1,2,3).take(2).toArray(),
  [1,2], 'take'

test (new Stream 1,2,3).takeWhile((x) -> x < 3).toArray(),
  [1,2], 'takeWhile'

test (new Stream StreamI.toStream people).takeWhere(name: 'Peter').toArray(),
  [name: 'Peter'], 'takeWhere'

test (new Stream 1,2,3).drop(2).toArray(),
  [3], 'drop'

test (new Stream 1,2,3).dropWhile((x) -> x < 3).toArray(),
  [3], 'dropWhile'

test (new Stream 1,2,3).zipWith(add, StreamI.stream 1,2,3).toArray(),
  [2,4,6], 'zipWith'

test (new Stream StreamI.chars 'a', 'z').interleave(StreamI.ints 1).take(6).toArray(),
  [1,'a',2,'b',3,'c'], 'interleave'

test (new Stream 1,2,3).fold1(add),
  6, 'fold1'

test (new Stream 1,2,3).interleave(StreamI.chars 'a', 'c').take(6).toObject(),
  {a:1, b:2, c:3}, 'toObject'

test (new Stream 1,2,3).find(2),
  1, 'find'

test (new Stream 1,2,3).some(odd),
  true, 'some'

test (new Stream 1,2,3).every(odd),
  false, 'every'

test (new Stream 1,2,3).append(StreamI.stream 4,5,6).toArray(),
  [1,2,3,4,5,6], 'append'

test (new Stream 1,2,3).union(StreamI.stream 2,3,4).toArray(),
  [1,2,3,4], 'union'

sss = new Stream StreamI.stream(StreamI.stream(1,2), StreamI.stream(3,4))

test sss.accumulate(StreamI.interleave).toArray(),
  [1,3,2,4], 'accumulate'

sss = new Stream StreamI.stream(StreamI.stream(1,2), StreamI.stream(3,4))

test sss.join().toArray(),
  [1,3,2,4], 'join'

res = do ({stream, flatMap, toArray} = StreamI) ->
  toArray(
    flatMap (stream 1,2), (x) ->
      flatMap (stream 3,4), (y) ->
        stream x + y)

test res, [4,5,5,6], 'flatMap'

test (new Stream 'lorem').map((x) -> x.toUpperCase()).toArray(),
  ['L','O','R','E','M'], 'string'

log '\nAll good! ✔'
