# PC and Control Unit Known Bugs

## Summary

The standalone PC module in `src/module/pc.v` is behaving as intended. The currently known bugs are in the control-unit side and in how it matches the rest of the datapath.

## Known Bugs

1. `state` is too narrow in `src/module/control_unit.v`.
   `state` is declared as 4 bits, but several state constants use values from 16 to 31. Those values wrap in 4 bits, so instructions such as `STRA`, `MOVAB`, `LDB`, `ADDB`, `SUBB`, `ADDBI`, `SUBBI`, `STRB`, and `MOVBA` decode to the wrong effective state values.

2. The control-unit test currently hides the state-width bug.
   In `test/control_unit_test.v`, the expected state argument is also 4 bits wide, so values like 16, 17, and 18 are truncated during comparison. This can make broken decode behavior appear to pass.

3. Control signals are generated in the same clocked block that updates the FSM state.
   In `src/module/control_unit.v`, outputs such as `PC_inc`, `MAR_in`, `IR_in`, `A_in`, and `B_in` are assigned inside the `posedge clk` state machine block. In a full CPU, that creates timing/race risk because datapath registers also sample control lines on the clock edge.

4. The control-unit ALU opcode meanings do not match `src/module/alu.v`.
   `src/module/control_unit.v` assumes `010 = B_sub_A`, `011 = Pass_A`, and `100 = Pass_B`, but `src/module/alu.v` implements `010 = AND`, `011 = OR`, and `100 = XOR`. Because of that, `SUBB`, `MOVAB`, `MOVBA`, `STRA`, and `STRB` will not behave correctly in an integrated CPU.

5. The control-unit testbench does not terminate cleanly.
   `test/control_unit_test.v` ends with `$stop` instead of `$finish`, so `vvp` keeps running after printing the summary unless the simulator is manually stopped.

## PC Module Status

`src/module/pc.v` currently looks correct for the project spec:

- reset clears `pc_out` to `0`
- `load` takes `bus_in[3:0]`
- `increment` adds 1
- `load` has priority over `increment`

The main remaining work is around the control unit and eventual top-level integration, not the PC module itself.
