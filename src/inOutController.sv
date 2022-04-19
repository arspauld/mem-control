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
    output  logic [11:0]  out_state;
	 output 	logic			  reset_out;

        // Define STATES for execution
    typedef enum logic [11:0] {
	    IDLE = 	     12'b000000000001,
        
        READ_ST0 =   12'b000000000010,
        READ_ST1 =   12'b000000000100,
        READ_ST2 =   12'b000000001000,
        READ_WAIT =  12'b000000010000,
        READ_DONE =  12'b000000100000,

        WRITE_ST0 =  12'b000001000000,
        WRITE_ST1 =  12'b000010000000,
        WRITE_ST2 =  12'b000100000000,
        WRITE_ST3 =  12'b001000000000,
        WRITE_ST4 =  12'b010000000000,
        WRITE_WAIT = 12'b100000000000

	} io_statetype;

    io_statetype STATE;

    // ADVANCE NEXT STATE
    always_ff @(posedge clk)
    begin
        if(key0_debounce == 1'b1 && key1_debounce == 1'b1) begin
            STATE <= IDLE;
		  end
        else 
        case(STATE)
            IDLE: begin
                if(key0_pulse) begin
                    STATE <= READ_ST0;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
						  
                end
                else begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                end
            end

            READ_ST0: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST0;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                end
                else if(key1_pulse) begin
                    STATE <= READ_ST1;
                    memoryAddress [7:0] <= sw[7:0];
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= READ_ST0;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            READ_ST1: begin
                if(key0_pulse) begin
                    STATE <= READ_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
                else if(key1_pulse) begin
                    STATE <= READ_ST2;
                    memoryAddress [15:8] <= sw[7:0];
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= READ_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            READ_ST2: begin
                if(key0_pulse) begin
                    STATE <= READ_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
                else if(key1_pulse) begin
                    STATE <= READ_WAIT;
                    memoryAddress [24:16] <= sw[8:0];
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= READ_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            READ_WAIT: begin
                if(memDone) begin
                    STATE <= READ_DONE;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
                else begin
                    STATE <= READ_WAIT;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            READ_DONE: begin
                if(key0_pulse) begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= READ_DONE;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end

            WRITE_ST0: begin
                if(key0_pulse) begin
                    STATE <= READ_ST0;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST1;
                    memoryAddress [7:0] <= sw[7:0];
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= WRITE_ST0;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            WRITE_ST1: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= 16'b0;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST2;
                    memoryAddress [15:8] <= sw[7:0];
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= WRITE_ST1;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            WRITE_ST2: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= 16'b0;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST3;
                    memoryAddress [24:16] <= sw[8:0];
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= WRITE_ST2;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            WRITE_ST3: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST3;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_ST4;
                    memoryAddress <= memoryAddress;
                    write_data [7:0] <= sw[7:0];
                end
                else begin
                    STATE <= WRITE_ST3;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            WRITE_ST4: begin
                if(key0_pulse) begin
                    STATE <= WRITE_ST4;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
                else if(key1_pulse) begin
                    STATE <= WRITE_WAIT;
                    memoryAddress <= memoryAddress;
                    write_data [15:8] <= sw[7:0];
                end
                else begin
                    STATE <= WRITE_ST4;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end
            WRITE_WAIT: begin
                if(memDone) begin
                    STATE <= IDLE;
                    memoryAddress <= 25'b0;
                    write_data <= 16'b0;
                end
                else begin
                    STATE <= WRITE_WAIT;
                    memoryAddress <= memoryAddress;
                    write_data <= write_data;
                end
            end

            default: begin
                STATE <= IDLE;
                memoryAddress <= 25'b0;
                write_data <= 16'b0;
            end

        endcase
    end

    // combinational outputs
    always_comb
    begin
        case(STATE)
            IDLE: begin
                ioDone <= 1'b0;
                modeOutput <= 2'b00;
					 reset_out <= 1'b1;
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

    assign displayData = read_data;
    assign out_state = STATE;


endmodule