module inOutControl (
    clk,
    key0_debounce,
    key1_debounce,
    key0_pulse,
    key1_pulse,
    sw,
    memDone,
    read_data,
	 

    modeOutput, //hex
    memoryAddress, // memory
    write_data, // memory
    displayData, //hex
    ioDone,    //ioDone
	 out_state,
	 reset_out
);

    input   logic         clk;
    input   logic         key0_debounce;
    input   logic         key1_debounce;
    input   logic         key0_pulse;
    input   logic         key1_pulse;
    input   logic [8:0]   sw;
    input   logic         memDone;
    input   logic [15:0]  read_data;

    output  logic [1:0]   modeOutput;
    output  logic [24:0]  memoryAddress; // memory
    output  logic [15:0]  write_data; // memory
    output  logic [15:0]  displayData; //hex
    output  logic         ioDone;     //ioDone
    output  logic [12:0]  out_state;
	 output 	logic			  reset_out;

    logic [15:0] realDisplay;

        // Define STATES for execution
    typedef enum logic [12:0] {
        RESET =      13'b0000000000001,
	    IDLE = 	     13'b0000000000010,
        
        READ_ST0 =   13'b0000000000100,
        READ_ST1 =   13'b0000000001000,
        READ_ST2 =   13'b0000000010000,
        READ_WAIT =  13'b0000000100000,
        READ_DONE =  13'b0000001000000,

        WRITE_ST0 =  13'b0000010000000,
        WRITE_ST1 =  13'b0000100000000,
        WRITE_ST2 =  13'b0001000000000,
        WRITE_ST3 =  13'b0010000000000,
        WRITE_ST4 =  13'b0100000000000,
        WRITE_WAIT = 13'b1000000000000

	} io_statetype;

    io_statetype STATE;

    // ADVANCE NEXT STATE
    always_ff @(posedge clk)
    begin
        if(key0_debounce === 1'b1 && key1_debounce === 1'b1) begin
            STATE <= RESET;
		  end
        else 
        case(STATE)
            RESET: begin
                if(key0_pulse) begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
						  
                end
                else begin
                    STATE <= RESET;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
            end
            IDLE: begin
                if(key0_pulse) begin
                    STATE <= READ_ST0;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;						  
                end
                else begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
            end

            READ_ST0: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST0;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= READ_ST1;
                    memoryAddress [7:0] <= sw[7:0];
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= READ_ST0;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            READ_ST1: begin
                if(key0_pulse) begin
                    STATE <= READ_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= READ_ST2;
                    memoryAddress [15:8] <= sw[7:0];
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= READ_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            READ_ST2: begin
                if(key0_pulse) begin
                    STATE <= READ_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= READ_WAIT;
                    memoryAddress [24:16] <= sw[8:0];
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= READ_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            READ_WAIT: begin
                if(memDone) begin
                    STATE <= READ_DONE;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= read_data;
                end
                else begin
                    STATE <= READ_WAIT;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            READ_DONE: begin
                if(key0_pulse) begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= READ_DONE;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end

            WRITE_ST0: begin
                if(key0_pulse) begin
                    STATE <= READ_ST0;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST1;
                    memoryAddress [7:0] <= sw[7:0];
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= WRITE_ST0;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            WRITE_ST1: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST2;
                    memoryAddress [15:8] <= sw[7:0];
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= WRITE_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            WRITE_ST2: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST3;
                    memoryAddress [24:16] <= sw[8:0];
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= WRITE_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            WRITE_ST3: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST3;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST4;
                    memoryAddress <= memoryAddress;
                    write_data [7:0] <= sw[7:0];
                    displayData <= displayData;
                end
                else begin
                    STATE <= WRITE_ST3;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            WRITE_ST4: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST4;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_WAIT;
                    memoryAddress <= memoryAddress;
                    write_data [15:8] <= sw[7:0];
                    displayData <= displayData;
                end
                else begin
                    STATE <= WRITE_ST4;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end
            WRITE_WAIT: begin
                if(memDone) begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                    displayData <= displayData;
                end
                else begin
                    STATE <= WRITE_WAIT;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                    displayData <= displayData;
                end
            end

            default: begin
                STATE <= IDLE;
                memoryAddress <= 25'b0;
                write_data <= 16'b0;
                displayData <= displayData;
            end

        endcase
    end

    // combinational outputs
    always_comb
    begin
        case(STATE)
            RESET: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b00;
                reset_out <= 1'b1;
            end
            IDLE: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b00;
                reset_out <= 1'b0;
            end

            READ_ST0: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b01;
                reset_out <= 1'b0;
            end
            READ_ST1: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b01;
                reset_out <= 1'b0;
            end
            READ_ST2: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b01;
                reset_out <= 1'b0;
            end
            READ_WAIT: begin
                ioDone <= 1'b1;
                modeOutput <= 2'b01;
				reset_out <= 1'b0;
            end
            READ_DONE: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b00;
                reset_out <= 1'b0;
            end

            WRITE_ST0: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b10;
                reset_out <= 1'b0;
            end
            WRITE_ST1: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b10;
                reset_out <= 1'b0;
            end
            WRITE_ST2: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b10;
                reset_out <= 1'b0;
            end
            WRITE_ST3: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b10;
                reset_out <= 1'b0;
            end
            WRITE_ST4: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b10;
                reset_out <= 1'b0;
            end
            WRITE_WAIT: begin
                modeOutput <= 2'b10;
                reset_out <= 1'b0;
                ioDone <= 1'b1;
            end

            default: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b00;
                reset_out <= 1'b0;
            end

        endcase
    end

    //assign displayData = displayData;
    assign out_state = STATE;


endmodule