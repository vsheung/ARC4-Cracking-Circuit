module tb_task2();

reg CLOCK_50;
reg [3:0] KEY;
reg [9:0] SW;
wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
wire [9:0] LEDR;

task2 dut(CLOCK_50, KEY, SW,
        HEX0, HEX1, HEX2,
        HEX3, HEX4, HEX5,
        LEDR);
// Your testbench goes here.

initial begin
    CLOCK_50 = 1'b0; #5;
forever begin
    CLOCK_50 = 1'b1; #5;
    CLOCK_50 = 1'b0; #5;
end
end

initial begin
SW = 10'b1100111100;
KEY[3] = 0;
#100;

//ASSERT THAT KEY, LEDR AND HEX DISPLAYS ARE NOT USED
$display("TIME#100 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
//assert({HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} == {7'bxxxxxxx, 7'bxxxxxxx, 7'bxxxxxxxx, 7'bxxxxxxxx, 7'bxxxxxxxx, 7'bxxxxxxxx});
$display("TIME#100 LEDR:%b, SW:%b", LEDR, SW);


KEY[3] = 1;
#100;
$display("TIME#200 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
$display("TIME#200 LEDR:%b, SW:%b", LEDR, SW);

KEY[3] = 0;
#200;
//ASSERT THAT KEY, LEDR AND HEX DISPLAYS ARE NOT USED
$display("TIME#300 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
//assert({HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} == {7'bxxxxxxx, 7'bxxxxxxx, 7'bxxxxxxxx, 7'bxxxxxxxx, 7'bxxxxxxxx, 7'bxxxxxxxx});
$display("TIME#300 LEDR:%b, SW:%b", LEDR, SW);

KEY[3] = 1;

$stop;
end

endmodule: tb_task2
