`timescale 1ns / 1ps

module qmult(
    input [31:0] a,
    input [31:0] b,
  output [63:0] c
    );

	//Parameterized values
	parameter Q = 15;
	parameter N = 32;
 
	wire [2*N-1:0] a_ext;
	wire [2*N-1:0] b_ext;
	wire [2*N-1:0] r_ext;
 
	reg [2*N-1:0] a_mult;
	reg [2*N-1:0] b_mult;
	reg [2*N-1:0] result;
 	reg [2*N-1:0] retVal;
 
 
	qtwosComp comp_a (a[30:0], a_ext);
 
	qtwosComp comp_b (b[30:0], b_ext);
 
	qtwosComp comp_r (result[N-2+Q:Q], r_ext);
 
	assign c = retVal;
 
	always @(a_ext,b_ext)
	begin
		if(a[N-1] == 1)
			a_mult <= a_ext;
		else
			a_mult <= a;
 
		if(b[N-1] == 1)
			b_mult <= b_ext;
		else
			b_mult <= b;		
	end 
 
	always @(a_mult,b_mult)
	begin
		result = a_mult * b_mult;
      //$display("%b and %b is %b",a_mult,b_mult,a_mult * b_mult);
      //$display("result   is     %b",result);
	end
 
	always @(result,r_ext)
	begin		
		//sign
      if((a[N-1] == 1 && b[N-1] == 0) || (a[N-1] == 0 && b[N-1] == 1)) begin
          retVal[2*N-1] = 1;
			retVal[2*N-2:0] <= r_ext[2*N-2:0];
		end
		else begin
			retVal[2*N-1] = 0;
          retVal[2*N-2:0] = result[2*N-2:0];//result[2*N-2+2*Q:2*Q];
		end
      //$display("value of retval %b",retVal);
    end
 
endmodule
