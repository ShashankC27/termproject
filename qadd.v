`timescale 1ns/1ps
module qadd(
    input [31:0] a,
    input [31:0] b,
    output [31:0] c,
	output done_flag
    );

//sign+16.15
//Parameterized values

reg done=0;

parameter Q = 15;
parameter N = 32;
 
reg [N-1:0] res;
 
assign c = res;
assign done_flag=done;

always @(a,b)
begin
	//both negative
	if(a[N-1] == 1 && b[N-1] == 1) begin
		//sign
		res[N-1] = 1;
		//whole
		res[N-2:0] = a[N-2:0] + b[N-2:0];
	end
	//both positive
	else if(a[N-1] == 0 && b[N-1] == 0) begin
		//sign
		res[N-1] = 0;
		//whole
		res[N-2:0] = a[N-2:0] + b[N-2:0];
	end
	//subtract a-b
	else if(a[N-1] == 0 && b[N-1] == 1) begin
		//sign
		if(a[N-2:0] > b[N-2:0])
			res[N-1] = 1;
		else
			res[N-1] = 0;
		//whole
		res[N-2:0] = a[N-2:0] - b[N-2:0];
	end
	//subtract b-a
	else begin
		//sign
		if(a[N-2:0] < b[N-2:0])
			res[N-1] = 1;
		else
			res[N-1] = 0;
		//whole
		res[N-2:0] = b[N-2:0] - a[N-2:0];
	end
	done=1;
end
 
endmodule
 