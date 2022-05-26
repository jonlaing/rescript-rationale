type t<'a, 'b> = {
  get: 'a => 'b,
  set: ('a, 'b) => 'a,
}

let make = (getter, setter) => {get: getter, set: setter}

let view = (a, l) => l.get(a)

let set = (a, l, v) => l.set(a, v)

let over = (a, l, f) => {
  let v = l.get(a)
  l.set(a, f(v))
}

let compose = (l0, l1) => {get: Function.pipe(l1.get, l0.get), set: (a, v) => l1.set(l0.get(a), v)}

let pipe = (l0, l1) => compose(l1, l0)

let optional = default => {
  get: a =>
    switch a {
    | Some(v) => v
    | None => default
    },
  set: (_, v) => Some(v),
}

let head = {
  get: Belt.List.head,
  set: (xs, v) =>
    switch v {
    | None => xs
    | Some(a) => Belt.List.tail(xs)->Belt.Option.getWithDefault(list{})->(tl => list{a, ...tl})
    },
}

let tail = {
  get: Belt.List.tail,
  set: (xs, v) =>
    switch v {
    | None => xs
    | Some(a) =>
      Belt.List.head(xs)->Belt.Option.map(hd => list{hd, ...a})->Belt.Option.getWithDefault(a)
    },
}

let index = i => {
  open Belt
  {
    get: x => x->List.get(i),
    set: (xs, v) =>
      switch v {
      | None => xs
      | Some(a) => xs->RList.update(i, a)
      },
  }
}

let prop = k => {
  module Dict = Belt.Map.String
  {
    get: d => d->Dict.get(k),
    set: (d, v) =>
      switch v {
      | None => d
      | Some(a) => d->Dict.set(k, a)
      },
  }
}

let listMap = l => {get: List.map(l.get), set: List.map2(l.set)}

let first = {get: fst, set: (a, v) => (v, snd(a))}

let second = {get: snd, set: (a, v) => (fst(a), v)}
