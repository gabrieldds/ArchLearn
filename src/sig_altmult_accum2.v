module sig_altmult_accum2
(
	input [7:0] dataa,
	input [7:0] datab,
	input clk, aclr, clken, sload,
	output signed [17:0] adder_out
);

	// Declare registers and wires
	reg signed [7:0] datab_reg;
	reg signed [8:0] dataa_reg;
	reg	signed [16:0] old_result;
	reg signed [17:0] accum_out;
	wire signed [17:0] multa;
	reg sload_reg;
	
	// Store the results of the operations on the current data
	assign multa = dataa_reg * datab_reg;
	//assign multa = $signed({1'b0, dataa}) * $signed(datab);
	
	// Store the value of the accumulation (or clear it)
	always @ (accum_out, sload_reg)
	begin
		if (sload_reg)
			old_result <= 0;
		else
			old_result <= accum_out;
	end

	assign adder_out = accum_out;
	
	// Clear or update data, as appropriate
	always @ (posedge clk or posedge aclr)
	begin
		if (aclr)
		begin
			dataa_reg <= 0;
			datab_reg <= 0;
			sload_reg <= 0;
			accum_out <= 0;
		end
		
		else if (clken)
		begin
			dataa_reg <= $signed({1'b0, dataa});
			datab_reg <= $signed(datab);
			sload_reg <= sload;
			accum_out <= old_result + multa;
		end

	end
endmodule
