module InOutControl_tb;
    timeunit 1ns;
    timeprecision 100ps;
    realtime delay=2.5ns;
    //logicS

    logic           clk;
    logic           key0;
    logic           key1;
    logic   [3:0]   sw;
    logic           memDone;
    logic   [15:0]  memOut;

    logic  [1:0]   modeOutput; //hex
    logic  [1:0]   stageLevel; // hex
    logic  [24:0]  memoryAddress; // memory
    logic  [15:0]  ioDataOut; // memory
    logic  [15:0]  displayData; //hex
    logic          ioDone;     //ioDone

//Test For writeCmd ********************************

    // initial begin
    //     clk <= 1'b0;
    //     memDone <= 1'b1;

    //     #10 sw <= 4'b0001; //Initalize Address values to 0
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0010;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0100;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b1000;
    //     #10 sw <= 4'b0000;

    //     #5 key0 <= 1'b1; //Go to CLEARMODE
    //     #5 key0 <= 1'b0;

    //     #5 key0 <= 1'b1; //Go to WRITEMODE
    //     #5 key0 <= 1'b0; 

    //     #5 key1 <= 1'b1; //Go to WRITELEVEL_1
    //     #5 key1 <= 1'b0; 

    //     #10 sw <= 4'b0001; //Set All LSB values to 1
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0010;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0100;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b1000;
    //     #10 sw <= 4'b0000;

    //     #5 key1 <= 1'b1; //Go to WRITELEVEL_2
    //     #5 key1 <= 1'b0; 

    //     #10 sw <= 4'b0001; //Set All MSB values to 1
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0010;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0100;
    //     #10 sw <= 4'b0000;

    //     #5 key1 = 1'b1; //Go to WRITELEVEL_3
    //     #5 key1 = 1'b0; 

    //     #10 sw <= 4'b0001; //Set All ioDataOut values to 1
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0010;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b0100;
    //     #10 sw <= 4'b0000;

    //     #10 sw <= 4'b1000;
    //     #10 sw <= 4'b0000;

    //     #5 key1 <= 1'b1; //Go to IDLE
    //     #5 key1 <= 1'b0; 
    //     #5 memDone <= 1'b0;
    
    // end

    // always begin
    //     #delay clk=~clk;
    // end

//Test For writeCmd ********************************


//Test For readCmd ********************************

    initial begin
        clk <= 1'b0;
        memDone <= 1'b1;

        #10 sw <= 4'b0001; //Initalize Address values to 0
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0010;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0100;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b1000;
        #10 sw <= 4'b0000;

        #5 key0 <= 1'b1; //Go to CLEARMODE
        #5 key0 <= 1'b0;

        #5 key0 <= 1'b1; //Go to WRITEMODE
        #5 key0 <= 1'b0; 

        #5 key0 <= 1'b1; //Go to READMODE
        #5 key0 <= 1'b0; 

        #5 key1 <= 1'b1; //Go to READLEVEL_1
        #5 key1 <= 1'b0; 

        #10 sw <= 4'b0001; //Set All LSB values to 1
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0010;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0100;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b1000;
        #10 sw <= 4'b0000;

        #5 key1 <= 1'b1; //Go to WRITELEVEL_2
        #5 key1 <= 1'b0; 

        #10 sw <= 4'b0001; //Set All MSB values to 1
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0010;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0100;
        #10 sw <= 4'b0000;

        #5 key1 = 1'b1; //Go to WRITELEVEL_3
        #5 key1 = 1'b0; 

        #10 sw <= 4'b0001; //Set All ioDataOut values to 1
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0010;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b0100;
        #10 sw <= 4'b0000;

        #10 sw <= 4'b1000;
        #10 sw <= 4'b0000;

        #5 key1 <= 1'b1; //Go to IDLE
        #5 key1 <= 1'b0; 
        #5 memDone <= 1'b0;
    
    end

    always begin
        #delay clk=~clk;
    end

//Test For readCmd ********************************




    inOutControl uut(
        .clk(clk),
        .key0(key0),
        .key1(key1),
        .sw(sw),
        .memDone(memDone),
        .memOut(memOut),
        .modeOutput(modeOutput),
        .stageLevel(stageLevel),
        .memoryAddress(memoryAddress),
        .ioDataOut(ioDataOut),
        .displayData(displayData),
        .ioDone(ioDone)
    );


endmodule