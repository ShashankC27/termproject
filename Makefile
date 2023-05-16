#############################################################
## Purpose: Makefile for Chap_2_Data_Types/homework3_solution
## Author: Chris Spear
##
## REVISION HISTORY:
## $Log: Makefile,v $
## Revision 1.1  2011/05/28 19:48:17  tumbush.tumbush
## Check into cloud repository
##
## Revision 1.1  2011/03/17 15:56:34  Greg
## Initial check-in
##
############################################################

#VCS_FILES = prog_test.sv accumulator.sv 
#QUESTA_FILES =prog_test.sv accumulator.sv
#TOPLEVEL = top

# Makefile for SystemVerilog Lab1
RTL= ./fptop_tb.sv ./fp_inf.sv
SVTB = ./fptop_dut.sv ./qadd.v ./qmult.v ./qdiv.v ./qtwoscomp.v
SEED = +ntb_random_seed_automatic

default: test 

test: compile run

run:
	./simv -l simv.log +ntb_random_seed_automatic

compile:
	vcs -l vcs.log -sverilog -debug_all -full64 $(SVTB) $(RTL)

dve:
	dve -vpd vcdplus.vpd &

debug:
	./simv -l simv.log -gui -tbug +ntb_random_seed=$(SEED)

solution: clean
	cp ../../solutions/lab1/*.sv .

clean:
	rm -rf simv* csrc* *.tmp *.vpd *.key *.log *hdrs.h

nuke: clean
	rm -rf *.v* *.sv include .*.lock .*.old DVE* *.tcl *.h
	cp .orig/* .

help:
	@echo ==========================================================================
	@echo  " 								       "
	@echo  " USAGE: make target <SEED=xxx>                                         "
	@echo  " 								       "
	@echo  " ------------------------- Test TARGETS ------------------------------ "
	@echo  " test       => Compile TB and DUT files, runs the simulation.          "
	@echo  " compile    => Compile the TB and DUT.                                 "
	@echo  " run        => Run the simulation.                                     "
	@echo  " dve        => Run dve in post-processing mode                         "
	@echo  " debug      => Runs simulation interactively with dve                  "
	@echo  " clean      => Remove all intermediate simv and log files.             "
	@echo  "                                                                       "
	@echo  " -------------------- ADMINISTRATIVE TARGETS ------------------------- "
	@echo  " help       => Displays this message.                                  "
	@echo  " solution   => Copies all files from solutions directory               "
	@echo  " nuke       => Erase all changes. Put all files back to original state "
	@echo  "								       "
	@echo ==========================================================================

