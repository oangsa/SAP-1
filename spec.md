# 8-bit Single-Bus Hardwired CPU Specification

## 1. Overview
This document specifies a simple educational CPU system with the following fixed characteristics:

- Data width: 8 bits
- Internal architecture: single shared data bus
- Control style: hardwired control logic (no microcode)
- Main memory size: 16 bytes (address range `0x0` to `0xF`)
- Processing core includes an ALU
- Core registers:
	- Program Counter (`PC`)
	- Memory Address Register (`MAR`)
	- Instruction Register (`IR`)
	- Register `A` (operand/result register)
	- Register `B` (second operand register)

This CPU is intended for small programs and simple arithmetic/logic demonstrations.

## 2. Architectural Model

### 2.1 Data and Address Width
- Data path width is 8 bits.
- Since memory has 16 bytes, addresses are 4 bits wide.

### 2.2 Bus Structure
- One 8-bit internal bus is shared by registers, ALU output path, and memory data transfers.
- Only one source may drive the bus at a time.
- One or more destination registers may latch bus data in a cycle if control signals allow it.

### 2.3 Clocking and Reset
- Synchronous design using a single system clock.
- Active reset initializes architectural state as follows:
	- `PC <- 0x0`
	- `MAR <- 0x0`
	- `IR <- 0x00`
	- `A <- 0x00`
	- `B <- 0x00`

## 3. Memory Subsystem

### 3.1 Capacity and Address Map
- Memory contains exactly 16 locations of 8 bits each.
- Valid addresses: `0x0` to `0xF`.

### 3.2 Interface Behavior
- `MAR` provides the memory address.
- Reads return the addressed byte onto the bus through controlled gating.
- Writes store bus data into the addressed memory locationProgram counter.

## 4. Register Definitions

### 4.1 Program Counter (`PC`)
- Width: 4 bits (or wider with lower 4 bits used for memory addressing).
- Holds address of the next instruction fetch.
- Supports:
	- Increment (`PC <- PC + 1`)
	- Load from bus (for jump/branch style operations)

Repository note:
- The standalone implementation of the program counter is `src/module/pc.v`.
- The control unit should drive the PC through control signals such as increment, load, and bus-enable behavior.
- The control unit should not maintain a duplicate internal PC register.

### 4.2 Memory Address Register (`MAR`)
- Width: 4 bits.
- Holds effective memory address for current read/write operation.
- Loaded from bus.

### 4.3 Instruction Register (`IR`)
- Width: 8 bits.
- Holds the currently fetched instruction.
- Loaded from bus during fetch.

### 4.4 Register `A`
- Width: 8 bits.
- Primary accumulator-style register.
- Stores one ALU operand and receives ALU results.
- May also exchange data with memory via the shared bus.

### 4.5 Register `B`
- Width: 8 bits.
- Secondary operand register for ALU operations.
- Loaded from bus.

## 5. ALU Specification

### 5.1 Inputs and Output
- Input 1: `A`
- Input 2: `B`
- Output: ALU result routed to internal bus (then typically latched into `A`)

### 5.2 Required Operations
At minimum, the ALU shall support:
- `ADD`: `A + B`
- `SUB`: `A - B`
- `AND`: bitwise AND
- `OR`: bitwise OR
- `XOR`: bitwise XOR
- `NOT`: bitwise NOT of `A` (or defined unary path)
- `PASS`: pass-through (e.g., `A`)

All results are 8-bit wide; overflow wraps modulo 256.

### 5.3 Status Flags (Recommended)
If flags are implemented, use:
- `Z` (zero): result equals `0x00`
- `C` (carry/borrow): carry out of add or borrow condition for subtract

Flags are optional unless required by instruction behavior.

## 6. Control Unit (Hardwired)
- The control unit is implemented as combinational/sequential logic that decodes `IR` and current timing step.
- No microinstruction ROM is used.
- Control signals include (representative):
	- Bus source select
	- Register load enables (`PC`, `MAR`, `IR`, `A`, `B`)
	- `PC` increment / load control
	- Memory read / write enable
	- ALU operation select

Implementation note:
- In this repository, `src/module/control_unit.v` is intended to generate control signals only.
- A separate top-level integration module may connect `control_unit`, `pc`, bus, memory, and datapath registers together.

## 7. Execution Model

### 7.1 Instruction Cycle
Each instruction executes in ordered phases:
1. Fetch
2. Decode
3. Execute

### 7.2 Fetch Sequence (reference)
1. `MAR <- PC`
2. Memory read, `IR <- M[MAR]`
3. `PC <- PC + 1`

Execution phase behavior depends on opcode type.

## 8. Instruction Encoding (Project-Defined)
The exact opcode map is implementation-defined, but should fit 8-bit instructions and the 4-bit address space. A common format is:

- Upper nibble `[7:4]`: opcode
- Lower nibble `[3:0]`: immediate/address field

Recommended minimum instruction classes:
- Data move/load/store
- ALU operations on `A` and `B`
- Control flow (jump/branch) using `PC` load semantics

## 9. Design Constraints
- Single-bus rule must be enforced to prevent contention.
- All storage elements are edge-triggered and synchronized to one clock domain.
- Behavior outside valid memory range `0x0` to `0xF` is undefined or masked by 4-bit addressing.
- Implementation should remain modular (separate ALU, register file/blocks, control, and memory modules).

## 10. Verification Expectations
At minimum, testbenches should verify:
- Reset state of all required registers
- Correct instruction fetch sequence
- Correct ALU results for all defined operations
- Correct memory read/write for all 16 addresses
- Correct `PC` increment and load behavior

---
This specification defines the required architecture baseline for the project. Instruction-level details may be extended, provided they remain consistent with the constraints above.
