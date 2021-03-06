/**
* File: memory_controller.sv

* Description: Contains the state machine and timing solutions necessary
* to interface with the SDRAM chip on a DE10-Lite evaluation board. Known commands
* include READ and WRITE
*
* Author: Alex Spaulding
* Date: April 8, 2022
* Contributors: Will McCormick, Juan Tarat, Ethan Alexander
**/


module memory_controller(
    clk,
    cmd,
    addr,
    wr_dq,
    rd_dq,
    ready,
    rst,
    valid,

    DRAM_ADDR,
    DRAM_BA,
    DRAM_DQ,

    DRAM_LDQM,
    DRAM_UDQM,
    DRAM_RAS_N,
    DRAM_CAS_N,
    DRAM_CKE,
    DRAM_CLK,
    DRAM_WE_N,
    DRAM_CS_N);

    input logic clk;
    input logic [1:0] cmd;
    input logic [24:0] addr;
    input logic [15:0] wr_dq;
    input logic ready;
    input logic rst;


    output logic valid;
        output logic [15:0] rd_dq;
    /** Interface to SDRAM CHIP **/

    // Address/Data
    output logic [12:0] DRAM_ADDR;
    output logic [1:0] DRAM_BA;
    inout logic [15:0] DRAM_DQ;

    // Command/Control
    output logic DRAM_LDQM;
    output logic DRAM_UDQM;
    output logic DRAM_RAS_N;
    output logic DRAM_CAS_N;
    output logic DRAM_CKE;
    output logic DRAM_CLK;
    output logic DRAM_WE_N;
    output logic DRAM_CS_N;

    // Autorefresh counter
    logic [6:0] refresh_count;

    // Define STATES for execution
    typedef enum logic [30:0] {
        RESET =  	        31'b0000000000000000000000000000001,
        RESET_NOP0 =            31'b0000000000000000000000000000010,
        RESET_PRECHARGE =       31'b0000000000000000000000000000100,
        RESET_NOP1 =            31'b0000000000000000000000000001000,
        RESET_REF0 =            31'b0000000000000000000000000010000,
        RESET_NOP2 =            31'b0000000000000000000000000100000,
        RESET_NOP3 =            31'b0000000000000000000000001000000,
        RESET_REF1 =            31'b0000000000000000000000010000000,
        RESET_NOP4 =            31'b0000000000000000000000100000000,
        RESET_NOP5 =            31'b0000000000000000000001000000000,
        RESET_LOAD =            31'b0000000000000000000010000000000,
        RESET_NOP6 =            31'b0000000000000000000100000000000,
        READ_INITIAL =          31'b0000000000000000001000000000000,
        READ_ACTIVE =           31'b0000000000000000010000000000000,
        READ_CMD =              31'b0000000000000000100000000000000,
        READ_NOP =              31'b0000000000000001000000000000000,
        READ_DATA =             31'b0000000000000010000000000000000,
        WRITE_INITIAL =         31'b0000000000000100000000000000000,
        WRITE_ACTIVE =          31'b0000000000001000000000000000000,
        WRITE_CMD =             31'b0000000000010000000000000000000,
        WRITE_NOP =             31'b0000000000100000000000000000000,
        REFRESH_INITIAL =       31'b0000000001000000000000000000000,
        REFRESH_PRECHARGE =     31'b0000000010000000000000000000000,
        REFRESH_NOP0 =          31'b0000000100000000000000000000000,
        REFRESH_AUTO =          31'b0000001000000000000000000000000,
        REFRESH_NOP1 =          31'b0000010000000000000000000000000,
        REFRESH_NOP2 =          31'b0000100000000000000000000000000,
        REFRESH_AUTO2 =         31'b0001000000000000000000000000000,
        REFRESH_NOP3    =       31'b0010000000000000000000000000000,
        REFRESH_IDLE =          31'b0100000000000000000000000000000,
        IDLE =                  31'b1000000000000000000000000000000

	} statetype;

    statetype STATE, NEXT_STATE;

    // Advance states
    always_ff @(posedge clk)
    begin
        if(rst) 
        begin
            STATE <= RESET;
        end
        else
        begin
            if(STATE == IDLE)
                refresh_count <= refresh_count - 1;
            else
                refresh_count <= 7'd127;
                
            STATE <= NEXT_STATE;
        end
    end

    // Next state logic, directly from state machine
    always_comb /*@(/*STATE, ready, cmd)*/
    begin
        case(STATE)
            RESET:              NEXT_STATE <= RESET_NOP0;
            RESET_NOP0:         NEXT_STATE <= RESET_PRECHARGE;
            RESET_PRECHARGE:    NEXT_STATE <= RESET_NOP1;
            RESET_NOP1 :        NEXT_STATE <= RESET_REF0;
            RESET_REF0:         NEXT_STATE <= RESET_NOP2;
            RESET_NOP2:         NEXT_STATE <= RESET_NOP3;
            RESET_NOP3:         NEXT_STATE <= RESET_REF1;
            RESET_REF1:         NEXT_STATE <= RESET_NOP4;
            RESET_NOP4:         NEXT_STATE <= RESET_NOP5;
            RESET_NOP5:         NEXT_STATE <= RESET_LOAD;
            RESET_LOAD:         NEXT_STATE <= RESET_NOP6;
            RESET_NOP6:         NEXT_STATE <= IDLE;

            READ_INITIAL:       NEXT_STATE <= READ_ACTIVE;
            READ_ACTIVE:        NEXT_STATE <= READ_CMD;
            READ_CMD:           NEXT_STATE <= READ_NOP;
            READ_NOP:           NEXT_STATE <= READ_DATA;
            READ_DATA:          NEXT_STATE <= IDLE;

            WRITE_INITIAL:      NEXT_STATE <= WRITE_ACTIVE;
            WRITE_ACTIVE:       NEXT_STATE <= WRITE_CMD;
            WRITE_CMD:          NEXT_STATE <= WRITE_NOP;
            WRITE_NOP:          NEXT_STATE <= IDLE;

            REFRESH_INITIAL:    NEXT_STATE <= REFRESH_PRECHARGE;
            REFRESH_PRECHARGE:  NEXT_STATE <= REFRESH_NOP0;
            REFRESH_NOP0:       NEXT_STATE <= REFRESH_AUTO;
            REFRESH_AUTO:       NEXT_STATE <= REFRESH_NOP1;
            REFRESH_NOP1:       NEXT_STATE <= REFRESH_NOP2;
            REFRESH_NOP2:       NEXT_STATE <= REFRESH_AUTO2;
            REFRESH_AUTO2:      NEXT_STATE <= REFRESH_NOP3;
            REFRESH_NOP3:       NEXT_STATE <= REFRESH_IDLE;
            REFRESH_IDLE:       NEXT_STATE <= IDLE;

            // IDLE has branches based on commands
            IDLE: begin
                // issue READ command
                if(ready)
                begin
                    NEXT_STATE <= cmd == 2'b10 ? WRITE_INITIAL : READ_INITIAL;
                end
                // check for refresh
                else if (refresh_count == 0)
                begin
                    NEXT_STATE <= REFRESH_INITIAL;
                end
                // continue to idle
                else 
                begin
                    NEXT_STATE <= IDLE;
                end
            end

        endcase
    end

    // Apply control signals and read data
    always_comb /*@(/**)*/
    begin
        case(STATE)
                RESET: begin // NOP
                        DRAM_CKE <= 1'b1;
                        DRAM_CS_N <= 1'b0;
                        DRAM_RAS_N <= 1'b1;
                        DRAM_CAS_N <= 1'b1;
                        DRAM_WE_N <= 1'b1;
                        DRAM_LDQM <= 1'b1;
                        DRAM_UDQM <= 1'b1;

                        DRAM_BA <= 2'b00;
                        DRAM_ADDR <= 13'b00;

                        valid <= 1'b0;
            end

                RESET_NOP0: begin
                        DRAM_CKE <= 1'b1;
                        DRAM_CS_N <= 1'b0;
                        DRAM_RAS_N <= 1'b1;
                        DRAM_CAS_N <= 1'b1;
                        DRAM_WE_N <= 1'b1;
                        DRAM_LDQM <= 1'b1;
                        DRAM_UDQM <= 1'b1;

                        DRAM_BA <= 2'b00;
                        DRAM_ADDR <= 13'b00;

                        valid <= 1'b0;
                end

                RESET_PRECHARGE: begin
                        DRAM_CKE <= 1'b1;
                        DRAM_CS_N <= 1'b0;
                        DRAM_RAS_N <= 1'b0;
                        DRAM_CAS_N <= 1'b1;
                        DRAM_WE_N <= 1'b0;
                        DRAM_LDQM <= 1'b1;
                        DRAM_UDQM <= 1'b1;

                        DRAM_BA <= 2'b00;
                        DRAM_ADDR <= {2'b00, 1'b1, 10'b0};

                        valid <= 1'b0;
                end

            RESET_NOP1: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            RESET_REF0: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
                
            end

            RESET_NOP2: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            RESET_NOP3: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            RESET_REF1: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            RESET_NOP4: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

                RESET_NOP5: begin
                        DRAM_CKE <= 1'b1;
                        DRAM_CS_N <= 1'b0;
                        DRAM_RAS_N <= 1'b1;
                        DRAM_CAS_N <= 1'b1;
                        DRAM_WE_N <= 1'b1;
                        DRAM_LDQM <= 1'b1;
                        DRAM_UDQM <= 1'b1;

                        DRAM_BA <= 2'b00;
                        DRAM_ADDR <= 13'b00;

                        valid <= 1'b0;
                end

            RESET_LOAD: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b0;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b0001000101000;

                    valid <= 1'b0;
            end

            RESET_NOP6: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b1;
            end


            READ_INITIAL: begin // NOP
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            READ_ACTIVE: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= addr[24:23];
                    DRAM_ADDR <= addr[22:10];

                    valid <= 1'b0;
            end

            READ_CMD: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= addr[24:23];
                    DRAM_ADDR <= {addr[12:11], 1'b1, addr[9:0]};

                    valid <= 1'b0;
            end

            READ_NOP: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            READ_DATA: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b1;
            end

            WRITE_INITIAL: begin // NOP
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            WRITE_ACTIVE: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= addr[24:23];
                    DRAM_ADDR <= addr[22:10];

                    valid <= 1'b0;
            end

            WRITE_CMD: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b0;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= addr[24:23];
                    DRAM_ADDR <= {addr[12:11], 1'b1, addr[9:0]};

                    valid <= 1'b0;
            end

            WRITE_NOP: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;


                    valid <= 1'b1;
            end

            REFRESH_INITIAL: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b0;
                    DRAM_UDQM <= 1'b0;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            REFRESH_PRECHARGE: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b0;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= {2'b00, 1'b1, 10'b0};

                    valid <= 1'b0;
            end

            REFRESH_NOP0: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;


                    valid <= 1'b0;
            end

            REFRESH_AUTO: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            REFRESH_NOP1: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;


                    valid <= 1'b0;
            end

            REFRESH_NOP2: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;


                    valid <= 1'b0;
            end

            REFRESH_AUTO2: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b0;
                    DRAM_CAS_N <= 1'b0;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;

                    valid <= 1'b0;
            end

            REFRESH_NOP3: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;


                    valid <= 1'b0;
            end

            REFRESH_IDLE: begin
                    DRAM_CKE <= 1'b1;
                    DRAM_CS_N <= 1'b0;
                    DRAM_RAS_N <= 1'b1;
                    DRAM_CAS_N <= 1'b1;
                    DRAM_WE_N <= 1'b1;
                    DRAM_LDQM <= 1'b1;
                    DRAM_UDQM <= 1'b1;

                    DRAM_BA <= 2'b00;
                    DRAM_ADDR <= 13'b00;


                    valid <= 1'b0;
            end

            // THIS MAY NEED TO BE CHANGED -- self refresh?
                IDLE: begin // NOP
                        DRAM_CKE <= 1'b1;
                        DRAM_CS_N <= 1'b0;
                        DRAM_RAS_N <= 1'b1;
                        DRAM_CAS_N <= 1'b1;
                        DRAM_WE_N <= 1'b1;
                        DRAM_LDQM <= 1'b1;
                        DRAM_UDQM <= 1'b1;

                        DRAM_BA <= 2'b00;
                        DRAM_ADDR <= 13'b00;


                        valid <= 1'b0;
                end

        endcase
    end

    // inout assignments
    //assign dq[15:0] =       cmd == 2'b01 ? DRAM_DQ[15:0] : 15'bz;
    //assign DRAM_DQ[15:0] =  cmd == 2'b01 ? 16'bz : dq[15:0];
    //assign DRAM_DQ[15:0] = cmd == 2'b01 ?   16'bz : dq[15:0];

    
        assign DRAM_DQ = cmd == 2'b01 ? {16{1'bz}} : wr_dq;
        assign rd_dq = DRAM_DQ;     
    
	 


    //when cmd is read DQ_DRAM will take high impedancce     

    // Static assignments
    assign DRAM_CLK = clk;   // Tie DRAM clock to memory controller clock
    // assign DRAM_BA[1:0] = addr[24:23];

endmodule 