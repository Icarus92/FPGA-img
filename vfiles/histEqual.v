`timescale 1ns/1ns
module histEqual(
    input hist_clk,
    input reset,
    input equalize_ctrl,    //启动均衡匿
    input origin_hist_ctrl, //计算原图直方囿
    input eqlzed_hist_ctrl, //计算均衡后直方图
    input img_switch,
    input hist_switch,  //切换输出的直方图
    input [15:0]pixel_address,  //均衡后图片像素地坿
    input [7:0]hist_address,    //直方图亮庍
    output [7:0]pixel_value,
    output [15:0]hist_value,    //直方图高庿
    output [3:0]condition_led   //过程控制
);

    //用到除法噿,length应为2的幂
    parameter
    length = 17'd65536;

    //过程控制
    reg origin_hist_flag = 0;
    reg eqlzed_hist_flag = 0;
    reg equalize_flag1 = 0;
    reg equalize_flag2 = 0;
    assign condition_led[0] = origin_hist_flag;
    assign condition_led[1] = eqlzed_hist_flag;
    assign condition_led[2] = equalize_flag1;
    assign condition_led[3] = equalize_flag2;

    //存储噿
    reg [16:0]origin_hist_map[255:0];
    reg [16:0]eqlzed_hist_map[255:0];

    //积分图
    reg [16:0]cdf_hist_map[255:0];
    reg [16:0]cdf_min = 17'd0;

    //图像像素数据
    wire [8:0]rom_data;
    wire [8:0]eql_data;

     //计数变量
    reg [7:0]hist_count = 8'd0;
    reg [15:0]pixel_count = 16'd0;

    //输出
    wire [15:0]switch_address;
    assign calculating = (eqlzed_hist_flag||origin_hist_flag||equalize_flag1||equalize_flag2);
    assign switch_address = (calculating)? (pixel_count-1):pixel_address;

    assign pixel_value = (img_switch)? rom_data : eql_data;
    assign hist_value = (hist_switch)? origin_hist_map[hist_address][15:0]:eqlzed_hist_map[hist_address][15:0];

    //内存坿.
    reg [8:0]img_rom[length-1:0];
    assign rom_data = img_rom[switch_address];

    reg [8:0]eqlzed_img[length-1:0];
    assign eql_data = eqlzed_img[switch_address];

    ///////////////////////////
    integer f;
    integer j;
    initial begin
        for (j=0; j<65536; j=j+1) begin
            eqlzed_img[j] = 9'd0;
        end

        $readmemb("txtdata\\img1.txt",img_rom);
    end
    //////////////////////////


    integer i;
    always @(posedge hist_clk) begin
        if(reset) begin
            for(i=0;i<256;i=i+1) begin
                origin_hist_map[i] <= 12'd0;
                eqlzed_hist_map[i] <= 12'd0;
                cdf_hist_map[i] <= 12'd0;
            end
            cdf_min <= 17'd0;
        end
    end


    //弿始计算原图的直方囿
    always @(posedge hist_clk) begin
        if (origin_hist_ctrl)
            origin_hist_flag <= 1;
        if (origin_hist_flag && (pixel_count >= length-1)) begin
            origin_hist_flag <= 0;
            ///////////////////////////
            f = $fopen("txtdata\\img1_origin_hist.txt","w");
            for (i = 0; i<256; i=i+1) begin
                $fdisplay(f,"%d",$unsigned(origin_hist_map[i]));
            end
            $fclose(f);
            //////////////////////////////
        end
    end

    //弿始计算均衡后的直方图
    always @(posedge hist_clk) begin
        if (eqlzed_hist_ctrl)
            eqlzed_hist_flag <= 1;
        if (eqlzed_hist_flag && (pixel_count >= length-1)) begin
            eqlzed_hist_flag <= 0;
            ///////////////////////////
            f = $fopen("txtdata\\img1_eqlzed_hist.txt","w");
            for (i = 0; i<256; i=i+1) begin
                $fdisplay(f,"%d",$unsigned(eqlzed_hist_map[i]));
            end
            $fclose(f);
            //////////////////////////////
        end
    end

    //弿始均衡化
    always @(posedge hist_clk) begin
        if (equalize_ctrl)
            equalize_flag1 <= 1;
        if (equalize_flag1 &&(hist_count >= 8'd255)) begin
            equalize_flag1 <= 0;
            equalize_flag2 <= 1;
        end
        if (equalize_flag2 && (pixel_count >= length-1)) begin
            equalize_flag2 <= 0;
            ////////////////////////////
            f = $fopen("txtdata\\img1_eqlzed.txt","w");
            for (j=0;j<65536;j=j+1) begin
                $fdisplay(f,"%d",$unsigned(eqlzed_img[j]));
            end
            $fclose(f);
            //////////////////////////
        end
    end

    //直方图计数器
    always @(posedge hist_clk) begin
		if(equalize_flag1) begin
			if (hist_count < 8'd255)
				hist_count <= hist_count + 1;
			else
				hist_count <= 8'd0;
		end else begin
			hist_count <= 8'd0;
		end
    end

    //图像计数噿
    always @(posedge hist_clk) begin
		if (origin_hist_flag||eqlzed_hist_flag||equalize_flag2) begin
			if (pixel_count < length-1)
				pixel_count <= pixel_count + 1;
			else
				pixel_count <= 16'd0;
		end else begin
			pixel_count <= 16'd0;
		end
    end

    //直方图计箿
    always @(pixel_count) begin
        if(origin_hist_flag)
            origin_hist_map[rom_data] <= origin_hist_map[rom_data] + 1;
        if(eqlzed_hist_flag)
            eqlzed_hist_map[eql_data] <= eqlzed_hist_map[eql_data] + 1;
    end

    //直方图积刿
    always @(hist_count) begin
        if(equalize_flag1)
            if (hist_count == 8'd1)
                cdf_hist_map[hist_count-1] <= origin_hist_map[hist_count-1];
            else
                cdf_hist_map[hist_count-1] <= cdf_hist_map[hist_count-2] + origin_hist_map[hist_count-1];
            if ((cdf_min == 17'd0) && (hist_count > 8'd1))
                cdf_min <= cdf_hist_map[hist_count-2];
    end

    //图像映射/直方图均衿
    always @(pixel_count) begin
        if(equalize_flag2)
            eqlzed_img[switch_address] <= (cdf_hist_map[rom_data] - cdf_min) * 255 / length;
    end
endmodule