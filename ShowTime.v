`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/11 11:55:38
// Design Name: 
// Module Name: ShowTime
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


module ShowTime(clk,rst,st,ena,oSel,oData,back);
    input clk;//���ӵ�ʱ��Ƶ��
    input rst;//��λ�ź� ��ena��Ч�� 1��ʾ��λ����ʾ00:00
    input st;//��ʼ����ͣ�ź� 1��ʼ 0��ͣ
    input ena;//ʹ���ź� 1����ʹ�ã�0����ʾ
    output [7:0] oSel;//������ѡ��8���е���Щ��ʾ 7Ϊ���λ
    output [6:0] oData;//ѡ�����������
    input back;//����ʱ
    reg [2:0] iSel=3'b000;
    reg [3:0] iData;
    wire ShowFrequence;//1��1�ε�Ƶ��
    SingleDisplay7 sd7(.iData(iData),.iSel(iSel),.ena(ena),.oData(oData),.oSel(oSel));
    Divider #(100000000) dir(.I_CLK(clk),.Rst(rst),.O_CLK(ShowFrequence));//100000000
    
    wire clk_refresh;//8��λ��ˢ��Ƶ��
    Divider #(100000) dirrf(.I_CLK(clk),.Rst(rst),.O_CLK(clk_refresh)); //   10KHz   for a refresh frequency of about 1 KHz to 60Hz

    reg [3:0] sec_h=4'b0000, sec_l=4'b0000, min_h=4'b0000, min_l=4'b0000, hor_h=4'b0000, hor_l=4'b0000;

    always @(posedge ShowFrequence or posedge rst)
    begin
        if(rst)
        begin
            sec_l<=4'b0000;
            sec_h<=4'b0000;
            min_l<=4'b0000;
            min_h<=4'b0000;
            hor_l<=4'b0000;
            hor_h<=4'b0000;         
        end
        else if(st)//��ʼ��ʱ�ź�
        begin
        if(!back)begin
            if(sec_l==4'b1001)//��ĵ�λ=9
            begin
                sec_l<=4'b0000;
                if(sec_h==4'b0101)//��ĸ�λ=5
                begin
                    sec_h<=4'b0000;

                    if(min_l==4'b1001)//�ֵĵ�λ=9
                    begin
                        min_l<=4'b0000;
                        if(min_h==4'b0101)//�ֵĸ�λ=5
                        begin
                            min_h<=4'b0000;

                            if(hor_h==4'b0010)//ʱ�ĸ�λ=2
                            begin
                                if(hor_l==4'b0011)//ʱ�ĵ�λ=3
                                begin
                                    hor_h<=4'b0000;
                                    hor_l<=4'b0000;
                                end
                                else
                                    hor_l<=hor_l+4'b0001;
                            end
                            else//ʱ�ĸ�λ=0,1
                            begin
                                if(hor_l==4'b1001)//ʱ�ĵ�λ=9
                                begin
                                    hor_h<=hor_h+4'b0001;
                                    hor_l<=4'b0000;
                                end
                                else
                                    hor_l<=hor_l+4'b0001;
                            end
                        end
                        else
                        min_h<=min_h+4'b0001;
                    end
                    else
                    min_l<=min_l+4'b0001;
                end
                else
                    sec_h<=sec_h+4'b0001;
            end
            else
                sec_l<=sec_l+4'b0001;
        end
        else begin
            if(sec_l==4'b0000)//��ĵ�λ=0
            begin
                sec_l<=4'b1001;
                if(sec_h==4'b0000)//��ĸ�λ=0
                begin
                    sec_h<=4'b0101;

                    if(min_l==4'b0000)//�ֵĵ�λ=0
                    begin
                        min_l<=4'b1001;
                        if(min_h==4'b0000)//�ֵĸ�λ=0
                        begin
                            min_h<=4'b0101;

                            if(hor_h==4'b0000)//ʱ�ĸ�λ=0
                            begin
                                if(hor_l==4'b0000)//ʱ�ĵ�λ=0
                                begin
                                    hor_h<=4'b0010;
                                    hor_l<=4'b0011;
                                end
                                else
                                    hor_l<=hor_l-4'b0001;
                            end
                            else//ʱ�ĸ�λ=2,1
                            begin
                                if(hor_l==4'b0000)//ʱ�ĵ�λ=0
                                begin
                                    hor_h<=hor_h-4'b0001;
                                    hor_l<=4'b0000;
                                end
                                else
                                    hor_l<=hor_l-4'b0001;
                            end
                        end
                        else
                        min_h<=min_h-4'b0001;
                    end
                    else
                    min_l<=min_l-4'b0001;
                end
                else
                    sec_h<=sec_h-4'b0001;
            end
            else
                sec_l<=sec_l-4'b0001;
        end

        end
    end



    //��ʱЧӦ��ʾÿһλ(6λ)
    reg [2:0]cnt=3'b000;
    always@(posedge clk_refresh)
    begin
      case(cnt)
            3'b000:
            begin
                iData<=sec_l;
                cnt<=cnt+3'b001;
            end
            3'b001:
            begin
                iData<=sec_h;
                cnt<=cnt+3'b010;
            end
            3'b011: 
            begin
                iData<=min_l;
                cnt<=cnt+3'b001;
            end
            3'b100:
            begin
                iData<=min_h;
                cnt<=cnt+3'b010;
            end
            3'b110:
            begin
                iData<=hor_l;
                cnt<=cnt+3'b001;
            end
            3'b111:
            begin
                iData<=hor_h;
                cnt<=3'b000;
            end
            default:cnt<=3'b000;
            endcase   
            iSel<=cnt;    
    end
endmodule
