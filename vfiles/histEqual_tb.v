`timescale 1ns/1ns
module histEqual_tb();

    localparam PERIOD=10;
    reg clk = 0;
    reg reset = 0;
    reg equalize_ctrl = 0;
    reg origin_hist_ctrl = 0;
    reg eqlzed_hist_ctrl = 0;
    wire [3:0]condition_led;

    histEqual h1(
        .hist_clk(clk),
        .reset(reset),
        .equalize_ctrl(equalize_ctrl),
        .origin_hist_ctrl(origin_hist_ctrl),
        .eqlzed_hist_ctrl(eqlzed_hist_ctrl),
        .hist_switch(),
        .pixel_address(),
        .hist_address(),
        .pixel_value(),
        .hist_value(),
        .condition_led(condition_led)
    );

    initial begin
        #(PERIOD/2);
        forever
            #(PERIOD/2) clk=~clk;
    end

    initial begin
		$dumpfile("lxtwave\\hist.lxt");
		$dumpvars(0,h1);

        #(PERIOD*10);

        reset = 1;
        #(PERIOD*10);
        reset = 0;

        #(PERIOD*10);

        origin_hist_ctrl = 1;
        #(PERIOD*10);
        origin_hist_ctrl = 0;

        #(PERIOD*66000);

        equalize_ctrl = 1;
        #(PERIOD*10);
        equalize_ctrl = 0;

        #(PERIOD * 67000);

        eqlzed_hist_ctrl = 1;
        #(PERIOD*10);
        eqlzed_hist_ctrl = 0;

        #(PERIOD*66000);


        $finish();
    end


endmodule