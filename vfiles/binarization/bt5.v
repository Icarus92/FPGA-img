module binarization_tb();

    localparam PERIOD=10;
    reg clk = 0;
    reg int_ctrl = 0;
    reg bin_ctrl = 0;
    wire [1:0]condition_led;

    reg [7:0]thres_length = 8'd5;


    binarization bin1(
        .bin_clk(clk),
        .int_ctrl(int_ctrl),
        .bin_ctrl(bin_ctrl),
        .thres_length(thres_length),
        .pixel_address(),
        .bin_data(),
        .condition_led()
    );

    initial begin
        #(PERIOD/2);
        forever
            #(PERIOD/2) clk=~clk;
    end

    initial begin
		$dumpfile("lxtwave\\bin.lxt");
		$dumpvars(0,bin1);

        #(PERIOD*10);

        int_ctrl = 1;
        #(PERIOD*10);
        int_ctrl = 0;

        #(PERIOD*70000);

        bin_ctrl = 1;
        #(PERIOD*10);
        bin_ctrl = 0;

        #(PERIOD*70000);

        $finish();
    end


endmodule