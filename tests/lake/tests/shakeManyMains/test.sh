#!/usr/bin/env bash
source ../common.sh

./clean.sh

# Test `lake shake` on several executables' roots at once: `A`, `B` and `C` each declare `main`,
# `A` and `C` each declare `main.match_1` for the `match` in their `main`, and `A` and `B` each
# declare a theorem `main_def` about their own `main`, which cannot share one environment. `A` and
# `C` import two modules declaring the same theorem `dup`, which load together, and `B` one
# declaring `dup` as a definition; `Lib.HelperOne` and `Lib.HelperTwo` declare `main.helper`
# differently, with no `main` of their own; `Lib.ChainOne`, `Lib.ChainTwo` and `Lib.ChainThree`
# declare `chain` as an axiom, a theorem and an axiom, which `finalizeImport` accepts together.

# `shake --fix` rewrites the sources it is given, so work on a copy
copy_to_work input/*
test_run build
test_run build +Lib.HelperOne +Lib.HelperTwo +Lib.Legacy +Lib.ChainOne +Lib.ChainTwo \
  +Lib.ChainThree +Lib.ChainUseOne +Lib.ChainUseTwo +Lib.ChainUseThree

ROOTS="A B C D E Lib.Used Lib.HelperOne Lib.HelperTwo Lib.ChainOne Lib.ChainTwo Lib.ChainThree"

# The roots load together, `B` apart from `A` for its `main_def`, `C` with `A` although each
# declares `dup` in two modules; the unused import of `Lib.Used`, reached from all three, is
# reported once, and the call fails for it.
if lake_out shake $ROOTS; then
  echo "FAILURE: expected shake to report unused imports"
  exit 1
fi
no_match_pat 'already contains' produced.out
match_pat 'B.*checked apart.*(main_def|dup)' produced.out
no_match_pat 'C.*checked apart' produced.out
no_match_pat 'Chain.*checked apart' produced.out
match_pat 'D.*checked apart' produced.out
match_pat 'remove.*Lib.Unused' produced.out
test "$(grep -c 'Used.lean:' produced.out)" = 1

# Each module's references to its own `main` keep pointing at it: no executable is told to import
# another. `D`'s `main` is renamed apart while its reference to `Lib.HelperOne`'s `main.helper`
# keeps that import used. `E`, loaded with `A`, renames its own `main.Box` apart from `A`'s, its
# projections included.
no_match_pat 'add.*import (A|B|C|D|E)\b' produced.out
no_match_pat 'E.*checked apart' produced.out
test "$(grep -A3 'D.lean:' produced.out | grep -c 'Lib.HelperOne')" = 0

# `Lib.Mid` loses its unused re-export of `Lib.Base` while `A`'s group is checked; `B`, checked
# apart, uses `Lib.Base` through it and is told to import it.
match_pat 'remove.*Lib.Base' produced.out
test "$(grep -A3 'B.lean:' produced.out | grep -c 'add.*Lib.Base')" = 1

# Alone, the three `Chain` modules load in one group too: `finalizeImport` takes the theorem in
# place of the first axiom before it meets the second, which only the theorem subsumes.
lake_out shake Lib.ChainOne Lib.ChainTwo Lib.ChainThree
no_match_pat 'checked apart' produced.out

# A group is checked on its own modules: `Lib.ChainUseOne` and `Lib.ChainUseThree`, each kept from
# `Lib.ChainUseTwo`'s group by `dup`, load the two axioms without the theorem, which don't load
# together, so the last is checked apart from both.
lake_out shake Lib.ChainUseTwo Lib.ChainUseOne Lib.ChainUseThree
no_match_pat 'already contains' produced.out
match_pat 'ChainUseThree.*checked apart' produced.out

# With one root, a call refused by its checks prints no `--fix` header, as before.
if lake_out shake --fix --add-downstream A B; then
  echo "FAILURE: expected --add-downstream of a module B doesn't import to be refused"
  exit 1
fi
match_pat 'cannot add .A. downstream, it is not imported' produced.out
no_match_pat 'will be made automatically' produced.out

# `--add-downstream` across roots checked apart is refused before any file is edited.
if lake_out shake --fix --add-downstream Lib.Base $ROOTS; then
  echo "FAILURE: expected --add-downstream across groups to be refused"
  exit 1
fi
match_pat 'cannot add .Lib.Base. downstream across roots that are checked apart' produced.out
no_match_pat '`dup`, `dup`' produced.out
match_text 'import Lib.Unused' Lib/Used.lean

# A group refused after the first, here for `Lib.Legacy`, which is no `module`, leaves the first
# group's edits unwritten and unannounced.
if lake_out shake --fix $ROOTS Lib.Legacy; then
  echo "FAILURE: expected shake to refuse Lib.Legacy"
  exit 1
fi
match_pat 'only works with .module.s' produced.out
no_match_pat 'will be made automatically' produced.out
no_match_pat 'remove' produced.out
match_text 'import Lib.Unused' Lib/Used.lean

# `--fix` removes the imports, with one summary for all groups, after which the project builds and
# shakes clean.
lake_out shake --fix $ROOTS
test "$(grep -c 'Successfully applied' produced.out)" = 1
test_run build
test_run shake $ROOTS
