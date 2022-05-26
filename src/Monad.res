module type General = {
  type t<'a, 'i, 'j, 'd, 'e>
  let bind: (t<'a, 'i, 'j, 'd, 'e>, 'a => t<'b, 'j, 'k, 'd, 'e>) => t<'b, 'i, 'k, 'd, 'e>
  let fmap: [
    | #DefineWithBind
    | #Custom((t<'a, 'i, 'j, 'd, 'e>, 'a => 'b) => t<'b, 'i, 'j, 'd, 'e>)
  ]
  let return: 'a => t<'a, 'i, 'i, 'd, 'e>
}

module type Basic = {
  type t<'a>
  let bind: (t<'a>, 'a => t<'b>) => t<'b>
  let return: 'a => t<'a>
  let fmap: [#DefineWithBind | #Custom((t<'a>, 'a => 'b) => t<'b>)]
}

module type Basic2 = {
  type t<'a, 'e>
  let bind: (t<'a, 'e>, 'a => t<'b, 'e>) => t<'b, 'e>
  let return: 'a => t<'a, 'e>
  let fmap: [
    | #DefineWithBind
    | #Custom((t<'a, 'e>, 'a => 'b) => t<'b, 'e>)
  ]
}

module type Basic3 = {
  type t<'a, 'd, 'e>
  let bind: (t<'a, 'd, 'e>, 'a => t<'b, 'c, 'e>) => t<'b, 'c, 'e>
  let return: 'a => t<'a, 'd, 'e>
  let fmap: [
    | #DefineWithBind
    | #Custom((t<'a, 'd, 'e>, 'a => 'b) => t<'b, 'd, 'e>)
  ]
}

module type Infix2 = {
  type t<'a, 'e>
}

module MakeGeneral = (M: General) => {
  let bind = M.bind
  let return = M.return
  let fmap = switch M.fmap {
  | #DefineWithBind => (m, f) => M.bind(m, a => M.return(f(a)))
  | #Custom(f) => f
  }
  let seq = (m, n) => m->bind(_ => n)
  let join = m => m->bind(a => a)
  let all = {
    let rec loop = (vs, ms) =>
      switch ms {
      | list{} => return(Belt.List.reverse(vs))
      | list{t, ...ts} => t->bind(v => loop(list{v, ...vs}, ts))
      }
    ts => loop(list{}, ts)
  }
  let rec all_ignore = ms =>
    switch ms {
    | list{} => return()
    | list{t, ...ts} => t->bind(() => all_ignore(ts))
    }
}

module MakeBasic = (M: Basic) => MakeGeneral({
  type t<'a, 'i, 'j, 'd, 'e> = M.t<'a>
  include (M: Basic with type t<'a> := M.t<'a>)
})

module MakeBasic2 = (M: Basic2) => MakeGeneral({
  type t<'a, 'i, 'j, 'd, 'e> = M.t<'a, 'd>
  include (M: Basic2 with type t<'a, 'd> := M.t<'a, 'd>)
})

module MakeBasic3 = (M: Basic3) => MakeGeneral({
  type t<'a, 'i, 'j, 'd, 'e> = M.t<'a, 'j, 'd>
  include (M: Basic3 with type t<'a, 'j, 'd> := M.t<'a, 'j, 'd>)
})
