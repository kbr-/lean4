module

public import Lib.ChainThree
public import Lib.DupX

public theorem uses_three : chain = chain ∧ dup = dup := ⟨rfl, rfl⟩
