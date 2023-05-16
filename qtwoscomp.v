`timescale 1ns/1ps
module qtwosComp(
    input [30:0] a,
    output [63:0] b
    );
	parameter Q = 15;
	parameter N = 32;
	reg [2*N-1:0] data;
	reg [2*N-1:0] flip;
	reg [2*N-1:0] out;
 
	
 
	assign b = out;
 
	always @(a)
	begin
		data <= a;		//if you dont put the value into a 64b register, when you flip the bits it wont work right
	end
 
	always @(data)
	begin
		flip <= ~a;
	end
 
	always @(flip)
	begin
		out <= flip + 1;
	end
 
endmodule