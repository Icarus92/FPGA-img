module binarization(
    input bin_clk,
    input int_ctrl,
    input bin_ctrl,
    input [7:0]thres_length,
    input [15:0]pixel_address,
    output bin_data,
    output [1:0]condition_led
);

    integer i,j,f;

    parameter
    width = 9'd256,
    height = 9'd256,
    length = 17'd65536;

    //过程控制的变量
    reg int_flag = 0;
    reg bin_flag = 0;
    reg [7:0]line_count = 8'd0;
    reg [7:0]row_count = 8'd0;
    wire [7:0]line;
    wire [7:0]row;
    assign line = line_count;
    assign row = row_count;
    assign condition_led[0] = int_flag;
    assign condition_led[1] = bin_flag;

    //连接rom中图片的变量
    wire [15:0]pixel_count;
    assign pixel_count = line * width + row;
    wire [8:0]rom_data;

    //积分表
    reg [24:0]int_map[255:0][255:0];

    //存储和输出二值化结果
    reg bin_map[length-1:0];
    assign bin_data = bin_map[pixel_address];
    ///////////////////////////////////////
    initial begin
        for (i = 0; i<height; i=i+1) begin
            for (j = 0; j<width; j=j+1) begin
                int_map[j][i] = 25'd0;
            end
        end
        for (i = 0; i<length; i=i+1) begin
            bin_map[i] = 0;
        end
    end
    //////////////////////////////////////////

    //内存块
    reg [8:0]img_rom[length-1:0];
    assign rom_data = img_rom[pixel_count];
    ///////////////////////////
    initial begin
        $readmemb("txtdata\\img1b.txt",img_rom);
    end
    //////////////////////////


    //启动积分
    always @(posedge bin_clk) begin
        if (int_ctrl)
            int_flag <= 1;
        if (int_flag && (line_count >= height-1) && (row_count >= width-1))
            int_flag <= 0;
    end

    //启动二值化
    always @(posedge bin_clk) begin
        if (bin_ctrl)
            bin_flag <= 1;
        if (bin_flag && (line_count >= height-1) && (row_count >= width-1)) begin
            bin_flag <= 0;
            ////////////////////////////
            f = $fopen("txtdata\\img1_bin80.txt","w");
            for (j=0;j<65536;j=j+1) begin
                $fdisplay(f,"%d",$unsigned(bin_map[j]));
            end
            $fclose(f);
            //////////////////////////
        end
    end

    //行列计数器
    always @(posedge bin_clk) begin
        if (bin_flag||int_flag) begin
            if (row_count < width-1)
                row_count <= row_count + 1;
            else begin
                row_count <= 8'd0;
                if (line_count < height-1)
                    line_count <= line_count + 1;
                else begin
                    line_count <= 8'd0;
                end
            end
        end else begin
            row_count <=8'd0;
            line_count <=8'd0;
        end
    end

    //图像积分
    always @(row_count) begin
        if (line == 8'd0) begin
            if (row == 8'd0)
                int_map[line][row] <= rom_data;
            else
                int_map[line][row] <= int_map[line][row-1] + rom_data;
        end else begin
            if (row == 8'd0)
                int_map[line][row] <= int_map[line-1][row] + rom_data;
            else
                int_map[line][row] <= int_map[line][row-1] + int_map[line-1][row] - int_map[line-1][row-1] + rom_data;
        end
    end


    //自适应区域的大小
    reg [15:0]thres_size = 16'd9;
    //四角的阈值缓存
    reg [24:0]thres_temp[3:0];
    //当前[line,row]位置在图片中的区域
    wire [3:0]thres_area;
    assign thres_area[3] = row > thres_length;
    assign thres_area[2] = row < width - thres_length;
    assign thres_area[1] = line > thres_length;
    assign thres_area[0] = line < height - thres_length;
    //按行列顺序计算阈值逐点二值化
    always @(row_count) begin
        case (thres_area)
            4'b1111:
                begin
                    thres_size <= (2 * thres_length + 1) * (2 * thres_length + 1);
                    thres_temp[0] <= int_map[line + thres_length][row + thres_length];
                    thres_temp[1] <= int_map[line - thres_length - 1][row + thres_length];
                    thres_temp[2] <= int_map[line - thres_length - 1][row - thres_length - 1];
                    thres_temp[3] <= int_map[line + thres_length][row - thres_length - 1];
                end
            4'b0111:
                begin
                    thres_size <= (row + thres_length + 1) * (2 * thres_length + 1);
                    thres_temp[0] <= int_map[line + thres_length][row + thres_length];
                    thres_temp[1] <= int_map[line - thres_length - 1][row + thres_length];
                    thres_temp[2] <= 16'd0;
                    thres_temp[3] <= 16'd0;
                end
            4'b1101:
                begin
                    thres_size <= (line + thres_length + 1) * (2 * thres_length + 1);
                    thres_temp[0] <= int_map[line + thres_length][row + thres_length];
                    thres_temp[1] <= 16'd0;
                    thres_temp[2] <= 16'd0;
                    thres_temp[3] <= int_map[line + thres_length][row - thres_length - 1];
                end
            4'b1011:
                begin
                    thres_size <= (width - row + thres_length) * (2 * thres_length + 1);
                    thres_temp[0] <= int_map[line + thres_length][width - 1];
                    thres_temp[1] <= int_map[line - thres_length - 1][width - 1];
                    thres_temp[2] <= int_map[line - thres_length - 1][row - thres_length - 1];
                    thres_temp[3] <= int_map[line + thres_length][row - thres_length - 1];
                end
            4'b1110:
                begin
                    thres_size <= (height - line + thres_length) * (2 * thres_length + 1);
                    thres_temp[0] <= int_map[height - 1][row + thres_length];
                    thres_temp[1] <= int_map[line - thres_length - 1][row + thres_length];
                    thres_temp[2] <= int_map[line - thres_length - 1][row - thres_length - 1];
                    thres_temp[3] <= int_map[height - 1][row - thres_length - 1];
                end
            4'b0101:
                begin
                    thres_size <= (row + thres_length + 1) * (line + thres_length + 1);
                    thres_temp[0] <= int_map[line + thres_length][row + thres_length];
                    thres_temp[1] <= 16'd0;
                    thres_temp[2] <= 16'd0;
                    thres_temp[3] <= 16'd0;
                end
            4'b1001:
                begin
                    thres_size <= (width - row + thres_length) * (line + thres_length + 1);
                    thres_temp[0] <= int_map[line + thres_length][width - 1];
                    thres_temp[1] <= 16'd0;
                    thres_temp[2] <= 16'd0;
                    thres_temp[3] <= int_map[line + thres_length][row - thres_length - 1];
                end
            4'b0110:
                begin
                    thres_size <= (row + thres_length + 1) * (height - line + thres_length);
                    thres_temp[0] <= int_map[height - 1][row + thres_length];
                    thres_temp[1] <= int_map[line - thres_length - 1][row + thres_length];
                    thres_temp[2] <= 16'd0;
                    thres_temp[3] <= 16'd0;
                end
            4'b1010:
                begin
                    thres_size <= (width - row + thres_length) * (height - line + thres_length);
                    thres_temp[0] <= int_map[height - 1][width - 1];
                    thres_temp[1] <= int_map[line - thres_length - 1][width - 1];
                    thres_temp[2] <= int_map[line - thres_length - 1][row - thres_length - 1];
                    thres_temp[3] <= int_map[height - 1][row - thres_length - 1];
                end
            default:
                begin
                    thres_size <= 16'd1;
                    thres_temp[0] <= 25'd0;
                    thres_temp[1] <= 25'd0;
                    thres_temp[2] <= 25'd0;
                    thres_temp[3] <= 25'd0;
                end
        endcase

        if (thres_size*rom_data >= (thres_temp[0]-thres_temp[1]+thres_temp[2]-thres_temp[3]))
            bin_map[pixel_count] <= 1;
        else
            bin_map[pixel_count] <= 0;
    end

endmodule