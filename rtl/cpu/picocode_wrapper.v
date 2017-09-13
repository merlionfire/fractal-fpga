// Author: merlionfire 
// 
// Create Date:    04/12/2015 
// Design Name: 
// Module Name:    picocode_wrapper    
// Project Name:   fractal
// Target Devices: Spartan-3AN 
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
//`define UART_TEST 1 

module picocode_wrapper  (
   input  wire          clk,
   input  wire          remap,
   input  wire [9:0]    inst_address,
   output wire [17:0]   inst_data_out,
   input  wire          ram_wr_en,
   input  wire [9:0]    ram_address,
   input  wire [17:0]   ram_data_in
) ; 

  wire   wr_en ; 

  wire [9:0]   address_0;
  wire [9:0]   address_1;

  wire [17:0]  instruction_0; 
  wire [17:0]  instruction_1; 

`ifdef UART_TEST  

  uart_test     uart_test_inst (
    .address      (  address_0        ),
    .instruction  (  instruction_0  ),
    .clk          (  clk            )
  );


`else 
  
  picocode     picocode_rom_inst (
    .address      (  address_0        ),
    .instruction  (  instruction_0  ),
    .clk          (  clk            )
  );

`endif

  picocode_ram  picocode_ram_inst (
    .clk         ( clk            ), //i
    .data_in     ( ram_data_in    ), //i
    .enable      ( 1'b1           ), //i
    .wr_en       ( wr_en          ), //i
    .address     ( address_1      ) , //i
    .instruction ( instruction_1  )  //o
  );

  // inst_address :  address where CPU fetchs instruction code 
  // ram_address  :  address where CPU uploads instruction code 
  //                     remap    ROM address      RAM address     Code source 
  // ROM is enabled :     0       inst_address     ram_address     ROM
  // RAM is enabled :     1           X            inst_address    RAM

  assign inst_data_out   =  remap ? instruction_1   :  instruction_0 ; 
  assign address_0       =  inst_address; 

  assign address_1       =  remap ? inst_address    :  ram_address; 

  assign wr_en           =  (~remap) & ram_wr_en ; 

endmodule 
