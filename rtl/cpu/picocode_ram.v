
module picocode_ram (
   input  wire           clk,
   input  wire [17:0]    data_in,
   input  wire           enable,
   input  wire           wr_en,
   input  wire [9:0]     address,
   output wire [17:0]    instruction 
);
      

   // 16K-bit data and 2K-bit parity synchronous single port block RAM
   // 1K X 16bit ( One instruction code is 16bit width ) 
   RAMB16_S18 ram_1024_x_18(
           .DI 	( data_in[15:0]     ),
           .DIP	( data_in[17:16]    ),
           .EN	( enable            ),
           .WE	( wr_en             ),
           .SSR	( 1'b0              ),
           .CLK	( clk               ),
           .ADDR( address           ),
           .DO	( instruction[15:0] ),
           .DOP	( instruction[17:16])
   ) ; 


endmodule 
