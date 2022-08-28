module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
             input logic odd_or_even,
             output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren,
             output logic [10:0] str_len);

    //pt memory variables
    logic [7:0] temp_addr;
    logic drop_out, arc_en, we_good, arc_rdy, start_flag, reset_arc;
    //logic [10:0] str_len;
    //logic delay_cycle;

    integer maxval;
    assign maxval = 24'b111111111111111111111111;


    //oh turns out we need a state machine
    reg [3:0] present_state, next_state;
    reg [23:0] key_next;
    reg [10:0] str_len_next;

    `define STANDBYSTART 4'b0000
    `define ARC4BEGIN 4'b0001
    `define STOPARC4 4'b0010
    `define ARC4BEGIN2 4'b0011
    `define NEXTKEY 4'b0100
    `define AITETHISTHEONE 4'b0101
    `define DONENOKEY 4'b0111

    // this memory must have the length-prefixed plaintext if key_valid
    //pt_mem pt(pt_addr, clk, pt_wrdata, 
               //pt_wren, pt_rddata);

    arc4 a4(clk, (rst_n && reset_arc), arc_en, 
            arc_rdy, key, ct_addr, 
            ct_rddata, pt_addr, pt_rddata,
            pt_wrdata, pt_wren);


    always@ (posedge clk or negedge rst_n) begin
    if (rst_n == 0) begin
        present_state <= `STANDBYSTART;
        key <= 0;
        str_len <=0;
    end else begin
        present_state <= next_state;
        key <= key_next;
        str_len <= str_len_next;
end
end


  always@(*) begin
    case (present_state)
            `STANDBYSTART: if (en == 1) begin
                        next_state = `ARC4BEGIN;
                    end else begin
                        next_state = `STANDBYSTART;
                        end
           `ARC4BEGIN: if ((pt_addr == 0) && (pt_wren ==1)) begin //change to ct_address
                            next_state = `STOPARC4;
                            end else begin
                            next_state = `ARC4BEGIN;
                        end
           `STOPARC4: next_state = `ARC4BEGIN2;
           `ARC4BEGIN2: if (key == maxval && (pt_wrdata<'h20 || pt_wrdata>'h7E)&&(pt_addr != 0)) begin
                            next_state = `DONENOKEY;
                        end else begin
                        if ((pt_wrdata <'h20 || pt_wrdata>'h7E) && (pt_addr != 0) && (pt_wren ==1)) begin
                            next_state = `NEXTKEY;
                        end else begin
                        if (pt_addr == str_len && pt_wrdata>='h20 && pt_wrdata<='h7E) begin
                            next_state = `AITETHISTHEONE;
                        end else begin
                            next_state = `ARC4BEGIN2;
                end
                end
                end
           `NEXTKEY: next_state = `ARC4BEGIN2;
           `AITETHISTHEONE: if (rst_n == 0)
                        next_state = `STANDBYSTART;
                    else
                        next_state = `AITETHISTHEONE;
           `DONENOKEY: if (rst_n == 0)
                        next_state = `STANDBYSTART;
                    else
                        next_state = `DONENOKEY;
            default: next_state = `STANDBYSTART;

    endcase
    
end

always_comb begin
    case (present_state)
            `STANDBYSTART: begin
            rdy = 0;
            arc_en = 0;
            key_valid = 0;
            str_len_next = 0;
            if (odd_or_even == 1)
                key_next = 0;
            else 
                key_next = 1;
            reset_arc = 1;
            end
            `ARC4BEGIN: begin
            rdy = 0;
            arc_en = 1;
            key_valid = 0;
            str_len_next = pt_wrdata;
            key_next = key;
            reset_arc = 1;
            end
            `STOPARC4: begin
            rdy = 0;
            arc_en = 1;
            key_valid = 0;
            str_len_next = str_len;
            key_next = key;
            reset_arc = 0;
            end
           `ARC4BEGIN2: begin
            rdy = 0;
            arc_en = 1;
            key_valid = 0;
            str_len_next = str_len;
            key_next = key;
            reset_arc = 1;
            end
            `NEXTKEY: begin
            rdy = 0;
            arc_en = 0;
            key_valid = 0;
            str_len_next = str_len;
            key_next = key + 2; //increment by 2 because of doublecrack
            reset_arc = 0; //reset after next key
            end
           `AITETHISTHEONE: begin
            rdy = 1;
            arc_en = 1;
            key_valid = 1;
            str_len_next = str_len;
            key_next = key;
            reset_arc = 1;
            end
           `DONENOKEY: begin
            rdy = 1;
            arc_en = 1;
            key_valid = 0;
            str_len_next = str_len;
            key_next = key;
            reset_arc = 1;
            end
            default: begin
            rdy = 0;
            arc_en = 0;
            key_valid = 0;
            str_len_next = 0; 
            key_next = 0;
            reset_arc = 1;
         
            end
    endcase
    
end

endmodule: crack
