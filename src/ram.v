module ram (
    input clk,
    input [15:0] read_address,
    input [15:0] write_address,
    input [7:0] data_in, 
    input write_enable,
    output reg [7:0] data_out
);
    parameter MEM_LENGTH = 255;
    parameter MEM_INIT_FILE = "";

    reg [7:0] memory [0:MEM_LENGTH-1];

    initial begin
        if (MEM_INIT_FILE != "") begin
            $readmemh(MEM_INIT_FILE, memory);
        end
    end

    always @(posedge clk) begin
        if (write_enable) begin
            memory[write_address] <= data_in;
        end
        data_out <= memory[read_address];
    end

endmodule