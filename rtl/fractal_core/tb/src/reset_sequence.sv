
class reset_sequence extends uvm_sequence #(reset_tr); 
   `uvm_object_utils(reset_sequence)

   function new(string name = "reset_sequence");
     super.new(name);
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
      set_automatic_phase_objection(1);
   endfunction: new

   virtual task body();
     `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
     `uvm_do_with(req, {kind == reset_tr::DEASSERT ; cycles == 3; } ); 
     `uvm_do_with(req, {kind == reset_tr::ASSERT ; cycles == 2; } ); 
     `uvm_do_with(req, {kind == reset_tr::DEASSERT ; cycles == 15; } ); 
   endtask : body 

endclass: reset_sequence 
