module InOutControl_tb;
    timeunit 1ns;
    timeprecision 100ps;
    realtime delay=2.5ns;
    //INPUTS
    bit clk;
    reg [1:0] button;
    reg [3:0] sw;
    reg memCmdDoneIn;
    reg [31:0] memDataIn;
    //OUTPUTS
    reg [1:0] memCmd;
    reg [31:0] ioDataOut;
    reg [63:0] memAddrOut;
    reg ioCmdDoneOut;     
    reg [31:0] dispData;

    initial begin
        memCmdDoneIn<=1'b1;
        button <= 2'b10;
        sw <= 4'b0000;
    end
    always @(memAddrOut) begin
            memCmdDoneIn <= 1'b0 ;
            #10 memCmdDoneIn <= 1'b1 ;
    end

    always begin
        #delay clk=~clk;
        button <=2'b00;
    end

        // input clk,              //clk input
        // input [1:0] button,     //post-debounced button input sent from debouncing module
        // input [3:0] sw,         //pose-debounced switch input sent from the debouncing module
        // input memCmdDoneIn,     //flag sent to InputOutputControl from the MemoryControl to signal if the MemoryControl is done executing it's command
        // input  [31:0] memDataIn,//data sent from the MemoryControl to InputOutputControl as a result of a read opertaion
        // output [1:0] memCmd,    //flag sent to the MemoryControl from InputOutputControl to identify which command is being operated
        // output [31:0] ioDataOut,//Data sent to the MemoryControl from InputOutputControl during a write command 
        // output [63:0] memAddrOut,//Address sent to the MemoryControl from InputOutputControl 
        // output ioCmdDoneOut,     //Flag sent form InputOutputControl to the MemoryControl to singal wheter it is done with getting input or not
        // output [31:0] dispData

    InOutControl uut(
        .clk(clk),
        .button(button),
        .sw(sw),
        .memCmdDoneIn(memCmdDoneIn),
        .memDataIn(memDataIn),
        .memCmd(memCmd),
        .ioDataOut(ioDataOut),
        .memAddrOut(memAddrOut),
        .ioCmdDoneOut(ioCmdDoneOut),
        .dispData(dispData)
    );

endmodule