module keypad1(	
	input clk,
	input rst_n,
	input [3:0]row,

	output reg key_flag,
	output reg [3:0]key_value,
	output reg [2:0]col
);

reg [3:0]   row_r;
reg [4:0]   c_state,n_state;
reg [6:0]   key_value_r;
reg         en_delay;
reg [19:0]  delay;

parameter CNT_MAX = 999_999;

localparam
	scan 		= 5'b00001,
	judge  		= 5'b00010,
	filter0 	= 5'b00100,
	down		= 5'b01000,
	filter1	 	= 5'b10000;

//寄存行的值	
always@(posedge clk or negedge rst_n)
if(!rst_n)
	row_r <= 0;
else 
	row_r <= row;

	
//状态机第一段		
always@(posedge clk or negedge rst_n)
if(!rst_n)
	c_state <= scan;
else 
	c_state <= n_state;

//状态机第二段		
always@(*) begin
	n_state = 5'bxxxxx;
	case(c_state)
		scan:begin
			n_state = judge;
		end
		judge:begin
			if(row_r != 4'b1111) n_state = filter0;
			else n_state = scan;
		end			
		filter0:begin
			if(delay == CNT_MAX) begin
				if(row_r != 4'b1111) n_state = down;
				else n_state = scan;
			end else
                n_state = c_state;                    
		end
        down:begin
            if(row_r == 4'b1111) n_state = filter1;
            else n_state = c_state;
        end        
        filter1:begin
            if(delay == CNT_MAX) begin
				if(row_r != 4'b1111) n_state = down;
				else n_state = scan;
			end else
				n_state = c_state;
		end
		default:n_state = scan;
	endcase
end 
				
//状态机第三段
always@(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		en_delay <= 0;
		col <= 4'b110;
		key_flag <= 0;
		key_value_r <= 0;
	end else begin
		case(n_state)
			scan:begin	
				en_delay <= 0;
				col <= {col[1:0],col[2]};		//进行col按键扫描
			end	
			
			judge:begin
				key_flag <= 0;
			end
			
			filter0:begin
				en_delay <= 1;
				if((delay == CNT_MAX-1)&&(row_r != 4'b1111)) begin
					key_flag <= 1;
					key_value_r <= {row_r,col};		//确定行列按键值
				end else begin
					key_flag <= 0;
					key_value_r <= 0;
				end 
			end 
			
			down:begin
				key_flag <= 0;
				en_delay <= 0;
				key_value_r <= 0;
			end 
				
			filter1:begin
				en_delay <= 1;
			end

			default:begin
				en_delay <= 0;
				col <= 4'b110;
				key_flag <= 0;
			end
		endcase
	end	
end

//抖动20ms的时间计数		
always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        delay <= 0;
    else if(en_delay) begin
        if(delay == CNT_MAX) delay <= 0;
        else delay <= delay + 1'b1;
    end else 
        delay <= 0;
end

//根据行和列的值确定输出按键值	
always@(posedge clk or negedge rst_n)
if(!rst_n)
	key_value <= 4'bxxxx;
else begin
	case(key_value_r)
		7'b1110_110: key_value <= 4'd1;
		7'b1110_101: key_value <= 4'd2;
		7'b1110_011: key_value <= 4'd3;
       
		7'b1101_110: key_value <= 4'd4;
		7'b1101_101: key_value <= 4'd5;
		7'b1101_011: key_value <= 4'd6;
       
		7'b1011_110: key_value <= 4'd7;
		7'b1011_101: key_value <= 4'd8;
		7'b1011_011: key_value <= 4'd9;
	
		7'b0111_110: key_value <= 4'd10;
		7'b0111_101: key_value <= 4'd0;
		7'b0111_011: key_value <= 4'd11;
		default:key_value <= 4'bxxxx;
	endcase
end 

endmodule 