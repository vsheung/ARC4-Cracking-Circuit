module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);
//inputs for init
wire en = 1'b1;
//outputs for init
wire rdy, wren;
wire [7:0] addr, wrdata;
//outputs for mem
wire [7:0] q;

    //instantiating s_mem
    s_mem s(addr, CLOCK_50, wrdata, wren, q);

    //instantiating init
    init i(CLOCK_50, KEY[3], en, rdy, addr, wrdata, wren);

endmodule: task1
