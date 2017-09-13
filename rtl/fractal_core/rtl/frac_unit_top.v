
module frac_unit_top #( 
      parameter N =  32 , 
      parameter M =  4
) (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   
   // --- uP interface 
   input  wire        pi_blk_sel,
   input  wire [3:0]  pi_addr,
   input  wire        pi_wr_en,
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output wire [7:0]  pi_rd_data
); 

wire  frac_go,  frac_busy,  frac_done_tick,  frac_found;

wire [ N-1 : 0 ]  frac_cx;
wire [ N-1 : 0 ]  frac_cy;
wire [15:0]       frac_max_iter;



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


   frac_unit_pi  frac_unit_pi_inst (
      .clk              ( clk              ), //i
      .rst              ( rst              ), //i
      .blk_sel          ( pi_blk_sel       ), //i
      .addr             ( pi_addr          ), //i
      .wr_en            ( pi_wr_en         ), //i
      .rd_en            ( pi_rd_en         ), //i
      .wr_data          ( pi_wr_data       ), //i
      .rd_data          ( pi_rd_data       ), //o
      .frac_cx          ( frac_cx          ), //o
      .frac_cy          ( frac_cy          ), //o
      .frac_max_iter    ( frac_max_iter    ), //o
      .frac_go          ( frac_go          ), //o
      .frac_busy        ( frac_busy        ), //i
      .frac_done_tick   ( frac_done_tick   ), //i
      .frac_found       ( frac_found       )  //i
   );

endmodule
