module

-- Loaded first, so `Lib.ChainTwo`'s theorem comes before both axioms; `Lib.DupZ` keeps
-- `Lib.ChainUseOne` and `Lib.ChainUseThree` out of this module's group.
public import Lib.ChainTwo
public import Lib.DupZ

public theorem uses_two : chain = chain ∧ dup = dup := ⟨rfl, rfl⟩
