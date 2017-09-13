`ifndef RESET_IF__SV
`define RESET_IF__SV
interface   reset_if ( input logic clk ) ; 

   logic rst;

   clocking drv @(posedge clk )  ; 
      output   rst;
   endclocking 

   clocking mon @(posedge clk )  ; 
      input   rst;
   endclocking 

endinterface

`endif // RESET_IF__SV
