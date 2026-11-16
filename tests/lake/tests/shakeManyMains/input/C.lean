module

public import Lib.Used
import Lib.DupX
import Lib.DupY

-- `main.match_1` here and in `A`, both exported, differ; `C` still shares `A`'s environment.
@[expose] public def main (args : List String) : IO Unit :=
  match args with
  | [] => IO.println greeting.length
  | _ => pure ()

/-- A reference to this module's own `main`; `C` shares `A`'s environment, so it must not resolve
to `A`'s `main`. -/
public def twice : IO Unit := main [] *> main []
