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
    valid,
    data_in,      /*byte input*/
    data_out,
    /*input signal to disable conv*/
    convin,
    /*output signals*/
    en_ctrl,  
    /*enable register ctrl*/
    w_finished,
    address_written /*number of bytes will be written*/
);
    /*declare parameters*/
    localparam MSB_BYTE = 8;
    localparam MSB_HALF_WORD = 16;
    localparam FSM_TAM = 4;
    /*FSM parameters*/
    localparam IDLE       = 4'b0000;
    localparam OP         = 4'b0001;
    localparam NOP1       = 4'b0010;
    localparam SEL_MEM    = 4'b1110;
    localparam NOP2       = 4'b0100;
    localparam LSBBYTE    = 4'b0011;
    localparam NOP3       = 4'b0110;
    localparam MSBBYTE    = 4'b0101;
    localparam NOP6       = 4'b1101;
    localparam WRITE      = 4'b0111;
    localparam NOP7       = 4'b1111;
    localparam CONVOLVE1  = 4'b1000;
    localparam NOP4       = 4'b1001;
    localparam CONVOLVE2  = 4'b1010;
    localparam NOP5       = 4'b1011;
    localparam CONVOLVE3  = 4'b1100;
    /*declare input, output paremeters*/
    input clk;
    input reset;
    input [MSB_BYTE-1:0] data_in;
    input [2:0]  convin;
    input w_finished;
    input valid;
    /*
     * en_ctrl[0]  -> en_mem_conv1;
     * en_ctrl[1]  -> en_mem_bias1;
     * en_ctrl[2]  -> en_mem_conv2;
     * en_ctrl[3]  -> en_mem_bias2;
     * en_ctrl[4]  -> en_mem_conv3;
     * en_ctrl[5]  -> en_mem_bias3;
     * en_ctrl[6]  -> en_mem_in;
     * en_ctrl[7]  -> en_convolve1;
     * en_ctrl[8]  -> en_convolve2;
     * en_ctrl[9]  -> en_convolve3;
     */
    output reg [9:0] en_ctrl;
    output reg [7:0] data_out;
    output reg [15:0] address_written;
    /***********************internal registers***********************/
    // reg definition of states of fsm
    reg [FSM_TAM-1:0] state;
    //reg definition for number of bytes will be written
    reg [4:0] smem;
    reg [2:0] cnt_bytes;
    reg save;
    //always sequencial block for fsm
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            cnt_bytes <= 3'b0; 
            en_ctrl   <= 8'b0;
            data_out  <= 8'b0;
            address_written <= 16'b0;
        end else begin
            case (state)
                IDLE: begin 
                    if(valid) begin
                        state <= OP;
                        cnt_bytes <= 0;
                        smem <= 0;
                        en_ctrl <= 0;
                        data_out <= 0;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                OP: begin 
                    if(data_in == 8'h19) begin
                        state <= SEL_MEM;
                    end else if(data_in == 8'h21) begin
                        state <= NOP7;
                    end else if(data_in == 8'h22) begin
                        state <= NOP4;
                    end else if(data_in == 8'h23) begin
                        state <= NOP5;
                    end else begin
                        state <= OP;
                    end
                end 
                NOP1: begin
                    //if(valid) begin
                        state <= WRITE;
                    //end
                    //else begin
                    //    state <= NOP1;
                    //end
                end
                SEL_MEM: begin 
                    if(data_in >= 0 && data_in < 8) begin
                        state <= NOP2;
                        smem  <= data_in[4:0];
                        cnt_bytes <= cnt_bytes + 1;
                    end else begin
                        state <= SEL_MEM;
                    end
                end
                NOP2: begin
                    if(valid != 0) begin
                        state <= LSBBYTE;
                    end else begin
                        state <= NOP2;
                    end
                end
                LSBBYTE: begin 
                    cnt_bytes <= cnt_bytes + 1;
                    address_written[7:0] <= data_in;
                    state <= MSBBYTE; 
                end
                NOP3: begin
                    if(valid) begin
                        state <= MSBBYTE;
                    end else begin
                        state <= NOP3;
                    end
                end
                MSBBYTE: begin
                    cnt_bytes <= cnt_bytes + 1;
                    address_written[15:8] <= data_in;
                    state <= NOP6; 
                end
                NOP6: begin
                    if(valid) begin
                        state <= NOP1;
                    end else begin
                        state <= NOP6;
                    end
                end
                WRITE: begin
                    //if(w_finished) begin
                        state <= OP;
                    //end else begin
                    //    state <= WRITE;
                        if (smem == 5'd0) begin
                            en_ctrl[0] <= 1'b1;
                            data_out <= data_in;
                        end else if(smem == 5'd1) begin
                            en_ctrl[1] <= 1'b1;
                            data_out <= data_in;
                        end else if(smem == 5'd2) begin
                            en_ctrl[2] <= 1'b1;
                            data_out <= data_in;
                        end else if(smem == 5'd3) begin
                            en_ctrl[3] <= 1'b1;
                            data_out <= data_in;
                        end else if(smem == 5'd4) begin
                            en_ctrl[4] <= 1'b1;
                            data_out <= data_in;
                        end else if(smem == 5'd5) begin
                            en_ctrl[5] <= 1'b1;
                            data_out <= data_in;
                        end else if(smem == 5'd6) begin
                            en_ctrl[6] <= 1'b1;
                            //data_out <= data_in;
                            save <= 1;
                        end
                    //end
                end
                NOP7: begin
                    if(valid) begin
                        state <= CONVOLVE1;
                    end else begin
                        state <= NOP7;
                    end
                end
                CONVOLVE1: if(convin[0]) begin
                    state <= IDLE;
                    en_ctrl[7] <= 1'b1; 
                end else begin
                    state <= CONVOLVE1;
                end
                NOP4: begin
                    if(valid) begin
                        state <= CONVOLVE2;
                    end else begin
                        state <= NOP4;
                    end
                end
                CONVOLVE2: if(convin[1]) begin
                    state <= IDLE;
                    en_ctrl[8] <= 1'b1;
                end else begin
                    state <= CONVOLVE2;
                end
                NOP5: begin
                    if(valid) begin
                        state <= CONVOLVE3;
                    end else begin
                        state <= NOP5;
                    end
                end
                CONVOLVE3: if(convin[2]) begin
                    state = IDLE;
                    en_ctrl[9] <= 1'b1;
                end else begin
                    state = CONVOLVE2;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule