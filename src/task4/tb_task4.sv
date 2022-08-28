module tb_task4();

reg CLOCK_50;
reg [3:0] KEY;
reg [9:0] SW;
wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
wire [9:0] LEDR;

task4 dut(CLOCK_50, KEY, SW,
        HEX0, HEX1, HEX2,
        HEX3, HEX4, HEX5,
        LEDR);

initial begin
    CLOCK_50 = 1'b0; #5;
forever begin
    CLOCK_50 = 1'b1; #5;
    CLOCK_50 = 1'b0; #5;
end
end

initial begin
SW = 10'b0000110000;
KEY[3] = 0;
#100;

//LEDs should not be lit up 

// 000000 should be displayed at this point since reset is high
$display("TIME#100 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
$display("TIME#100 LEDR:%b, SW:%b", LEDR, SW);


// 000018 should be displayed at this point 
KEY[3] = 1;
#100;
$display("TIME#200 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
$display("TIME#200 LEDR:%b, SW:%b", LEDR, SW);

// 000000 should be displayed at this point since reset is high
KEY[3] = 0;
#200;
$display("TIME#400 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
$display("TIME#400 LEDR:%b, SW:%b", LEDR, SW);

//MAX VALUE FOR SWITCH: 10b'1111111111;
KEY[3] = 1;
SW = 10'b1111111111;
#200;
// 0003ff should be displayed
$display("TIME#600 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
$display("TIME#600 LEDR:%b, SW:%b", LEDR, SW);

SW = 10'b0000011111;
#200;
// 00001F shoul d be displayed
$display("TIME#800 HEX0:%b, HEX1:%b, HEX2:%b, HEX3:%b, HEX4:%b, HEX5:%b", HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
$display("TIME#800 LEDR:%b, SW:%b", LEDR, SW);

$stop;
end


endmodule: tb_task4
