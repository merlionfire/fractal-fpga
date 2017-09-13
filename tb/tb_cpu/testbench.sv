`timescale 1ns / 1ps  
//`default_nettype none 

//////////////////////////////////////////////////////////////////////////////////
// Author: merlionfire 
// 
// Create Date:    23/04/2017 
// Design Name: 
// Module Name:    testbech 
// Project Name:   tb_uart
// Target Devices:  
// Tool versions: 
// Description: 
//
// Dependencies:    testbench for uart rtl with uP interface
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////


module testbench  ( ) ; 


   parameter RND_TEST_NUM      =  1000 ; 
   parameter REG_UART_ADDR     =  4'h5 ;


   `include "uart_pi.vh" 


   //*******************************************************************//
   //     Class Declaration                                             // 
   //*******************************************************************//

    logic       clk ; 
    logic       reset_external ; 


    wire        rst ; 

    wire [7:0]    port_id;
    wire          write_strobe;
    wire          read_strobe;
    wire [7:0]    out_port;
    wire [7:0]    in_port;
    
    wire          interrupt;
    wire          interrupt_ack;
    wire          pi_blk_sel;
    wire [3:0]    pi_addr;
    wire          pi_wr_en;
    wire          pi_rd_en;
    wire [7:0]    pi_wr_data;

    wire          reset_over_remap; 

    logic [7:0]   uart_reg_data ; 

   //*******************************************************************//
   //     DUT Instatiation                                                  // 
   //*******************************************************************//

   cpu_top  cpu_top_inst (
      .clk              ( clk              ), //i
      .reset            ( rst              ), //i
      .port_id          ( port_id          ), //o
      .write_strobe     ( write_strobe     ), //o
      .read_strobe      ( read_strobe      ), //o
      .out_port         ( out_port         ), //o
      .in_port          ( in_port          ), //i
      .interrupt        ( interrupt        ), //i
      .interrupt_ack    ( interrupt_ack    ), //o
      .pi_blk_sel       ( pi_blk_sel       ), //i
      .pi_addr          ( pi_addr          ), //i
      .pi_wr_en         ( pi_wr_en         ), //i
      .pi_rd_en         ( pi_rd_en         ), //i
      .pi_wr_data       ( pi_wr_data       ), //i
      .pi_rd_data       (                  ), //o
      .reset_over_remap ( reset_over_remap )  //o
   );


   assign   in_port     =  uart_reg_data ; 
   assign   pi_wr_data  =  out_port;

   assign   pi_blk_sel  =  ( port_id[7:4] == 4'h6 ) ? 1'b1 : 1'b0 ; 
   assign   pi_addr     =  port_id[3:0] ; 
   assign   pi_wr_en    =  write_strobe ; 
   assign   pi_rd_en    =  read_strobe ; 

   assign   rst       =  reset_external || reset_over_remap ; 

   //*******************************************************************//
   //     Clock                                                         // 
   //*******************************************************************//
 
   always #5ns clk  = ~ clk ;  


   //*******************************************************************//
   //     FSDB dumper                                                   // 
   //*******************************************************************//

   initial begin
      $fsdbDumpfile("cosim_verdi.fsdb");
      $fsdbDumpvars();
   end

   //*******************************************************************//
   //     Main test                                                     // 
   //*******************************************************************//
   

   initial begin 
      clk   =  1'b0 ; 
      reset_external = 1'b1 ; 
      $display("[INFO] Starting to test <CPU_top> module ........." ) ; 
      repeat (20) @( negedge clk )  ; 
      reset_external = 1'b0 ; 
      $display("[INFO] Unfreeze <CPU_top> module ........." ) ; 
      $display("[INFO] Test case starts........." ) ; 
      respond_cpu_read() ; 
      $display("[INFO] All instruction codes have been loaded........" ) ; 
      repeat(100) @( posedge clk ) ;   
      $finish ;       

   end 

   //*************************************************************//
   // Task and function definition 
   //*************************************************************//
   
   task respond_cpu_read ( ) ; 

     byte   code[1024] ; 
     int    idx ; 
     logic  rx_fifo_rdy ; 
     logic  code_read_done ; 

     code[0]   =  8'h01;
     code[1]   =  8'h00;
     code[2]   =  8'h00;
     code[3]   =  8'h0b;
     code[4]   =  8'h80;
     code[5]   =  8'h01;
     code[6]   =  8'hf0;
     code[7]   =  8'ha0;
     code[8]   =  8'h01;
     code[9]   =  8'hc7;
     code[10]  =  8'hc0;
     code[11]  =  8'h02;
     code[12]  =  8'h04;
     code[13]  =  8'h40;
     code[14]  =  8'h03;

 
     idx         =  0 ; 
     rx_fifo_rdy = 1'b1 ;   

     forever begin 
         if ( port_id[7:4] == REG_UART_ADDR ) begin 
            case ( pi_addr ) 
               REG_UART_STATUS_ADDR    :  uart_reg_data  =  {  7'b0000000 , rx_fifo_rdy } ;  
               REG_UART_READ_FIFO_ADDR :  begin 
                     uart_reg_data  =  code[idx] ;  
                     code_read_done =  1'b1 ; 
               end
            endcase 
            wait(read_strobe) ; 
            @(posedge clk ) ; 
            uart_reg_data  =  8'h00 ; 
            if ( code_read_done ) begin 
               idx++ ; 
               code_read_done =  1'b0 ; 
               if ( idx == 2048 ) begin 
                  rx_fifo_rdy =  1'b0 ; 
                  disable fork ;
               end
            end
            @(negedge clk ) ; 
         end else begin 
            @(posedge clk ) ; 
         end

      end

   endtask 
   
endmodule
