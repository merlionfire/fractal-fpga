`timescale  1ns / 100ps 
`default_nettype  none 
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:      Merlionfire 
// 
// Create Date:   12/04/2017 
// Design Name: 
// Module Name:   uart_pi 
// Function:      uart register configuation through processor interface      
//
// Note: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//
module   uart_pi   (
   // --- clock and reset 
   input  wire        clk,
   input  wire        rst,
   // --- uP interface
   input  wire        pi_blk_sel, 
   input  wire [3:0]  pi_addr, 
   input  wire        pi_wr_en, 
   input  wire        pi_rd_en,
   input  wire [7:0]  pi_wr_data,
   output reg  [7:0]  pi_rd_data,
   input  wire        interrupt_ack, 
   output reg         interrupt,
   // --- transmitter FIFO interface 
   input  wire        tx_fifo_overrun,
   input  wire        tx_fifo_rdy, 
   output wire        tx_fifo_wr_en,
   output wire [7:0]  tx_fifo_wr_data,
   // --- receiver FIFO interface 
   input  wire        rx_fifo_overrun,
   input  wire        rx_fifo_rdy,
   output wire        rx_fifo_rd_en,
   input  wire [7:0]  rx_fifo_rd_data,
   // --- Baud rate generator interface 
   output wire [7:0]  baud_16x_in_cycles 
) ; 

   `include "uart_pi.vh" 

   parameter   CLK_MHZ     =  75 ;
   //parameter   BAUD_RATE   =  19200 ; 
   parameter   BAUD_RATE   =  128000 ; 

`ifdef SIM 
   localparam  N_CYCLES_OF_BAUD_16X =  2 ;   
`else 
   localparam  N_CYCLES_OF_BAUD_16X =  ( CLK_MHZ * 62500 / BAUD_RATE ) - 1 ;   
`endif


   wire        reg_control_wr_stb;
   wire        reg_write_fifo_wr_stb;
   reg [7:0]   reg_control  ;         

 // -------------------------------------------------------------------------------
 //    Register write address decoder    
 // -------------------------------------------------------------------------------

   assign   reg_control_wr_stb      =  (  pi_addr  == REG_UART_CONTROL_ADDR )    & pi_wr_en & pi_blk_sel ; 
   assign   reg_write_fifo_wr_stb   =  (  pi_addr  == REG_UART_WRITE_FIFO_ADDR ) & pi_wr_en & pi_blk_sel ; 

 // -------------------------------------------------------------------------------
 //    Register Write    
 // -------------------------------------------------------------------------------


   always @( posedge clk ) begin 
      if ( rst ) begin 
         reg_control  <= N_CYCLES_OF_BAUD_16X ; 
      end else begin 
         if ( reg_control_wr_stb )      reg_control     <= pi_wr_data[7:0] ; 
      end
   end


   always @( posedge clk ) begin 
      if ( rst ) begin 
         interrupt   <= 1'b0;
      end else begin 
         if ( interrupt_ack ) begin 
            interrupt   <= 1'b0 ; 
         end else if ( rx_fifo_rdy ) begin 
            interrupt   <= 1'b1 ; 
         end
      end
   end

 // -------------------------------------------------------------------------------
 //    Register  rename    
 // -------------------------------------------------------------------------------


   // 16 * 1/75M * N  = 1 / baud_rate 
   // N = 75M / ( baud_rate * 16 ) ; 
   //
   assign   baud_16x_in_cycles   =  reg_control[7:0] ; 

 // -------------------------------------------------------------------------------
 //    Register  read    
 // -------------------------------------------------------------------------------
   
   always @(*) begin 
      pi_rd_data  =  8'h00;
      if ( pi_rd_en & pi_blk_sel ) begin 
         case ( pi_addr ) 
            REG_UART_STATUS_ADDR    :  pi_rd_data  =  {  4'b0000 ,tx_fifo_overrun, tx_fifo_rdy ,rx_fifo_overrun ,rx_fifo_rdy } ;  
            REG_UART_READ_FIFO_ADDR :  pi_rd_data  =  rx_fifo_rd_data ;  

         endcase 
      end
   end

 // -------------------------------------------------------------------------------
 //    Interface connection     
 // -------------------------------------------------------------------------------
    assign  tx_fifo_wr_en    =  reg_write_fifo_wr_stb ; 
    assign  tx_fifo_wr_data  =  pi_wr_data[7:0] ;   
    assign  rx_fifo_rd_en    =  pi_rd_en & pi_blk_sel & ( pi_addr == REG_UART_READ_FIFO_ADDR ) ; 


endmodule     
