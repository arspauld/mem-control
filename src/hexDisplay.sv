// state 1: print clear = 2'b00
// state 2: print read = 2'b01
// state 3: print rlte = 2'b10

module hexDisplay (
    input   [1:0]   stage,
    input   [1:0]   modeSelect,     
    input   [15:0]  inVal,
    output  [7:0]   HEX0,
    output  [7:0]   HEX1,
    output  [7:0]   HEX2,
    output  [7:0]   HEX3,
    output  [7:0]   HEX4,
    output  [7:0]   HEX5              
);

//my idea is to handle the input from the controller modules rather than here
//so here we just need to set the output to whatever value is input, clock it
//for howmany cycles we want and change it every time the input changes, more
//inputs may need to be added so that we handle printing read and stuff, but for
//now lets keep it simple, for now this just displays the info as its input
//{char5,char4,char3,char2,char1,char0} = {1'b0,inVal[23:20],1'b0,inVal[19:16],1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};

reg [4:0] char0;
reg [4:0] char1;
reg [4:0] char2;
reg [4:0] char3;
reg [4:0] char4;
reg [4:0] char5;

localparam [1:0] CLEARMODE = 2'b00;
localparam [1:0] READMODE = 2'b01;
localparam [1:0] WRITEMODE = 2'b10;
localparam [1:0] IDLE = 2'b11;

localparam CHAR_R = 5'd16;
localparam CHAR_E = 5'd14;
localparam CHAR_A = 5'd10;
localparam CHAR_D = 5'd17;
localparam CHAR_T = 5'd18;  
localparam CHAR_C = 5'd12;
localparam CHAR_L = 5'd1;
localparam BLANK = 5'd19;

always @(*)
begin
    if(modeSelect == READMODE) begin
        if(stage == 2'b00) begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,CHAR_E,CHAR_A,CHAR_D,BLANK,BLANK};
        end
        else if(stage == 2'b01) begin
            //get address to read
            {char5,char4,char3,char2,char1,char0} = {CHAR_R, BLANK,1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end
        else if(stage == 2'b10) begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_T,BLANK,1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end 
        else begin
            //display value
            {char5,char4,char3,char2,char1,char0} = {CHAR_R, BLANK, 1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end
    end else if (modeSelect == WRITEMODE) begin
        if(stage == 2'b00) begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,CHAR_L,CHAR_T,CHAR_E,BLANK, BLANK};
        end 
        else if(stage == 2'b01) begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_T,BLANK,1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end
        else if(stage == 2'b10) begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_T,BLANK,1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end  
        else begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_T,BLANK,1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end 
    end 
    else if (modeSelect == CLEARMODE) begin
        {char5,char4,char3,char2,char1,char0} = {CHAR_C,CHAR_L,CHAR_E,CHAR_A,CHAR_R,BLANK};
    end
    else if (modeSelect == IDLE)begin
        {char5,char4,char3,char2,char1,char0} = {5'd1,CHAR_D,CHAR_L,CHAR_E,BLANK,BLANK};
		end
		else begin
		{char5,char4,char3,char2,char1,char0} = {BLANK,BLANK,BLANK,BLANK,BLANK};
		end
end
        
hexDriver displayRes [5:0](
    .inVal({char5,char4,char3,char2,char1,char0}),
    .outVal({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0})
);

endmodule

