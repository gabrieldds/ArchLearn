`define CONV1_MEM_LENGTH  2400
`define CONV2_MEM_LENGTH  12800
`define CONV3_MEM_LENGTH  12800
`define BIAS1_LENGTH      32
`define BIAS2_LENGTH      16
`define BIAS3_LENGTH      32
`define CONV1OUT_LENGTH   32 * 32 * 32
`define CONV2OUT_LENGTH   16 * 16 * 16
`define CONV3OUT_LENGTH    8 *  8 * 32
`define INPUT1_LENGTH     32 * 32 * 3
`define INPUT2_LENGTH     16 * 16 * 32
`define INPUT3_LENGTH      8 *  8 * 16
`define BYTE 8
`define HALF_WORD 16 
`define IMG1_DATA          "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/debug_input1.mem"
`define CONV1_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv1_wt.mem"
`define BIAS1_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv1_bias.mem"
`define IMG2_DATA          "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/debug_input2.mem"
`define CONV2_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv2_wt.mem"
`define BIAS2_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv2_bias.mem"
`define IMG3_DATA          "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/debug_input3.mem"
`define CONV3_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv3_wt.mem"
`define BIAS3_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv3_bias.mem"

module archlearn_tb;

    parameter [`BYTE-1:0] CONV_DIM_IMG2    = 16;
    parameter [`BYTE-1:0] CONV_DIM_OUT2    = 16;   //dimension of output img
    parameter [`BYTE-1:0] CONV_DIM_KERNEL2 = 5;    //dimension of kernel mask
    parameter [`BYTE-1:0] CONV_DIM_CH2     = 32;   //dimension of input channel
    parameter [`BYTE-1:0] CONV_OUT_CH2     = 16;  //dimension of output channel
    parameter [`BYTE-1:0] STRIDE2          = 1;   //stride len
    parameter [`BYTE-1:0] PADDING2         = 2;   // padding len
    parameter [`BYTE-1:0] KSIZE2           = 3;

    parameter [`BYTE-1:0] CONV_DIM_IMG3    = 8;
    parameter [`BYTE-1:0] CONV_DIM_OUT3    = 8;   //dimension of output img
    parameter [`BYTE-1:0] CONV_DIM_KERNEL3 = 5;    //dimension of kernel mask
    parameter [`BYTE-1:0] CONV_DIM_CH3     = 16;   //dimension of input channel
    parameter [`BYTE-1:0] CONV_OUT_CH3     = 32;  //dimension of output channel
    parameter [`BYTE-1:0] STRIDE3          = 1;   //stride len
    parameter [`BYTE-1:0] PADDING3         = 2;   // padding len
    parameter [`BYTE-1:0] KSIZE3           = 2;

    reg clk, clock, reset, en_ctrl, en_ctrl2, en_ctrl3;
    wire [15:0] s_addr, s_addr2, s_addr3;
    wire [15:0] w_addr, w_addr2, w_addr3;
    wire [15:0] b_addr, b_addr2, b_addr3;
    wire [15:0] save_addr, save_addr2, save_addr3;
    wire [7:0]  bias, bias2, bias3, signal, signal2, signal3, weight, weight2, weight3;
    wire signed [7:0] convout, convout2, convout3;
    wire s_convout, s_convout2, s_convout3, en_save, en_save2, en_save3, finish, finish2, finish3, sload, sload2, sload3;  
    wire en_sum, en_sum2, en_sum3, en_write, en_write2, en_write3;
    wire en_mac, en_mac2, en_mac3, en_sat, en_sat2, en_sat3, en_mult_r, en_mult_r2, en_mult_r3;
    reg clken, clken2, clken3;

    localparam CLK_PERIOD = 20;
    always #(CLK_PERIOD/2) clk=~clk;

    task run_clock;
    begin
        #(CLK_PERIOD/2) clock = ~clock;
        #(CLK_PERIOD/2) clock = ~clock; 
    end
    endtask

    initial begin
        #1 clk <= 0; clock <= 0; reset <= 0; en_ctrl <= 0;
        run_clock;
        run_clock;
        reset <= 1;
        run_clock;
        reset <= 0;
        run_clock;
        en_ctrl <= 1; en_ctrl2 <= 1; en_ctrl3 <= 1;
        run_clock;
    end

    reg fin_reg, fin_reg2, fin_reg3;

    always @(posedge clk) begin
        if(reset) begin
            fin_reg  <= 0;
            fin_reg2 <= 0;
            fin_reg3 <= 0;
        end else begin
            fin_reg  <= finish;
            fin_reg2 <= finish2;
            fin_reg3 <= finish3;
        end

        if (fin_reg) begin
            en_ctrl <= 0;
            $stop;
        end

        if (fin_reg2) begin
            en_ctrl2 <= 0;
        end

        if (fin_reg3) begin
            en_ctrl3 <= 0;
        end
    end

    conv_ctrl groundctrl (clk, reset, en_ctrl, s_addr, w_addr, b_addr, save_addr, en_sum, en_save, en_write, s_convout, en_sat, en_mac, en_mult_r, finish);
    convolve conv(clk, reset, en_mac, en_write, en_sat, en_mult_r, bias, signal, weight, convout);

    conv_ctrl #(
        .CONV_DIM_IMG(CONV_DIM_IMG2),
        .CONV_DIM_OUT(CONV_DIM_OUT2),
        .CONV_DIM_KERNEL(CONV_DIM_KERNEL2),
        .CONV_DIM_CH(CONV_DIM_CH2),
        .CONV_OUT_CH(CONV_OUT_CH2),
        .STRIDE(STRIDE2),
        .PADDING(PADDING2),
        .KSIZE(KSIZE2)
    ) groundctrl2 (
        .clk(clk),
        .reset(reset),
        .en_ctrl(en_ctrl2),
        .s_addr(s_addr2),
        .w_addr(w_addr2),
        .b_addr(b_addr2),
        .save_addr(save_addr2),
        .en_sum(en_sum2),
        .en_save(en_save2),
        .en_write(en_write2),
        .s_convout(s_convout2),
        .en_sat(en_sat2),
        .en_mac(en_mac2),
        .en_mult_r(en_mult_r2),
        .finish(finish2)
    );

    convolve #(
        .BIAS_SHIFT(4),
        .OUT_SHIFT(9)
    ) conv2 (
        .clk(clk),
        .reset(reset),
        .clken(en_mac2),
        .s_convout(en_write2),
        .en_sat(en_sat2),
        .en_mult_r(en_mult_r2),
        .bias(bias2),
        .signal(signal2),
        .weight(weight2),
        .convout(convout2)
    );

    conv_ctrl #(
        .CONV_DIM_IMG(CONV_DIM_IMG3),
        .CONV_DIM_OUT(CONV_DIM_OUT3),
        .CONV_DIM_KERNEL(CONV_DIM_KERNEL3),
        .CONV_DIM_CH(CONV_DIM_CH3),
        .CONV_OUT_CH(CONV_OUT_CH3),
        .STRIDE(STRIDE3),
        .PADDING(PADDING3),
        .KSIZE(KSIZE3)
    ) groundctrl3 (
        .clk(clk),
        .reset(reset),
        .en_ctrl(en_ctrl3),
        .s_addr(s_addr3),
        .w_addr(w_addr3),
        .b_addr(b_addr3),
        .save_addr(save_addr3),
        .en_sum(en_sum3),
        .en_save(en_save3),
        .en_write(en_write3),
        .s_convout(s_convout3),
        .en_sat(en_sat3),
        .en_mac(en_mac3),
        .en_mult_r(en_mult_r3),
        .finish(finish3)
    );

    convolve #(
        .BIAS_SHIFT(1),
        .OUT_SHIFT(7)
    ) conv3 (
        .clk(clk),
        .reset(reset),
        .clken(en_mac3),
        .s_convout(en_write3),
        .en_sat(en_sat3),
        .en_mult_r(en_mult_r3),
        .bias(bias3),
        .signal(signal3),
        .weight(weight3),
        .convout(convout3)
    );

    ram #(
        .MEM_LENGTH(`INPUT1_LENGTH),
        .MEM_INIT_FILE(`IMG1_DATA)
    ) input_mem (
        .clk(clk),
        .read_address(s_addr),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(signal)
    );

    ram #(
        .MEM_LENGTH(`INPUT2_LENGTH),
        .MEM_INIT_FILE(`IMG2_DATA)
    ) input_mem2 (
        .clk(clk),
        .read_address(s_addr2),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(signal2)
    );

    ram #(
        .MEM_LENGTH(`INPUT3_LENGTH),
        .MEM_INIT_FILE(`IMG3_DATA)
    ) input_mem3 (
        .clk(clk),
        .read_address(s_addr3),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(signal3)
    );

    ram #(
        .MEM_LENGTH(`CONV1_MEM_LENGTH),
        .MEM_INIT_FILE(`CONV1_DATA)
    ) conv1_in_mem (
        .clk(clk),
        .read_address(w_addr),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(weight)
    );

    ram #(
        .MEM_LENGTH(`CONV2_MEM_LENGTH),
        .MEM_INIT_FILE(`CONV2_DATA)
    ) conv1_in_mem2 (
        .clk(clk),
        .read_address(w_addr2),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(weight2)
    );

    ram #(
        .MEM_LENGTH(`CONV3_MEM_LENGTH),
        .MEM_INIT_FILE(`CONV3_DATA)
    ) conv1_in_mem3 (
        .clk(clk),
        .read_address(w_addr3),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(weight3)
    );

    ram #(
        .MEM_LENGTH(`BIAS1_LENGTH),
        .MEM_INIT_FILE(`BIAS1_DATA)
    ) bias_in_mem (
        .clk(clk),
        .read_address(b_addr),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(bias)
    );

    ram #(
        .MEM_LENGTH(`BIAS2_LENGTH),
        .MEM_INIT_FILE(`BIAS2_DATA)
    ) bias_in_mem2 (
        .clk(clk),
        .read_address(b_addr2),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(bias2)
    );

    ram #(
        .MEM_LENGTH(`BIAS3_LENGTH),
        .MEM_INIT_FILE(`BIAS3_DATA)
    ) bias_in_mem3 (
        .clk(clk),
        .read_address(b_addr3),
        .write_address(),
        .data_in(8'bx),
        .write_enable(1'b0),
        .data_out(bias3)
    );

    ram #(
        .MEM_LENGTH(`CONV1OUT_LENGTH)
    ) conv1_out_mem (
        .clk(clk),
        .read_address(),
        .write_address(save_addr),
        .data_in(convout),
        .write_enable(en_write),
        .data_out()
    );

    ram #(
        .MEM_LENGTH(`CONV2OUT_LENGTH)
    ) conv1_out_mem2 (
        .clk(clk),
        .read_address(),
        .write_address(save_addr2),
        .data_in(convout2),
        .write_enable(en_write2),
        .data_out()
    );

    ram #(
        .MEM_LENGTH(`CONV3OUT_LENGTH)
    ) conv1_out_mem3 (
        .clk(clk),
        .read_address(),
        .write_address(save_addr3),
        .data_in(convout3),
        .write_enable(en_write3),
        .data_out()
    );

endmodule