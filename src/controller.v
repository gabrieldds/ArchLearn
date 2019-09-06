/*******************************************************************
*Module name:  controller
*Date Created: 03/08/2019
*Last Modified: 03/08/2019
*Description: This is memory and operation controller of convolution.
********************************************************************/
module controller(
    /*input clk signal*/
    clk,            /*clock signal*/
    /*input reset signal*/ 
    reset,         /*reset signal*/
    /*input data*/ 
    data_in,      /*byte input*/
    /*input signal to disable conv*/
    convin,
    /*output signals*/
    en_ctrl,  
    /*enable register ctrl*/
    w_finished,
    r_finished,
    address_written /*number of bytes will be written*/
);
    /*declare parameters*/
    localparam MSB_BYTE = 7;
    localparam MSB_HALF_WORD = 15;
    localparam COUNTERWIDTH = 2;
    localparam COUNTERRESETVALUE = 2;
    localparam FSM_TAM = 4;
    localparam MEM_OFFSET = 64;
    /*FSM parameters*/
    localparam RECEIVING  = 4'b0000;
    localparam SEL_MEM    = 4'b0001;
    localparam SEL_TAM    = 4'b0010;
    localparam SEL_TAMR   = 4'b0101;
    localparam WRITE      = 4'b0011;
    localparam READ       = 4'b0100;
    localparam CONVOLVE1  = 4'b0110;
    localparam CONVOLVE2  = 4'b0111;
    localparam CONVOLVE3  = 4'b1000;  
    /*declare input, output paremeters*/
    input clk;
    input reset;
    input  [MSB_BYTE:0] data_in;
    /*
     * en_ctrl[0]  -> en_mem_conv1;
     * en_ctrl[1]  -> en_mem_bias1;
     * en_ctrl[2]  -> en_mem_conv2;
     * en_ctrl[3]  -> en_mem_bias2;
     * en_ctrl[4]  -> en_mem_conv3;
     * en_ctrl[5]  -> en_mem_bias3;
     * en_ctrl[6]  -> en_mem_in;
     * en_ctrl[7]  -> en_mem_res;
     * en_ctrl[8]  -> en_convolve1;
     * en_ctrl[9]  -> en_convolve2;
     * en_ctrl[10] -> en_convolve3;
     */
    output reg w_finished;
    output reg r_finished;
    output reg [10:0] en_ctrl;
    output reg [15:0] address_written;
    output reg [2:0]  convin;
    /***********************internal registers***********************/
    // reg definition of states of fsm
    reg [FSM_TAM-1:0] state;
    reg [FSM_TAM-1:0] next_state;
    //reg definition for number of bytes will be written
    reg wen;
    reg ren;
    reg [4:0] smem;
    reg [15:0] n_bytes;
    reg valid_byte;
    wire count_address_enable;
    //always sequencial block for fsm
    always @(posedge clk) begin
        if (reset) begin
            state <= RECEIVING;
            wen <= 0;
            ren <= 0;
            w_finished <= 0;
            r_finished <= 0;
            en_ctrl <= 0;
        end else begin
            state <= next_state;
        end
    end
    //always combinational block for next_state fsm
    always @(state or data_in or valid_byte or wen or ren or w_finished or r_finished or convin) begin
        next_state = 0;
        case (state)
            RECEIVING: if(data_in == 8'h19) begin
                next_state = SEL_MEM;
            end else if(data_in == 8'h18) begin
                next_state = SEL_TAM;
            end else if(data_in == 8'h21) begin
                next_state = CONVOLVE1;
            end else if(data_in == 8'h22) begin
                next_state = CONVOLVE2;
            end else if(data_in == 8'h23) begin
                next_state = CONVOLVE3;
            end
            else begin
                next_state = RECEIVING;
            end
            SEL_MEM: if(valid_byte == 1'b1)  begin
                next_state = SEL_TAM;
            end else begin
                next_state = SEL_MEM;
            end
            SEL_TAM: if(wen == 1'b1) begin
                next_state = WRITE;
            end else begin
                next_state = SEL_TAM;
            end
            WRITE: if(w_finished == 1'b1) begin
                next_state = RECEIVING;
            end else begin
                next_state = WRITE;
            end
            CONVOLVE1: if(convin[0]) begin
                next_state = RECEIVING;
            end else begin
                next_state = CONVOLVE1;
            end
            CONVOLVE2: if(convin[1]) begin
                next_state = RECEIVING;
            end else begin
                next_state = CONVOLVE2;
            end 
            CONVOLVE3: if(convin[2]) begin
                next_state = RECEIVING;
            end else begin
                next_state = CONVOLVE2;
            end
            default: next_state = RECEIVING;
        endcase
    end

    always @(posedge clk) begin
        case(state)
            RECEIVING: begin
                en_ctrl <= 0;
                address_written <= 0;
                wen <= 0;
                ren <= 0;
                valid_byte <= 0;
                w_finished <= 0;
                r_finished <= 0;
            end
            SEL_MEM: if (data_in >= 0 && data_in < 8) begin
                valid_byte <= 1'b1;
                smem <= data_in[4:0];
            end else begin
                valid_byte <= 1'b0;
            end
            SEL_TAM: begin 
                n_bytes <= data_in * 16'd64;
                if ((n_bytes % 64) == 0) begin
                    wen <= 1'b1;
                end else begin
                    wen <= 1'b0;
                end
            end
            WRITE: if(smem == 5'h00) begin
                en_ctrl[0] <= 1'b1;
            end else if(smem == 5'h1) begin
                en_ctrl[1] <= 1'b1;
            end else if(smem == 5'h2) begin
                en_ctrl[2] <= 1'b1;
            end else if(smem == 5'h3) begin
                en_ctrl[3] <= 1'b1;
            end else if(smem == 5'h4) begin
                en_ctrl[4] <= 1'b1;
            end else if(smem == 5'h5) begin
                en_ctrl[5] <= 1'b1;
            end else if(smem == 5'h6) begin
                en_ctrl[6] <= 1'b1;
            end
            CONVOLVE1: en_ctrl[8]  <= 1'b1;
            CONVOLVE2: en_ctrl[9]  <= 1'b1;
            CONVOLVE3: en_ctrl[10] <= 1'b1;
        endcase
    end

    assign count_address_enable = en_mem_conv1 || en_mem_conv2 || en_mem_conv3 || en_mem_bias1 || en_mem_bias2 || en_mem_bias3
                                  || en_mem_in || en_mem_res;

    always @(posedge clk) begin
        if(count_address_enable) begin
            if(reset) begin
                address_written <= {16{1'b0}};
            end else if(address_written == n_bytes) begin
                address_written <= {16{1'b0}};
                w_finished <= 1;
                r_finished <= 1;
            end else begin
                address_written <= address_written + 16'b1;
            end
        end
    end
endmodule