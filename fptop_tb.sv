`timescale 1ns/1ps
`default_nettype none

class transaction;
    rand bit [31:0] a;
    rand bit [31:0] b;
    reg [1:0] opcode;
    bit [31:0] c;

    //opcode = 2'b00;


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
        repeat (1) begin
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
        repeat(1) begin
            transaction trans;
            gen_driv.get(trans);
            vif.a = trans.a;
            vif.b = trans.b;
            vif.opcode=trans.opcode;
            #100;
            trans.display("Driver Block");
        end
    endtask
endclass

class monitor;
    virtual fp_inf vif;
    mailbox mon_sb;

    function new (virtual fp_inf vif,mailbox mon_sb);
        this.vif =vif;
        this.mon_sb =mon_sb;
    endfunction

    task main();
        repeat(1) begin
            transaction trans;
            trans = new();
            trans.a=vif.a;
            trans.b=vif.b;
            trans.c=vif.c;

            mon_sb.put(trans);
            trans.display("Monitor Block");
        end
    endtask
endclass

class scoreboard;
    mailbox mon_sb;

    function new(mailbox mon_sb);
        this.mon_sb =mon_sb;
    endfunction
    
    real ar,br,cr;
    virtual fp_inf i_intf;

    task main();
        transaction trans;
        repeat(1) begin
            mon_sb.get(trans);
            trans.display("scoreboard");
            i_intf.conv_fixed(.fixed(trans.a),.num(ar));
            i_intf.conv_fixed(trans.b,br);
            i_intf.conv_fixed(trans.c,cr);

            if((ar+br) == cr) begin
                $display("**********************************");
                $display("Correct output have been received.");
                $display(" a = %b, b = %b and c = %b",trans.a,trans.b,trans.c);
                $display(" a = %f, b = %f and c = %f",ar,br,cr);
            end
            else begin
                $display("**********************************");
                $display("Incorrect output have been generated");
                $display(" a = %d, b = %d and c = %c",trans.a,trans.b,trans.c);
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
        #50;
        mon.main();
        scb.main();
        //join
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
    
    // Create an instance of the interface
    fp_inf ii_intf();

    // Bind the interface instance to the virtual interface
    bind ii_intf = i_intf;

    
    test t1(i_intf);

    fptop_dut dut(.a(i_intf.a),.b(i_intf.b),.clk(clk),.start(start),.opcode(i_intf.opcode),.c(i_intf.c));
    //top_dut dut(i_intf.slave);

    initial begin
        $vcdpluson;
        $vcdplusmemon;
        #10000;
        $finish;
    end
endmodule

