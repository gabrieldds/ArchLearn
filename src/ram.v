module ram (
    input clk,
    input [15:0] address,
    input [7:0] data_in, 
    input write_enable,
    input read_enable,
    output reg [7:0] data_out
);
    parameter MEM_LENGTH = 255;
    parameter MEM_INIT_FILE = "";

    reg [7:0] memory [0:MEM_LENGTH];

    initial begin
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, memory);
        end
    end

    always @(posedge clk) begin
        if (write_enable) begin
            memory[address] <= data_in;
        end

        if(read_enable) begin
            data_out <= memory[address];
        end
    end

endmodule