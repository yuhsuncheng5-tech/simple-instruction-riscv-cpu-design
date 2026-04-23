# simple-instruction-riscv-cpu-design

## Overview
This project is a 32-bit pipelined RISC-V CPU implemented in Verilog via Vivado. Featuring a four-stage pipeline, custom ALU, and control units, it supports R, I, S, B, U, and J-type instructions. It includes hazard management and custom testbenches for streamlined simulation and hardware verification. 

## Features
* **Pipelined Architecture:** Utilizes a pipeline layout with dedicated hardware registers (IF/ID, ID/EX, EX/MEM, MEM/WB) to maximize instruction throughput.
* **Custom Hardware Modules:** Built from scratch with dedicated functional units, including an Arithmetic Logic Unit (ALU), Control Unit, Register File, and Memory/Program Counter (PC) units.
* **Instruction Set Architecture:** Supports fundamental RISC-V instructions across multiple formats:
  * **R-type:** `ADD`, `SUB`, `AND`, `OR`, `XOR`
  * **I-type:** `ADDI`, `LW`
  * **S-type:** `SW`
  * **B-type:** `BEQ`
  * **J-type / U-type:** `JAL`, etc.
* **Hazard Resolution:** Integrates dedicated logic to successfully manage pipeline stalls and load-use hazards, ensuring data consistency during execution.
<img width="848" height="499" alt="RISC CPU" src="https://github.com/user-attachments/assets/22bf52ae-60b4-40ef-9d15-dbca9793feb6" />

## Project Structure
* `src/` - Contains all Verilog source files for the CPU components (ALU, Control Unit, Pipeline Registers, Memory, etc.).
* `tb/` - Contains custom Verilog testbenches used for hardware verification and simulation.

## Technologies Used
* **Hardware Description Language:** Verilog
* **Development Environment:** Xilinx Vivado

## Getting Started
1. Clone the repository to your local machine.
2. Open Xilinx Vivado and create a new project, adding all the Verilog files from the `src/` directory as design sources.
3. Load your desired machine code into the CPU's instruction memory module.
4. Add the testbenches from the `tb/` directory as simulation sources in Vivado and run the behavioral simulation to verify the pipeline and instruction execution.


