/**
* File: inOutController.sv

* Description: The module takes a 5 bit input and 
* sends the 8 bit to the hex display
*
* Source: CPE324-Lab Modified by Juan Tarat
* Date: April 8, 2022
* Contributors: Ethan Alexander
**/
module hexDriver(
    input [4:0] inVal,
    output reg [7:0] outVal
);

always@(inVal)
begin
    case (inVal)
        5'd0  : outVal = 8'hC0; // 0
        5'd1  : outVal = 8'hF9; // 1
        5'd2  : outVal = 8'hA4; // 2
        5'd3  : outVal = 8'hB0; // 3
        5'd4  : outVal = 8'h99; // 4
        5'd5  : outVal = 8'h92; // 5
        5'd6  : outVal = 8'h82; // 6 
        5'd7  : outVal = 8'hF8; // 7
        5'd8  : outVal = 8'h80; // 8
        5'd9  : outVal = 8'h90; // 9
        5'd10 : outVal = 8'h88; // A
        5'd11 : outVal = 8'h83; // B
        5'd12 : outVal = 8'hC6; // C
        5'd13 : outVal = 8'hA1; // D
        5'd14 : outVal = 8'h86; // E
        5'd15 : outVal = 8'h8E; // F
        5'd16 : outVal = 8'hAF; // r
        5'd17 : outVal = 8'hA1; // d
        5'd18 : outVal = 8'h87; // t
        5'd19 : outVal = 8'hF7; //_
        5'd20 : outVal = 8'hBF; //-
		5'd21 : outVal = 8'hAB; //n 
        5'd22 : outVal = 8'h7F; //.   
        5'd23 : outVal = 8'hC7; // L  
        5'd24 : outVal = 8'hC1; // U
        default : outVal = 8'hFF; // blank
    endcase
end

endmodule