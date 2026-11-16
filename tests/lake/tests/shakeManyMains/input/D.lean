module

-- Declares `dup` as `B` does, so it can't join `A`'s group, and `main_eq` as `B` does, about a
-- `main` of `B`'s type, so it can't join `B`'s either. Its `main` is renamed apart, while its
-- reference to `Lib.HelperOne`'s `main.helper` keeps pointing at that module.
import Lib.DupZ
public import Lib.HelperOne

@[expose] public def main : IO Unit := pure ()

public theorem main_eq : main = main := rfl

public theorem helper_one : main.helper = main.helper := rfl
