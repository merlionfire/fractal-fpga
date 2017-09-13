
class ports_reset_sequence extends uvm_sequence #(packet);

  virtual up_if vif;           // DUT virtual interface

  `uvm_object_utils(ports_reset_sequence)

  function new(string name="ports_reset_sequence");
    super.new(name);
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);

     set_automatic_phase_objection(1);
  endfunction: new

  virtual task pre_start();
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    uvm_config_db#(virtual up_if)::get(get_sequencer(), "", "vif", vif);
    if (vif == null) begin
      `uvm_fatal("CFGERR", "Interface for the Driver Reset Sequence not set");
    end
  endtask: pre_start

  virtual task body();
    `uvm_info("TRACE", $sformatf("%m"), UVM_HIGH);
    vif.pi_blk_sel = '0;
    vif.pi_addr = '0; 
    vif.pi_wr_en = '0;
    vif.pi_rd_en = '0;
    vif.pi_wr_data = '0;
    vif.pi_rd_data = '0;
    vif.interrupt = '0;
    vif.interrupt_ack  = '0; 
  endtask: body

endclass 
