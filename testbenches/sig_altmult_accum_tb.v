module sig_altmult_accum_tb;

reg clk;
reg rst_n;

reg [7:0] dataa, datab;
reg clken, clock, sload;

localparam CLK_PERIOD = 20;
always #(CLK_PERIOD/2) clk=~clk;

wire signed [16:0] adder_out;
task run_clock;
    begin
        #(CLK_PERIOD/2) clock = ~clock;
        #(CLK_PERIOD/2) clock = ~clock; 
    end
endtask

initial begin
    #1 rst_n<=1'bx;clk<=1'bx;
    #(CLK_PERIOD*3) rst_n<=1;
    #(CLK_PERIOD*3) rst_n<=0; clk<=0; clock <= 0; dataa <= 0; datab <= 0;
    run_clock; clken <= 1; sload <= 0;
    run_clock; dataa <= 255; datab <= 128;
    run_clock; dataa <= 55;  datab <= 127;
    run_clock; dataa <= 135; datab <= 128;
    run_clock;
end

sig_altmult_accum mac(dataa, datab, clk, rst_n, clken, sload, adder_out);

endmodule