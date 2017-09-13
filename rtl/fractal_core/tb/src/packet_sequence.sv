`ifndef PACKET_SEQUENCE__SV
`define PACKET_SEQUENCE__SV

class packet_sequence_base extends uvm_sequence #(packet);
   `uvm_object_utils(packet_sequence_base)

   function new(string name ="packet_sequence_base");
      super.new(name);
      `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      set_automatic_phase_objection(1); 
   endfunction: new

endclass: packet_sequence_base


class packet_sequence extends packet_sequence_base; 

   int   iter_cnt =  -1 ; 

   `uvm_object_utils_begin(packet_sequence)
      `uvm_field_int(iter_cnt, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "packet_sequence");
     super.new(name);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
   endfunction: new

   virtual task pre_start();
      super.pre_start(); 
      //uvm_config_db#(int)::get(get_sequencer(), get_type_name(), "iter_cnt", iter_cnt); 
   endtask: pre_start

   virtual task body();
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      for ( int x = 40 ; x < 100 ; x++ ) begin 
         for ( int y = 0 ; y < 768 ; y++ ) begin  
            `uvm_do_with(req, { x == local::x  ; y == local::y ; } ) ; 
         end
      end
         //`uvm_do_with(req, { x==10 ; y==757 ; } ) ; 
         //`uvm_do_with(req, { x==512 ; y==384 ; } ) ; 
      //end
   endtask: body

endclass: packet_sequence

`endif
