`ifndef FRACTAL_ENV__SV
`define FRACTAL_ENV__SV

class fractal_env extends uvm_env ; 
   `uvm_component_utils(fractal_env) 

   master_agent   mst_agt ; 
   reset_agent    rst_agt ; 
   output_agent   o_agt ; 

   typedef scoreboard #(packet, packet)  pkt_scoreboard ; 

   pkt_scoreboard    sb; 
   
   virtual_reset_sequencer    v_reset_sqr ; 

   function new(string name, uvm_component parent);
      super.new(name, parent);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      
      mst_agt   =  master_agent::type_id::create("mst_agt", this) ;    
      rst_agt   =  reset_agent::type_id::create("rst_agt", this);
      o_agt     =  output_agent::type_id::create("o_agt",this);

      v_reset_sqr =  virtual_reset_sequencer::type_id::create("v_reset_sqr",this); 
      uvm_config_db#(uvm_object_wrapper)::set(this,"v_reset_sqr.reset_phase","default_sequence", virtual_reset_sequence::get_type() ) ; 

      uvm_config_db#(uvm_object_wrapper)::set(this,"mst_agt.sqr.main_phase", "default_sequence", packet_sequence::get_type()); 

      sb =  pkt_scoreboard::type_id::create("sb", this);

   endfunction: build_phase 

   virtual function void connect_phase(uvm_phase phase);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      v_reset_sqr.reset_sqr   =  rst_agt.sqr ; 
      v_reset_sqr.pkt_sqr.push_back( mst_agt.sqr ) ; 

      mst_agt.analysis_port.connect(sb.before_export) ; 
      o_agt.analysis_port.connect(sb.after_export)  ; 
   endfunction: connect_phase 

endclass 

`endif
