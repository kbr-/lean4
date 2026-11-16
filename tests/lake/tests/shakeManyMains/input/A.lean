module

public import Lib.Used
public import Lib.Mid
import Lib.DupX
import Lib.DupY

-- The `match` gives `main` an auxiliary declaration `main.match_1`, which `C` declares too.
@[expose] public def main (args : List String) : IO Unit :=
  match args with
  | [] => IO.println s!"{greeting} {mid}"
  | _ => pure ()

/-- Declared by `E` too, under its own `main`, which is renamed apart. -/
public structure main.Box where
  n : Nat

/-- A reference to this module's own `main`, which must keep resolving here. -/
public theorem main_def : main [] = IO.println s!"{greeting} {mid}" := rfl
