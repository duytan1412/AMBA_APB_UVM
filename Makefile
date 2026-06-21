# Makefile for AMBA APB UVM Verification Environment

COMPILER ?= vcs
TEST ?= apb_base_test
UVM_HOME ?= $(shell if [ -d "/usr/local/uvm-1.2" ]; then echo "/usr/local/uvm-1.2"; else echo "."; fi)

RTL_DIR = ./rtl
TB_DIR  = ./tb/uvm
SIM_DIR = ./sim_results

RTL_SRC = $(RTL_DIR)/apb_ram.sv
TB_SRC  = $(TB_DIR)/tb_top.sv

VCS_FLAGS      = -sverilog -ntb_opts uvm -full64 +incdir+$(TB_DIR)
XCELIUM_FLAGS  = -sv -uvm -uvmhome $(UVM_HOME) -incdir $(TB_DIR)
IVFLAGS        = -g2012 -I $(TB_DIR)

.PHONY: all simulate lint clean help

all: simulate

simulate:
ifeq ($(COMPILER),vcs)
	@echo "Running $(TEST) with Synopsys VCS..."
	vcs $(VCS_FLAGS) $(RTL_SRC) $(TB_SRC) -R +UVM_TESTNAME=$(TEST)
else ifeq ($(COMPILER),xcelium)
	@echo "Running $(TEST) with Cadence Xcelium..."
	xrun $(XCELIUM_FLAGS) $(RTL_SRC) $(TB_SRC) +UVM_TESTNAME=$(TEST)
else
	@echo "Error: simulate requires COMPILER=vcs or COMPILER=xcelium for UVM."
	@exit 1
endif

lint:
	@echo "Running RTL lint with Icarus Verilog..."
	iverilog $(IVFLAGS) -tnull $(RTL_SRC)
	@echo "Icarus lint is RTL-only; full UVM requires VCS/Xcelium/Questa."

clean:
	@echo "Cleaning up simulation artifacts..."
	rm -rf csrc simv* *.daidir *.log uvm_dpi.so vc_hdrs.h
	rm -rf xcelium.d xrun.log xrun.history
	rm -f $(SIM_DIR)/*.vvp $(SIM_DIR)/*.vcd

help:
	@echo "APB UVM Makefile usage:"
	@echo "  make simulate COMPILER=vcs TEST=apb_random_test"
	@echo "  make simulate COMPILER=xcelium TEST=apb_error_test"
	@echo "  make lint"
	@echo "  make clean"
