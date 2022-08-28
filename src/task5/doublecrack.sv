module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic [23:0] key_odd, key_even;
    logic key_valid_odd, key_valid_even;
    logic [7:0] ct_addr_odd, ct_rddata_odd, ct_addr_even, ct_rddata_even;
    logic en_c1, en_c2;
    logic [7:0] pt_addr_odd, pt_rddata_odd, pt_wrdata_odd, pt_wren_odd;
    logic [7:0] pt_addr_even, pt_rddata_even, pt_wrdata_even, pt_wren_even;
    logic c1_rdy, c2_rdy;
    logic [10:0] str_len_c1, str_len_c2, str_len;
    logic [7:0] pt_addr, pt_wrdata, pt_rddata;
    logic pt_wren_even_before, pt_wren_odd_before;

    logic [7:0] pt_addr_odd_after, pt_addr_odd_before, pt_addr_even_before, pt_addr_even_after;

    `define STANDBYSTART 4'b0000
    `define CRACKBEGIN 4'b0001
    `define READYDETECTEDKEY 4'b0010
    `define READYDETECTEDNOKEY 4'b0011

    move_memory move(clk, rst_n, str_len_c1, str_len_c2, c1_rdy,
                    c2_rdy, pt_rddata_odd, pt_rddata_even, pt_addr, pt_wrdata,
                    pt_addr_odd_after, pt_addr_even_after);

    //add two instances of CTMEM for each crack
    ct_mem ct_odd(ct_addr_odd, clk, 0, 0, ct_rddata_odd);

    ct_mem ct_even(ct_addr_even, clk, 0, 0, ct_rddata_even);

    assign pt_addr_even = (c2_rdy == 1)?pt_addr_even_after: pt_addr_even_before;
    assign pt_addr_odd = (c1_rdy == 1)?pt_addr_odd_after: pt_addr_odd_before;
    
    assign pt_wren_odd = (c1_rdy == 1)?0: pt_wren_odd_before;
    assign pt_wren_even = (c2_rdy == 1)?0: pt_wren_even_before;

    //add two instances of PTMEM for each crack
    pt_mem pt_odd(pt_addr_odd, clk, pt_wrdata_odd, pt_wren_odd, pt_rddata_odd);

    pt_mem pt_even(pt_addr_even, clk, pt_wrdata_even, pt_wren_even, pt_rddata_even);
    
    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(pt_addr, clk, pt_wrdata, 1, pt_rddata);
    //assign pt_addr = 40;
    //assign pt_wrdata = 40;

    // for this task only, you may ADD ports to crack
    crack c1(clk, rst_n, en_c1, c1_rdy,
             key_odd, key_valid_odd,
             ct_addr_odd, ct_rddata_odd,
             1, pt_addr_odd_before, pt_rddata_odd, 
             pt_wrdata_odd, pt_wren_odd_before,
             str_len_c1);

    crack c2(clk, rst_n, en_c2, c2_rdy,
             key_even, key_valid_even,
             ct_addr_even, ct_rddata_even,
             0, pt_addr_even_before, pt_rddata_even,
             pt_wrdata_even, pt_wren_even_before,
             str_len_c2);

    reg [3:0] present_state, next_state;
    reg [23:0] key_next;

    always@ (posedge clk or negedge rst_n) begin
    if (rst_n == 0) begin
        present_state <= `STANDBYSTART;
        key <= 0;
    end else begin
        present_state <= next_state;
        key <= key_next;
end
end

   always@(*) begin
    case (present_state)
        `STANDBYSTART: if (en == 1)
                        next_state = `CRACKBEGIN;
                       else
                        next_state = `STANDBYSTART;
        `CRACKBEGIN: if ((c1_rdy == 1 && key_valid_odd == 1) || (c2_rdy == 1 && key_valid_even == 1))
                        next_state = `READYDETECTEDKEY;
                    else if ((c1_rdy == 1 && key_valid_odd == 0) || (c2_rdy == 1 && key_valid_even == 0))
                        next_state = `READYDETECTEDNOKEY;
                    else
                        next_state = `CRACKBEGIN;
        `READYDETECTEDKEY: if (rst_n == 0)
                        next_state = `STANDBYSTART;
                        else
                        next_state = `READYDETECTEDKEY;
        `READYDETECTEDNOKEY: if (rst_n == 0)
                        next_state = `STANDBYSTART;
                        else
                        next_state = `READYDETECTEDNOKEY;
        default: next_state = `STANDBYSTART;
    endcase
    end 
    
    always_comb begin
    case (present_state)
        `STANDBYSTART: begin
        en_c1 = 0;
        en_c2 = 0;
        rdy = 0;
        key_next = 0;
        key_valid = 0;
        end
        `CRACKBEGIN: begin
        en_c1 = 1;
        en_c2 = 1;
        rdy = 0;
        key_next = 0;
        key_valid = 0;
        end
        `READYDETECTEDKEY: begin
        rdy = 1;
        if (c1_rdy == 1) begin
            key_next = key_odd;
            en_c1 = 0;
            en_c2 = 0;
        end else begin
        if (c2_rdy == 1) begin
            key_next = key_even;
            en_c1 = 0;
            en_c2 = 0;
        end else begin
            key_next = 0;
            en_c1 = 0;
            en_c2 = 0;
        end
        end
        key_valid = 1;
        end
        `READYDETECTEDNOKEY: begin
        en_c1 = 0;
        en_c2 = 0;
        rdy = 1;
        key_next = 0;
        key_valid = 0;
        end
        default: begin
        en_c1 = 0;
        en_c2 = 0;
        rdy = 0;
        key_next = 0;
        key_valid = 0;
        end
    endcase
    end
    

endmodule: doublecrack


module move_memory (input logic clk, input logic rst_n, input logic [10:0] str_len_c1,
                    input logic [10:0] str_len_c2, input logic c1_rdy,
                    input logic c2_rdy, input logic [7:0] pt_rddata_odd,
                    input logic [7:0] pt_rddata_even, output logic [7:0] pt_addr,
                    output logic [7:0] pt_wrdata, output logic [7:0] pt_addr_odd,
                    output logic [7:0] pt_addr_even);

`define WAITFORREADY 4'b0000
`define STORESTUFFODD 4'b0001
`define DONE 4'b0010
`define STORESTUFFEVEN 4'b0011
reg [7:0] pt_addr_odd_next, pt_addr_even_next;
reg [7:0]pt_addr_next, pt_wrdata_next;
reg [3:0] next_state, present_state;
reg [10:0]seq_flag, seq_flag_next;

always @(posedge clk or negedge rst_n) begin

if (rst_n == 0) begin
    pt_addr <= 0;
    present_state <= `WAITFORREADY;
    seq_flag <= 0;
    pt_wrdata <=0;
    pt_addr_even <= 0;
    pt_addr_odd <= 0;

end else begin
    pt_addr <= pt_addr_next;
    present_state <= next_state;
    seq_flag <= seq_flag_next;
    pt_wrdata <= pt_wrdata_next;
    pt_addr_even <= pt_addr_even_next;
    pt_addr_odd <= pt_addr_odd_next;
end 
end

always_comb begin
    case(present_state)
        `WAITFORREADY: if (c1_rdy == 1)
                        next_state = `STORESTUFFODD;
                        else if (c2_rdy == 1)
                        next_state = `STORESTUFFEVEN;
                        else
                        next_state = `WAITFORREADY;
        `STORESTUFFODD: if (seq_flag ==5 && pt_addr == str_len_c1)
                        next_state = `DONE;
                        else
                        next_state = `STORESTUFFODD;
        `STORESTUFFEVEN: if (seq_flag ==5 && pt_addr == str_len_c2)
                        next_state = `DONE;
                        else
                        next_state = `STORESTUFFEVEN;
        `DONE: if (rst_n == 0)
                next_state = `WAITFORREADY;
                else
                next_state = `DONE;
        default: next_state = `WAITFORREADY;
    endcase
end

always_comb begin
    case(present_state)
        `WAITFORREADY: begin
        seq_flag_next <= 0;
        pt_addr_next <= 0;
        pt_wrdata_next <= 0;
        pt_addr_even_next <= 0;
        pt_addr_odd_next <=0;
        end

        `STORESTUFFEVEN:begin
        if(seq_flag == 5) begin
        seq_flag_next <= 0;
        pt_wrdata_next <= 0;
        pt_addr_next <= pt_addr + 1;
        pt_addr_even_next <= pt_addr_even + 1;
        pt_addr_odd_next <=0;
        end else begin
        seq_flag_next <= seq_flag +1;
        pt_wrdata_next <= pt_rddata_even;
        pt_addr_next <= pt_addr;
        pt_addr_even_next <= pt_addr_even;
        pt_addr_odd_next <=0;
        end
        end

        `STORESTUFFODD: begin
        if(seq_flag == 5) begin
        seq_flag_next <= 0;
        pt_wrdata_next <= 0;
        pt_addr_next <= pt_addr + 1;
        pt_addr_even_next <= 0;
        pt_addr_odd_next <= pt_addr_odd + 1;
        end else begin
        seq_flag_next <= seq_flag + 1;
        pt_wrdata_next <= pt_rddata_odd;
        pt_addr_next <= pt_addr;
        pt_addr_even_next <= 0;
        pt_addr_odd_next <= pt_addr_odd;
        end
        end

        `DONE: begin
        seq_flag_next <= 0;
        if (c1_rdy == 1)
        pt_wrdata_next <= pt_rddata_odd;
        else if (c2_rdy == 1)
        pt_wrdata_next <= pt_rddata_even;
        else
        pt_wrdata_next <=0;
        pt_addr_next <= 0;
        pt_addr_even_next <= 0;
        pt_addr_odd_next <= 0;
        end

    endcase
end 

endmodule 
