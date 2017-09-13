`ifndef UP_IF__SV
`define UP_IF__SV
interface   up_if ( input logic    clk , input logic    rst) ; 

   logic       pi_blk_sel;
   logic       pi_wr_en, pi_rd_en;
   logic       interrupt, interrupt_ack ; 
   logic [7:0] pi_wr_data;
   logic [7:0] pi_rd_data;
   logic [3:0] pi_addr; 

   initial begin 
      pi_blk_sel     =  1'b0 ; 
      pi_addr        =  'h0  ;
      pi_wr_en       =  1'b0 ; 
      pi_rd_en       =  1'b0 ; 
      pi_wr_data     =  'h00 ; 
   end 

endinterface

`endif //UP_IF__SV
