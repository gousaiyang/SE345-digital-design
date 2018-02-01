# Experiment Exam

## Problem
You will be asked to add an instruction to your CPU, and write corresponding assembly code to test the correctness of your implementation. You can choose to implement this either on the single-cycle CPU or the pipelined CPU as you wish.

The problem in this repo:
> Add a R-type instruction `hamd R3, R1, R2`, which can calculate the [hamming distance](https://en.wikipedia.org/wiki/Hamming_distance) between two 32bit integers(`R1` and `R2`) and store to `R3`. Write some assembly code to calculate the hamming distance between `8'b11001010` and `SW[7..0]`, and show result on `HEX0` in decimal format.

## Solution
Steps:
1. Think clearly and find out what the new instruction will do in every stage (Fetch, Decode, Execute, Memory, Write Back). Fulfill the truth table.
2. Consider what hazards (along with combinational hazards) will arise when we add the new instruction, when and where to detect the hazards, and how to deal with the hazards.
3. Find out the verilog files that you need to modify/add, and finish implementation.
4. Write assembly code to test your implementation.

In this problem, `hamd` is simply a calculational R-type instruction, which will not introduce any new hazards, so we only need to modify `pipe_cu.v` and `alu.v`. In order to enhance modularity, I put the concrete implementation of hamming distance calculation into a new file `hamd.v`. Finally `hamd_test.s` is written to test correctness on board.
