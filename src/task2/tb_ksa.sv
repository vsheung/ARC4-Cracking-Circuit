module tb_ksa();

reg clk, rst_n, en;
reg [23:0] key;
reg [7:0] rddata;
wire rdy, wren;
wire [7:0] addr, wrdata; 
integer i;

ksa dut(clk, rst_n, en, rdy,
        key, addr, rddata, wrdata, wren);


initial begin
    clk = 1'b0; #5;
forever begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
end
end

initial begin
//start with en deasserted and rst asserted
en = 1'b0;
rst_n = 1'b1;
key = 24'b000000000000001100111100;
#100;

//reset
rst_n = 1'b0;
rddata = 8'b00000000;
#100;
assert(rdy == 0);
assert(addr == 0);
assert(wrdata == 0);

//start for another 100 clicks
rst_n = 1'b1;
#100;

//en is off
rst_n = 1'b0;
en = 1'b0;
#100;
assert(rdy == 0);
assert(addr == 0);
assert(wrdata == 0);

// begin and check values

//s[i] = 0
//rddata = 8'b00000000;
en = 1'b1;
rst_n = 1'b1;
for (i=0; i< 31; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d, rdy = %d ",addr, wrdata, wren, rdy);  
  end

//s[i] = 1
rddata = 8'b00000001;
#190;
rddata = 8'b00000100;
#30;
rddata = 8'b00000001;
for (i=0; i< 12; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d, rdy = %d ",addr, wrdata, wren, rdy); 
  end

//s[i] = 2
rddata = 8'b00000010;
#190;
rddata = 8'b01000010;
#30;
rddata = 8'b00000010;
for (i=0; i< 12; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d, rdy = %d ",addr, wrdata, wren, rdy); 
  end

en = 1'b0;
#100;
assert(rdy == 0);
//assert(addr == 0);
//assert(wrdata == 0);

en = 1'b1;
#100;
$stop;

end

endmodule: tb_ksa
