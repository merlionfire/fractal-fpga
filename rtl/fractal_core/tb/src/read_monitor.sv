`ifndef READ_MONITOR__SV
`define READ_MONITOR__SV

class read_monitor extends uvm_monitor;

   virtual up_if  vif;

   uvm_analysis_port #(packet) analysis_port;

   `uvm_component_utils(read_monitor)

   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

     uvm_config_db#(virtual up_if)::get(this,"", "vif", vif ) ; 

     analysis_port = new("analysis_port", this);

   endfunction: build_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (vif == null) begin
       `uvm_fatal("CFGERR", "Interface for read_monitor not set");
     end
   endfunction: end_of_elaboration_phase

   virtual task run_phase(uvm_phase phase);
      packet   pkt; 
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

      forever begin  
        pkt =  packet::type_id::create("pkt", this ) ; 
        get_packet(pkt);
        `uvm_info("Got_Output_Packet", {"\n", pkt.sprint()}, UVM_MEDIUM);
        analysis_port.write(pkt); 
      end

   endtask 

   virtual task get_packet(packet pkt);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     forever begin
       wait( vif.mon.pi_rd_en && vif.mon.pi_blk_sel && (vif.mon.pi_addr == 'h0) ) ; 
       `uvm_info("Got_Output_Packet", "Found register read\n",  UVM_HIGH);
       if ( vif.mon.pi_rd_data[0]  == 1'b0 ) break ; 
       @(vif.mon iff (vif.mon.pi_rd_en == 1'b0 ) ) ; 
       `uvm_info("Got_Output_Packet", "pi_rd_en deasserted\n",  UVM_HIGH);
     end
     
     if ( vif.mon.pi_rd_data[1] == 1'b1 ) begin 
       pkt.result =  packet::TRUE ; 
     end else begin 
       pkt.result =  packet::FALSE ; 
     end
     pkt.x  =  vif.x;
     pkt.y  =  vif.y;
     @(vif.mon iff (vif.mon.pi_rd_en == 1'b0 ) ) ; 
   endtask: get_packet


endclass: read_monitor

`endif // READ_MONITOR__SV
