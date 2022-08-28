module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    // your code here
    `define WAITEN 4'b0000
    `define CRACKITUP 4'b0001
    `define WEDONE 4'b0010

    wire [7:0] ct_addr, ct_rddata;
    wire en;
    assign en = 1;
    wire rdy, key_valid;
    wire [23:0] key1;

    //using HEX display code from lab1
    logic [3:0] h0, h1, h2, h3, h4, h5;

    ct_mem ct(ct_addr, CLOCK_50, 0, 0, ct_rddata);

    crack c( CLOCK_50, KEY[3], en, rdy,
             key1, key_valid, ct_addr, ct_rddata);

    //oh turns out we need a state machine
    reg [3:0] present_state, next_state;

    always@ (posedge CLOCK_50 or negedge KEY[3]) begin
    if (KEY[3] == 0) begin
        present_state <= `WAITEN;
    end else begin
        present_state <= next_state;
end
end

    always_comb begin
    case (present_state)
            `WAITEN: if (en == 1)
                        next_state = `CRACKITUP;
                    else
                        next_state = `WAITEN;
            `CRACKITUP: if (rdy == 1)
                        next_state = `WEDONE;
                        else
                        next_state = `CRACKITUP;
            `WEDONE: if (KEY[3] == 0)
                        next_state = `WAITEN;
                    else
                        next_state = `WEDONE;
            default: next_state = `WAITEN;

    endcase
    
end

always_comb begin
    //outputs
    case (present_state)
        `WAITEN: begin
                h0=0;
                h1=0;
                h2=0;
                h3=0;
                h4=0;
                h5=0;
                end
        `CRACKITUP: begin
                h0=0;
                h1=0;
                h2=0;
                h3=0;
                h4=0;
                h5=0;
                end
        `WEDONE: if (key_valid == 1) begin
                h0= key1[3:0];
                h1= key1[7:4];
                h2= key1[11:8];
                h3= key1[15:12];
                h4= key1[19:16];
                h5= key1[23:20];
                end else begin
                h0=16;
                h1=16;
                h2=16;
                h3=16;
                h4=16;
                h5=16;
                end
        default: begin
                h0=0;
                h1=0;
                h2=0;
                h3=0;
                h4=0;
                h5=0;
                end
    endcase
end

    card7seg hex0(h0, HEX0);
    card7seg hex1(h1, HEX1);
    card7seg hex2(h2, HEX2);
    card7seg hex3(h3, HEX3);
    card7seg hex4(h4, HEX4);
    card7seg hex5(h5, HEX5);

    

endmodule: task4

module card7seg(input [3:0] SW, output [6:0] HEX0);
//FINAL COMMIT
reg [6:0] seg7_out;
    //display depending on input
    always @(*) begin
        case (SW)
            0: seg7_out = 7'b1000000;
            1: seg7_out = 7'b1111001;
            2: seg7_out = 7'b0100100;
            3: seg7_out = 7'b0110000;
            4: seg7_out = 7'b0011001;
            5: seg7_out = 7'b0010010;
            6: seg7_out = 7'b0000010;
            7: seg7_out = 7'b1111000;
            8: seg7_out = 7'b0000000;
            9: seg7_out = 7'b0010000;
            10: seg7_out = 7'b0001000;
            11: seg7_out = 7'b0000011;
            12: seg7_out = 7'b1000110;
            13: seg7_out = 7'b0100001;
            14: seg7_out = 7'b0000110;
            15: seg7_out = 7'b0001110;
            16: seg7_out = 7'b0111111;// -------
            default: seg7_out = 7'b1111111;
        endcase
    end
   // your code goes here
   assign HEX0 = seg7_out;

endmodule