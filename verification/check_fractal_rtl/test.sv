`timescale 1ns / 100ps
`default_nettype none 

module testbench () ; 

   parameter N = 32 ; 
   parameter CX_ORIG  = 32'he0_00_00_00 ; 
   parameter CY_ORIG  = 32'he8_00_00_00 ; 
   parameter MAX_ITER = 16'h20 ;  
   parameter DELTA    = 32'h00_01_00_00 ;  

   parameter PY_ORIG  = 767 ; 
   parameter PX_ORIG  = 0 ; 
   parameter PX_LIMIT = 768 ; 


   logic clk, rst ; 
   logic signed [N-1:0]  frac_cx, frac_cy ; 
   logic frac_go, frac_busy,frac_done_tick, frac_found ;  
   logic [15:0]   frac_max_iter ; 
   logic signed [10:0]    px, py ; 

   frac_unit_core  frac_unit_core_inst (
      .frac_clk       ( clk            ), //i
      .frac_rst       ( rst            ), //i
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

   always #10ns clk = ~ clk ; 

   //*******************************************************************//
   //     Main test                                                     // 
   //*******************************************************************//

   initial begin 
     rst   =  1'b1; clk   =  1'b0; frac_go  =  1'b0 ;  
     px    =  PX_ORIG ; 
     py    =  PY_ORIG ; 

     //reset dut 
     repeat (8) @(posedge clk ) ; 
     #5 rst = 1'b0;   
     repeat (20) @(posedge clk ) ; 

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

     #200us ; 
     $finish ; 

     frac_max_iter   = MAX_ITER ;   
     frac_cy         = CY_ORIG  ;  

     while ( py >= 0 ) begin 
        frac_cx   =  CX_ORIG ;   
        px =  PX_ORIG ;  
        while ( px < PX_LIMIT ) begin
           frac_go   = 1'b1 ;  
           repeat (1) @(posedge clk ) ; 
           frac_go   =  1'b0 ; 
           repeat (2) @(posedge clk ) ; 
           wait ( frac_done_tick == 1'b1 ) ;  
           repeat (1) @(posedge clk ) ; 
           if ( frac_found == 1'b1 ) begin  
              $display("%0f,%0f", frac_cx, frac_cy ) ;   
           end
           frac_cx   += DELTA ; 
           repeat (1) @(posedge clk ) ; 
           px++ ; 
        end
        frac_cy   += DELTA ; 
        py--; 
     end
     #200us ; 
     $finish ; 
      
  end 

  //*******************************************************************//
  //     FSDB dumper                                                   // 
  //*******************************************************************//

  initial begin
      $fsdbDumpfile("cosim_verdi_simple.fsdb");
      $fsdbDumpvars();
      //$fsdbDumpvars(0, "testbench.fractal_top_inst");
      //#1s $finish ; 
  end

  task exe_frac_calc ( logic [31:0] frac_cx, frac_cy, logic [15:0] frac_max_iter ) ;
     $display ( "@cx=%0h\tcy=%0h", frac_cx, frac_cy ) ;  
     @(posedge clk ) ; 
     frac_go   =  1'b1 ; 
     @(posedge clk ) ; 
     frac_go   =  1'b0 ; 
     wait ( frac_done_tick == 1'b1 ) ;  
     repeat (20) @(posedge clk ) ; 
  endtask 

endmodule    
