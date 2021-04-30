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
  defstruct     [:name]
end
defmodule SoP.Num do
  @enforce_keys [:val]
  defstruct     [:val]
end

#TODO factor out the common macro from Product and Sum
defmodule SoP.Product do
  defstruct     [factors: []]

  def multiply(%__MODULE__{factors: ff}, %__MODULE__{factors: gg}) do
    %__MODULE__{factors: ff ++ gg}
  end
end
defmodule SoP.Sum do
  defstruct     [terms: []]
  def add(%__MODULE__{terms: tt}, %__MODULE__{terms: ss}) do
    %__MODULE__{terms: tt ++ ss}
  end
end


defmodule SoP do
  alias SoP.Var, as: V
  alias SoP.Num, as: N
  alias SoP.Product, as: P
  alias SoP.Sum, as: S

  # sop invariant:  for every term node, every node from that node to the root is also a term
  def sop(n) when is_number(n), do: %N{val: n}
  def sop({var_name, [], _}) when is_atom(var_name), do: %V{name: var_name}


  #TODO factor out macro from next 2 sop cases
  # this allows our plus signs to "bubble up" the tree, until our invariant is reached.
  def sop({:*, _, [ {:+, _, [a,b]}, m ]}), do:
    %S{terms: [
      %P{factors: [sop(a), sop(m)]},
      %P{factors: [sop(b), sop(m)]}
    ]}
  def sop({:*, _, [n, {:+, _, [x,y]} ]}), do:
    %S{terms: [
      %P{factors: [sop(n), sop(x)]},
      %P{factors: [sop(n), sop(y)]}
    ]}


  #TODO factor out macro from next 2 sop cases
  # consolidate our terms
  def sop({:+, _, [ {:+, _, [a,b]}, m ]}), do:
    %S{terms: [
      sop(a),
      sop(b),
      sop(m)
    ]}
  def sop({:+, _, [ n, {:+, _, [a,b]} ]}), do:
    %S{terms: [
      sop(n),
      sop(a),
      sop(b)
    ]}

  # back up the call stack
  def sop({:*, _, [a,b]}), do: %P{factors: [a,b]}
  def sop({:+, _, [x,y]}), do: %S{terms: [x,y]}
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
