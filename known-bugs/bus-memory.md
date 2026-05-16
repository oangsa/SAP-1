# Bus and Memory Known Bugs

## Summary

Against the cleaned-up assignment spec, there are no strong direct spec violations in the current `bus.v` and `memory.v` modules. The remaining items are mostly design concerns and verification gaps to keep in mind during integration.

## Design / Verification Notes

1. `src/module/memory.v` hardcodes initial RAM contents inside the module.
   This is not forbidden by the assignment spec, but it makes the memory block less reusable and can conflict with tests or programs that are supposed to load their own contents.

2. `src/module/bus.v` hides bus-contention bugs by using priority logic.
   If more than one source-enable signal is asserted at the same time, the bus always picks one source by `if/else` priority order instead of exposing an invalid condition. This does not directly break the assignment spec, but it can hide upstream control bugs.

3. `src/module/memory.v` always exposes `data_out` with no explicit read-enable on the memory interface.
   The current design relies on the external bus mux to decide whether memory reaches the bus. That can still fit the assignment, but it makes the memory block less self-contained.

4. The current bus test does not verify correctness.
   `test/bus_test.v` changes the inputs over time, but it never checks whether `bus_data` matches the expected source value. Because of that, the test can pass even if the bus logic is wrong.

5. The current memory test does not verify correctness.
   `test/memory_test.v` performs reads and writes, but it does not contain assertions or comparisons for expected `data_out` values. A broken memory implementation could still appear to pass.

## Notes

- The current bus implementation appears fine for single-driver cases.
- The current memory write path appears fine for simple synchronous writes.
- The main risks at this stage are hidden integration problems and weak verification coverage, not clear assignment-spec violations.
