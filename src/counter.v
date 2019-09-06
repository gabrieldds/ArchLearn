/*******************************************************************
*Module name:  mem_controller
*Date Created: 03/08/2019
*Last Modified: 03/08/2019
*Description: This is memory controller of all rams.
********************************************************************/
module counter(
    /*input clk signal*/
    clk,
    /*input reset signal*/
    reset,
    /*input enable counter*/
    enable,
    /*output count number*/
    counter
);

/*********************parameters declaratiom***************************/
parameter COUNTER_WIDTH = 3;
parameter COUNTER_RESET_VALUE = 7;
/********************input and output ports declaration****************/
input clk;
input reset;
input enable;
output reg [COUNTER_WIDTH-1:0] counter;

always @(posedge clk) begin
    if(reset) begin
        counter <= {COUNTER_WIDTH{1'b0}};
    end else if(counter == COUNTER_RESET_VALUE && enable) begin
        counter <= {COUNTER_WIDTH{1'b0}};
    end else if(enable) begin
        counter <= counter + 1;
    end
end

endmodule
