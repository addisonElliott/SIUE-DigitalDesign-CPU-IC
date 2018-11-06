`timescale 1 ns / 1 ns

module system_tb();
    wire [3:0] LEDs;

    reg reset, clock;
    reg [3:0] switches;

    // UUT = Unit Under Test
    system UUT(LEDs, switches, reset, clock);

    initial begin
        reset <= 1'b1;
        clock <= 1'b0;
        switches <= 4'b0000;

        // This dumps state to VCD file that can be used to view simulation results
        $dumpfile("system.vcd");
        $dumpvars(0, system_tb);

        forever begin
            // 5ns = 1/2 * period for 100MHz clock
            #5 clock <= ~clock;
        end
    end

    // TODO: Write a better testbench when a good program is entered into the module
    initial begin
        #7 reset <= 1'b0;
        #200 $finish();
    end
endmodule
