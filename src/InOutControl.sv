module InOutControl(
    input clk,              //clk input
    input [1:0] button,     //post-debounced button input sent from debouncing module
    input [3:0] sw,         //pose-debounced switch input sent from the debouncing module
    input memCmdDoneIn,     //flag sent to InputOutputControl from the MemoryControl to signal if the MemoryControl is done executing it's command
    input  [31:0] memDataIn,//data sent from the MemoryControl to InputOutputControl as a result of a read opertaion
    output [1:0] memCmd,    //flag sent to the MemoryControl from InputOutputControl to identify which command is being operated
    output [31:0] ioDataOut,//Data sent to the MemoryControl from InputOutputControl during a write command 
    output [63:0] memAddrOut,//Address sent to the MemoryControl from InputOutputControl 
    output ioCmdDoneOut,     //Flag sent form InputOutputControl to the MemoryControl to singal wheter it is done with getting input or not
    output [31:0] dispData //This will be sent to a display module to be displayed on the LEDs idk exactly how these work so I just figured it would be 32-bits (8 bits per LED)..
);

reg [63:0] nextAddr;
reg [1:0] cmdLvl;
reg [1:0] currentCmd;
reg [3:0] swState;

var localDone;
var canChangeCmd;
var localMemCmd;
var localIoCmdDoneOut;
reg [31:0] localIoDataOut;
reg [63:0] localMemAddrOut;
reg [31:0] localDispData;


initial begin
    nextAddr = 32'h00000000;
    cmdLvl = 2'b00;
    currentCmd = 2'b00;
    swState = 4'b0000;
    localDone = 1'b0;
    canChangeCmd = 1'b0;
     
end

function void clearCmd(nextAddr);
    localMemCmd <= 2'b00;
    localIoDataOut <= 16'h0000;
    localMemAddrOut <= nextAddr;
    localIoCmdDoneOut <= 1'b0;    
endfunction

function void writeCmd( input [1:0] cmdLvl, input [3:0] sw, input [1:0] button);
    case(cmdLvl)
        1'b01 : begin  //Get the 4 LSB of the write address
            //Incrementer for LED1
            if(swState[0] == 1'b0) begin  
                if(sw[0] == 1'b1) begin
                    if(localMemAddrOut[7:0] == 8'hF) begin
                        localMemAddrOut[7:0] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[7:0]++;
                    end
                end
            end
            swState[0] <= sw[0];

            //Incrementer for LED1
            if(swState[1] == 1'b0) begin  
                if(sw[1] == 1'b1) begin
                    if(localMemAddrOut[15:8] == 8'hF) begin
                        localMemAddrOut[15:8] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[15:8]++;
                    end
                end
            end
            swState[1] <= sw[1];

            //Incrementer for LED2
            if(swState[2] == 1'b0) begin  
                if(sw[2] == 1'b1) begin
                    if(localMemAddrOut[23:16] == 8'hF) begin
                        localMemAddrOut[23:16] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[23:16]++;
                    end
                end
            end
            swState[2] <= sw[2];

            //Incrementer for LED2
            if(swState[3] == 1'b0) begin  
                if(sw[3] == 1'b1) begin
                    if(localMemAddrOut[31:24] == 8'hF) begin
                        localMemAddrOut[31:24] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[31:24]++;
                    end
                end
            end
            swState[3] <= sw[3];
        end
        1'b10 : begin //Get the 4 MSB of the write address
            if(swState[0] == 1'b0) begin  
                if(sw[0] == 1'b1) begin
                    if(localMemAddrOut[39:32] == 8'hF) begin
                        localMemAddrOut[39:32] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[39:32]++;
                    end
                end
            end
            swState[0] <= sw[0];

            //Incrementer for LED1
            if(swState[1] == 1'b0) begin  
                if(sw[1] == 1'b1) begin
                    if(localMemAddrOut[47:40] == 8'hF) begin
                        localMemAddrOut[47:40] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[47:40]++;
                    end
                end
            end
            swState[1] <= sw[1];

            //Incrementer for LED2
            if(swState[2] == 1'b0) begin  
                if(sw[2] == 1'b1) begin
                    if(localMemAddrOut[55:48] == 8'hF) begin
                        localMemAddrOut[55:48] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[55:48]++;
                    end
                end
            end
            swState[2] <= sw[2];

            //Incrementer for LED2
            if(swState[3] == 1'b0) begin  
                if(sw[3] == 1'b1) begin
                    if(localMemAddrOut[63:56] == 8'hF) begin
                        localMemAddrOut[63:56] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[63:56]++;
                    end
                end
            end
            swState[3] <= sw[3];
        end
        1'b11 : begin   //Get the data to write to said address.
            if(swState[0] == 1'b0) begin  
                if(sw[0] == 1'b1) begin
                    if(localIoDataOut[7:0] == 8'hF) begin
                        localIoDataOut[7:0] <= 8'h0;
                    end
                    else begin
                        localIoDataOut[7:0]++;
                    end
                end
            end
            swState[0] <= sw[0];

            //Incrementer for LED1
            if(swState[1] == 1'b0) begin  
                if(sw[1] == 1'b1) begin
                    if(localIoDataOut[15:8] == 8'hF) begin
                        localIoDataOut[15:8] <= 8'h0;
                    end
                    else begin
                        localIoDataOut[15:8]++;
                    end
                end
            end
            swState[1] <= sw[1];

            //Incrementer for LED2
            if(swState[2] == 1'b0) begin  
                if(sw[2] == 1'b1) begin
                    if(localIoDataOut[23:16] == 8'hF) begin
                        localIoDataOut[23:16] <= 8'h0;
                    end
                    else begin
                        localIoDataOut[23:16]++;
                    end
                end
            end
            swState[2] <= sw[2];
            //Incrementer for LED2
            if(swState[3] == 1'b0) begin  
                if(sw[3] == 1'b1) begin
                    if(localIoDataOut[31:24] == 8'hF) begin
                        localIoDataOut[31:24] <= 8'h0;
                    end
                    else begin
                        localIoDataOut[31:24]++;
                    end
                end
            end
            swState[3] <= sw[3];
        end
        2'b10 : begin
            cmdLvl++;
            if(cmdLvl == 2'b11)begin //Once command level is incremented past 3, then the memory module takes over and 
                localIoCmdDoneOut <= 1'b1;
                cmdLvl <= 2'b00;
            end
        end
    endcase
endfunction

function void readCmd(input [1:0] cmdLvl, input [3:0] sw, input [1:0] button);
    case(cmdLvl)
        1'b01 : begin  //Get the 4 LSB of the read address
            //Incrementer for LED0
            if(swState[0] == 1'b0) begin  
                if(sw[0] == 1'b1) begin
                    if(localMemAddrOut[7:0] == 8'hF) begin
                        localMemAddrOut[7:0] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[7:0]++;
                    end
                end
            end
            swState[0] <= sw[0];

            //Incrementer for LED1
            if(swState[1] == 1'b0) begin  
                if(sw[1] == 1'b1) begin
                    if(localMemAddrOut[15:8] == 8'hF) begin
                        localMemAddrOut[15:8] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[15:8]++;
                    end
                end
            end
            swState[1] <= sw[1];

            //Incrementer for LED2
            if(swState[2] == 1'b0) begin  
                if(sw[2] == 1'b1) begin
                    if(localMemAddrOut[23:16] == 8'hF) begin
                        localMemAddrOut[23:16] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[23:16]++;
                    end
                end
            end
            swState[2] <= sw[2];

            //Incrementer for LED2
            if(swState[3] == 1'b0) begin  
                if(sw[3] == 1'b1) begin
                    if(localMemAddrOut[31:24] == 8'hF) begin
                        localMemAddrOut[31:24] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[31:24]++;
                    end
                end
            end
            swState[3] <= sw[3];
        end
        1'b10 : begin //Get the 4 MSB of the write address
            if(swState[0] == 1'b0) begin  
                if(sw[0] == 1'b1) begin
                    if(localMemAddrOut[39:32] == 8'hF) begin
                        localMemAddrOut[39:32] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[39:32]++;
                    end
                end
            end
            swState[0] <= sw[0];

            //Incrementer for LED1
            if(swState[1] == 1'b0) begin  
                if(sw[1] == 1'b1) begin
                    if(localMemAddrOut[47:40] == 8'hF) begin
                        localMemAddrOut[47:40] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[47:40]++;
                    end
                end
            end
            swState[1] <= sw[1];

            //Incrementer for LED2
            if(swState[2] == 1'b0) begin  
                if(sw[2] == 1'b1) begin
                    if(localMemAddrOut[55:48] == 8'hF) begin
                        localMemAddrOut[55:48] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[55:48]++;
                    end
                end
            end
            swState[2] <= sw[2];

            //Incrementer for LED2
            if(swState[3] == 1'b0) begin  
                if(sw[3] == 1'b1) begin
                    if(localMemAddrOut[63:56] == 8'hF) begin
                        localMemAddrOut[63:56] <= 8'h0;
                    end
                    else begin
                        localMemAddrOut[63:56]++;
                    end
                end
            end
            swState[3] <= sw[3];
        end
        1'b11 : begin   //Get the data from address specified in command level 1 and 2
            cmdLvl++;
            if(cmdLvl == 2'b11) begin//Once command level is incremented past 3, then the memory module takes over and 
                localIoCmdDoneOut <= 1'b1;
                cmdLvl <= 2'b00;
            end
        end
    endcase
endfunction

function void cmdReset();
    cmdLvl <= 2'b00; //Sets teh level of the command to 0 (i.e. select instruction level)
    //dispData <= idklol
    localIoDataOut <= 16'h0000;
    localMemCmd <= 2'b11;
    currentCmd <= 2'b00; //Sets the current command to clear
endfunction

always @(posedge clk) begin
    if(memCmdDoneIn == 1'b1 && canChangeCmd == 1'b1) begin
        case(button)
            2'b11 : begin  //Command Reset, acts like Ctrl + C in a terminal and resets the command to be exectued to clear
                if(currentCmd != 2'b00) begin //If the cmd is alread on clear do not reset the cmd
                    cmdReset();
                end
            end
            2'b10 : begin
                if(currentCmd == 2'b00) begin //Initiate Clear
                    cmdLvl++;
                    canChangeCmd <= 1'b0;
                end
                   else if(currentCmd == 2'b01) begin //Initiate Write
                    cmdLvl++;
                    canChangeCmd <= 1'b0;
                end
                else if(currentCmd == 2'b10) begin//Initiate Read
                    cmdLvl++;
                    canChangeCmd <= 1'b0;
                end
                else begin     //Default statement
                    cmdReset();
                end
            end
            default : begin     //Increment current Command Mode (doubles as default)
                 if(currentCmd == 2'b10 || currentCmd == 2'b11) begin
                    currentCmd <= 2'b00;
                end 
                else begin
                    currentCmd++;
                end
            end
        endcase
    end
    if(canChangeCmd == 1'b0) begin //Execute the right command 
        case(currentCmd)
            2'b00 : begin
                clearCmd(nextAddr);
                if(nextAddr <= 7'hFFFFFFFF) begin
                    nextAddr <= 7'h00000000;
                end 
                nextAddr++;
            end
            2'b01 : begin
                writeCmd(cmdLvl,sw,button);

            end
            2'b10 : begin
                readCmd(cmdLvl,sw,button);
            end
            default : begin
                cmdReset();
            end
        endcase
    end

end
    //Assign Outputs
    assign memCmd = localMemCmd;
    assign ioDataOut = localIoDataOut; 
    assign memAddrOut = localMemAddrOut;
    assign ioCmdDoneOut = localIoCmdDoneOut;
    //assign dispData = localDispData; 

endmodule
