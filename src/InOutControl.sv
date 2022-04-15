module InOutControl(
    input clk,              //clk input
    input [1:0] button,     //post-debounced button input sent from debouncing module
    input [3:0] sw,         //pose-debounced switch input sent from the debouncing module
    input memCmdDoneIn,     //flag sent to InputOutputControl from the MemoryControl to signal if the MemoryControl is done executing it's command
    input  [15:0] memDataIn,//data sent from the MemoryControl to InputOutputControl as a result of a read opertaion
    
    output [1:0] memCmd,    //flag sent to the MemoryControl from InputOutputControl to identify which command is being operated
    output [15:0] ioDataOut,//Data sent to the MemoryControl from InputOutputControl during a write command 
    output [24:0] memAddrOut,//Address sent to the MemoryControl from InputOutputControl 
    output ioCmdDoneOut,     //Flag sent form InputOutputControl to the MemoryControl to singal wheter it is done with getting input or not
    output [15:0] dispData //This will be sent to a display module to be displayed on the LEDs idk exactly how these work so I just figured it would be 32-bits (8 bits per LED)..
);

logic [24:0] nextAddr;
logic [1:0] cmdLvl;
logic [1:0] currentCmd;
logic [3:0] swState;

logic localDone;
//logic //canChangeCmdmd;
logic localMemCmd;
logic localIoCmdDoneOut;
logic [15:0] localIoDataOut;
logic [24:0] localMemAddrOut;


// initial begin
//     nextAddr = 32'h00000000;
//     localDone = 1'b0;
//     //canChangeCmdmd = 1'b1;
//     localMemAddrOut = 32'h00000000;
//     localIoDataOut = 16'h0000;
// end

always@(posedge memCmdDoneIn) begin
    localMemAddrOut <= 32'h00000000;
    localIoDataOut <= 16'h0000;
    localIoCmdDoneOut <= 1'b0;
    if(cmdLvl != 2'b00) begin
        //canChangeCmdmd <= 1'b1;
    end
    
end

always @(posedge clk) begin         //ALWAYS @ POSEDGE CLK
    // if(cmdLvl === 2'bxx) begin
    //     cmdLvl <= 2'b00;
    // end
    // if(currentCmd === 2'bxx) begin
    //     currentCmd <= 2'b00;
    // end
    // if(//canChangeCmdmd === 1'bx) begin
    //     //canChangeCmdmd <= 1'b1;
    // end 
    if(memCmdDoneIn == 1'b1) begin
        case(button) 
            2'b11 : begin  //CMD RESET
                    cmdLvl <= 2'b00; //Sets the level of the command to 0 (i.e. select instruction level)
                    localIoDataOut <= 16'h0000;
                    localMemAddrOut <= 32'h00000000;
                    localIoCmdDoneOut <= 1'b0;
                    localMemCmd <= 2'b11;
                    currentCmd <= 2'b00; //Sets the current command to clear
                    //canChangeCmdmd <= 1'b1;
            end
            2'b10 : begin //EXECUTE CMD
                if(currentCmd == 2'b00) begin //Initiate Clear
                    cmdLvl <= cmdLvl + 1;
                    //canChangeCmdmd <= 1'b0;
                end
                else if(currentCmd == 2'b01) begin //Initiate Write
                    if(cmdLvl == 2'b11) begin
                        cmdLvl <= 2'b00; //Sets the level of the command to 0 (i.e. select instruction level)
                        currentCmd <= 2'b00; //Sets the current command to clear
                        localIoCmdDoneOut <= 1'b1;
                    end
                    cmdLvl <= cmdLvl + 1;
                    //canChangeCmdmd <= 1'b0;

                end
                else if(currentCmd == 2'b10) begin//Initiate Read
                    cmdLvl <= cmdLvl + 1;
                    //canChangeCmdmd <= 1'b0;
                end
                // else begin    //DEFAULT CMD RESET
                //     cmdLvl <= 2'b00; //Sets the level of the command to 0 (i.e. select instruction level)
                //     localMemCmd <= 2'b11;
                //     currentCmd <= 2'b00; //Sets the current command to clear
                //     //canChangeCmdmd <= 1'b1;
                // end
            end
            2'b01: begin    //CYCLE TO NEXT CMD
                //if(//canChangeCmd == 2'b1) begin
                    if(currentCmd == 2'b10 || currentCmd == 2'b11) begin
                        currentCmd <= 2'b00;
                    end 
                    else begin
                        currentCmd <= currentCmd + 1;
                    end
                // end
            end
            default : begin
            end
        endcase

        if(cmdLvl != 2'b00) begin //IF YOU ARE NOT CYCLING THROUGH COMMANDS
            case(currentCmd) //EXECUTE THE RIGHT CMD 
                2'b00 : begin //EXECUTE CLEAR CMD
                    localMemCmd <= 2'b00;
                    localIoDataOut <= 16'h0000;
                    localMemAddrOut <= nextAddr;
                    localIoCmdDoneOut <= 1'b1; 

                    if(nextAddr == 24'hFFFFFF) begin
                        nextAddr <= 24'h000000;
                        //canChangeCmd <= 1'b1;
                        cmdLvl <= 2'b00;
                    end 
                    nextAddr++;
                    localIoCmdDoneOut <= 1'b1;
                end
                2'b01 : begin //EXECUTE WRITE CMD 

                end
                2'b10 : begin   //EXECUTE READ CMD (INCOMPLETE)
                end
                default : begin //CMD RESET
                    cmdLvl <= 2'b00;
                    localIoDataOut <= 16'h0000;
                    localMemCmd <= 2'b11;
                    currentCmd <= 2'b00;
                    //canChangeCmdmd <= 1'b1;
                end
            endcase
        end
    end
end
always @(posedge sw[0])begin    //INCREMENTOR FOR LED 0
    if(memCmdDoneIn == 1'b1) begin
        case(currentCmd)
            2'b01 : begin//WRITE CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[3:0] == 4'hF) begin
                            localMemAddrOut[3:0] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[3:0]++;
                        end
                    end
                    2'b10 : begin //Get the 4 MSB of the write address
                        if(localMemAddrOut[19:16] == 4'hF) begin
                            localMemAddrOut[19:16] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[19:16]++;
                        end
                    end
                    2'b11 : begin   //Get the data to write to said address.
                        if(localIoDataOut[3:0] == 4'hF) begin
                            localIoDataOut[3:0] <= 4'h0;
                        end
                        else begin
                            localIoDataOut[3:0]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            2'b10 : begin//READ CMD
                case(cmdLvl)
                    2'b01 : begin  
                        if(localMemAddrOut[3:0] == 4'hF) begin
                            localMemAddrOut[3:0] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[3:0]++;
                        end
                    end
                    2'b10 : begin  
                        if(localMemAddrOut[19:16] == 4'hF) begin
                            localMemAddrOut[19:16] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[19:16]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            default : begin
            end
        endcase
    end
end


always @(posedge sw[1])begin    //INCREMENTOR FOR LED 0
    if(memCmdDoneIn == 1'b1) begin
        case(currentCmd)
            2'b01 : begin//WRITE CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[7:4] == 4'hF) begin
                            localMemAddrOut[7:4] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[7:4]++;
                        end
                    end
                    2'b10 : begin //Get the 4 MSB of the write address
                        if(localMemAddrOut[23:20] == 4'hF) begin
                            localMemAddrOut[23:20] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[23:20]++;
                        end
                    end
                    2'b11 : begin   //Get the data to write to said address.
                        if(localIoDataOut[7:4] == 4'hF) begin
                            localIoDataOut[7:4] <= 4'h0;
                        end
                        else begin
                            localIoDataOut[7:4]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            2'b10 : begin //READ CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[7:4] == 4'hF) begin
                            localMemAddrOut[7:4] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[7:4]++;
                        end
                    end
                    2'b10 : begin //Get the 4 MSB of the write address
                        if(localMemAddrOut[23:20] == 4'hF) begin
                            localMemAddrOut[23:20] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[23:20]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            default : begin
            end
        endcase
    end
end
always @(posedge sw[2])begin    //INCREMENTOR FOR LED 0
    if(memCmdDoneIn == 1'b1) begin
        case(currentCmd)
            2'b01 : begin//WRITE CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[11:8] == 4'hF) begin
                            localMemAddrOut[11:8] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[11:8]++;
                        end
                    end
                    2'b10 : begin //Get the 4 MSB of the write address
                        if(localMemAddrOut[24] == 1'b1) begin
                            localMemAddrOut[24] <= 1'b0;
                        end
                        else begin
                            localMemAddrOut[24]++;
                        end
                    end
                    2'b11 : begin   //Get the data to write to said address.
                        if(localIoDataOut[11:8] == 4'hF) begin
                            localIoDataOut[11:8] <= 4'h0;
                        end
                        else begin
                            localIoDataOut[11:8]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            2'b10 : begin //READ CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[11:8] == 4'hF) begin
                            localMemAddrOut[11:8] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[11:8]++;
                        end
                    end
                    2'b10 : begin //Get the 4 MSB of the write address
                        if(localMemAddrOut[24] == 1'b1) begin
                            localMemAddrOut[24] <= 1'b0;
                        end
                        else begin
                            localMemAddrOut[24]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            default : begin
            end
        endcase
    end
end

always @(posedge sw[3])begin    //INCREMENTOR FOR LED 0
    if(memCmdDoneIn == 1'b1) begin
        case(currentCmd)
            2'b01 : begin//WRITE CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[15:12] == 4'hF) begin
                            localMemAddrOut[15:12] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[15:12]++;
                        end
                    end
                    2'b10 : begin 
                    end
                    2'b11 : begin   //Get the data to write to said address.
                        if(localIoDataOut[15:12] == 4'hF) begin
                            localIoDataOut[15:12] <= 4'h0;
                        end
                        else begin
                            localIoDataOut[15:12]++;
                        end
                    end
                    default : begin
                    end
                endcase
            end
            2'b10 : begin //READ CMD
                case(cmdLvl)
                    2'b01 : begin  //Get the 4 LSB of the write address
                        if(localMemAddrOut[15:12] == 4'hF) begin
                            localMemAddrOut[15:12] <= 4'h0;
                        end
                        else begin
                            localMemAddrOut[15:12]++;
                        end
                    end
                    2'b10 : begin 
                    end
                    default : begin
                    end
                endcase
            end
            default : begin
            end
        endcase
    end
end

    //ASSIGN OUTPUTS
    assign memCmd = localMemCmd;
    assign ioDataOut = localIoDataOut; 
    assign memAddrOut = localMemAddrOut;
    assign ioCmdDoneOut = localIoCmdDoneOut;

endmodule
// always @(posedge sw[0]) begin
//     case(state)
//         (WRITE_LEVEL1 || READ_LEVEL1) : begin
//               if(localmemoryAddress[3:0] == 4'hF) begin
//                     localMemoryAddress[3:0] <= 4'h0;
//                 end
//                 else begin
//                     localMemoryAddress[3:0]++;
//                 end
//             end
//         end
//         (WRITE_LEVEL2 || READ_LEVEL2) : begin
//               if(localmemoryAddress[19:16] == 4'hF) begin
//                     localMemoryAddress[19:16] <= 4'h0;
//                 end
//                 else begin
//                     localMemoryAddress[19:16]++;
//                 end
//             end
//         end
//         WRITE_LEVEL3 : begin
//             if(localIoDataOut[3:0] == 4'hF) begin
//                 localIoDataOut[3:0] <= 4'h0;
//             end
//             else begin
//                 localIoDataOut[3:0]++;
//             end
//         end
//         default : begin
//         end
//     endcase
// end

// always @(posedge sw[1]) begin
//     case(state)
//         (WRITE_LEVEL1 || READ_LEVEL1) : begin
//               if(localmemoryAddress[7:4] == 4'hF) begin
//                     localMemoryAddress[7:4] <= 4'h0;
//                 end
//                 else begin
//                     localMemoryAddress[7:4]++;
//                 end
//             end
//         end
//         (WRITE_LEVEL2 || READ_LEVEL2) : begin
//               if(localmemoryAddress[23:20] == 4'hF) begin
//                     localMemoryAddress[23:20] <= 4'h0;
//                 end
//                 else begin
//                     localMemoryAddress[23:20]++;
//                 end
//             end
//         end
//         WRITE_LEVEL3 : begin
//             if(localIoDataOut[7:4] == 4'hF) begin
//                 localIoDataOut[7:4] <= 4'h0;
//             end
//             else begin
//                 localIoDataOut[7:4]++;
//             end
//         end
//         default : begin
//         end
//     endcase
// end

// always @(posedge sw[2]) begin
//     case(state)
//         (WRITE_LEVEL1 || READ_LEVEL1) : begin
//               if(localmemoryAddress[11:8] == 4'hF) begin
//                     localMemoryAddress[11:8] <= 4'h0;
//                 end
//                 else begin
//                     localMemoryAddress[11:8]++;
//                 end
//             end
//         end
//         (WRITE_LEVEL2 || READ_LEVEL2) : begin
//               if(localmemoryAddress[24] == 1'b1) begin
//                     localMemoryAddress[24] <= 1'b0;
//                 end
//                 else begin
//                     localMemoryAddress[24]++;
//                 end
//             end
//         end
//         WRITE_LEVEL3 : begin
//             if(localIoDataOut[11:8] == 4'hF) begin
//                 localIoDataOut[11:8] <= 4'h0;
//             end
//             else begin
//                 localIoDataOut[11:8]++;
//             end
//         end
//         default : begin
//         end
//     endcase
// end

// always @(posedge sw[3]) begin
//     case(state)
//         (WRITE_LEVEL1 || READ_LEVEL1) : begin
//               if(localmemoryAddress[15:12] == 4'hF) begin
//                     localMemoryAddress[15:12] <= 4'h0;
//                 end
//                 else begin
//                     localMemoryAddress[15:12]++;
//                 end
//             end
//         end
//         WRITE_LEVEL3 : begin
//             if(localIoDataOut[15:12] == 4'hF) begin
//                 localIoDataOut[15:12] <= 4'h0;
//             end
//             else begin
//                 localIoDataOut[15:12]++;
//             end
//         end
//         default : begin
//         end
//     endcase
// end
