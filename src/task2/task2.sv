module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);
//inputs for ksa
wire en, ksa_en;
assign en = 1;
//outputs for ksa
wire rdy_ksa, rdy_init, wren_init, wren_ksa, wren;
wire [7:0] addr_init, addr_ksa, addr, wrdata, wrdata_init, wrdata_ksa;
//outputs for mem
wire [7:0] q;

//inputs for switch
wire [23:0] SW_mod;
assign SW_mod = {14'b00000000000000, SW};

    assign ksa_en = wren_init ? 0 : 1;

    assign addr = wren_init? addr_init: addr_ksa;
    assign wrdata = wren_init? wrdata_init: wrdata_ksa;
    assign wren = wren_init? wren_init: wren_ksa;
    //instantiating s_mem
    s_mem s(addr, CLOCK_50, wrdata, wren, q);

    //instantiating init
    init i(CLOCK_50, KEY[3], en, rdy_init, addr_init, wrdata_init, wren_init);

    //instantiating ksa
    ksa ksa1(CLOCK_50, KEY[3], ksa_en, rdy_ksa, SW_mod, addr_ksa, q, wrdata_ksa, wren_ksa);

    
    
endmodule: task2
