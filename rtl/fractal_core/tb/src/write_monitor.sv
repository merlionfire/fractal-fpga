`ifndef WRITE_MONITOR__SV
`define WRITE_MONITOR__SV

class write_monitor extends uvm_monitor;

   virtual up_if  vif;

   uvm_analysis_port #(packet) analysis_port;

   `uvm_component_utils(write_monitor)

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
       `uvm_fatal("CFGERR", "Interface for write_monitor not set");
     end
   endfunction: end_of_elaboration_phase

   virtual task run_phase(uvm_phase phase);
      packet   pkt; 
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

      forever begin  
        pkt =  packet::type_id::create("pkt", this ) ; 
        get_packet(pkt);
        `uvm_info("Got_Input_Packet", {"\n", pkt.sprint()}, UVM_HIGH);
        analysis_port.write(pkt); 
      end

   endtask 


  virtual task get_packet(packet pkt);
    logic [10:1][7:0] data ;
    logic [3:0]   addr ; 
    logic [7:0]   wr_data;   
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

    forever begin
       wait( vif.mon.pi_wr_en && vif.mon.pi_blk_sel ) ; 
       //`uvm_info("Got_Input_Packet", "Found register write\n",  UVM_MEDIUM);
       addr    = vif.mon.pi_addr ; 
       wr_data = vif.mon.pi_wr_data;
       if ( ( addr == 'h0 ) && wr_data[0] == 1'b1 ) break ; 
       data[addr] =  wr_data; 
       @(vif.mon iff ( vif.mon.pi_wr_en == 1'b0 ) );
       //`uvm_info("Got_Input_Packet", "pi_wr_en deasserted\n",  UVM_MEDIUM);
    end
    pkt.cx     =  packet::bits2float(data[4:1]) ; 
    pkt.cy     =  packet::bits2float(data[8:5]) ; 
    pkt.iter   =  $unsigned(data[10:9]); 
    pkt.x      =  vif.x;
    pkt.y      =  vif.y;
    @(vif.mon iff ( vif.mon.pi_wr_en == 1'b0 ) );

  endtask: get_packet

endclass: write_monitor

`endif
