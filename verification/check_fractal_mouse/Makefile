
COMPILER = vlog 
TB_FILES = ./testbench.v 
LIB_DIR = ../../../lib  
RTL_FILES = -f rtl.f  /opt/Xilinx/14.7/ISE_DS/ISE/verilog/src/glbl.v
ALL_FILES =  $(RTL_FILES) $(TB_FILES)

OPT =  +v2k -sv -novopt  -l build.log  +libext+.v+.h+.vh    -y $(LIB_DIR) +define+SIM 
RUN =  vsim -l cosim.log -wlftlim 1 -pli libpli.so -c testbench -L xilinx_XilinxCoreLib -L xilinx_unisims -L xilinx_simprims  work.glbl \
		-do "nolog -all ; coverage save -onexit $(UCDB_FILE)  ; run -all ; quit" 
comp : 
	$(COMPILER) $(OPT) $(ALL_FILES) 
	vericom -sverilog -2001 -nolog  -lib work.verdi  +libext+.v+.h+.vh +incdir+../../rtl  $(ALL_FILES) 

run : 
	$(RUN)  

verdi : 
	verdi -2001 $(SIM_OPT)  -lib work.verdi  -ssf cosim_verdi.fsdb -top testbench -nologo &
