`ifndef UP_DRVER__SV
`define UP_DRVER__SV

class up_driver extends uvm_driver #(packet);
   virtual up_if     vif;

   `uvm_component_utils(up_driver)

   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      uvm_config_db#(virtual up_if)::get(this,"","vif",vif); 
   endfunction: build_phase
   
   function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

     if (vif == null) begin
       `uvm_fatal("CFGERR", "Interface for up_driver not set");
     end
   endfunction: end_of_elaboration_phase

   virtual task run_phase(uvm_phase phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      forever begin
         seq_item_port.get_next_item(req); 
         `uvm_info("DRV_RUN", {"\n", req.sprint()}, UVM_HIGH);
         send(req);
         wait_for_done();
         seq_item_port.item_done();
      end
   endtask: run_phase

   virtual task send( packet pkt ) ; 
      bit signed [31:0] reg_val_all ;  
      bit [3:0]   reg_addr ; 

     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      reg_addr =  4'h1; 

      reg_val_all =  packet::float2bits(pkt.cx) ;  
      `uvm_info("DRV_RUN", $sformatf("\n\t\tcx = %0f --> 0x%8h\n", pkt.cx, reg_val_all), UVM_HIGH);

      vif.x    <= pkt.x ; 
      vif.y    <= pkt.y ; 
      write_reg(reg_addr++,reg_val_all[0+:8]) ; 
      write_reg(reg_addr++,reg_val_all[8+:8]) ; 
      write_reg(reg_addr++,reg_val_all[16+:8]) ; 
      write_reg(reg_addr++,reg_val_all[24+:8]) ; 

      reg_val_all =  packet::float2bits(pkt.cy) ;  
      `uvm_info("DRV_RUN", $sformatf("\n\t\tcy = %0f --> 0x%8h\n", pkt.cy, reg_val_all), UVM_HIGH);
      write_reg(reg_addr++,reg_val_all[0+:8]) ; 
      write_reg(reg_addr++,reg_val_all[8+:8]) ; 
      write_reg(reg_addr++,reg_val_all[16+:8]) ; 
      write_reg(reg_addr++,reg_val_all[24+:8]) ; 

      write_reg(reg_addr++,pkt.iter[0+:8]) ; 
      write_reg(reg_addr++,pkt.iter[8+:8]) ; 

      write_reg(4'h0, 8'h01) ; 
   endtask 

   virtual task wait_for_done(); 
      bit [7:0]   reg_val  ; 
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      forever begin 
         read_reg(4'h0, reg_val) ; 
         if (reg_val[0] == 1'b0 ) return ; 
      end
   endtask: wait_for_done

   virtual task write_reg( input  bit [3:0] addr, bit [7:0]  data) ; 
      vif.drv.pi_blk_sel <= 1'b1 ;  
      vif.drv.pi_addr    <= addr ; 
      vif.drv.pi_wr_data <= data ; 
      `uvm_info("TRACE", $sformatf("%m : write address and data"), UVM_HIGH);
      @vif.drv; 
      vif.drv.pi_wr_en   <= 1'b1 ;
      `uvm_info("TRACE", $sformatf("%m : assert write enable"), UVM_HIGH);
      @vif.drv; 
      vif.drv.pi_wr_en   <= 1'b0 ;
      vif.drv.pi_blk_sel <= 1'b0 ;  
      `uvm_info("TRACE", $sformatf("%m : De-assert write enable and blk_sel"), UVM_HIGH);
   endtask 

   virtual task read_reg( input bit [3:0] addr, output bit [7:0] data) ;
      vif.drv.pi_blk_sel <= 1'b1 ;  
      vif.drv.pi_addr    <= addr ; 
      `uvm_info("TRACE", $sformatf("%m : Assert blk_sel and read address"), UVM_HIGH);
      @vif.drv; 
      vif.drv.pi_rd_en   <= 1'b1 ;
      `uvm_info("TRACE", $sformatf("%m : Assert read enable"), UVM_HIGH);
      @vif.drv; 
      data  =  vif.drv.pi_rd_data ; 
      vif.drv.pi_rd_en   <= 1'b0 ;
      vif.drv.pi_blk_sel <= 1'b0 ;  
      `uvm_info("TRACE", $sformatf("%m : De-assert read enable and blk_sel"), UVM_HIGH);
      `uvm_info("TRACE", $sformatf("%m : Sample read data ( 0x%8h )", data), UVM_HIGH);
   endtask 

endclass: up_driver 
`endif
