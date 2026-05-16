# CPU and Register Known Bugs

## Summary

Against the current assignment spec, the main problems are in `src/module/cpu.v`. The current `src/module/register.v` file looks acceptable for the A/B register role at this stage.

## Known Bugs

1. `src/module/cpu.v` does not use the actual `pc.v` module.
   The top-level CPU builds its own shadow PC value instead of instantiating and wiring the standalone program counter module required by the project structure.

2. The CPU shadow PC behavior is wrong for the assignment spec.
   In `src/module/cpu.v`, the shadow PC only changes on `PC_inc`, ignores `PC_in`/load behavior, and increments by 4 instead of 1. This breaks normal instruction fetch sequencing for a 16-byte, 4-bit-address SAP-1 style design.

3. The CPU currently fails its own top-level execution test.
   Running `test/tb_cpu.v` ends with `A register = 3 (expected 9)`, so the current CPU top-level module does not correctly execute the simple `LDA 3` followed by `ADDA 6` flow.

4. The CPU inherits the current control-unit state bug directly.
   `src/module/cpu.v` wires in `src/module/control_unit.v` as-is, so the broken state-width handling in the control unit also affects the CPU top-level behavior.

5. `test/tb_cpu.v` is compensating for broken PC behavior.
   The testbench places the second instruction at `ram[4]` instead of the next sequential address because the current CPU PC path increments by 4. This means the test is validating the current broken behavior rather than the assignment-spec behavior.

## Register Status

`src/module/register.v` currently looks okay for the A/B register role:

- `reg_A` resets to zero and loads the bus when `A_in` is asserted
- `reg_B` resets to zero and loads the bus when `B_in` is asserted

## Verification Notes

- There is currently no dedicated standalone testbench for `src/module/register.v`.
- The main issues at this stage are in CPU integration, not in the current A/B register implementation.
