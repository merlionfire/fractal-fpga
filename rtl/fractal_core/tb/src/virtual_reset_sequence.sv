class virtual_reset_sequencer extends uvm_sequencer; 
   `uvm_component_utils(virtual_reset_sequencer) 
   
   typedef  uvm_sequencer#(reset_tr) reset_sequencer; 
   typedef  uvm_sequencer#(packet)   packet_sequencer;

   reset_sequencer   reset_sqr ;
   packet_sequencer  pkt_sqr[$] ; 


   function new(string name ="virtual_reset_sequencer", uvm_component parent);
     super.new(name, parent);    
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

endclass: virtual_reset_sequencer


class virtual_reset_sequence extends uvm_sequence;

   reset_sequence          reset_seq;
   ports_reset_sequence    ports_reset_seq;

   uvm_event   reset_event = uvm_event_pool::get_global("reset");

   `uvm_object_utils(virtual_reset_sequence) 
   `uvm_declare_p_sequencer(virtual_reset_sequencer)

   function new(string name="virtual_reset_sequence"); 
      super.new(name);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      set_automatic_phase_objection(1);
   endfunction

   virtual task body();
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      fork
         `uvm_do_on(reset_seq,   p_sequencer.reset_sqr); 
         foreach ( p_sequencer.pkt_sqr[i] ) begin
            int j = i;
            fork 
               begin 
                  reset_event.wait_on();
                  `uvm_do_on( ports_reset_seq, p_sequencer.pkt_sqr[j]) ; 
               end
            join_none
         end
      join
   endtask: body

endclass: virtual_reset_sequence

