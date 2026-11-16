module

-- Its `main` and structure `main.Box` are renamed apart from `A`'s, projections included: the
-- value of `main.Box.n` projects from `main.Box`, so a projection left unrenamed would make this
-- module need `A`, whose `main.Box` it would then name.
public structure main.Box where
  n : Nat

public def main : IO Unit := pure ()
