module ram_ren_tb;

    reg clk, enclk, wen, ren;
    reg [15:0] address;
    reg [7:0] datain;
    wire [7:0] q;

    task run_clock;
    begin
        #10 enclk = ~enclk;
        #10 enclk = ~enclk;
    end
    endtask

    always begin
        #10 clk = ~clk;
    end

    initial begin
        clk = 0; wen = 0; ren = 0; address = 0; enclk = 0;
        run_clock;
        address = 0; datain = 2; wen = 1;
        run_clock;
        wen = 0;
        run_clock;
        address = 1;
        datain  = 255;
        wen     = 1;
        run_clock;
        wen     = 0;
        run_clock; 
        address = 1;
        ren     = 1;
        run_clock;
        ren     = 0;
        run_clock;
        address = 0;
        ren = 1;
        run_clock;
        ren = 0;
    end



    ram ram1(clk, address, datain, wen, ren, q);

endmodule