# SHA-256 VHDL Implementation

## Project Overview
This project provides a VHDL implementation of the SHA-256 cryptographic hash algorithm, designed for ASIC and FPGA systems. The implementation includes:
- `sha256.vhd`: The core module implementing the SHA-256 algorithm.
- `sha256_tb.vhd`: A testbench to simulate and validate the functionality of the SHA-256 implementation.

## Features
- Full 512-bit message block input.
- Outputs a 256-bit hash digest.
- Supports ASIC and FPGA synthesis.
- Testbench included for verification.

## How to Use
1. Add the VHDL files to your project in a VHDL-compatible simulation tool (e.g., ModelSim, GHDL, or Vivado).
2. Simulate the testbench (`sha256_tb.vhd`) to verify functionality.
3. Synthesize and implement the `sha256.vhd` file on an FPGA for hardware testing.

## Test Data
- Input: "abc" (padded to 512 bits).
- Expected Output: `BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD`.

## Folder Structure

## Author
- Abdulmunem A. Abdulsamad
- Research Topic: Application of FPGA Devices in Network Security
