module InOutControl_tb;
    timeunit 1ns;
    timeprecision 100ps;
    realtime delay=2.5ns;

    logic clk;
    logic key0_pulse;
    logic key1_pulse;
    logic [8:0] sw;

    logic memDone;
    logic ioDone;

    logic [15:0] write_data;
    logic [15:0] read_data;
    logic [24:0] memoryAddress;
    logic [15:0] displayData;
    logic [1:0] mode_output;

    logic [12:0] out_state;

    //     #10 sw <= 4'b1000;
    //     #10 sw <= 4'b0000;

//Test For READ ********************************
    initial begin
        clk <= 1'b0;
        memDone <= 1'b1;

        // #5 key0_pulse <= 1'b1; key1_pulse <= 1'b1; //Go to IDLE
        // #5 key0_pulse <= 1'b0; key1_pulse <= 1'b0;

        #5 key0_pulse <= 1'b1; //Go to READ_ST0
        #5 key0_pulse <= 1'b0;

        #10 sw <= 9'b011111111; //Set memoryAddress [7:0] to all 1's at next state transition

        #5 key1_pulse <= 1'b1; //Go to READ_ST1
        #5 key1_pulse <= 1'b0;

      //#10 sw <= 9'b000000000
        #10 sw <= 9'b011111111; //Set memoryAddress [15:8] to all 1's at next state transition

        #5 key1_pulse <= 1'b1; //Go to READ_ST2
        #5 key1_pulse <= 1'b0;

        #10 sw <= 9'b111111111; //Set memoryAddress [24:16] to all 1's at next state transition

        #5 key1_pulse <= 1'b1; memDone<=1'b0; //Go to READ_WAIT
        #5 key1_pulse <= 1'b0;

        #5 read_data <= 16'hAAAA;
        #5 memDone <= 1'b1; //Go to READ_DONE

        #5 key0_pulse <= 1'b1; //Go to IDLE
        #5 key0_pulse <= 1'b0;
    end

//Test For READ ********************************

//Test For WRITE ********************************
    // initial begin
    //     clk <= 1'b0;
    //     memDone <= 1'b1;

    //     #5 key0_pulse <= 1'b1; key1_pulse <= 1'b1; //Go to IDLE
    //     #5 key0_pulse <= 1'b0; key1_pulse <= 1'b0;

    //     #5 key0_pulse <= 1'b1; //WRITE_ST0
    //     #5 key0_pulse <= 1'b0;

    //     #10 sw <= 9'b011111111; //Set memoryAddress [7:0] to all 1's at next state transition

    //     #5 key1_pulse <= 1'b1; //Go to WRITE_ST1
    //     #5 key1_pulse <= 1'b0;

    //   //#10 sw <= 9'b000000000
    //     #10 sw <= 9'b011111111; //Set memoryAddress [15:8] to all 1's at next state transition

    //     #5 key1_pulse <= 1'b1; //Go to WRITE_ST2
    //     #5 key1_pulse <= 1'b0;

    //     #10 sw <= 9'b111111111; //Set memoryAddress [24:16] to all 1's at next state transition

    //     #5 key1_pulse <= 1'b1; //Go to WRITE_ST3
    //     #5 key1_pulse <= 1'b0;

    //     #10 sw<= 9 'b011001100; //Set write_data [7:0] to all 1's at next state transition

    //     #5 key1_pulse <= 1'b1; //Go to WRITE_ST4
    //     #5 key1_pulse <= 1'b0;

    //     #10 sw <= 9'b011001100; //Set write_data [15:0] to all 1's at next state transition

    //     #5 key1_pulse <= 1'b1; memDone<=1'b0; //Go to WRITE_WAIT
    //     #5 key1_pulse <= 1'b0;


    //     #5 memDone <= 1'b1; //Go to IDLE

    // end

//Test For WRITE ********************************

    always begin
        #delay clk=~clk;
    end

    inOutControl uut(
        .clk(clk),
        .key0_pulse(key0_pulse),
        .key1_pulse(key1_pulse),
        .sw(sw),
        .memDone(memDone),
        .read_data(read_data),
        .modeOutput(modeOutput),    
        .memoryAddress(memoryAddress),
        .displayData(displayData),
        .ioDone(ioDone),
        .out_state(out_state)
    );



endmodule