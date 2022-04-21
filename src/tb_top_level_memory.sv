/**
* File: memory_controller_tb.sv

* Description: Contains the testbench for a module designed to
* interface with the SDRAM on a DE10-Lite evaluation board
*
* Author: Alex 
* Date: April 8, 2022
* Contributors: Will McCormick, Juan Tarat, Ethan Alexander
**/

/*
* MEMORY_CONTROLLER:
*
* @clk - clock signal, 50MHz rising edge
* @cmd [1:0] - ONE HOT command mode: (2'b10 = WRITE) (2'b01 = READ) 
* @addr [24:0] - 25 bit address for the 512Mb memory
* @dq [15:0] - 16 bit data line
* @ready - flags that the input lines are driven to identify a command
* @rst - synchronous reset
* @valid - flags that the command has finished and data is valid
*
*/



module top_level_memory_controller_tb;
    timeunit 1ns;
    timeprecision 100ps;
    realtime delay=10ns;
    //INPUTS
    bit             clk;
    logic           key0;
    logic           key1;
    logic           key0_debounce;
    logic           key1_debounce;
    logic   [8:0]   switches;
    logic   [1:0]   modeOutput;
    logic   [1:0]   cmd;
    logic   [24:0]  addr;
    wire	[15:0]	dq;	//goes into the controller
    logic	[15:0]	dq_data;

    logic           ready;
    logic           rst;
    logic           valid;

    
    /** Interface to SDRAM CHIP **/
    // Address/Data
    logic [12:0] DRAM_ADDR;
    logic [1:0] DRAM_BA;
    wire [15:0] DRAM_DQ;

    // Command/Control
    logic DRAM_LDQM;
    logic DRAM_UDQM;
    logic DRAM_RAS_N;
    logic DRAM_CAS_N;
    logic DRAM_CKE;
    logic DRAM_CLK;
    logic DRAM_WE_N;
    logic DRAM_CS_N;

// test RESET, WRITE, READ

    initial begin
        switches <= 9'b000000011;
        #21;
        // submit reset command
        {key0_debounce,key1_debounce} <= 2'b11; #21 {key0_debounce,key1_debounce} <= 2'b00;
        key0 <= 0; key1 <= 0;
        // IDLE
        #21 key0 <= 1; #21 key0 <= 0;
        #200;
        // Read ..
        #21 key0 <= 1; #21 key0 <= 0;
        // Rite ..
        #21 key0 <= 1; #21 key0 <= 0;


        // this is write
        // Select rite mode
        #21 key1 <= 1; #21 key1 <= 0;
        // rite_L
        #21 key1 <= 1; #21 key1 <= 0;
        // rite_U
        #21 key1 <= 1; #21 key1 <= 0;
        // data_L
        #21 key1 <= 1; #21 key1 <= 0;
        // data_U
        #21 key1 <= 1; #21 key1 <= 0;
        // back in Idle
        #200;

        // this is read
        // Read ..
        #21 key0 <= 1; #21 key0 <= 0;
        // Select read mode
        #21 key1 <= 1; #21 key1 <= 0;
        // read_L
        #21 key1 <= 1; #21 key1 <= 0;
        // read_U
        #21 key1 <= 1; #21 key1 <= 0;
        // display read value
        #400;
        // return to idle
        #21 key0 <= 1; #21 key0 <= 0;
        #500;


    end
   
    always begin
        #delay clk=~clk;
    end


    inOutControl ioControl(
        .clk            (clk),
        .key0_debounce  (key0_debounce),
        .key1_debounce  (key1_debounce),
        .key0_pulse     (key0),
        .key1_pulse     (key1),
        .sw             (switches),
        .memDone        (valid),
        .read_data      (dq),
	 
        .modeOutput     (cmd), //mem
        .memoryAddress  (addr), // memory
        .write_data     (dq_data), // memory
        .ioDone         (ready),    //ioDone
	    .reset_out      (rst)
    );

    memory_controller uut (
        .clk(clk),
        .cmd(cmd),
        .addr(addr),
        .rd_dq(dq),
        .wr_dq(dq_data),
        .ready(ready),
        
        .rst(rst),
        .valid(valid),

        .DRAM_ADDR(DRAM_ADDR),
        .DRAM_BA(DRAM_BA),
        .DRAM_DQ(DRAM_DQ),

        .DRAM_LDQM(DRAM_LDQM),
        .DRAM_UDQM(DRAM_UDQM),
        .DRAM_RAS_N(DRAM_RAS_N),
        .DRAM_CAS_N(DRAM_CAS_N),
        .DRAM_CKE(DRAM_CKE),
        .DRAM_CLK(DRAM_CLK),
        .DRAM_WE_N(DRAM_WE_N),
        .DRAM_CS_N(DRAM_CS_N)
    );

    mt48lc32m16a2 memory(
		.Dq		(DRAM_DQ),
		.Addr	(DRAM_ADDR),
		.Ba		(DRAM_BA),
		.Clk	(DRAM_CLK),
		.Cke	(DRAM_CKE),
		.Cs_n	(DRAM_CS_N),
		.Ras_n	(DRAM_RAS_N),
		.Cas_n	(DRAM_CAS_N),
		.We_n	(DRAM_WE_N),
		.Dqm    ({DRAM_UDQM, DRAM_LDQM})
	);

endmodule