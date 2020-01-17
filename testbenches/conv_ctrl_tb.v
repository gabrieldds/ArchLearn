module conv_ctrl_tb;

reg clk, reset, en_ctrl, enclk;
wire en_sum, finish, save;
wire [15:0] s_addr, w_addr, b_addr, save_addr;

localparam CLK_PERIOD = 20;
always #(CLK_PERIOD/2) clk=~clk;

task run_clock;
begin
    #10 enclk = ~enclk;
    #10 enclk = ~enclk;
end
endtask

initial begin
    clk<=1'b0; reset <= 1;
    run_clock; reset <= 0; 
    run_clock; en_ctrl <= 1;
end

always @(posedge clk) begin
    if(finish) begin
        en_ctrl <= 0;
        $stop;
    end
end

conv_ctrl groundctrl (clk, reset, en_ctrl, s_addr, w_addr, b_addr, save_addr, en_sum, save, finish);

endmodule