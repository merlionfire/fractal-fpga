
COMPILER = vlog 
ALL_FILES =  ../../rtl/frac_unit_core.v ../../rtl/multiplier_wrapper.v ../../ISE/multiply_ip/mult32X32s.v test.sv

OPT =  +v2k -sv -novopt +incdir+../../rtl  -l build.log     
RUN =  vsim -l cosim.log -wlftlim 1 -pli libpli.so -c testbench -L xilinx_XilinxCoreLib -L xilinx_unisims -L xilinx_simprims  work.glbl \
		-do "nolog -all ; coverage save -onexit $(UCDB_FILE)  ; run -all ; quit" 
comp : 
	$(COMPILER) $(OPT) $(ALL_FILES) 
	vericom -sverilog -2001 -nolog  -lib work.verdi  +libext+.v+.h+.vh +incdir+../../rtl  $(ALL_FILES) 

run : 
	$(RUN)  

verdi : 
	verdi -2001 $(SIM_OPT)  -lib work.verdi  -ssf cosim_verdi_simple.fsdb -top testbench -nologo &
