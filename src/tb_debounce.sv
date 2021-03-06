// Testbench 
`timescale 1ns/100 ps

module tb_debounce;

   logic sig_in=0, clk=0;
   wire sig_out;

   initial
      begin

      sig_in <= 0; 
      #100 

      sig_in <= 1;              
      #100 

      sig_in <= 0;      
      #500 
      
      sig_in <= 1;
      #500 
      
      sig_in <= 0;
      #1000 
      
      sig_in <= 1;
      #1000 
      
      sig_in <= 0;
      #5000 
      
      sig_in <= 1;
      #100000 
      
      sig_in <= 0;
      #50000
      
      sig_in <= 1;
      #5000
      
      sig_in <= 0;

      end

   // set up a free running clock with period 10 ns
   always
      begin
      clk = #1 ~clk;
      end

        
   // instantiate the debouncer as the unit under test (uut)
   debounce #(.DWELL_CNT(49999)) uut(.sig_in(sig_in), .clk(clk), .sig_out(sig_out)); 

endmodule