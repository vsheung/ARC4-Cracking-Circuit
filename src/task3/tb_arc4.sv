module tb_arc4();

reg clk, rst_n, en;
reg [23:0] key;
wire rdy, pt_wren;
reg [7:0] ct_rddata, pt_rddata;
wire [7:0] ct_addr, pt_addr, pt_wrdata;

integer i;

arc4 dut (clk, rst_n, en, rdy,
        key, ct_addr, ct_rddata,
        pt_addr, pt_rddata, pt_wrdata,
        pt_wren);

initial begin
    clk = 1'b0; #5;
forever begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
end
end

initial begin 
ct_rddata = 8'b00000011;
pt_rddata = 8'b11010000;
en = 1'b1;
rst_n = 1'b1;
key = 24'b000000000000001100111100;
#100;

//reset
rst_n = 1'b0;
#100;
//assert(rdy == 0);
assert(pt_wren == 0);
assert(ct_addr == 1);
assert(pt_addr == 1);
assert(pt_wrdata == 0);

//start for another 100 clicks
rst_n = 1'b1;
#100;

//en is off
rst_n = 1'b0;
en = 1'b0;
#100;
//assert(rdy == 0);
assert(pt_wren == 0);
assert(ct_addr == 1);
assert(pt_addr == 1);
assert(pt_wrdata == 0);

// begin and check values

//assert that prga is enabled after 7650 clicks

rst_n = 1'b1;
en = 1'b1;
#7650;
for (i=0; i< 20; i=i+1) begin
#10 $display("pt_wren = %d, ct_addr = %d, pt_addr = %d, pt_wrdata = %d",
pt_wren, ct_addr, pt_addr,  pt_wrdata);
end

en = 1'b0;
for (i=0; i< 20; i=i+1) begin
#10 $display("SHOULD STAY AT SAME STATE: pt_wren = %d, ct_addr = %d, pt_addr = %d, pt_wrdata = %d",
pt_wren, ct_addr, pt_addr,  pt_wrdata);
end

rst_n = 1'b0;
for (i=0; i< 20; i=i+1) begin
#10 $display("SHOULD ALL BE 0: pt_wren = %d, ct_addr = %d, pt_addr = %d, pt_wrdata = %d",
pt_wren, ct_addr, pt_addr,  pt_wrdata);
end

rst_n = 1;
$stop;
end
endmodule: tb_arc4
