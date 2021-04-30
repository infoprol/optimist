defmodule Fsm do
  @moduledoc """
  taken from https://www.theerlangelist.com/article/macros_1
  """
  fsm = [
    running: {:pause,   :paused},
    running: {:stop,    :stopped},
    paused:  {:resume,  :running}
  ]

  for {state, {action, next_state}} <- fsm do
    def unquote(action)(unquote(state)), do: unquote(next_state)
  end
  def initial, do: :running
end


defmodule SoP.Scratch do
  @moduledoc """
      {:*, [context: SoP.Scratch, import: Kernel],
        [
      {:+, [context: SoP.Scratch, import: Kernel],
        [
          {:*, [context: SoP.Scratch, import: Kernel],
          [
            {:+, [context: SoP.Scratch, import: Kernel],
              [{:a, [], SoP.Scratch}, {:b, [], SoP.Scratch}]},
            {:+, [context: SoP.Scratch, import: Kernel], [41, 1]}
          ]},
          {:x, [], SoP.Scratch}
        ]},
      {:*, [context: SoP.Scratch, import: Kernel],
        [
          {:+, [context: SoP.Scratch, import: Kernel],
          [{:x, [], SoP.Scratch}, {:y, [], SoP.Scratch}]},
          {:+, [context: SoP.Scratch, import: Kernel],
          [{:m, [], SoP.Scratch}, {:n, [], SoP.Scratch}]}
        ]}
        ]}
   """

  def expr_eg() do
    quote do (((a + 7) * (41 + 1)) + x) * ((x + y) * (m + n))
    end
  end
end

defmodule SoP.Var do
  @enforce_keys [:name]
  defstruct     [:name, node_t: :V]
end
defmodule SoP.Num do
  @enforce_keys [:val]
  defstruct     [:val, node_t: :N]
end

#TODO factor out the common macro from Product and Sum
defmodule SoP.Product do
  defstruct     [node_t: :P, factors: []]

  def multiply(%__MODULE__{factors: ff}, %__MODULE__{factors: gg}) do
    %__MODULE__{factors: ff ++ gg}
  end
end
defmodule SoP.Sum do
  defstruct     [node_t: :S, terms: []]
  def add(%__MODULE__{terms: tt}, %__MODULE__{terms: ss}) do
    %__MODULE__{terms: tt ++ ss}
  end
end


defmodule SoP do
  @moduledoc """

  take the AST from quoting an expression involving only the symbols
  `(` `)` `+` `*`
  as well as literal numbers and variable names.
  return an AST representing an equivalent expression, considered as an
  algrebraic expression, but that is in sum of products form.  this
  is also just multiplying out the equation.


  i don't think this is exactly it, but parsing expressions involving
  S -> term + term
  term -> P|S|V|N
  P -> fact * fact
  fact -> P|V|N

  1. `parse`
      take ast and build a binary tree of our fake discriminated union types, where
      the leaves are of type V or N, and the non-leaves are type P or S.
  2.  `bubble_plus`
      keeping the tree binary, we "bubble up" the S nodes so that for any S node,
      every node on the path from it to the root is also an S node.  the tree manipulation
      we're doing here is just distributing multiplication over addition.
  3.  `rollup`
      now we merge subtrees (lists) of contiguous `*`s into products, and subtrees of
      contiguous `+`s into terms.

  INVARIANT (established on completion of step 2)
  sop invariant:  for every term node, every node from that node to the root is also a term

  """

  # fake discriminated union types
  alias SoP.Var, as: V
  alias SoP.Num, as: N
  alias SoP.Product, as: P
  alias SoP.Sum, as: S


  # let's parse this into a normalized binary tree.
  def parse(n) when is_number(n), do: %N{val: n}
  def parse({var_name, [], _}) when is_atom(var_name), do: %V{name: var_name}
  def parse({:*, _, [p,q]}), do: %P{factors: [ parse(p), parse(q) ]}
  def parse({:+, _, [p,q]}), do: %S{terms:   [ parse(p), parse(q) ]}

  #TODO factor out macro from nept 2 bubble_plus cases?
  # this allows our plus signs to "bubble up" the tree, until our invariant is reached.
  def bubble_plus(%P{factors: [ %S{terms: [p, q]}, m ]}), do:
    %S{terms: [ bubble_plus(%P{factors: [p,m]}), bubble_plus(%P{factors: [q,m]}) ]}
  # and the right subtree
  def bubble_plus(%P{factors: [ n, %S{terms: [p, q]} ]}), do:
    %S{terms: [ bubble_plus(%P{factors: [n, p] }), bubble_plus(%P{factors: [n, q] }) ]}

  # now, everqthing else we wanna just pass through, except of course
  # we want to applq bubble_plus to subtrees in the S and (those) P (cases not
  # already covered).
  def bubble_plus(%P{factors: [p, q]}), do: %P{factors: [ bubble_plus(p), bubble_plus(q) ]}
  def bubble_plus(%S{terms: [m, n]}), do: %S{terms: [ bubble_plus(n), bubble_plus(m) ]}
  def bubble_plus(elem) when is_struct(elem) and elem.__struct__ in [N,V], do: elem




  #TODO factor out macro from next 2 sop cases
  # consolidate our terms
  def sopxx({:+, _, [ {:+, _, [a,b]}, m ]}), do:
    %S{terms: [
      sopxx(a),
      sopxx(b),
      sopxx(m)
    ]}
  def sopxx({:+, _, [ n, {:+, _, [a,b]} ]}), do:
    %S{terms: [
      sopxx(n),
      sopxx(a),
      sopxx(b)
    ]}

  # back up the call stack
  def sopxx({:*, _, [a,b]}), do: %P{factors: [a,b]}
  def sopxx({:+, _, [x,y]}), do: %S{terms: [x,y]}
end











defmodule Tracer do
  @moduledoc """
  taken from https://www.theerlangelist.com/article/macros_1
  """
  defmacro trace(expr_ast) do
    str_repr = Macro.to_string(expr_ast)
    quote do
      ans = unquote(expr_ast)
      Tracer.print(unquote(str_repr), ans)
      ans
    end
  end

  def print(str_repr, ans) do
    IO.puts("ans of #{str_repr}: #{inspect ans}")
  end
end
