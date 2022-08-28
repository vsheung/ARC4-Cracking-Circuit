module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    wire ksa_en, prga_en;
    //assign en = 1'b1; 
    //smem inputs
    wire [7:0] s_addr, s_wrdata, q;
    wire s_wren;

    //variables for init
    wire rdy_init, wren_init;
    wire [7:0] addr_init, wrdata_init;

    //variables for ksa
    wire rdy_ksa, wren_ksa;
    wire [7:0] addr_ksa, wrdata_ksa;

    //variables for prga
    wire rdy_prga, wren_prga;
    wire [7:0] addr_prga, wrdata_prga;

    //variables for counter
    wire [9:0] counter_out;

    //counter
    counter counter1(counter_out, wren_ksa, rst_n, clk);
    //instantiate s_mem
    s_mem s(s_addr, clk, s_wrdata, s_wren, q);

    //instantiate init
    init i(clk, rst_n, en, rdy_init, 
           addr_init, wrdata_init, wren_init);

    //instantiate ksa
    ksa k(clk, rst_n, ksa_en, rdy_ksa, 
           key, addr_ksa, q, wrdata_ksa, wren_ksa);
    
    //instantiate prga
    
    prga p(clk, rst_n, prga_en, 
           rdy_prga, key, addr_prga,
           q, wrdata_prga, wren_prga,
           ct_addr, ct_rddata, pt_addr,
           pt_rddata, pt_wrdata, pt_wren);

    //initialize init, ksa then prga
    //assign ksa_en = wren_init ? 0 : 1;
    assign ksa_en = wren_init ? 0 : 1;
    assign prga_en = (counter_out > 765)? 1 : 0;

    assign s_addr = (wren_init == 1)? addr_init: ((counter_out > 765)? addr_prga: addr_ksa);
    assign s_wrdata = (wren_init == 1)? wrdata_init: ((counter_out > 765)? wrdata_prga: wrdata_ksa);
    assign s_wren = (wren_init == 1)? wren_init: ((counter_out > 765)? wren_prga: wren_ksa);

endmodule: arc4

module counter(out, enable, reset, clk);
input enable, reset, clk;
output reg [9:0] out;

initial out = 0;

always @(posedge clk) begin
    if (reset == 1'b0) begin
        out <= 10'b0000000000;
    end else begin
        if (enable == 1) begin
        out <= out + 1;
        end 
        end
end
endmodule