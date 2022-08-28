module tb_init();

reg clk, rst_n, en;
wire rdy, wren;
wire [7:0] addr, wrdata; 
integer i;


init dut(clk, rst_n, en, 
    rdy, addr, wrdata, wren);


initial begin
    clk = 1'b0; #5;
forever begin
    clk = 1'b1; #5;
    clk = 1'b0; #5;
end
end

initial begin
//assert reset, check that nothing is written 
en = 1'b0;
rst_n = 1'b0;
#2000;
assert(rdy == 0);
assert(addr == 0);
assert(wrdata == 0);

//begin process, assert enable and reset
en = 1'b1;
rst_n = 1'b1;
#2000;
//display addr and wrdata every 10 seconds, making sure values are the same
for (i=0; i< 200; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d",addr, wrdata, wren); 
  end

//reset process once more
rst_n = 1'b0;
#100;
assert(rdy == 0);
assert(addr == 0);
assert(wrdata == 0);
rst_n = 1'b1;
//display addr and wrdata every 10 seconds, making sure values are the same
for (i=0; i< 600; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d, rdy = %d ",addr, wrdata, wren, rdy); 
  end

//addr and wrdata should not increment 
en = 1'b0;
for (i=0; i< 20; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d, rdy = %d ",addr, wrdata, wren, rdy);  
  end

en = 1'b1;
for (i=0; i< 120; i=i+1) begin
    #10 $display("addr = %d, wrdata = %d, wren = %d, rdy = %d ",addr, wrdata, wren, rdy); 
  end

$stop;

end


endmodule: tb_init
