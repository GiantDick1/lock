
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/05 19:15:55
// Design Name: 
// Module Name: decider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//code    #      *      0       1      2       3        4        5        6         7        8        9
//       1011  1010    0000   0001    0010   0011     0100     0101     0110      0111      1000     1001
module decider(
input reset_1,       //置位信号
input [3:0] Code_1, //输入�?1位按�?
input Valid_1,      //有效信号
//input [15:0] Key ,   //用户输入4位密�?
//input [15:0] Key_1,
//input  [3:0] Key,
input clk,
input set,
                                    //对应存储器的地址
//input [2:0] RAM_1_addr,            //对应存储器的地址
output reg OPEN,
output reg  LOCK,
output reg SAVE_LIGHT,
  output   reg  [2:0] count_1,
  output reg [3:0] RAM_1_DATA ,
  output reg [3:0] RAM_DATA
    );  
    integer i;    
    reg [3:0] RAM_addr_1;
    reg [9:0] RAM_addr;
 // output   wire [3:0] RAM_DATA_1;         
 // output   wire [3:0]  RAM_DATA;                                              
    reg [2:0] state_1,next_state_1;
 reg [3:0] RAM [9:0];
  reg [3:0] RAM_1 [3:0];
  //  initial $readmemb("RAM_DATA.txt",RAM_1,0,3);
    parameter B_0=4'b0001;   //LOCK
    parameter B_1=4'b0010;   //OPEN THE LOCK
    parameter B_2=4'b0100;   //SAVE
 //   parameter B_3=4'b1000;   //LOCK

 initial
 begin
 RAM_1[1]=4'b1001;
  RAM_1[2]=4'b1100;
   RAM_1[4]=4'b0001;
    RAM_1[8]=4'b0000;
 end

 always @(posedge clk)     //�洢����RAM��ַ
 begin
 if(reset_1==1)
 RAM_addr_1=10'b0000000001;
 else if(RAM_addr<=512)
 begin
RAM_addr=RAM_addr<<1;
RAM[RAM_addr]=Code_1;
RAM_DATA=RAM[RAM_addr];
end
else 
RAM_addr=10'b00000001;
end
 always @(posedge clk)     //�洢����RAM��ַ
 begin
 if(reset_1==1)
 RAM_addr_1=4'b0001;
 else if(RAM_addr_1<=8)
 begin
RAM_addr_1=RAM_addr_1<<1;
RAM_1[RAM_addr_1]=4'b0001;

end
else 
RAM_addr=4'b0001;
end

/*
   always@(posedge clk )            //###############
   begin
   if(reset_1)                                   //进入复位，可以输入新密码
   state_1<=B_2;                                 //进入存储模式
   else 
   state_1<=next_state_1;      
   end                       //否则进入下一状�??
*/
always@(posedge clk)
    begin
    if(reset_1==1)
    begin
    OPEN=1'b0;
    SAVE_LIGHT=1'b0;
    LOCK=1'b1;
    end
    else 
    begin
                case(state_1)
B_0:                                                        //����״̬���ж��Ƿ��������"#"������������ת������״̬
begin
                    if((RAM[2]==RAM_1[1])&&(RAM[4]==RAM_1[2])&&(RAM[8]==RAM_1[4])&&(RAM[16]==RAM_1[8])&&(RAM[1]==4'b1011))
                        begin
                            next_state_1=B_1;
                            OPEN=1'b1;
                            SAVE_LIGHT=1'b0;
                            LOCK=1'b0;
                        end
                    else if(RAM[1]==4'b1011)                  //�?直按下�??#键�?�，则一直打�?
                        begin
                        next_state_1=B_1;                  
                        OPEN=1'b1;
                        SAVE_LIGHT=1'b0;
                        LOCK=1'b0;
                        end
                        else if((RAM[2]==RAM_1[1])&&(RAM[4]==RAM_1[2])&&(RAM[8]==RAM_1[4])&&(RAM[16]==RAM_1[8])&&(RAM[1]==4'b1010))
                        begin

                        next_state_1=B_2;                 //����洢״̬
                        SAVE_LIGHT=1'b1;
                        OPEN=1'b0;
                        LOCK=1'b1;
                        end
                        else 
                        begin
                        next_state_1=B_0;                 //��������״̬
                        LOCK=1'b1;
                         OPEN=1'b0;
                          SAVE_LIGHT=1'b0;
                        end
        end                
B_1: 
begin                                                              //��״̬
if(Valid_1==1)
begin
             OPEN=1'b1;
             LOCK=1'b0;
             SAVE_LIGHT=1'b0;
             if(RAM[1]==4'b1011)                            //һֱ���¡�#�����ִ�
             begin
             next_state_1=B_1;
             OPEN=1'b1;
             LOCK=1'b0;
             SAVE_LIGHT=1'b0;
            end
        else   
        /*
        if((RAM_DATA[1]==RAM_DATA_1[1])&&(RAM_DATA[2]==RAM_DATA_1[2])&&(RAM_DATA[3]==RAM_DATA_1[3])&&(RAM_DATA[4]==RAM_DATA_1[4])&&(RAM_DATA[0]==4'b1010))       //                
            begin
            
                        next_state_1=B_2;                 //����洢״̬
                        SAVE_LIGHT=1'b1;
                        OPEN=1'b0;
                        LOCK=1'b1;

             
            end
            */
    
            begin

                        next_state_1=B_0;                 //��������״̬
                        LOCK=1'b1;
                        SAVE_LIGHT=1'b0;
                        OPEN=1'b0;

                        end
end
end
B_2:                      //�洢״̬
begin
if(set==1)               //���븴λ������4λ����
begin
for(i=0;i<8;i=i*2)
RAM_1[i]=Code_1;
end
else
begin                          //����洢
count_1=1'b0;
SAVE_LIGHT=1'b1;
 LOCK=1'b1;
 OPEN=1'b0;
for(i=1;i<=512;i=i*2)                    //������������
begin
RAM[i]=Code_1;
end

while (!((RAM[2]==RAM[64])&&(RAM[4]==RAM[128])&&(RAM[8]==RAM[256]))&&(RAM[16]==RAM[512])&&(RAM[1]==4'b1011)&&(RAM[32]==4'b1011))   //���������벻ͬ���������롣ÿ�����붼��"#"����
begin
for(i=1;i<=512;i=i+1)
begin
RAM[i]=Code_1;
count_1=count_1+1;
end
end
RAM_1[1]=RAM[2];
RAM_1[2]=RAM[4];
RAM_1[4]=RAM[8];
RAM_1[8]=RAM[16];
SAVE_LIGHT=1'b0;   //�޸������룬�洢ָʾ����
 LOCK=1'b1;
 OPEN=1'b0;
 next_state_1=B_0;  //�޸��������������״̬
end
end
endcase

end
end
endmodule
