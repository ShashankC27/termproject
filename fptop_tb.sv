`timescale 1ns/1ps
`default_nettype none

class transaction;
    rand bit [31:0] a;
    rand bit [31:0] b;
    rand bit [1:0] opcode;
    bit [31:0] c;
    reg done_flag;

    //opcode = 2'b00;

   constraint opcode_constraint {
        opcode inside {[0:2]};
    }

    function void display(string name);
        $display("------------------------");
        $display(" %s and values of a and b are %d %d",name,a,b);
        $display("%d value of opcode %d value of c",opcode,c);
        $display("------------------------");
    endfunction
endclass

class generator;
    transaction trans;
    mailbox gen_driv;

    function new (mailbox gen_driv);
        this.gen_driv =gen_driv;
    endfunction

    task main();
        repeat (10) begin
            trans = new();
            trans.randomize();
            trans.opcode=2'b00;
            trans.display("Generator Block");
            gen_driv.put(trans);
        end
    endtask
endclass

class driver;
    virtual fp_inf vif;
    mailbox gen_driv;

    function new(virtual fp_inf vif,mailbox gen_driv);
        this.vif=vif;
        this.gen_driv=gen_driv;
    endfunction

    task main();
        //repeat(10)
        forever begin
            transaction trans;
        if(gen_driv.try_peek(trans)) begin
            
            gen_driv.get(trans);
            vif.a = trans.a;
            vif.b = trans.b;
            vif.opcode=trans.opcode;
            trans.display("Driver Block");
            end
            $display("Waiting driver");
            while(!vif.done_flag)  begin
                #5;
                $display("Still in the wait block driver");
            end
            $display("done waiting driver");
        end
        
    endtask
endclass

class monitor;
    virtual fp_inf vif;
    mailbox mon_sb;
    transaction trans;

    function new (virtual fp_inf vif,mailbox mon_sb);
        this.vif =vif;
        this.mon_sb =mon_sb;
    endfunction

    task main();
        //repeat(10)
        $display("Here in the monitor");
        forever begin
            #5;
            
            trans = new();
            trans.a=vif.a;
            trans.b=vif.b;
            //->vif.done_flag;
            $display("Waiting");
            while(!vif.done_flag)  begin
                #5;
                $display("Still in the wait block");
            end
            $display("done waiting");
            trans.c=vif.c;
            trans.opcode=vif.opcode; 

            mon_sb.put(trans);
            trans.display("Monitor Block");
        end
    endtask
endclass

class scoreboard;
    mailbox mon_sb;
    transaction trans;

    function new(mailbox mon_sb);
        this.mon_sb =mon_sb;
    endfunction
    
    real ar,br,cr;
    virtual fp_inf i_intf;

    parameter Q = 15;
    parameter N = 32;

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

    task main();
        $display("here in the scoreboard");
        //repeat(10)
        forever begin
        
        if(mon_sb.try_peek(trans)) begin
            mon_sb.get(trans);
            trans.display("scoreboard");

            conv_fixed(trans.a,ar);
            conv_fixed(trans.b,br);
            conv_fixed(trans.c,cr);
            if((ar+br) == cr) begin
                $display("**********************************");
                $display("Correct output have been received.");
                $display(" a = %b, b = %b and c = %b",trans.a,trans.b,trans.c);
                $display(" a = %f, b = %f and c = %f",ar,br,cr);
                $display("ourput = %f and expected = %f",(ar+br),cr);
            end
            else begin
                $display("**********************************");
                $display("Incorrect output have been generated");
                $display(" a = %b, b = %b and c = %b",trans.a,trans.b,trans.c);
                $display(" a = %f, b = %f and c = %f",ar,br,cr);
                $display("ourput = %f and expected = %f",(ar+br),cr);
            end
        end
        end
    endtask

endclass

class environment;
    generator gen;
    driver driv;
    monitor mon;
    scoreboard scb;

    mailbox m1;
    mailbox m2;

    virtual fp_inf vif;

    function new(virtual fp_inf vif);
        this.vif=vif;
        m1 = new();
        m2 = new();
        gen = new(m1);
        driv = new(vif,m1);
        mon = new(vif,m2);
        scb = new(m2);
    endfunction

    task test();
        //fork
        gen.main();
        driv.main();
        mon.main();
        scb.main();
        //join_any
    endtask

    task run;
        test();
        //$finsih;
    endtask
endclass

program test(fp_inf i_intf);
    environment env;

    initial begin
        env = new(i_intf);
        env.run();
    end
endprogram

module top_tb;

    bit clk=0;
    bit start=1;

    
    always #5 clk = ~clk;
    
    fp_inf i_intf(clk);
    
    test t1(i_intf);

    fptop_dut dut(.a(i_intf.a),.b(i_intf.b),.clk(clk),.start(start),.opcode(i_intf.opcode),.c(i_intf.c),.done_flag(i_intf.done_flag));
    //top_dut dut(i_intf.slave);

    initial begin
        $vcdpluson;
        $vcdplusmemon;
        
        #10000;
        $finish;
    end
endmodule

