module pulseDetector(
    input   clk,
    input   key,

    output pulse
);

logic flag;
logic localPulse;

always @(posedge clk)
begin
    if(key == 1'b1 && flag == 1'b0)
    begin
        flag <= 1'b1;
        localPulse <= 1'b1;
    end

    else if(flag == 1'b1 && key == 1'b1) begin
        flag <= 1'b1;
        localPulse <= 1'b0;
    end

    else if(key == 1'b0) begin
        flag <= 1'b0;
        localPulse <= 1'b0;
    end
    else begin
        flag <= 0;
    end
end

assign pulse = localPulse;

endmodule : pulseDetector
