`ifndef RESET_AGENT__SV
`define RESET_AGENT__SV

typedef class reset_driver;
typedef class reset_monitor;

class reset_agent extends uvm_agent;
   typedef uvm_sequencer#(reset_tr) reset_sequencer ; 

   virtual reset_if  vif;
   reset_sequencer   sqr ; 
   reset_driver      drv;
   reset_monitor     mon;

   `uvm_component_utils(reset_agent)

   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     `uvm_info("RSTCFG", $sformatf("Reset agent <%s> setting for is_active is: %p", this.get_name(), is_active), UVM_MEDIUM);

     uvm_config_db#(virtual reset_if)::get(this,"", "vif", vif);
     uvm_config_db#(virtual reset_if)::set(this,"*", "vif", vif);

     if (is_active == UVM_ACTIVE) begin
       sqr = reset_sequencer::type_id::create("sqr", this);
       drv = reset_driver::type_id::create("drv", this);
     end
     mon = reset_monitor::type_id::create("mon", this);
   endfunction: build_phase

   virtual function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (is_active == UVM_ACTIVE) begin
       drv.seq_item_port.connect(sqr.seq_item_export);
     end
   endfunction: connect_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (vif == null) begin
       `uvm_fatal("CFGERR", "Interface for reset agent not set");
     end
   endfunction: end_of_elaboration_phase

endclass

`endif // RESET_AGENT__SV
