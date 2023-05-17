`timescale 1ns/1ps
interface fp_inf(input bit clk);
    logic [31:0] a;
    logic [31:0] b;
    logic [1:0] opcode;
    logic [31:0] c;
    logic start=1;
	logic done_flag;
	
    modport slave (input a, b, opcode, start, output c , done_flag );

parameter Q = 15;
parameter N = 32;

//real,logic
task conv_rational;
	input real num;
	output [N-1:0] fixed;
 
    integer i;
    real tmp;

    begin
	    tmp = num;
 
	    //set sign
		if(tmp < 0) begin
		//if its negative, set the sign bit and make the temporary number position by multiplying by -1
		    fixed[N-1] = 1;
			tmp = tmp * -1;
		end
		else begin
		 //if its positive, the sign bit is zero
		    fixed[N-1] = 0;
		end
 
		 //check that the number isnt too large
		if(tmp > (1 << N-Q-1)) begin
		    $display("Error!!! rational number %f is larger than %d whole bits can represent!",num,N-Q-1);
		end
 
		 //set whole part
		for(i=0; i<N-Q-1; i=i+1) begin
		    if(tmp >= (1 << N-Q-2-i)) begin
		    //if its greater or equal, subtract out this power of 2 and put a one at this position
		        fixed[N-2-i] = 1;
				tmp = tmp - (1 << N-Q-2-i);
			end
			else begin
			//if its less, put a zero at this position
				fixed[N-2-i] = 0;
			end
		end
 
		 //set fractional part
		for(i=1; i<=Q; i=i+1) begin
			if(tmp >= 1.0/(1 << i)) begin
			//if its greater or equal, subtract out this power of 2 and put a one at this position
				fixed[Q-i] = 1;
				tmp = tmp - 1.0/(1 << i);
			end
			else begin
			//if its less, put a zero at this position
				fixed[Q-i] = 0;
			end
	    end
 
		 //check that the number isnt too small (loss of precision)
		if(tmp > 0) begin
			$display("Error!!! LOSS OF PRECISION converting rational number %f's fractional part using %d bits!",num,Q);
		end
	 end
endtask

/*
	*	Task to convert from fixed point to rational
*/
//logic,real
task conv_fixed;
	input [N-1:0] fixed;
	output real num;
 
	integer i;
 
	begin
		num = 0;
 
		 //set whole part
		for(i=0; i<N-Q-1; i=i+1) begin
			if(fixed[N-2-i] == 1) begin
			//if theres a one at this position, add the power of 2 to the rational number
				num = num + (1 << N-Q-2-i);
			end
		end
 
		 //set fractional part
		for(i=1; i<=Q; i=i+1) begin
			if(fixed[Q-i] == 1) begin
			//if theres a one at this position, add the power of 2 to the rational number
				num = num + 1.0/(1 << i);
			end
		end
 
		 //set sign
		if(fixed[N-1] == 1) begin
		 //if the sign bit is set, negate the rational number
			num = num * -1;
		end
	 end
endtask


endinterface