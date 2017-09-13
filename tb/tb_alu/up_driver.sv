`ifndef UP_DRIVER__SV
`define UP_DRIVER__SV


class up_driver ; 

   virtual   up_if    vif ; 

   function new( virtual up_if vif ) ; 
      this.vif=  vif; 
   endfunction 

   task execute( input alu_packet pkt, output   alu_packet resp ) ; 
      bit [7:0]   reg_data ; 
      resp  =  new() ; 
      resp.alu_op  =  pkt.alu_op ; 

      wait_alu_ready(); 
      configure_alu_operand( pkt ) ; 
      start_alu_operation( pkt ) ;  
      wait_and_read_result( resp ) ; 
   endtask 

   task wait_alu_ready();

      fork
         begin
            bit [7:0]   reg_data ; 
            while(1) begin 
               @(posedge vif.clk )  ; 
               bus_read_reg ( REG_ALU_CTRL_STATUS_ADDR , reg_data ) ; 
               if ( reg_data[0] == 1'b0 ) break ;  
            end
         end

         begin
            repeat(50) @(posedge vif.clk )  ; 
            $display("@%0t: [ERROR] Time-out for waiting ALU is ready!!! Will force to stop sim soon.....", $time ) ;
            $finish ;  
         end

      join_any

      disable fork ; 


   endtask 

   task  configure_alu_operand (  alu_packet  pkt ) ; 
      bus_write_reg( REG_ALU_A_0_ADDR,  pkt.a[7:0]   );
      bus_write_reg( REG_ALU_A_1_ADDR,  pkt.a[15:8]  );
      bus_write_reg( REG_ALU_A_2_ADDR,  pkt.a[23:16] );
      bus_write_reg( REG_ALU_A_3_ADDR,  pkt.a[31:24] );
      bus_write_reg( REG_ALU_B_0_ADDR,  pkt.b[7:0]   );
      bus_write_reg( REG_ALU_B_1_ADDR,  pkt.b[15:8]  );
      bus_write_reg( REG_ALU_B_2_ADDR,  pkt.b[23:16] );
      bus_write_reg( REG_ALU_B_3_ADDR,  pkt.b[31:24] );
   endtask 

   task  start_alu_operation( alu_packet  pkt ) ; 
      bit [7:0]   reg_data ; 

      case ( pkt.alu_op )  
         DIV : reg_data[7:4]  =  4'h0 ; 
         MUL : reg_data[7:4]  =  4'h1 ; 
         default: reg_data[7:4]  =  4'h2 ; 
      endcase 

      reg_data[0] =  1'b1 ; 
      reg_data[1] =  1'b1 ; 

      bus_write_reg ( REG_ALU_CTRL_STATUS_ADDR , reg_data ) ; 

   endtask


   task wait_and_read_result( alu_packet  resp ) ; 

      bit [7:0]   reg_data ; 

      wait_alu_ready();

      bus_read_reg ( REG_ALU_Q_0_ADDR , reg_data ) ; 
      resp.result[7:0]    =  reg_data ; 
      bus_read_reg ( REG_ALU_Q_1_ADDR , reg_data ) ; 
      resp.result[15:8]   =  reg_data ; 
      bus_read_reg ( REG_ALU_Q_2_ADDR , reg_data ) ; 
      resp.result[23:16]  =  reg_data ; 
      bus_read_reg ( REG_ALU_Q_3_ADDR , reg_data ) ; 
      resp.result[31:24]  =  reg_data ; 

      bus_read_reg ( REG_ALU_R_0_ADDR , reg_data ) ; 
      resp.remainder[7:0]    =  reg_data ; 
      bus_read_reg ( REG_ALU_R_1_ADDR , reg_data ) ; 
      resp.remainder[15:8]   =  reg_data ; 
      bus_read_reg ( REG_ALU_R_2_ADDR , reg_data ) ; 
      resp.remainder[23:16]  =  reg_data ; 
      bus_read_reg ( REG_ALU_R_3_ADDR , reg_data ) ; 
      resp.remainder[31:24]  =  reg_data ; 

   endtask ; 

   task bus_write_reg( input logic [3:0]   addr, logic [7:0] data )  ;
      @( posedge vif.clk )  ; 
      #1 ; 
      vif.pi_blk_sel     =  1'b1 ; 
      vif.pi_addr        =  addr ;
      vif.pi_wr_data     =  data ; 
      @( posedge vif.clk )  ; 
      #1 ; 
      vif.pi_wr_en       =  1'b1 ; 
      @( posedge vif.clk )  ; 
      vif.pi_wr_en       =  1'b0 ; 
      vif.pi_blk_sel     =  1'b0 ; 
   endtask 

   task bus_read_reg( input logic [3:0]   addr,  output logic [7:0] data_out  )  ;

      @( posedge vif.clk )  ; 
      #1 ; 
      vif.pi_blk_sel     =  1'b1 ; 
      vif.pi_addr        =  addr ;
      @( posedge vif.clk )  ; 
      #1 ; 
      vif.pi_rd_en       =  1'b1 ; 
      @( posedge vif.clk )  ; 
      data_out           =  vif.pi_rd_data ; 
      vif.pi_rd_en       =  1'b0 ; 
      vif.pi_blk_sel     =  1'b0 ; 
   `ifdef DEBUBG
      $display("@%0t: [INFO] Read out register data 0x%02h", $time, data_out) ; 
   `endif 
   endtask  

endclass

`endif  //UP_DRIVER__SV
