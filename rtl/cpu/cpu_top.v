// Author: merlionfire 
// 
// Create Date:    05/072017 
// Design Name: 
// Module Name:    cpu_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description:    The top module of CPU subsytem
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module cpu_top (
       
   // --- clock and reset 
   input  wire          clk,
   input  wire          reset,
   
   // --- I/O interface 
   output wire [7:0]    port_id,
   output wire          write_strobe,
   output wire          read_strobe,
   output wire [7:0]    out_port,
   input  wire [7:0]    in_port,
    
   // --- interrupt 
   input  wire          interrupt_uart,
   input  wire          interrupt_alu,
   input  wire          interrupt_mouse,
   output wire          interrupt_ack,
   //
   // --- uP interface 
   input  wire          pi_blk_sel,
   input  wire [3:0]    pi_addr,
   input  wire          pi_wr_en,
   input  wire          pi_rd_en,
   input  wire [7:0]    pi_wr_data,
   output wire [7:0]    pi_rd_data,

   // Remap reset
   output reg           reset_over_remap
);

   wire     interrupt;
   wire [17:0] instruction, instruction_out, inst_data_out ;
   wire [9:0]  address, inst_address  ; 
   reg      remap_1d, remap_2d, remap_3d, remap_4d ; 
   wire     remap_edge, remap_3d_edge ; 

   // --- code preload interface  
   wire          remap;
   wire [9:0]    ram_address; 
   wire          ram_wr;
   wire [17:0]   ram_data_in;
   wire          inst_update;

  //******************************************************************//
  // Instantiate PicoBlaze and the Program ROM/RAM.                       // 
  //******************************************************************//

  kcpsm3 kcpsm3_inst (
    .address(address),
    .instruction(instruction),
    .port_id(port_id),
    .write_strobe(write_strobe),
    .out_port(out_port),
    .read_strobe(read_strobe),
    .in_port(in_port),
    .interrupt(interrupt),
    .interrupt_ack(interrupt_ack),
    .reset(reset),
    .clk(clk)
  );

   picocode_wrapper  picocode_wrapper_inst (
      .clk           ( clk            ), //i
      .remap         ( remap_4d       ), //i
      .ram_data_in   ( inst_data_out  ), //i
      .ram_address   ( inst_address   ), //i
      .ram_wr_en     ( inst_update    ), //i
      .inst_address  ( address        ), //i
      .inst_data_out ( instruction_out ) //o
   );

   cpu_pi  uart_pi_inst (
      .clk              ( clk             ), //i
      .rst              ( reset           ), //i
      .pi_blk_sel       ( pi_blk_sel      ), //i
      .pi_addr          ( pi_addr         ), //i
      .pi_wr_en         ( pi_wr_en        ), //i
      .pi_rd_en         ( pi_rd_en        ), //i
      .pi_wr_data       ( pi_wr_data      ), //i
      .pi_rd_data       ( pi_rd_data      ), //o
      .inst_update      ( inst_update     ), //o
      .inst_address     ( inst_address    ), //o
      .inst_data_out    ( inst_data_out   ), //o
      .remap            ( remap           ), //o
      .interrupt_uart   ( interrupt_uart  ), //i
      .interrupt_alu    ( interrupt_alu   ), //i
      .interrupt_mouse  ( interrupt_mouse )  //i
   );

// ====================================================
//        _____________________________
// _______|
//           _____________________________
// __________|
//              _____________________________
// _____________|
//
//        ____
//________|  |_______________________________
//                                   ____
//___________________________________|  |____________
//           ___________________________
//___________|                          |____________  reset_over_remap

   always   @( posedge clk ) begin 
         remap_1d   <= remap;
         remap_2d   <= remap_1d;
         remap_3d   <= remap_2d; 
         remap_4d   <= remap_3d; 
   end 

   assign remap_edge    =  remap ^ remap_1d ; 
   assign remap_3d_edge =  remap_3d ^ remap_4d ; 


   initial begin 
        reset_over_remap    = 1'b0 ; 
   end 

   always   @( posedge clk ) begin 
      if (  remap_edge ) begin 
        reset_over_remap    <= 1'b1 ; 
      end else if ( remap_3d_edge ) begin 
        reset_over_remap    <= 1'b0 ; 
      end
  end


   
  assign   instruction =  instruction_out ; 
  assign   interrupt   =  interrupt_uart | interrupt_alu | interrupt_mouse ; 

endmodule
