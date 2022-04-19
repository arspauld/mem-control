module inOutControl (
    input           clk,
    input           key0,
    input           key1,
    input   [3:0]   sw,
    input           memDone,
    input   [15:0]  memOut,

    output  [1:0]   modeOutput, //hex
    output  [1:0]   stageLevel, // hex
    output  [24:0]  memoryAddress, // memory
    output  [15:0]  ioDataOut, // memory
    output  [15:0]  displayData, //hex
    output          ioDone     //ioDone
);

logic [3:0]     state;
logic [1:0]     localModeOutput;
logic [1:0]     localStageLevel;
logic [15:0]    localDisplayData;
logic [24:0]    localMemAddr;
logic [15:0]    localIoDataOut;
logic           localIoDone;

localparam [3:0] CLEARMODE = 4'b0000;
localparam [3:0] READMODE = 4'b0001;
localparam [3:0] WRITEMODE = 4'b0010;
localparam [3:0] IDLE = 4'b1111;

localparam [3:0] WRITELEVEL_1 = 4'b0011;
localparam [3:0] WRITELEVEL_2 = 4'b0100;
localparam [3:0] WRITELEVEL_3 = 4'b0101;

//Pending: define them correctly
localparam [3:0] READLEVEL_1 = 4'b0110;
localparam [3:0] READLEVEL_2 = 4'b0111;
localparam [3:0] READLEVEL_3 = 4'b1000;

//Local Memory Addresses
logic [3:0] localMemAddrLSBSw0;
logic [3:0] localMemAddrLSBSw1;
logic [3:0] localMemAddrLSBSw2;
logic [3:0] localMemAddrLSBSw3;

logic [3:0] localMemAddrMSBSw0;
logic [3:0] localMemAddrMSBSw1;
logic       localMemAddrMSBSw2;

logic [3:0] localIoDataOutSw0;
logic [3:0] localIoDataOutSw1;
logic [3:0] localIoDataOutSw2;
logic [3:0] localIoDataOutSw3;

always@(posedge clk) begin
    if(memDone == 1'b1) begin
        case(state)
            CLEARMODE : begin //clearCmd
                if(key0 == 1'b1) begin //change mode
                    state <= WRITEMODE;
                    localModeOutput <= 2'b10;
                    localStageLevel <= 2'b00;
                end
                
                else begin
                    state <= CLEARMODE;
                    localModeOutput <= 2'b00;
                end
            end

            WRITEMODE : begin //write
                if(key0 == 1'b1) begin //change mode
                    state <= READMODE; // go to read
                    localModeOutput = 2'b01;
                    localStageLevel = 2'b00;
                end
                else if (key1 == 1'b1) begin
                    state <= WRITELEVEL_1; // write level 1
                    localStageLevel <= 2'b01;
                end
                else begin
                    state <= WRITEMODE;
                    localModeOutput = 2'b10;
                end
            end

            WRITELEVEL_1 : begin //write level 1
                if(key1 == 1'b1) begin
                    state <= WRITELEVEL_2;
                    localStageLevel <= 2'b10;
                end
                else begin
                    state <= WRITELEVEL_1;
                    localDisplayData <= {localMemAddrLSBSw3,localMemAddrLSBSw2,localMemAddrLSBSw1,localMemAddrLSBSw0};
                end
            end

            WRITELEVEL_2 : begin
                if(key1 == 1'b1) begin
                    state <= WRITELEVEL_3;
                    localStageLevel <= 2'b11;
                end
                else begin
                    state <= WRITELEVEL_2;
                    localDisplayData <= {4'b0,localMemAddrMSBSw2,localMemAddrMSBSw1,localMemAddrMSBSw0};
                end
            end

            WRITELEVEL_3 : begin
                if(key1 == 1'b1) begin
                    state <= IDLE;
                    localStageLevel <= 2'b00;
                    localModeOutput <= 2'b11;
                    localIoDone <= 1'b1;
                end
                else begin
                    state <= WRITELEVEL_3;
                    localDisplayData <= {localIoDataOutSw3,localIoDataOutSw2,localIoDataOutSw1,localIoDataOutSw0};
                end
            end

            READMODE : begin //read
                if(key0 == 1'b1) begin //change mode
                    state <= CLEARMODE; // go to clear
                    localModeOutput = 2'b00;
                    
                end
                else if (key1 == 1'b1) begin
					localModeOutput = 2'b01;
                    state <= READLEVEL_1;
                    localStageLevel <= 2'b01;
                end
                else begin
                    state <= 4'b0001; //stay
                    localModeOutput = 2'b01;
                end
            end

            READLEVEL_1 : begin //write level 1
                if(key1 == 1'b1) begin
                    state <= READLEVEL_2;
                    localStageLevel <= 2'b10;
                end
                else begin
                    state <= READLEVEL_1;
                    localDisplayData <= {localMemAddrLSBSw3,localMemAddrLSBSw2,localMemAddrLSBSw1,localMemAddrLSBSw0};
                end
            end

            READLEVEL_2 : begin
                if(key1 == 1'b1) begin
                    state <= READLEVEL_3;
                    localStageLevel <= 2'b11;
                    localIoDone <= 1'b1;
                end
                else begin
                    state <= READLEVEL_2;
                    localDisplayData <= {4'b0,localMemAddrMSBSw2,localMemAddrMSBSw1,localMemAddrMSBSw0};
                end
            end

            READLEVEL_3 : begin
                if(key1 == 1'b1) begin
                    state <= IDLE;
                    localModeOutput <= 2'b00;
                    localStageLevel <= 2'b00;
                end
                else begin
                    state <= READLEVEL_3;
                    localDisplayData <= {memOut[15:12],memOut[11:8], memOut[7:4], memOut[3:0]};
                end
            end

            default : begin
                if(key0 == 1) begin
                    state <= CLEARMODE;
                    localModeOutput <= 2'b00;

                end   
                else begin
                    localModeOutput <= 2'b11;
                end

                localStageLevel <= 2'b00;
                localIoDone <= 1'b0;
            end
        endcase
    end
    // else begin
    //     if(state == WRITELEVEL_3) begin
    //         state <= IDLE;
    //     end
    //     else if(state) begin
    //         state <= READLEVEL_3;
    //     end 
    // end
end


always @(posedge sw[0]) begin
    case(state)
            WRITELEVEL_1 : begin
            if(localMemAddrLSBSw0 == 4'hF) begin
                localMemAddrLSBSw0 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw0 <= localMemAddrLSBSw0 + 1'b1;
            end
        end
            READLEVEL_1 : begin
            if(localMemAddrLSBSw0 == 4'hF) begin
                localMemAddrLSBSw0 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw0 <= localMemAddrLSBSw0 + 1'b1;
            end
        end 
            WRITELEVEL_2 : begin
            if(localMemAddrMSBSw0 == 4'hF) begin
                localMemAddrMSBSw0 <= 4'h0;
            end
            else begin
                localMemAddrMSBSw0 <= localMemAddrMSBSw0 + 1'b1;
            end
        end
            READLEVEL_2 : begin
            if(localMemAddrMSBSw0 == 4'hF) begin
                localMemAddrMSBSw0 <= 4'h0;
            end
            else begin
                localMemAddrMSBSw0 <= localMemAddrMSBSw0 + 1'b1;
            end
        end
        WRITELEVEL_3 : begin
            if(localIoDataOutSw0 == 4'hF) begin
                localIoDataOutSw0 <= 4'h0;
            end
            else begin
                localIoDataOutSw0 <= localIoDataOutSw0 + 1'b1;
            end
        end
        default : begin

            localMemAddrLSBSw0 <= 4'b0;
            localMemAddrMSBSw0 <= 4'b0;
            localIoDataOutSw0 <= 4'b0;

        end
    endcase
end

always @(posedge sw[1]) begin
    case(state)
        WRITELEVEL_1 : begin
            if(localMemAddrLSBSw1 == 4'hF) begin
                localMemAddrLSBSw1 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw1 <= localMemAddrLSBSw1 + 1'b1;
            end
        end
        READLEVEL_1 : begin
            if(localMemAddrLSBSw1 == 4'hF) begin
                localMemAddrLSBSw1 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw1 <= localMemAddrLSBSw1 + 1'b1;
            end
        end 
        WRITELEVEL_2 : begin
            if(localMemAddrMSBSw1 == 4'hF) begin
                localMemAddrMSBSw1 <= 4'h0;
            end
            else begin
                localMemAddrMSBSw1 <= localMemAddrMSBSw1 + 1'b1;
            end
        end
        READLEVEL_2 : begin
            if(localMemAddrMSBSw1 == 4'hF) begin
                localMemAddrMSBSw1 <= 4'h0;
            end
            else begin
                localMemAddrMSBSw1 <= localMemAddrMSBSw1 + 1'b1;
            end
        end
        WRITELEVEL_3 : begin
            if(localIoDataOutSw1 == 4'hF) begin
                localIoDataOutSw1 <= 4'h0;
            end
            else begin
                localIoDataOutSw1 <= localIoDataOutSw1 + 1'b1;
            end
        end
        default : begin

            localMemAddrLSBSw1 <= 4'b0;
            localMemAddrMSBSw1 <= 4'b0;
            localIoDataOutSw1 <= 4'b0;

        end
    endcase
end

always @(posedge sw[2]) begin
    case(state)
        WRITELEVEL_1 : begin
            if(localMemAddrLSBSw2 == 4'hF) begin
                localMemAddrLSBSw2 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw2 <= localMemAddrLSBSw2 + 1'b1;
            end
        end
        READLEVEL_1 : begin
            if(localMemAddrLSBSw2 == 4'hF) begin
                localMemAddrLSBSw2 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw2 <= localMemAddrLSBSw2 + 1'b1;
            end
        end
        WRITELEVEL_2 : begin
            if(localMemAddrMSBSw2 == 1'b1) begin
                localMemAddrMSBSw2 <= 1'b0;
            end
            else begin
                localMemAddrMSBSw2 <= localMemAddrMSBSw2 + 1'b1;
            end
        end
        READLEVEL_2 : begin
            if(localMemAddrMSBSw2 == 1'b1) begin
                localMemAddrMSBSw2 <= 1'b0;
            end
            else begin
                localMemAddrMSBSw2 <= localMemAddrMSBSw2 + 1'b1;
            end
        end
        WRITELEVEL_3 : begin
            if(localIoDataOutSw2 == 4'hF) begin
                localIoDataOutSw2 <= 4'h0;
            end
            else begin
                localIoDataOutSw2 <= localIoDataOutSw2 + 1'b1;
            end
        end
        default : begin

            localMemAddrLSBSw2 <= 4'b0;
            localMemAddrMSBSw2 <= 1'b0;
            localIoDataOutSw2 <= 4'b0;

        end
    endcase
end

always @(posedge sw[3]) begin
    case(state)
        WRITELEVEL_1 : begin
            if(localMemAddrLSBSw3 == 4'hF) begin
                localMemAddrLSBSw3 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw3 <= localMemAddrLSBSw3 + 1'b1;
            end
        end
        READLEVEL_1 : begin
            if(localMemAddrLSBSw3 == 4'hF) begin
                localMemAddrLSBSw3 <= 4'h0;
            end
            else begin
                localMemAddrLSBSw3 <= localMemAddrLSBSw3 + 1'b1;
            end
        end

        WRITELEVEL_3 : begin
            if(localIoDataOutSw3 == 4'hF) begin
                localIoDataOutSw3 <= 4'h0;
            end
            else begin
                localIoDataOutSw3 <= localIoDataOutSw3 + 1'b1;
            end
        end
        default : begin

            localMemAddrLSBSw3 <= 4'b0;
            localIoDataOutSw3 <= 4'b0;

        end
    endcase
end

//assign signals
assign modeOutput = localModeOutput;
assign stageLevel = localStageLevel;
assign memoryAddress = {localMemAddrMSBSw2,localMemAddrMSBSw1,localMemAddrMSBSw0,localMemAddrLSBSw3,localMemAddrLSBSw2,localMemAddrLSBSw1,localMemAddrLSBSw0};
assign ioDataOut = {localIoDataOutSw3,localIoDataOutSw2,localIoDataOutSw1,localIoDataOutSw0};
assign displayData = localDisplayData;
assign ioDone = localIoDone;

endmodule