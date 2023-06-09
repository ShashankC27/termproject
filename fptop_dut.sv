`timescale 1ns/1ps
`default_nettype none

module fptop_dut(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] c,
    output reg done_flag,
	input clk,
	input start,
	input [1:0] opcode
    );

	localparam Add = 2'b00;
	localparam Mul = 2'b01;
	localparam Div = 2'b10;

	// Inputs
	reg [31:0] a_sig;
	reg [31:0] b_sig;
    
    reg done_flag_add;
    reg done_flag_div;
    reg done_flag_mult;
	//temporary Outputs
	wire [31:0] result;
    wire [31:0] c_adder;
    //wire [31:0] c_multiplier;
    wire [31:0] c_divider;
 
	//qadd #(23, 32) adder(a, b, c_adder);
    //qmult #(23, 32) multiplier(a, b, c_multiplier);
    //qdiv #(15, 32) divider(a, b, start, clk, c_divider, flag_done);

    assign a_sig = a;
    assign b_sig = b;

    //reg flag_done;

    qadd adder(.a(a_sig),.b(b_sig),.c(c_adder),.done_flag(done_flag_add));
    //qmult multiplier(.a(a_sig),.b(b_sig),.c(c_multiplier));
    qdiv divider(.dividend(a_sig),.divisor(b_sig),.start(start),.clk(clk),.quotient_out(c_divider),.complete(done_flag_mult));
	


	always @ (posedge clk) begin
       //$display("in the loop %d %d %d",a,b,opcode);
        if (1) begin
           // $display("in the loop %d",opcode);
            case (opcode)
                Add: begin
                    if(done_flag_add) begin
                   $display("Value for add is a_sign =%d b_sign =%d  and output is %d",a_sig,b_sig,c_adder);
                    c = c_adder;
                    done_flag=done_flag_add;
                    end
                end
                Mul: begin
                    //$display("Value for Mul is a_sign =%b b_sign =%b  and output is %b",a_sig,b_sig,c_multiplier);
                    //c <= c_multiplier;
                    //done_flag=done_flag_mult;
                end
                Div: begin
                    if(done_flag_div) begin
                    c <= c_divider;
                    done_flag=done_flag_div;
                    $display("Value for DIv is a_sign =%b b_sign =%b  and output is %b",a_sig,b_sig,c_divider);
                    end
                end
            endcase
        end
    end
endmodule