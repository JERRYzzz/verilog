/****************************/
//async_fifo design example
//  auhor:ZFL
//      >DATAWIDTH = 8;
//      >ADDRDEPTH = 16;
//      >ADDRWIDTH = 4;
/***************************/
module async_fifo(rst,wr_en,rd_en,clk_rd,clk_wr,data_in,data_out,f_empty,f_full);
parameter           DATAWIDTH = 8;
parameter           ADDRDEPTH = 16;
parameter           ADDRWIDTH = 4;
input                       clk_rd,clk_wr,rst,wr_en,rd_en;
input   [DATAWIDTH-1:0]     data_in;
output                      f_empty,f_full;
output  [DATAWIDTH-1:0]     data_out;

reg     [DATAWIDTH-1:0]     mem[ADDRDEPTH-1:0];
reg     [DATAWIDTH-1:0]     data_out;
reg     [ADDRWIDTH:0]       w_addr_a,r_addr_a;
wire    [ADDRWIDTH:0]       w_addr_g,r_addr_g;//gray code output
reg     [ADDRWIDTH:0]       r_addr_c;//gray read address -> write clock;just for full flag
reg     [ADDRWIDTH:0]       w_addr_c;//gray witer address -> read clock;just for empty flag

GRAYTRAN g_r(.bin(r_addr_a),.gray(r_addr_g));
GRAYTRAN g_w(.bin(w_addr_a),.gray(w_addr_g));
/****************************/
//Read operation
/***************************/
always@(posedge clk_rd or negedge rst)
begin
    if(!rst)begin
        r_addr_a<='b0;
        w_addr_c<='b0;
    end
    else begin
        w_addr_c<=w_addr_g;
        if(rd_en&&(!f_empty))begin
            data_out<=mem[r_addr_g[ADDRWIDTH-1:0]];
            r_addr_a<=r_addr_a+1;
        end
    end
end

/****************************/
//Write operation
/***************************/
always@(posedge clk_wr or negedge rst)
begin
    if(!rst)begin
        w_addr_a<='b0;
        r_addr_c<='b0;
    end
    else begin
        r_addr_c<=r_addr_g;
        if(wr_en&&(!f_full))begin
            mem[w_addr_g[ADDRWIDTH-1:0]]<=data_in;
            w_addr_a<=w_addr_a+1;
        end
    end
end

/****************************/
//Empty flag and Full flag
/***************************/
assign f_full =(r_addr_c[ADDRWIDTH]!=w_addr_g[ADDRWIDTH]
            &&  r_addr_c[ADDRWIDTH-1:0]==w_addr_g[ADDRWIDTH-1:0])
            ?1:0;
assign f_empty=(r_addr_g==w_addr_c)?1:0;

endmodule


/****************************/
//Gray code transform
//  author:ZFL
//      >Width=4
/***************************/
module GRAYTRAN(bin,gray);
parameter           ADDRDEPTH = 16;
parameter           ADDRWIDTH = 4;
input   [ADDRWIDTH:0] bin;
output  [ADDRWIDTH:0] gray;
wire    [ADDRWIDTH:0] gray;

assign gray[4]=bin[4];
assign gray[3]=bin[3];
assign gray[2]=bin[3]^bin[2];
assign gray[1]=bin[2]^bin[1];
assign gray[0]=bin[1]^bin[0];

endmodule



/****************************/
//async_fifo testbench example
//      DATAWIDTH = 8;
//      ADDRDEPTH = 16;
//      ADDRWIDTH = 4;
/***************************/
`timescale  10ns/1ns
module tb_async_fifo();

parameter           DATAWIDTH = 8;
parameter           ADDRDEPTH = 16;
parameter           ADDRWIDTH = 4;

reg                         clk_rd,clk_wr,rst,wr_en,rd_en;
reg     [DATAWIDTH-1:0]     data_in;
wire                        f_empty,f_full;
wire    [DATAWIDTH-1:0]     data_out;

async_fifo   async_fifo_0(
                    .clk_rd(clk_rd),.clk_wr(clk_wr),.rst(rst),
                    .wr_en(wr_en),.rd_en(rd_en),
                    .data_in(data_in),.data_out(data_out),
                    .f_empty(f_empty),.f_full(f_full)
                );

always #15 clk_rd=~clk_rd;
always #10 clk_wr=!clk_wr;

//inital setting;
initial begin
    clk_rd=1;
    clk_wr=1;
    rst=1;
    wr_en=0;
    rd_en=0;
    data_in='b0;
end

//reset,time < 70;
initial begin
    #35     rst=0;
    #30     rst=1;
end

//write data,wr_clk period:#20
initial begin
    #100    wr_en=1;
    #20     data_in='d1;
    #20     data_in='d2;
    #20     data_in='d3;
    #20     data_in='d4;
    #20     data_in='d5;
    #20     data_in='d6;
    #20     data_in='d7;
    #20     data_in='d8;
    #20     data_in='d9;
    #20     data_in='d10;
    #20     data_in='d11;
    #20     data_in='d12;
    #20     data_in='d13;
    #20     data_in='d14;
    #20     data_in='d15;
    #20     data_in='d16;
    #20     data_in='d17;
    #20     data_in='d18;
    #20     data_in='d19;
    #20     wr_en=0;
end

//read data,clk_rd period:#30
initial begin
    #420    rd_en=1;
    #600    rd_en=0;
    #30     $finish;
end

initial begin $dumpfile("tb_async_fifo.vcd");$dumpvars(0,tb_async_fifo);end

endmodule
