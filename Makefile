# Makefile for AMBA APB UVM Verification Environment

# Compiler Selection (Default to VCS style commands for professional alignment)
COMPILER ?= vcs
UVM_HOME ?= $(shell if [ -d "/usr/local/uvm-1.2" ]; then echo "/usr/local/uvm-1.2"; else echo "."; fi)

# Directories
RTL_DIR = ./rtl
TB_DIR  = ./tb/uvm
SIM_DIR = ./sim_results

# Source Files
RTL_SRC = $(RTL_DIR)/apb_ram.sv
TB_SRC  = $(TB_DIR)/tb_top.sv

# Standard Flags for Industry Compilers
VCS_FLAGS      = -sverilog -ntb_opts uvm -full64 +incdir+$(TB_DIR)
XCELIUM_FLAGS  = -sv -uvm -uvmhome $(UVM_HOME) -incdir $(TB_DIR)
IVFLAGS        = -g2012 -I $(TB_DIR)

.PHONY: all simulate compile clean help

all: simulate

simulate:
ifeq ($(COMPILER),vcs)
	@echo "Running simulation with Synopsys VCS..."
	vcs $(VCS_FLAGS) $(RTL_SRC) $(TB_SRC) -R +UVM_TESTNAME=apb_random_test
else ifeq ($(COMPILER),xcelium)
	@echo "Running simulation with Cadence Xcelium..."
	xmvhdl $(RTL_SRC)
	xrun $(XCELIUM_FLAGS) $(TB_SRC) +UVM_TESTNAME=apb_random_test
else ifeq ($(COMPILER),iverilog)
	@echo "Running lint/compile with Icarus Verilog..."
	iverilog $(IVFLAGS) -o $(SIM_DIR)/sim.vvp $(RTL_SRC) $(TB_SRC)
	vvp $(SIM_DIR)/sim.vvp
else
	@echo "Error: Unsupported compiler $(COMPILER). Use vcs, xcelium, or iverilog."
endif

clean:
	@echo "Cleaning up simulation artifacts..."
	rm -rf csrc simv* *.daidir *.log uvm_dpi.so vc_hdrs.h
	rm -rf xcelium.d xrun.log xrun.history
	rm -f $(SIM_DIR)/*.vvp $(SIM_DIR)/*.vcd

help:
	@echo "Professional APB UVM Makefile usage:"
	@echo "  make simulate COMPILER=vcs     - Run with Synopsys VCS (Recommended)"
	@echo "  make simulate COMPILER=xcelium - Run with Cadence Xcelium"
	@echo "  make simulate COMPILER=iverilog- Run basic lint with Icarus Verilog"
	@echo "  make clean                     - Remove all simulation files"
