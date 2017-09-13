`timescale 1ns / 100ps
module tb_top ;
   parameter   CYCLES_FOR_HALF_PERIOD  =  5 ; 
   
   bit   clk ;

   up_if    cpu_if(clk) ; 
   reset_if rst_if(clk) ; 

   //*******************************************************************//
   //     DUT Instatiation                                                  // 
   //*******************************************************************//

   frac_unit_top  frac_unit_top_inst (
      .clk        ( clk               ), //i
      .rst        ( rst_if.rst        ), //i
      .pi_blk_sel ( cpu_if.pi_blk_sel ), //i
      .pi_addr    ( cpu_if.pi_addr    ), //i
      .pi_wr_en   ( cpu_if.pi_wr_en   ), //i
      .pi_rd_en   ( cpu_if.pi_rd_en   ), //i
      .pi_wr_data ( cpu_if.pi_wr_data ), //i
      .pi_rd_data ( cpu_if.pi_rd_data )  //o
   );

   //*******************************************************************//
   //     Clock                                                         // 
   //*******************************************************************//

   initial begin 
      forever  #(CYCLES_FOR_HALF_PERIOD) clk = ~clk ; 
   end

   //*******************************************************************//
   //     FSDB dumper                                                   // 
   //*******************************************************************//

   /*
   initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars(0, tb_top.frac_unit_top_inst,"+all");
      
   end
   */
endmodule 
