`define CONV1_MEM_LENGTH  2400
`define CONV2_MEM_LENGTH  12800
`define CONV3_MEM_LENGTH  12800
`define BIAS1_LENGTH      32
`define BIAS2_LENGTH      16
`define BIAS3_LENGTH      32
`define CONV1OUT_LENGTH   32 * 32 * 32
`define CONV2OUT_LENGTH   16 * 16 * 32
`define CONV3OUT_LENGTH   8  * 8  * 32
`define INPUT_LENGTH      32 * 32 * 3
`define IMG_DATA          "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/img_data.mem"
`define CONV_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/conv_data.mem"
`define BIAS_DATA         "C:/Users/gabri/Documents/Projetos/ArchLearn/testbenches/mem_files/bias_data.mem"

module archlearn_tb;

    reg clk, clock, reset, en_ctrl;
    wire [15:0] s_addr, w_addr, b_addr, save_addr;
    wire [7:0]  bias, signal, weight;
    wire signed [7:0] convout;
    wire s_convout, en_save, finish, sload, en_sum, en_read, en_write, en_mac, en_sat, en_mult_r;
    reg clken;

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
        en_ctrl <= 1;
        run_clock;
    end

    always @(posedge clk) begin
        if (finish) begin
            $stop;
        end
    end
    
    conv_ctrl groundctrl (clk, reset, en_ctrl, s_addr, w_addr, b_addr, save_addr, en_sum, en_save, en_read, en_write, s_convout, en_sat, en_mac, en_mult_r, finish);
    convolve conv(clk, reset, en_mac, en_write, en_sat, en_mult_r, bias, signal, weight, convout);
    
    ram #(
        .MEM_LENGTH(`INPUT_LENGTH),
        .MEM_INIT_FILE(`IMG_DATA)
    ) input_mem (
        .clk(clk),
        .address(s_addr),
        .data_in(8'bx),
        .write_enable(1'b0),
        .read_enable(en_read),
        .data_out(signal)
    );

    ram #(
        .MEM_LENGTH(`CONV1_MEM_LENGTH),
        .MEM_INIT_FILE(`CONV_DATA)
    ) conv1_in_mem (
        .clk(clk),
        .address(w_addr),
        .data_in(8'bx),
        .write_enable(1'b0),
        .read_enable(en_read),
        .data_out(weight)
    );

    ram #(
        .MEM_LENGTH(`BIAS1_LENGTH),
        .MEM_INIT_FILE(`BIAS_DATA)
    ) bias_in_mem (
        .clk(clk),
        .address(b_addr),
        .data_in(8'bx),
        .write_enable(1'b0),
        .read_enable(1'b1),
        .data_out(bias)
    );

    ram #(
        .MEM_LENGTH(`CONV1OUT_LENGTH)
    ) conv1_out_mem (
        .clk(clk),
        .address(save_addr),
        .data_in(convout),
        .write_enable(en_write),
        .read_enable(1'b0),
        .data_out()
    );

endmodule