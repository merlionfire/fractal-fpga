//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Merlionfire 
// 
// Create Date:   02:24:07 12/02/2017 
// Design Name: 
// Module Name:   alu 
// Project Name: 
// Target Devices: 
// Function:      alu top module  
//
// Note: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module alu (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // --- uP interface
   input  wire        pi_blk_sel, 
   input  wire [3:0]  pi_addr, 
   input  wire        pi_wr_en, 
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output wire [7:0]  pi_rd_data,
   input  wire        interrupt_ack, 
   output wire        interrupt

) ; 

   wire           alu_go_r;
   wire           alu_en_r;
   wire [3:0]     alu_func_r;
   wire [31:0]    alu_op_a_r; 
   wire [31:0]    alu_op_b_r; 
   wire           alu_op_done;
   wire [31:0]    q_in; 
   wire [31:0]    r_in;


   alu_pi  alu_pi_inst (
      .clk           ( clk           ), //i
      .rst           ( rst           ), //i
      .pi_blk_sel    ( pi_blk_sel    ), //i
      .pi_addr       ( pi_addr       ), //i
      .pi_wr_en      ( pi_wr_en      ), //i
      .pi_rd_en      ( pi_rd_en      ), //i
      .pi_wr_data    ( pi_wr_data    ), //i
      .pi_rd_data    ( pi_rd_data    ), //o
      .interrupt_ack ( interrupt_ack ), //i
      .interrupt     ( interrupt     ), //o
      .alu_go_r      ( alu_go_r      ), //o
      .alu_en_r      ( alu_en_r      ), //o
      .alu_func_r    ( alu_func_r    ), //o
      .alu_op_a_r    ( alu_op_a_r    ), //o
      .alu_op_b_r    ( alu_op_b_r    ), //o
      .alu_op_done   ( alu_op_done   ), //i
      .q_in          ( q_in          ), //i
      .r_in          ( r_in          )  //i
   );

   alu_engine  alu_engine_inst (
      .clk        ( clk          ), //i
      .rst        ( rst          ), //i
      .ce         ( alu_en_r     ), //i
      .start      ( alu_go_r     ), //i
      .a          ( alu_op_a_r   ), //i
      .b          ( alu_op_b_r   ), //i
      .op         ( alu_func_r   ), //i
      .valid      ( alu_op_done  ), //o
      .q          ( q_in         ), //o
      .r          ( r_in         )  //o
   );

endmodule 
