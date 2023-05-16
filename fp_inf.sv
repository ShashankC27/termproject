`timescale 1ns/1ps
interface fp_inf(input bit clk);
    logic [31:0] a;
    logic [31:0] b;
    logic [1:0] opcode;
    logic [31:0] c;
    logic start=1;

    modport slave (input a, b, opcode, start, output c );

endinterface