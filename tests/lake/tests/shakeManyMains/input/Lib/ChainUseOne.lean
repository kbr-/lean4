module

-- With `Lib.ChainUseThree`, the two axioms without the theorem that subsumes both.
public import Lib.ChainOne
public import Lib.DupX

public theorem uses_one : chain = chain ∧ dup = dup := ⟨rfl, rfl⟩
