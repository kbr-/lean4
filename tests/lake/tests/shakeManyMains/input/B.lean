module

public import Lib.Used
public import Lib.Mid
import Lib.DupZ

-- `base` comes from `Lib.Base` through `Lib.Mid`'s re-export, which shake removes from `Lib.Mid`
-- while checking `A`'s group: `B`, checked apart, must be told to import `Lib.Base` itself.
@[expose] public def main : IO Unit := IO.println s!"{greeting} {mid} {base}"

/-- A reference to this module's own `main`, which must keep resolving here. -/
public theorem main_def : main = IO.println s!"{greeting} {mid} {base}" := rfl

/-- Stated alike in `D`, whose `main` has this type too; once each `main` has a name of its own,
the two statements differ, and `D` is checked apart from `B`. -/
public theorem main_eq : main = main := rfl
