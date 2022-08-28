module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    //arc4 inputs
    wire en = 1'b1;
    wire [7:0] ct_rddata, pt_rddata;
    //arc4 outputs
    wire rdy, pt_wren;
    wire [7:0] ct_addr, pt_addr, pt_wrdata;
    //key for arc4
    wire [23:0] SW_mod;
    assign SW_mod = {14'b00000000000000, SW};

    //instantiate ciphertext memory
    ct_mem ct(ct_addr, CLOCK_50, 0, 0, ct_rddata);

    //instantiate plaintext memory
    pt_mem pt(pt_addr, CLOCK_50, pt_wrdata, pt_wren, pt_rddata);

    //instantiate arc4
    arc4 a4(CLOCK_50, KEY[3], en, rdy,
            SW_mod, ct_addr, ct_rddata,
            pt_addr, pt_rddata, pt_wrdata, pt_wren);


endmodule: task3
