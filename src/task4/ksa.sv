module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);


initial rdy = 1'b0;
reg [4:0] seq_flag;
reg addr_plus_flag;
reg write_or_nah;
reg [7:0] j, j_new, temp_addr, si, sj, count;
reg stop;
initial begin

    write_or_nah = 0;
    j = 8'b00000000;
    seq_flag = 5'b00000;
    temp_addr = 8'b00000000;
    si = 8'b00000000;
    sj = 8'b00000000;
    addr = 8'b00000000;
    addr_plus_flag = 1'b0;
    wrdata = 8'b00000000;
    stop = 0;
    count =0;
end


always @(posedge clk or negedge rst_n) begin 
    if (rst_n == 0) begin
        stop = 0;
        count =0;
        write_or_nah <=0;
        j <= 0;
        temp_addr <=0;
        si = 8'b00000000;
        sj = 8'b00000000;
        addr = 8'b00000000;
        rdy <= 1'b0;
        wrdata <= 0;
        seq_flag <= 0;
        addr_plus_flag <= 0;
        addr <= 0;
    end else begin
    if (rdy == 1'b1) begin
        if (seq_flag == 31) begin
            seq_flag <= 0;
            addr_plus_flag <= 1;
            if (count == 255) begin
            rdy <= 1'b0;
            stop <= 1;
            write_or_nah = 0;
            end else begin
            addr <= addr + 1;
            count <= count + 1;
            rdy <= 1'b0;
            write_or_nah = 0;
            end
        end
        if (seq_flag < 31) begin
            if (seq_flag%5 ==4||seq_flag%5 ==3||seq_flag%5 ==2||seq_flag%5 ==1)
            rdy <= 1'b0;
            else
            rdy <= 1'b1;
            addr_plus_flag <= 0;
            seq_flag <= seq_flag + 1;
            //write_or_nah = 0;
        end 
    end else begin
        if (addr <= 255 && en == 1 && stop == 0) begin
           //put in addr to read s[i]
           if (seq_flag == 0) begin
           rdy <=1;
           if (en == 1) begin
           //si <= rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah = 0;
           end
           end 
           //read s[i]
           else if (seq_flag == 5) begin
           rdy <=1;
           if (en == 1) begin
           si <= rddata;
           seq_flag <= seq_flag + 1;
           write_or_nah = 0;
           end
           end
           //compute j
           else if (seq_flag == 10) begin
           rdy <=1;
           if (en == 1) begin
           if (addr%3 == 0)
                j <= (j + si + key[23:16])%256;
           else if (addr%3 == 1)
                j <= (j + si + key[15:8])%256;
           else  
                j <= (j + si + key[7:0])%256;
           seq_flag <= seq_flag + 1;
           write_or_nah = 0;
           end
           end
           //put in address to read sj
           else if (seq_flag == 15) begin 
           rdy <=1;
           if (en == 1) begin
           temp_addr <= addr;
           addr <= j;
           seq_flag <= seq_flag + 1;
           write_or_nah = 0;
           end
           end
           //read s[j]
           else if (seq_flag == 20) begin
           rdy <=1;
           if (en == 1) begin
           sj <= rddata; 
           seq_flag <= seq_flag + 1;
           write_or_nah = 0;
           end
           end

           //write s[i] into address j
           else if (seq_flag == 25) begin
           rdy <=1;
           if (en == 1) begin
           wrdata <= si;
           seq_flag <= seq_flag + 1;
           write_or_nah = 1;
           end
           end
           //write s[j] into address i
           else if (seq_flag == 30) begin
           rdy <=1;
           if (en == 1) begin
           addr <= temp_addr;
           wrdata <= sj;
           seq_flag <= seq_flag + 1;
           write_or_nah = 1;
           end
           end

           else if (seq_flag !=30 &&seq_flag !=25&&seq_flag !=20 &&seq_flag !=15 &&seq_flag !=10 &&seq_flag !=5 &&seq_flag !=0) begin
           if (en == 1) begin
           seq_flag <= seq_flag + 1;
           write_or_nah = 0;
           end
           end
end
end
end
end


// your code here

always_comb begin
    if (/*rdy == 1'b1 && */en == 1'b1 && write_or_nah == 1'b1)
        wren = 1'b1;
    else 
        wren = 1'b0;
end

endmodule: ksa

//j = 0
//for i = 0 to 255
//j = (j + s[i] + key[i mod 3] mod 256
//swap values of s[i] and s[j]
