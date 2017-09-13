`ifndef OUTPUT_AGENT__SV
`define OUTPUT_AGENT__SV

class output_agent extends uvm_agent;
   `uvm_component_utils(output_agent)

   virtual up_if     vif;
   read_monitor      rd_mon;
   uvm_analysis_port #(packet)   analysis_port; 

   function new(string name, uvm_component parent);
     super.new(name, parent);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     rd_mon =  read_monitor::type_id::create("rd_mon",this) ; 
     analysis_port   =  new("analysis_port",this) ; 

     uvm_config_db#(virtual up_if)::get(this,"", "vif", vif); 
     uvm_config_db#(virtual up_if)::set(this,"*", "vif" , vif);
   endfunction: build_phase
   
   virtual function void connect_phase(uvm_phase phase);
     super.build_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     rd_mon.analysis_port.connect(this.analysis_port); 
   endfunction: connect_phase

   virtual function void end_of_elaboration_phase(uvm_phase phase);
     super.end_of_elaboration_phase(phase);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     if (vif == null) begin
       `uvm_fatal("CFGERR", "Interface for output_agent not set");
     end
   endfunction: end_of_elaboration_phase

endclass: output_agent

`endif //OUTPUT_AGENT__SV
