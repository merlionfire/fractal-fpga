`ifndef MASTER_AGENT__SV
`define MASTER_AGENT__SV

class master_agent extends uvm_agent;
   `uvm_component_utils(master_agent) 

   typedef  uvm_sequencer #(packet) packet_sequencer;  

   virtual     up_if    vif; 
   packet_sequencer     sqr;
   up_driver            drv ; 
   write_monitor        wr_mon ; 
   uvm_analysis_port #(packet)   analysis_port; 

   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

     if ( is_active == UVM_ACTIVE ) begin 
        sqr    =  packet_sequencer::type_id::create("sqr", this);
        drv    =  up_driver::type_id::create("drv",this); 
     end

     wr_mon =  write_monitor::type_id::create("wr_mon",this) ; 
     analysis_port   =  new("analysis_port",this) ; 

     uvm_config_db#(virtual up_if)::get(this,"", "vif", vif); 
     uvm_config_db#(virtual up_if)::set(this,"*", "vif" , vif);

   endfunction: build_phase
   
   virtual function void connect_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if ( is_active == UVM_ACTIVE ) begin 
         drv.seq_item_port.connect(sqr.seq_item_export);
     end
     wr_mon.analysis_port.connect(this.analysis_port) ; 
   endfunction: connect_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (vif == null) begin
       `uvm_fatal("CFGERR", "Interface for master agent not set");
     end
   endfunction: end_of_elaboration_phase

endclass: master_agent
`endif
