`timescale 1 ns / 1 ns

module SCIC_tb();
    wire [3:0] LEDs;

    reg reset, clock;
    reg [3:0] switches;

    // UUT = Unit Under Test
    SCIC UUT(LEDs, switches, reset, clock);

    initial begin
        reset <= 1'b1;
        clock <= 1'b0;
        switches <= 4'b0000;

        // This dumps state to VCD file that can be used to view simulation results
        $dumpfile("SCIC.vcd");
        $dumpvars(0, SCIC_tb);

        forever begin
            // 5ns = 1/2 * period for 100MHz clock
            #5 clock <= ~clock;
        end
    end

    // General testbench that does not rely on changing switches
    initial begin
         #7 reset <= 1'b0;
         #10000 $finish();
     end

/*
    // Test bench used for read_and_write_io program
    initial begin
        #7 reset <= 1'b0;
        #13 switches <= 4'b0001;
        // First switch value is loaded at 25ns
        // Takes 60ns for next switch value to be loaded
        #60 switches <= 4'b0010;
        #60 switches <= 4'b0011;
        #60 switches <= 4'b0100;
        #60 switches <= 4'b0101;
        #60 switches <= 4'b0110;
        #60 switches <= 4'b0111;
        #60 switches <= 4'b1000;
        #60 switches <= 4'b1001;
        #60 switches <= 4'b1010;
        #60 switches <= 4'b1011;
        #60 switches <= 4'b1100;
        #60 switches <= 4'b1101;
        #60 switches <= 4'b1110;
        #60 switches <= 4'b1111;
        #1000 $finish();
    end
*/

// SDF annotate.

initial begin
	$sdf_annotate("/home/campus/dashbau/cds/ece484/sim_dir/sdf/SCIC_syn.sdf",UUT, , ,"MAXIMUM");
end

endmodule