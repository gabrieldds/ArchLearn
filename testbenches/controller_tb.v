module controller_tb;

    localparam CONV1OUT_LENGTH  = 32 * 32 * 32;

    reg clk;
    reg reset;

    reg [7:0] data_in;
    reg [2:0] convin;
    wire [9:0] en_ctrl;
    wire [15:0] address_written;
    reg w_finished;
    reg valid;

    reg [7:0] mem_conv1   [0:2431];
	reg [7:0] mem_bias1   [0:31];
	reg [7:0] mem_convout [0:CONV1OUT_LENGTH];
	reg [7:0] mem_input   [0:3072];

    reg [7:0] mem_conv1_fpga   [0:2431];
    reg [7:0] mem_bias1_fpga   [0:31];
    reg [7:0] mem_convout_fpga [0:CONV1OUT_LENGTH-1];
    reg [7:0] mem_input_fpga   [0:3071];

 
    localparam period = 20;
    initial begin
        reset = 1'b1;
        #period;
        reset = 1'b0;
    end

    always begin
        clk = 1'b1;
        #period;
        clk = 1'b0;
        #period;
    end

    reg flag;

    initial begin
		$readmemh("conv_data.mem", mem_conv1);
		$readmemh("img_data.mem",  mem_input);
		$readmemh("bias_data.mem", mem_bias1);

        #100 valid   = 1'b1;
        #22 data_in = 8'h19;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h06;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h00;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h00;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = mem_input[0];
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h19;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h06;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h01;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = 8'h00;
        #20 valid   = 1'b0;
        #20 valid   = 1'b1;
        #22 data_in = mem_input[1];
        #20 valid   = 1'b0;
	end

    //wire [15:0] addr_in;
    //counter#(16, 3072) counter_in(clk, reset, enable_counter, addr_in);

    /*always @(*) begin
        if (enable_counter && addr_in < 3072) begin
           data_in <= mem_input[addr_in]; 
        end
    end */

    wire [7:0] data_out;
    always @(posedge clk) begin
        if(en_ctrl[6]) begin
            mem_input_fpga[address_written] <= data_out;
            w_finished <= 1'b1;
        end
    end

    controller ctrl(clk, reset, valid, data_in, data_out, convin, en_ctrl, w_finished, address_written);

endmodule