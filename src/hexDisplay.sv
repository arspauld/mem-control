// state 1: print clear = 2'b00
// state 2: print read = 2'b01
// state 3: print rlte = 2'b10

module hexDisplay (
    input   [12:0]  state,     
    input   [15:0]  inVal,
    
    output  [7:0]   HEX0,
    output  [7:0]   HEX1,
    output  [7:0]   HEX2,
    output  [7:0]   HEX3,
    output  [7:0]   HEX4,
    output  [7:0]   HEX5              
);

reg [4:0] char0;
reg [4:0] char1;
reg [4:0] char2;
reg [4:0] char3;
reg [4:0] char4;
reg [4:0] char5;

localparam CHAR_R = 5'd16;
localparam CHAR_E = 5'd14;
localparam CHAR_A = 5'd10;
localparam CHAR_D = 5'd17;
localparam CHAR_T = 5'd18;  
localparam CHAR_C = 5'd12;
localparam CHAR_  = 5'd19;
localparam CHAR_DASH = 5'd20;
localparam CHAR_N = 5'd21;
localparam CHAR_DOT = 5'd22;
localparam CHAR_L = 5'd23;
localparam CHAR_U = 5'd24;
localparam BLANK = 5'd25;

// Define STATES for execution

localparam RESET        =   13'b0000000000001;
localparam IDLE         =   13'b0000000000010;
localparam READ_ST0     =   13'b0000000000100;
localparam READ_ST1     =   13'b0000000001000;
localparam READ_ST2     =   13'b0000000010000;
localparam READ_WAIT    =   13'b0000000100000;
localparam READ_DONE    =   13'b0000001000000;
localparam WRITE_ST0    =   13'b0000010000000;
localparam WRITE_ST1    =   13'b0000100000000;
localparam WRITE_ST2    =   13'b0001000000000;
localparam WRITE_ST3    =   13'b0010000000000;
localparam WRITE_ST4    =   13'b0100000000000;
localparam WRITE_WAIT   =   13'b1000000000000;

always_comb begin  
    case (state)
        RESET : begin
            {char5,char4,char3,char2,char1,char0} = {5'd1, CHAR_N, 5'd1, CHAR_T, BLANK, BLANK};
			end
        IDLE : begin
            {char5,char4,char3,char2,char1,char0} = {5'd1,CHAR_D,CHAR_L,CHAR_E,BLANK,BLANK};
        end

        READ_ST0 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,CHAR_E,CHAR_A,CHAR_D,CHAR_DOT,CHAR_DOT};
        end

        READ_ST1 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,CHAR_E,CHAR_A,CHAR_D,CHAR_,CHAR_L};
        end

        READ_ST2 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,CHAR_E,CHAR_A,CHAR_D,CHAR_,CHAR_U};
        end

        READ_WAIT : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,CHAR_E,CHAR_A,CHAR_D,CHAR_,CHAR_DASH};
        end

        READ_DONE : begin
            {char5,char4,char3,char2,char1,char0} = {BLANK,BLANK,1'b0,inVal[15:12],1'b0,inVal[11:8],1'b0,inVal[7:4],1'b0,inVal[3:0]};
        end

        WRITE_ST0 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,5'd1,CHAR_T,CHAR_E,CHAR_DOT,CHAR_DOT};
        end

        WRITE_ST1 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,5'd1,CHAR_T,CHAR_E,CHAR_,CHAR_L};
        end

        WRITE_ST2 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,5'd1,CHAR_T,CHAR_E,CHAR_,CHAR_U};
        end

        WRITE_ST3 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_D,CHAR_A,CHAR_T,CHAR_A,CHAR_,CHAR_L};
        end
		  
		WRITE_ST4 : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_D,CHAR_A,CHAR_T,CHAR_A,CHAR_,CHAR_U};
        end

        WRITE_WAIT : begin
            {char5,char4,char3,char2,char1,char0} = {CHAR_R,5'd1,CHAR_T,CHAR_E,CHAR_,CHAR_DASH};
        end

        default : begin
            {char5,char4,char3,char2,char1,char0} = {BLANK, BLANK, BLANK, BLANK, BLANK, BLANK};
		  end

    endcase
end
        
hexDriver displayRes [5:0](
    .inVal({char5,char4,char3,char2,char1,char0}),
    .outVal({HEX5,HEX4,HEX3,HEX2,HEX1,HEX0})
);

endmodule

