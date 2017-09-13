#-----------------------------------------------------------------------------
#
# Filename    : Makefile
#
# Created by  : $Merlionfire$
#               14/04/2015 # 
# Description : Compile the files at and below this level   
#
#-----------------------------------------------------------------------------

TB_BUILD_FLAG = on 
PROJ = test_alu

COMPILER = vlog 
#COMPILER = vcs -full64
RTL_FILES = ../../rtl/alu/divider.v  ~/FPGA_Project/lib/glbl.v
LIB_DIR = ~/FPGA_Project/lib  
TB_FILES = testbench.v 
MODEL_FILES =  
ALL_FILES =  $(RTL_FILES) $(MODEL_FILES) $(TB_FILES)

#SIM_OPT = +define+SVA +define+SIM   +define+x512Mb +define+sg5E +define+x16 +define+MAX_MEM 
# -----------------------------   Code Coverage   ----------------------------
COVER_TYPE   = +cover=sbcef
COVER_REPORT_FILE  = $(PROJ)_cov.txt 
COVER_REPORT_HTML_DIR  = $(PROJ)_cov_report_html 
UCDB_FILE    = $(PROJ)_cov.ucdb 
#COVER_OPT    = -coverage 
# ------------------------------------------------ ----------------------------
  
OPT =  +v2k -sv -novopt  +libext+.v+.h+.vh -y $(LIB_DIR)   -l build.log     

INC = 

RUN = vsim -l cosim.log -wlftlim 1 -pli libpli.so  -c testbench  work.glbl \
		-do "nolog -all ; run -all ; quit" 

default : help 

comp : 
	$(COMPILER) $(OPT) $(ALL_FILES)    
	vericom -sverilog -2001 -nolog  $(SIM_OPT) -lib work.verdi  +libext+.v+.h+.vh  -y $(LIB_DIR)  $(ALL_FILES) 
run : 
	$(RUN)  
verdi : 
	verdi -2001 $(SIM_OPT)  -lib work.verdi  -ssf cosim_verdi.fsdb -top testbench -nologo &
nlint : 
	 nLint  -gui
cover_report_txt  : 
	vcover report -detail $(UCDB_FILE) -output $(COVER_REPORT_FILE)   
cover_report_html  : 
	vcover report -html -htmldir $(COVER_REPORT_HTML_DIR)  $(UCDB_FILE)    
help : 
	@echo "==================== HELP ====================="
	@echo "comp        : Compiles everything with debugger"
	@echo "==============================================="
	@echo "run         : Run simulation                   "
	@echo "==============================================="
	@echo "help        : Print help information           "
	@echo "            : This is default parameter        "
	@echo "=============================================================="
	@echo "cover_report_html: Create code coverage report in htlm format "
	@echo "=============================================================="
	@echo "nlint       : invoke nlint gui                 "
	@echo "==============================================="
	@echo ""
	@echo ""

