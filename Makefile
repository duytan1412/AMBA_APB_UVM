# Makefile for AMBA APB UVM Verification Environment

# Tools
IVERILOG = iverilog
VVP = vvp

# Directories
RTL_DIR = rtl
TB_DIR = tb/uvm

# Source Files
RTL_SRC = $(RTL_DIR)/apb_ram.v
TB_SRC  = $(TB_DIR)/tb_top.sv

# Flags
# -g2012 enables SystemVerilog features in Icarus Verilog
IVFLAGS = -g2012 -I $(TB_DIR)

# Default target
all: simulate

# Note: Native UVM 1.2 requires a compiled library which is complex to set up with iverilog natively.
# This target is a placeholder for environments where UVM is pre-compiled for iverilog.
# The primary recommended execution environment is EDA Playground (Cadence Xcelium).
compile:
	@echo "Compiling RTL and Testbench with SystemVerilog support..."
	$(IVERILOG) $(IVFLAGS) -o sim.vvp $(RTL_SRC) $(TB_SRC)

simulate: compile
	@echo "Running Simulation..."
	$(VVP) sim.vvp

clean:
	@echo "Cleaning up..."
	rm -f sim.vvp
	rm -f dump.vcd
	rm -f *.log

help:
	@echo "Makefile usage:"
	@echo "  make all      - Compile and run simulation (Requires UVM-compatible simulator)"
	@echo "  make clean    - Remove generated files"
	@echo ""
	@echo "Note: Full UVM 1.2 support is limited in open-source simulators like Icarus Verilog."
	@echo "For best results, use Cadence Xcelium via EDA Playground."
