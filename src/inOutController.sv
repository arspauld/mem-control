module inOutControl (
    input           clk,
    input           key0,
    input           key1,
    input   [3:0]   switches,
    input           memDone,

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
logic [24:0]    localMemoryAddress;
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
localparam [3:0] READLEVEL_1 = 4'b0000;
localparam [3:0] READLEVEL_2 = 4'b0000;
localparam [3:0] READLEVEL_3 = 4'b0000;




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
                    localStageLevel <= 2'01
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
                    localDisplayData <= localMemoryAddress[15:0];
                end
            end

            WRITELEVEL_2 : begin
                if(key1 == 1'b1) begin
                    state <= WRITELEVEL_3;
                    localStageLevel <= 2'b11;
                end
                else begin
                    state <= WRITELEVEL_2;
                    localDisplayData <= {7'b0, localMemoryAddress[24:16]};
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
                    localDisplayData <= localIoDataOut;
                end
            end



            READMODE : begin //read
                if(key0 == 1'b1) begin //change mode
                    state <= CLEARMODE; // go to clear
                    localModeOutput = 2'b00;
                    localStageLevel = 2'b01;
                end
                else if (key1 == 1'b1) begin
                    //TODO
                end
                else begin
                    state <= 4'b0001; //stay
                    localModeOutput = 2'b01;
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

                localMemoryAddress <= 25'b0;
                localIoDataOut <= 16'b0;
                localStageLevel <= 2'b00;
                localIoDone <= 1'b0;
            end
        endcase
    end
    else begin
        state <= IDLE; 
end


always @(posedge sw[0]) begin
    case(state)
        (WRITE_LEVEL1 || READ_LEVEL1) : begin
              if(localMemoryAddress[3:0] == 4'hF) begin
                    localMemoryAddress[3:0] <= 4'h0;
                end
                else begin
                    localMemoryAddress[3:0]++;
                end
            end
        end
        (WRITE_LEVEL2 || READ_LEVEL2) : begin
              if(localMemoryAddress[19:16] == 4'hF) begin
                    localMemoryAddress[19:16] <= 4'h0;
                end
                else begin
                    localMemoryAddress[19:16]++;
                end
            end
        end
        WRITE_LEVEL3 : begin
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

always @(posedge sw[1]) begin
    case(state)
        (WRITE_LEVEL1 || READ_LEVEL1) : begin
              if(localMemoryAddress[7:4] == 4'hF) begin
                    localMemoryAddress[7:4] <= 4'h0;
                end
                else begin
                    localMemoryAddress[7:4]++;
                end
            end
        end
        (WRITE_LEVEL2 || READ_LEVEL2) : begin
              if(localMemoryAddress[23:20] == 4'hF) begin
                    localMemoryAddress[23:20] <= 4'h0;
                end
                else begin
                    localMemoryAddress[23:20]++;
                end
            end
        end
        WRITE_LEVEL3 : begin
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

always @(posedge sw[2]) begin
    case(state)
        (WRITE_LEVEL1 || READ_LEVEL1) : begin
              if(localMemoryAddress[11:8] == 4'hF) begin
                    localMemoryAddress[11:8] <= 4'h0;
                end
                else begin
                    localMemoryAddress[11:8]++;
                end
            end
        end
        (WRITE_LEVEL2 || READ_LEVEL2) : begin
              if(localMemoryAddress[24] == 1'b1) begin
                    localMemoryAddress[24] <= 1'b0;
                end
                else begin
                    localMemoryAddress[24]++;
                end
            end
        end
        WRITE_LEVEL3 : begin
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

always @(posedge sw[3]) begin
    case(state)
        (WRITE_LEVEL1 || READ_LEVEL1) : begin
              if(localMemoryAddress[15:12] == 4'hF) begin
                    localMemoryAddress[15:12] <= 4'h0;
                end
                else begin
                    localMemoryAddress[15:12]++;
                end
            end
        end
        WRITE_LEVEL3 : begin
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

//assign signals
assign modeOutput = localModeOutput;
assign stageLevel = localStageLevel;
assign memoryAddress = localMemoryAddress;
assign ioDataOut = localIoDataOut;
assign displayData = localDisplayData;
assign ioDone = localIoDone;

endmodule