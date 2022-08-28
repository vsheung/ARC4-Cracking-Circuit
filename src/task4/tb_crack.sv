module tb_crack();

reg clk, rst_n, en;
reg [7:0] ct_rddata;

wire rdy, key_valid;
wire [23:0] key;
wire [7:0] ct_addr;
integer i;


crack dut(clk, rst_n, en, rdy,
        key, key_valid, ct_addr, ct_rddata);
// Your testbench goes here.

initial begin
    clk = 1'b0; #5;
forever begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
end
end

initial begin 
ct_rddata = 8'b00000011;
en = 1'b1;
rst_n = 1'b1;
#100;

//reset
rst_n = 1'b0;
#100;
assert(rdy == 0);
assert(key_valid == 0);
assert(key == 0);
assert(ct_addr == 1);

//start for another 100 clicks
rst_n = 1'b1;
#100;

//en is off
rst_n = 1'b0;
en = 1'b0;
#100;
assert(rdy == 0);
assert(key_valid == 0);
assert(key == 0);
assert(ct_addr == 1);

ct_rddata = 8'b00000001;
rst_n = 1;
en = 1;
//wait until it spits out key
for (i=0; i< 800; i=i+1) begin
    #10 $display("rdy = %d, key = %d, key_valid = %d, ct_addr = %d",
    rdy, key, key_valid, ct_addr);  
  end
en = 1'b0;

//fsm should not continue
for (i=0; i< 10; i=i+1) begin
    #10 $display("rdy = %d, key = %d, key_valid = %d, ct_addr = %d",
    rdy, key, key_valid, ct_addr);  
  end

en = 1'b1;
ct_rddata = 8'b00000001;
for (i=0; i< 100; i=i+1) begin
    #10 $display("rdy = %d, key = %d, key_valid = %d, ct_addr = %d",
    rdy, key, key_valid, ct_addr);  
  end

rst_n = 1'b0;
#100;
ct_rddata = 8'b01110000;
for (i=0; i< 10; i=i+1) begin
    #10 $display("rdy = %d, key = %d, key_valid = %d, ct_addr = %d",
    rdy, key, key_valid, ct_addr);  
  end

rst_n = 1'b1;

for (i=0; i< 100; i=i+1) begin
    #10 $display("rdy = %d, key = %d, key_valid = %d, ct_addr = %d",
    rdy, key, key_valid, ct_addr);  
  end
$stop;

end
endmodule: tb_crack
