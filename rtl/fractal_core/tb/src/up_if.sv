`ifndef UP_IF__SV
`define UP_IF__SV
interface  up_if ( input logic clk) ;

   logic       pi_blk_sel;
   logic [3:0] pi_addr; 
   logic       pi_wr_en;
   logic       pi_rd_en;
   logic [7:0] pi_wr_data;
   logic [7:0] pi_rd_data;
   logic       interrupt;
   logic       interrupt_ack ; 

   bit [15:0]  x;
   bit [15:0]  y;

   clocking drv @(posedge clk ) ; 
      default  input #1step output #2; 
      output   pi_blk_sel ; 
      output   pi_addr;
      output   pi_wr_en; 
      output   pi_rd_en; 
      output   pi_wr_data; 
      output   interrupt;
      input    pi_rd_data;
      input    interrupt_ack;
   endclocking

   clocking  mon @(posedge clk ) ; 
      default  input #1step output #2; 
      input    pi_blk_sel ; 
      input    pi_addr;
      input    pi_wr_en; 
      input    pi_rd_en; 
      input    pi_wr_data; 
      input    interrupt_ack;
      input    pi_rd_data;
      input    interrupt;
   endclocking


endinterface

`endif //UP_IF__SV
