let allPass = (x, fs) => fs->Belt.Array.reduce(true, (acc, f) => acc ? f(x) : acc)

let and_ = (a, b) => a && b

let anyPass = (x, fs) => fs->Belt.Array.reduce(false, (acc, f) => acc ? acc : f(x))

let both = (x, f, g) => f(x) && g(x)

let either = (x, f, g) => f(x) || g(x)

let not__ = (x, f) => !f(x)

let or_ = (a, b) => a || b

let unless = (x, pred, f) => pred(x) ? x : f(x)

let rec until = (x, pred, f) => pred(x) ? x : until(f(x), pred, f)

let when_ = (x, pred, f) => unless(not__(pred), f, x)
