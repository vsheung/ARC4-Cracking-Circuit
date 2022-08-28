module tb_prga();

reg clk, rst_n, en;
reg [23:0] key;
reg [7:0] s_rddata, ct_rddata, pt_rddata;

wire rdy, s_wren, pt_wren;
wire [7:0] s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata;
integer i;

prga dut(clk, rst_n, en, rdy,
        key, s_addr, s_rddata, s_wrdata, 
        s_wren, ct_addr, ct_rddata, pt_addr,
        pt_rddata, pt_wrdata, pt_wren);

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
s_rddata = 8'b00000001;
en = 1'b1;
rst_n = 1'b1;
key = 24'b000000000000001100111100;
#100;

//reset
rst_n = 1'b0;
#100;
assert(rdy == 0);
assert(s_wren == 0);
assert(pt_wren == 0);
assert(s_addr == 0);
assert(ct_addr == 1);
assert(pt_addr == 1);
assert(s_wrdata == 0);
assert(pt_wrdata == 0);

//start for another 100 clicks
rst_n = 1'b1;
#100;

//en is off
rst_n = 1'b0;
en = 1'b0;
#100;
assert(rdy == 0);
assert(s_wren == 0);
assert(pt_wren == 0);
assert(s_addr == 0);
assert(ct_addr == 1);
assert(pt_addr == 1);
assert(s_wrdata == 0);
assert(pt_wrdata == 0);

// begin and check values

//pt[1]

ct_rddata = 41;
en = 1'b1;
rst_n = 1'b1;
for (i=0; i< 20; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end
s_rddata = 1;
for (i=0; i< 25; i=i+1) begin
   #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata); 
  end
s_rddata = 2;
for (i=0; i< 30; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata); 
  end
s_rddata = 5;
for (i=0; i< 20; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end
ct_rddata = 2;
for (i=0; i< 25; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata); 
  end

//pt[1]
ct_rddata = 41;
for (i=0; i< 20; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end
s_rddata = 3;
for (i=0; i< 25; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end
s_rddata = 6;
for (i=0; i< 30; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end
//randomly stop: should stop at sequence flag 80
en = 0;
for (i=0; i< 30; i=i+1) begin
    #10 $display(" SHOULD STAY AT SAME STATE s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end

//re-enable 
en = 1;
s_rddata = 7;
for (i=0; i< 20; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);  
  end
ct_rddata = 3;
for (i=0; i< 25; i=i+1) begin
    #10 $display("s_wren = %d, pt_wren = %d, s_addr = %d, ct_addr = %d, pt_addr = %d, s_wrdata = %d, pt_wrdata = %d",
    s_wren, pt_wren, s_addr, ct_addr, pt_addr, s_wrdata, pt_wrdata);
  end


end


endmodule: tb_prga
