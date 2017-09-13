`timescale 1ns / 100ps
`default_nettype none 

//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    04/14/2015 
// Design Name: 
// Module Name:    tb_frac_calc.v 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module testbench () ; 

  parameter N = 32 ; 

  logic frac_clk, frac_rst ; 

  logic [N-1:0]  frac_cx, frac_cy ; 
  logic frac_go, frac_busy,frac_done_tick, frac_found ;  
  logic [15:0]   frac_max_iter ; 

  //*******************************************************************//
  //     Instatiation                                                  // 
  //*******************************************************************//

  frac_calc #( .N(N), .M(4) ) frac_calc_inst (
      .frac_clk       ( frac_clk       ), //i
      .frac_rst       ( frac_rst       ), //i
      .frac_cx        ( frac_cx        ), //i
      .frac_cy        ( frac_cy        ), //i
      .frac_go        ( frac_go        ), //i
      .frac_max_iter  ( frac_max_iter  ), //i
      .frac_busy      ( frac_busy      ), //o
      .frac_done_tick ( frac_done_tick ), //o
      .frac_found     ( frac_found     )  //o
  );


  //*******************************************************************//
  //     clock                                                         // 
  //*******************************************************************//

  always #10ns frac_clk = ~ frac_clk ; 


  //*******************************************************************//
  //     Main test                                                     // 
  //*******************************************************************//

  initial begin 
     frac_rst   =  1'b1; frac_clk   =  1'b0; frac_go  =  1'b0 ;  
     
     //reset dut 
     repeat (8) @(posedge frac_clk ) ; 
     #5 frac_rst = 1'b0;   
     repeat (20) @(posedge frac_clk ) ; 

     //frac_cx   =  32'he000_0000 ; 
     //frac_cy   =  32'he800_0000 ; 
     
     frac_cx   =  32'h0800_0000 ;   // 0.5 
     frac_cy   =  32'hf800_0000 ;   // -0.5 
     frac_max_iter   = 16'd30 ;     
     exe_frac_calc ( frac_cx, frac_cy, frac_max_iter ) ; 

     frac_cx   =  32'h1800_0000 ;   // 1.5
     frac_cy   =  32'he800_0000 ;   // -1.5 
     exe_frac_calc ( frac_cx, frac_cy, frac_max_iter ) ; 

     frac_cx   =  32'h0300_0000 ;   // 9/256
     frac_cy   =  32'he800_0000 ; 
     exe_frac_calc ( frac_cx, frac_cy, frac_max_iter ) ; 
     $finish ; 
      
  end 


  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
  end

  task exe_frac_calc ( logic [31:0] frac_cx, frac_cy, logic [15:0] frac_max_iter ) ;
     $display ( "@cx=%0h\tcy=%0h", frac_cx, frac_cy ) ;  
     @(posedge frac_clk ) ; 
     frac_go   =  1'b1 ; 
     @(posedge frac_clk ) ; 
     frac_go   =  1'b0 ; 
     wait ( frac_done_tick == 1'b1 ) ;  
     repeat (20) @(posedge frac_clk ) ; 
  endtask 



endmodule 
