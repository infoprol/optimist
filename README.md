# Optimist

originally, i was going to try implementing a plug to do conditional http puts.
but then trying to look into the plug macro got me into looking at macros generally,
so that's what we've got so far - a little hacking away at my SoP module.

SoP for Sum of Products.  Right now, only dealing with `+` and `*` - that way the algorithm
itself won't have too much clutter.  it would generalize to include `-` and `/` easily enough.

just a little ast, and just tree manipulation.  pretty much all the interesting stuff is going
to be in `lib/sop/scratch.ex`.  _NOTE_ there's a bit of cruft.  this is a work in progress.

## try this (from the base dir of this repo)

run `iex -S mix` and from there:

```elixir
import SoP
import SoP.Scratch

ast = expr_eg  # example expression
bb_0 = parse(ast)  # ok, "parsing" is probably a bad choice of name.  we transform the elixir ast into
                   # a binary tree made up of our own fake union type (see comments in code)

bb_1 = bubble_plus(bb_0)   # each pass of bubble_plus over the tree will bubble up `+`s at least one
			   # level (of those needing bubbling).  however, to get proper form for
			   # step 3, may need to call bubble_plus again.
```

any unfamiliar terminology is slang from the code itself - in particular, `bubble_plus` is not just
a better version of some `bubble` function; it's just the function that bubbles the pluses.

anything still unfamiliar after looking through the SoP modules code is probably just me abusing terminology.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `optimist` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:optimist, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/optimist](https://hexdocs.pm/optimist).

