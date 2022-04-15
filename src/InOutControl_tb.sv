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








//INPUT OUTPUT DESCRIPTIONS ***********************
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
//INPUT OUTPUT DESCRIPTIONS ***********************


   
//Test For clearCmd ********************************
    // initial begin
    //     memCmdDoneIn<=1'b1;        
    //     sw <= 4'b0000;
    //     #5 button <=2'b00; 
    //     #5 button <=2'b10; 
    //     #5 button <=2'b00; 

    // end

    // always begin
    //     #delay clk=~clk;
    // end 

    // always @(memAddrOut) begin
    //         memCmdDoneIn <= 1'b0 ;
    //         #10 memCmdDoneIn <= 1'b1 ;
    // end

//Test For clearCmd ********************************

//Test For writeCmd ********************************

    initial begin
        memCmdDoneIn<=1'b1;
        button <= 2'b00;
        sw <= 4'b0000;

        #5 button <= 2'b11; //INITIAL CMD RESET
        #5 button <= 2'b00; //Set button is unpressed


        #5 button <=2'b01; //Cycle to writeCmd after 1 cc
        #5 button <=2'b10; //Initiate writeCmd after 1 cc
                            //Get LSBs stage
                            //cmdLvl should be 1
        #5 button <=2'b00; //Set button is unpressed
        
        #10 sw <= 4'b0001;  //Expected memAddrOut = 0000 0001;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0001;
        
        #10 sw <= 4'b0010; //Expected memAddrOut = 0000 0011;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0010;

        #10 sw <= 4'b0100; //Expected memAddrOut = 0000 0111;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0100;

        #10 sw <= 4'b1000; //Expected memAddrOut = 0000 1111;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b1000;

        #5 button <=2'b10; //Initiate 2nd stage of writeCmd
                            //Get MSBs stage
                            //cmdLvl should be 2   
        #5 button <=2'b00; //Set button is unpressed

        #10 sw <= 4'b0001;  //Expected memAddrOut = 0001 1111;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0001;
        
        #10 sw <= 4'b0010; //Expected memAddrOut =0011 1111;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0010;

        #10 sw <= 4'b0100; //Expected memAddrOut = 0111 1111;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0100;

        #10 sw <= 4'b1000; //Expected memAddrOut = 1111 1111;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b1000;

        #5 button <=2'b10; //Initiate 3nd stage of writeCmd
                            //Get Data to write stage
                            //cmdLvl should be 3
        #5 button <=2'b00; //Set button is unpressed
        #10 sw <= 4'b0001;  //Expected ioDataOut = 0000;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0001;
        
        #10 sw <= 4'b0010; //Expected ioDataOut = 0000;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0010;

        #10 sw <= 4'b0100; //Expected ioDataOut = 0000;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b0100;

        #10 sw <= 4'b1000; //Expected ioDataOut = 0000;
        #10 sw <= 4'b0000;
        #10 sw <= 4'b1000;
                         
        #5 button <=2'b10; //End writeCmd
                            //Send data to memControl to write
                            //cmdLvl should be 0
        #5 button <=2'b00; //Set button is unpressed

        memCmdDoneIn <= 1'b0;

        //42 #10s, Run 4300ns to capture whole test in one sim.
    end
   
    always begin
        #delay clk=~clk;
    end


// Test For writeCmd ********************************

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

    // InOutControl2 uut(
    //     .clk(clk),
    //     .button(button),
    //     .sw(sw),
    //     .input(inOutEn),
    //     .input(dataIn),

    //     .addrIncEn(addrIncEn),
    //     .clearEn(clearEn)
    // );



endmodule