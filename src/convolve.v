module convolve(
    clk,
    reset,
    clken,
    sload,
    save,
    bias,
    signal,
    weight,
    s_convout,
    convout,
);

    input  clk, reset, clken, sload, save;
    input  [7:0] signal, weight;
    input  [7:0] bias;
    output reg signed [7:0] convout;
    output reg s_convout;

    wire signed [17:0] adder_out;
    reg signed  [17:0] r_bias;
    reg signed  [17:0] conv_temp;
    reg save_r;

    sig_altmult_accum mac(
        .clk(clk),
        .aclr(reset),
        .clken(clken),
        .sload(sload),
        .dataa(signal),
        .datab(weight),
        .adder_out(adder_out)
    );

    always @(posedge clk) begin
        if(reset) begin
            save_r    <= 0;
            r_bias    <= 0;
            conv_temp <= 0;
        end else begin
            save_r <= save;
            r_bias <= $signed(bias) <<< 6;
            conv_temp <= (adder_out + r_bias) >>> 9;
        end
    end

    always @(posedge clk) begin
        if(save_r) begin
            if (conv_temp > 18'd127) begin
                convout <= 8'd127;
            end else if(conv_temp < -18'd128) begin
                convout <= -8'd128;
            end else begin
                convout <= conv_temp[7:0];
            end
        end
    end


endmodule