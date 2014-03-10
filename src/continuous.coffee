###!
 * Continuous.js
 * @author Cedric Ruiz
 * @license MIT
###
do (exports = window ? module.exports) ->
  # Helpers
  #
  curry = (as...) -> (bs...) ->
    as[0].apply @, as[1..].concat bs

  compose = (fs...) ->
    fs.reduce (f, g) ->
      (as...) -> f g as...

  flip = (f) -> (x, y) ->
    f y, x

  memo = (f) ->
    store = {}
    (x) ->
      return store[x] if x of store
      store[x] = f x

  # Stream
  #
  force = (f) -> f()

  cons = (x, y) -> (list) ->
    list x, y

  consL = (x, y) ->
    cons x, -> y

  head = (list) ->
    list (x) -> x

  tail = (xs) ->
    force xs (x, y) -> y

  stream = (xs...) ->
    if xs.length is 1 and typeof xs[0] is 'string'
      xs = xs[0]
    if xs.length
      cons xs[0], -> stream ([].concat xs[1..])...

  toStream = (xs) ->
    stream.apply null, xs

  iterate = (f, acc) ->
    if acc?
      cons acc, -> iterate f, f acc

  map = (f, xs) ->
    if xs?
      cons (f head xs), -> map f, tail xs

  pluck = (prop, xs) ->
    map ((x) -> x[prop]), xs

  filter = (f, xs) ->
    while xs? and not f head xs
      xs = tail xs
    if xs?
      cons (head xs), -> filter f, tail xs

  unique = (xs) ->
    seen = {}
    filter ((x) -> seen[x] = 1 unless seen[x]), xs

  reject = (f, xs) ->
    filter ((x) -> not f x), xs

  without = (args..., xs) ->
    filter ((x) -> x not in args), xs

  take = (n, xs) ->
    if n and xs?
      cons (head xs), -> take n - 1, tail xs

  takeWhile = (f, xs) ->
    if f head xs
      cons (head xs), -> takeWhile f, tail xs

  takeWhere = (obj, xs) ->
    filter ((x) -> false not in (x[k] is v for k, v of obj)), xs

  drop = (n, xs) ->
    while n--
      xs = tail xs
    xs

  dropWhile = (f, xs) ->
    while f head xs
      xs = tail xs
    xs

  zipWith = (f, xs, ys) ->
    if xs? and ys?
      cons (f (head xs), head ys), -> zipWith f, (tail xs), tail ys

  interleave = (xs, ys) ->
    return ys unless xs?
    cons (head xs), -> interleave ys, tail xs

  fold = (acc, f, xs) ->
    i = 0
    while xs?
      acc = if acc? then f acc, (head xs), i else head xs
      xs = tail xs
      i++
    acc

  fold1 = curry fold, null

  toArray = curry fold, [], (x, y) -> x.concat y

  toObject = (xs) ->
    key = head xs
    f = (obj, x, i) ->
      if i % 2 then obj[key] = x else key = x
      obj
    fold {}, f, xs

  doStream = (n, f, xs) ->
    i = 0
    while n-- and xs?
      break if (f (head xs), i) is false
      xs = tail xs
      i++
    null

  each = curry doStream, Infinity

  find = (x, xs) ->
    ret = false
    each ((y, i) -> ret = i if x is y), xs
    ret

  some = (f, xs) ->
    ret = false
    each ((x) -> ret = true if f x), xs
    ret

  every = (f, xs) ->
    ret = true
    each ((x) -> ret = false unless f x), xs
    ret

  append = (xs, ys) ->
    ys = toArray ys
    i = ys.length
    while i--
      xs = consL ys[i], xs
    xs

  union = compose unique, append

  # Monadic
  #
  accumulate = (f, xs) ->
    if xs?
      f (head xs), accumulate f, tail xs

  join = curry accumulate, interleave

  flatMap = flip compose join, map

  # Extra
  #
  repeat = curry iterate, (x) -> x

  ints = curry iterate, (x) -> x + 1

  rand = iterate Math.random, Math.random()

  chars = (start, end) ->
    next = null
    f = (x) ->
      return next = start if next is end
      next = String.fromCharCode 1 + x.charCodeAt 0
    iterate f, start

  # Constructor
  #
  StreamI = {
    head, tail
    stream, toStream, iterate
    map, pluck, filter, unique, reject, without
    take, takeWhile, takeWhere,
    drop, dropWhile,
    zipWith, interleave
    fold, fold1, toArray, toObject
    doStream, each, find, some, every
    append, union
    accumulate, join, flatMap
    repeat, ints, rand, chars
    memo
  }

  class Stream
    constructor: (xs...) ->
      @xs = if typeof xs[0] is 'function' then xs[0] else toStream xs
    get: -> @xs
    clone: -> new Stream @xs

  for meth, f of StreamI
    do (meth, f) ->
      Stream::[meth] = (args...) ->
        @xs = f.apply null, args.concat @xs
        return @xs if meth in [
          'head'
          'doStream', 'each', 'find', 'some', 'every', 'fold', 'fold1'
          'toArray', 'toObject'
        ]
        this

  # Export
  #
  exports.StreamI = StreamI
  exports.Stream = Stream
