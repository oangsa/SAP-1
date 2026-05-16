# SAP-1 Verilog Project Specification

## 1. Overview

Implement a simplified SAP-1 computer in Verilog.

The design must follow these fixed requirements:

- 8-bit data path
- single internal bus
- hardwired control unit
- total memory size of 16 bytes
- one ALU
- the following registers:
  - Program Counter (`PC`)
  - Memory Address Register (`MAR`)
  - Instruction Register (`IR`)
  - Register `A`
  - Register `B`

## 2. Required Modules

The project is organized into the following modules:

- Top module: `CPU`
- Control unit
- Register
- Program counter (`PC`)
- Arithmetic logic unit (`ALU`)
- Memory
- Bus

## 3. Architectural Constraints

### 3.1 Data and Address Width

- All main data transfers are 8 bits wide.
- Since the memory size is 16 bytes, memory addresses are 4 bits wide.

### 3.2 Bus Organization

- The system uses one shared internal 8-bit bus.
- Only one source may drive the bus at a time.
- Registers may load data from the bus when enabled by the control unit.

### 3.3 Control Style

- The CPU uses a hardwired control unit.
- No microcode ROM is required.

## 4. Register Requirements

### 4.1 Program Counter (`PC`)

- Holds the address of the next instruction.
- Uses 4-bit addressing for the 16-byte memory space.
- Must support increment.

### 4.2 Memory Address Register (`MAR`)

- Holds the memory address used for memory access.
- Width is 4 bits.

### 4.3 Instruction Register (`IR`)

- Holds the current instruction.
- Width is 8 bits.

### 4.4 Register `A`

- Stores one operand for ALU operations.
- Stores ALU results.
- Width is 8 bits.

### 4.5 Register `B`

- Stores the second operand for ALU operations.
- Width is 8 bits.

## 5. ALU Requirements

- The CPU includes one ALU.
- The ALU operates on 8-bit values.
- The ALU uses register `A` and register `B` as operands.

## 6. Memory Requirements

- Total memory size is 16 bytes.
- Each memory location stores 8 bits.
- Valid address range is `0x0` to `0xF`.

## 7. Top-Level Behavior

- The `CPU` top module is responsible for connecting the control unit, registers, PC, ALU, memory, and bus together.
- The system is synchronous and uses a shared clock.
- The design should support reset behavior appropriate for the CPU state elements.

## 8. Notes

- This file is intended to match the given project instruction.
- Detailed instruction encoding, micro-operations, and implementation choices may be defined separately as long as they remain consistent with the requirements above.
