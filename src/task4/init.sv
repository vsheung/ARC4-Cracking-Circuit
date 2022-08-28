module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

reg flag;
initial rdy = 1'b0;
initial addr = 8'b00000000;
initial flag = 0;
//assign rdy = en;

always @(negedge clk)begin
if (rdy == 1'b0 && en ==1'b1 && rst_n == 1 && addr !=255) begin
    addr <= addr + 1;
    wren = 1'b1;
    flag = 0;
end else begin
    if (rst_n == 0) begin
    addr <= 0;
    wren = 1'b1;
    flag = 0;
end else begin

    if (flag == 1) begin
        wren = 1'b0;
end else begin

    if (addr == 255) begin
        addr = 255;
        flag = 1;
        wren = 1'b1;
end
end
end
end
end

always @(posedge clk or negedge rst_n) begin
    if (addr == 256) begin
        rdy <= 1'b1;
            if (en == 1) begin
            wrdata <= 255;
            end
        end else begin
    if (rst_n == 0) begin
        rdy <= 1'b0;
        //reg_en <= 1'b0;
        wrdata <= 0;
    end else begin
    if (rdy == 1'b1) begin
        rdy <= 1'b0;
        //reg_en <= 1'b0;
        wrdata <= 0;
    end else begin
    if (addr < 256) begin
        rdy <= 1'b1;
        if (en == 1) begin
            wrdata <= addr;
            end
end
end
end
end
end
// your code here


endmodule: init

//initialize cipher state
//for i = 0;
//s[i] = i;