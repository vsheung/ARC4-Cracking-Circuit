module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

initial rdy = 1'b0;
reg [6:0] seq_flag;
//reg s_addr_plus_flag, ct_addr_plus_flag, pt_addr_plus_flag;
reg write_or_nah_pt, write_or_nah_s;
reg [7:0] i, j, k, temp_addr, comb_addr, si, sj, scomb_add, ciphertext;

//bytestream
reg [7:0] pad;

assign s_wren = write_or_nah_s? 1:0;
assign pt_wren = write_or_nah_pt? 1:0;

initial begin

    write_or_nah_pt <= 0;
    write_or_nah_s <= 0;
    i <= 8'b00000000;
    j <= 8'b00000000;
    k <= 8'b00000010;
    seq_flag <= 6'b000000;
    temp_addr <= 8'b00000000;
    si <= 8'b00000000;
    sj <= 8'b00000000;
    scomb_add <= 8'b00000000;
    s_addr <= 8'b00000000;
    ct_addr <= 8'b00000001;
    pt_addr <= 8'b00000001;
    comb_addr <= 8'b00000000;
    s_wrdata <= 8'b00000000;
    pt_wrdata <= 8'b00000000;
end


always @(posedge clk or negedge rst_n) begin 
    if (rst_n == 0) begin
        rdy <= 1'b0;
        write_or_nah_pt <= 0;
        write_or_nah_s <= 0;
        i <= 8'b00000000;
        j <= 8'b00000000;
        k <= 8'b00000010;
        seq_flag <= 6'b000000;
        temp_addr <= 8'b00000000;
        si <= 8'b00000000;
        sj <= 8'b00000000;
        scomb_add <= 8'b00000000;
        s_addr <= 8'b00000000;
        ct_addr <= 8'b00000001;
        pt_addr <= 8'b00000001;
        comb_addr <= 8'b00000000;
        s_wrdata <= 8'b00000000;
        pt_wrdata <= 8'b00000000;
    end else begin
    if (rdy == 1'b1) begin


        if (seq_flag == 126) begin
            seq_flag <= 0;
            s_addr <= s_addr + 1;
            ct_addr <= ct_addr + 1;
            pt_addr <= pt_addr + 1;
            rdy <= 1'b0;
            write_or_nah_pt <= 0;
            write_or_nah_s <= 0;
        end
        if (seq_flag < 126) begin
            if (seq_flag%5 ==4||seq_flag%5 ==3||seq_flag%5 ==2||seq_flag%5 ==1)
            rdy <= 1'b0;
            else
            rdy <= 1'b1;
            seq_flag <= seq_flag + 1;
        end 
    end else begin



        if (ct_addr <= k && en == 1) begin

           //put ct_addr as 0 to find msg_length k
           if (seq_flag == 0) begin
           rdy <=1;
           if (en == 1) begin
           temp_addr <= ct_addr;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 

           else if (seq_flag == 5) begin
           rdy <=1;
           if (en == 1) begin
           ct_addr <= 0;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 

           //read k
           else if (seq_flag == 10) begin
           rdy <=1;
           if (en == 1) begin
           k <= ct_rddata;
           //consider later for k ==0
           //if (k == 0)
           //seq_flag <= 100;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 

           //calculate i
           else if (seq_flag == 15) begin
           rdy <=1;
           if (en == 1) begin
           ct_addr <= temp_addr;
           i <= (i + 1)%256;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 
           //put i in address to calculate s[i]
           else if (seq_flag == 20) begin
           rdy <=1;
           if (en == 1) begin
           //temp_addr <= ct_addr;
           s_addr <= i;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 
           //read s[i]
           else if (seq_flag == 25) begin
           rdy <=1;
           if (en == 1) begin
           si <= s_rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end
           //calculate j
           else if (seq_flag == 30) begin
           rdy <=1;
           if (en == 1) begin
           j <= (j + si)%256;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //put j in address to calculate s[j]
           else if (seq_flag == 35) begin
           rdy <=1;
           if (en == 1) begin
           s_addr <= j;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 

           //read s[j]
           else if (seq_flag == 40) begin
           rdy <=1;
           if (en == 1) begin
           sj <= s_rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 
           
            //write s[i] into address j
           else if (seq_flag == 45) begin
           rdy <=1;
           if (en == 1) begin
           s_wrdata <= si;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 1;
           end
           end
           //write s[j] into address i
           else if (seq_flag == 50) begin
           rdy <=1;
           if (en == 1) begin
           s_addr <= i;
           s_wrdata <= sj;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 1;
           end
           end
           //write addr back to k
           else if (seq_flag == 55) begin
           rdy <=1;
           if (en == 1) begin
           ct_addr <= temp_addr;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //put i in address to calculate s[i]
           else if (seq_flag == 60) begin
           rdy <=1;
           if (en == 1) begin
           s_addr <= i;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 

           //read s[i]
           else if (seq_flag == 65) begin
           rdy <=1;
           if (en == 1) begin
           si <= s_rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //put j in address to calculate s[j]
           else if (seq_flag == 70) begin
           rdy <=1;
           if (en == 1) begin
           s_addr <= j;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end 

           //read s[j]
           else if (seq_flag == 75) begin
           rdy <=1;
           if (en == 1) begin
           sj <= s_rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //calculate comb_addr
           else if (seq_flag == 80) begin
           rdy <=1;
           if (en == 1) begin
           comb_addr <= si + sj;
           //ct_addr <= comb_addr;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //put in address to calc s[comb_addr]
           else if (seq_flag == 85) begin
           rdy <=1;
           if (en == 1) begin
           s_addr <= comb_addr;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //read s[comb_addr]
           else if (seq_flag == 90) begin
           rdy <=1;
           if (en == 1) begin
           scomb_add <= s_rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //revert address back to k, assign value of pad[k]
           //also put in addr to read ciphertext[k]
           else if (seq_flag == 95) begin
           rdy <=1;
           if (en == 1) begin
           ct_addr <= temp_addr;
           pad <= scomb_add;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end
        
           //read ciphertext[k]
           else if (seq_flag == 100) begin
           rdy <=1;
           if (en == 1) begin
           ciphertext <= ct_rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           //write plaintext[k] = pad[k] xor ciphertext[k]
           else if (seq_flag == 105) begin
           rdy <=1;
           if (en == 1) begin
           pt_wrdata <= pad ^ ciphertext;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 1;
           write_or_nah_s = 0;
           end
           end

           else if (seq_flag == 110) begin
           rdy <=1;
           if (en == 1) begin
           //ct_addr <= 0;
           temp_addr <= pt_addr;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end
           
           //write k to = pt[0] 
           else if (seq_flag == 115) begin
           rdy <=1;
           if (en == 1) begin
           ct_addr <= 0;
           pt_addr <= 0;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end

           else if (seq_flag == 120) begin
           rdy <=1;
           if (en == 1) begin
           pt_wrdata <= k;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 1;
           write_or_nah_s = 0;
           end
           end

           else if (seq_flag == 125) begin
           rdy <=1;
           if (en == 1) begin
           pt_addr <= temp_addr;
           ct_addr <= temp_addr;
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end



           else if (seq_flag !=125 &&
                    seq_flag !=120 && seq_flag !=115 && seq_flag !=110 && seq_flag !=105 &&
                    seq_flag !=100 && seq_flag !=95 && seq_flag !=90 && seq_flag !=85 && seq_flag !=80 &&
                    seq_flag !=75 && seq_flag !=70 && seq_flag !=65 &&
                    seq_flag !=60 && seq_flag !=55 && seq_flag !=50 &&
                    seq_flag !=45 && seq_flag !=40 && seq_flag !=35 &&
                    seq_flag !=30 && seq_flag !=25 && seq_flag !=20 &&
                    seq_flag !=15 && seq_flag !=10 && seq_flag !=5 &&
                    seq_flag !=0) begin
           if (en == 1) begin
           seq_flag <= seq_flag + 1;
           write_or_nah_pt = 0;
           write_or_nah_s = 0;
           end
           end
end
end
end
end

endmodule: prga
