
module debounce #(
  parameter [19:0] DWELL_CNT
)  (
  input  clk,
  input  sig_in,
  output sig_out
);

// declare logic signals here for the 16-bit counter and 1-bit state
longint counter;
logic curr_state;
logic temp;
localparam[19:0] CNT = DWELL_CNT - 1;

initial
begin
  // add initialization values to registers here
  counter = 19'b0;
  curr_state = 0;
end

always @(posedge clk)
begin
	if (sig_in != sig_out) begin
        counter += 1;
    end 
    else begin
        counter <= 19'h0;
    end

    if (counter == CNT) begin
        curr_state <= sig_in;
        //curr_state <= 0;
    end

end

// assign sig_out to the 1-bit reg that's tracking the debounce state
assign sig_out = curr_state;
     
endmodule
     
