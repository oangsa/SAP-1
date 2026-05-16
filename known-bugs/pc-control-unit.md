# PC and Control Unit Known Bugs

## Summary

Against the current assignment spec, `src/module/pc.v` is in good shape. The confirmed bugs are on the control-unit side and in the control-unit/ALU interface.

## Known Bugs

1. `state` is too narrow in `src/module/control_unit.v`.
   `state` is declared as 4 bits, but several state constants use values from 16 to 31. Those values wrap in 4 bits, so instructions such as `STRA`, `MOVAB`, `LDB`, `ADDB`, `SUBB`, `ADDBI`, `SUBBI`, `STRB`, and `MOVBA` decode to the wrong effective state values.

2. The control-unit ALU opcode meanings do not match `src/module/alu.v`.
   `src/module/control_unit.v` assumes `010 = B_sub_A`, `011 = Pass_A`, and `100 = Pass_B`, but `src/module/alu.v` implements `010 = AND`, `011 = OR`, and `100 = XOR`. Because of that, `SUBB`, `MOVAB`, `MOVBA`, `STRA`, and `STRB` will not behave correctly in an integrated CPU.

## PC Module Status

`src/module/pc.v` currently looks correct for the project spec:

- reset clears `pc_out` to `0`
- `load` takes `bus_in[3:0]`
- `increment` adds 1
- `load` has priority over `increment`

## Verification / Design Notes

- `test/control_unit_test.v` currently hides the state-width bug because expected state values are also truncated to 4 bits during comparison.
- `test/control_unit_test.v` ends with `$stop` instead of `$finish`, so simulation keeps running unless it is stopped manually.
- `src/module/control_unit.v` generates control outputs in the same clocked block that updates the FSM state. This is a timing risk for later integration, but it is listed here as a design concern rather than a direct assignment-spec mismatch.
