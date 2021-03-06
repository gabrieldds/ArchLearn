module convolve(
    clk,
    reset,
    clken,
    s_convout,
    en_sat,
    en_mult_r,
    bias,
    signal,
    weight,
    convout
);

    parameter BIAS_SHIFT = 6;
    parameter OUT_SHIFT  = 9;

    input  clk, reset, clken, s_convout, en_sat, en_mult_r;
    input  [7:0] signal, weight;
    input  [7:0] bias;
    output wire signed [7:0] convout;

    wire signed [17:0] adder_out;
    reg signed  [17:0] conv_temp;

    sig_altmult_accum mac(
        .clk(clk),
        .aclr(reset | s_convout),
        .clken(clken),
        .sload(s_convout),
        .dataa(signal),
        .datab(weight),
        .adder_out(adder_out)
    );

    reg signed [17:0] multa_r;

    always @(posedge clk) begin
        if(reset) begin
            multa_r <= 18'b0;
        end else if(en_mult_r) begin
            if (clken && s_convout) begin
                multa_r <= $signed(signal) * $signed(weight);
            end
        end else begin
            multa_r <= 18'b0;
        end
    end

    always @(posedge clk) begin
        if(reset) begin
            conv_temp <= 18'b0;
        end else if(en_sat) begin
            conv_temp <= (adder_out + multa_r + ($signed(bias) <<< BIAS_SHIFT)) >>> OUT_SHIFT;
        end
    end

    assign convout = (en_sat && conv_temp >  18'd127) ?  8'd127  :
                     (en_sat && conv_temp < -18'd128) ? -8'd128  : conv_temp[7:0];

endmodule