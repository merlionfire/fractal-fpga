`timescale  1ns / 100ps 
`default_nettype  none 
module uart(

   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,

   // serial port iterface 
   input  wire        rx,
   output wire        tx,

   // --- uP interface 
   input  wire        pi_blk_sel,
   input  wire [3:0]  pi_addr,
   input  wire        pi_wr_en,
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output wire [7:0]  pi_rd_data,
   input  wire        interrupt_ack, 
   output wire        interrupt

);


   wire         rx_fifo_full; 
   wire         rx_fifo_half_full;
   wire         rx_fifo_rd_en; 
   wire [7:0]   rx_fifo_rd_data;
   wire         rx_data_rdy;
   wire         rx_fifo_rdy;
   

   wire  [7:0]  rx_data_out ; 
   wire         rx_done_tick; 
   wire  [7:0]  tx_data_in  ; 
   wire         tx_done_tick, tx_data_in_valid ; 
   wire         baud_16x_tick ; 
   wire  [7:0]  baud_16x_in_cycles  ; 

   wire         tx_fifo_wr_en;
   wire  [7:0]  tx_fifo_wr_data;
   wire         tx_fifo_full;
   wire         tx_fifo_half_full;

   wire         tx_fifo_rdy;

   baud_rate_generator  baud_rate_generator_inst (
      .clk                  ( clk                ), //i
      .rst                  ( rst                ), //i
      .baud_16x_in_cycles   ( baud_16x_in_cycles ), //i   
      .baud_16x_tick        ( baud_16x_tick      )  //o
   );
   

   uart_rx uart_rx_inst ( 
      .clk           ( clk          ),
      .rst           ( rst          ),         
      .serial_in     ( rx           ),
      .baud_16x_tick ( baud_16x_tick),
      .data_in       ( rx_data_out  ), 
      .rx_done_tick  ( rx_done_tick )
   );

   bbfifo_16x8 uart_fifo_rx (	
      .clk           ( clk             ), //i
      .reset         ( rst             ), //i
      .write         ( rx_done_tick    ), //i 
      .data_in       ( rx_data_out     ), //i
      .full          ( rx_fifo_full    ), //o
      .half_full     ( rx_fifo_half_full    ), //o
      .read          ( rx_fifo_rd_en   ), //i 
      .data_out      ( rx_fifo_rd_data ), //o
      .data_present  ( rx_data_rdy     )  //o
   );

   uart_tx uart_tx_inst ( 
      .clk           ( clk          ),
      .rst           ( rst          ),         
      .serial_out    ( tx           ),  // IO
      .baud_16x_tick ( baud_16x_tick),  
      .data_in       ( tx_data_in   ),  // TX FIFO -->  
      .data_valid    ( tx_data_in_valid ) , // TX FIFO -->
      .tx_done_tick  ( tx_done_tick )
   );

   bbfifo_16x8 uart_fifo_tx (	
      .clk           ( clk             ), //i
      .reset         ( rst             ), //i
      .write         ( tx_fifo_wr_en   ), //i 
      .data_in       ( tx_fifo_wr_data ), //i
      .full          ( tx_fifo_full    ), //o
      .half_full     ( tx_fifo_half_full ), //o
      .read          ( tx_done_tick    ), //i 
      .data_present  ( tx_data_in_valid), //o
      .data_out      ( tx_data_in   )  //o
   );

   uart_pi  uart_pi_inst (
      .clk                ( clk                ), //i
      .rst                ( rst                ), //i
      .pi_blk_sel         ( pi_blk_sel         ), //i
      .pi_addr            ( pi_addr            ), //i
      .pi_wr_en           ( pi_wr_en           ), //i
      .pi_rd_en           ( pi_rd_en           ), //i
      .pi_wr_data         ( pi_wr_data         ), //i
      .pi_rd_data         ( pi_rd_data         ), //o
      .interrupt_ack      ( interrupt_ack      ), //i
      .interrupt          ( interrupt          ), //o
      .tx_fifo_overrun    ( 1'b0               ), //i
      .tx_fifo_rdy        ( tx_fifo_rdy        ), //i
      .tx_fifo_wr_en      ( tx_fifo_wr_en      ), //o
      .tx_fifo_wr_data    ( tx_fifo_wr_data    ), //o
      .rx_fifo_overrun    ( 1'b0               ), //i
      .rx_fifo_rdy        ( rx_fifo_rdy        ), //i
      .rx_fifo_rd_en      ( rx_fifo_rd_en      ), //o
      .rx_fifo_rd_data    ( rx_fifo_rd_data    ), //i
      .baud_16x_in_cycles ( baud_16x_in_cycles )  //o
   );


   assign   tx_fifo_rdy    =  !tx_fifo_full ; 
   assign   rx_fifo_rdy    =  rx_data_rdy ;   
   

endmodule 
