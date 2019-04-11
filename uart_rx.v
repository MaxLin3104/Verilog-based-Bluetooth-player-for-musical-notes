`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/17 18:44:18
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(rxd,clk,rx_ack,bdata,rx_begin);
    input rxd,clk;
    output reg [7:0] bdata;
    output rx_ack;
    output rx_begin;
    
    //���ڽ���״̬����Ϊ����״̬���ȴ������ա��������
    localparam IDLE=0,
           RECEIVE=1,
           RECEIVE_END=2;

    reg [3:0]cur_st,nxt_st; //״̬������
    reg [4:0]count;

    wire neg_clk;
    assign neg_clk=clk;

    always@(posedge clk)
      cur_st<=nxt_st;

    always@(*)
    begin
        nxt_st=cur_st;
      case(cur_st)
        IDLE: if(!rxd)nxt_st=RECEIVE; //���յ���ʼ�źţ���ʼ��������
        RECEIVE: if(count==7)nxt_st=RECEIVE_END; //��λ���ݽ��ռ���
        RECEIVE_END: nxt_st=IDLE; //�������
        default: nxt_st=IDLE;
      endcase
    end
    
    
    
    
    always@(posedge neg_clk)
      if(cur_st ==RECEIVE)
        count<=count+1; //�������ݼ���
      else if(cur_st==IDLE || cur_st==RECEIVE_END)
        count<=0;

    always@(posedge neg_clk)
      if(cur_st==RECEIVE)
      begin
        bdata[6:0]<=bdata[7:1]; //���Դ��� �ӵ�λ����λ ��������
        bdata[7]<=rxd;
      end
      
    assign rx_begin=(cur_st ==RECEIVE)?1'b1:1'b0;
    assign rx_ack=(cur_st==RECEIVE_END)?1'b1:1'b0; //�������ʱ�ظ��ź�

endmodule
