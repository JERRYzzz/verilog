/****************************/
//sync_fifo design example
//      DATAWIDTH = 8;
//      ADDRDEPTH = 16;
//      ADDRWIDTH = 4;
/***************************/
module sync_fifo(clk,rst,wr_en,rd_en,data_in,data_out,f_empty,f_full);
parameter           DATAWIDTH = 8;
parameter           ADDRDEPTH = 16;
parameter           ADDRWIDTH = 4;
input                       clk,rst,wr_en,rd_en;
input   [DATAWIDTH-1:0]     data_in;
output                      f_empty,f_full;
output  [DATAWIDTH-1:0]     data_out;

reg     [DATAWIDTH-1:0]     mem[ADDRDEPTH-1:0];
reg     [DATAWIDTH-1:0]     data_out;
wire    [ADDRWIDTH-1:0]     w_addr,r_addr;
reg     [ADDRWIDTH:0]       w_addr_a,r_addr_a;

assign r_addr=r_addr_a[ADDRWIDTH-1:0];
assign w_addr=w_addr_a[ADDRWIDTH-1:0];

/****************************/
//Read operation
/***************************/
always@(posedge clk or negedge rst)
begin
    if(!rst)begin
        r_addr_a<='b0;
    end
    else begin
        if(rd_en&&(!f_empty))begin
            data_out<=mem[r_addr];
            r_addr_a<=r_addr_a+1;
        end
    end
end

/****************************/
//Write operation
/***************************/
always@(posedge clk or negedge rst)
begin
    if(!rst)begin
        w_addr_a<='b0;
    end
    else begin
        if(wr_en&&(!f_full))begin
            mem[w_addr]<=data_in;
            w_addr_a<=w_addr_a+1;
        end
    end
end

/****************************/
//Empty flag and Full flag
/***************************/
assign f_empty=(r_addr_a==w_addr_a)?1:0;
assign f_full =(r_addr_a[ADDRWIDTH]!=w_addr_a[ADDRWIDTH]
            &&  r_addr_a[ADDRWIDTH-1:0]==w_addr_a[ADDRWIDTH-1:0])
            ?1:0;

endmodule



/****************************/
//sync_fifo testbench example
//      DATAWIDTH = 8;
//      ADDRDEPTH = 16;
//      ADDRWIDTH = 4;
/***************************/
`timescale  10ns/1ns
module tb_sync_fifo();

parameter           DATAWIDTH = 8;
parameter           ADDRDEPTH = 16;
parameter           ADDRWIDTH = 4;

reg                         clk,rst,wr_en,rd_en;
reg     [DATAWIDTH-1:0]     data_in;
wire                        f_empty,f_full;
wire    [DATAWIDTH-1:0]     data_out;

sync_fifo   sync_fifo_0(
                    .clk(clk),.rst(rst),
                    .wr_en(wr_en),.rd_en(rd_en),
                    .data_in(data_in),.data_out(data_out),
                    .f_empty(f_empty),.f_full(f_full)
                );

always #5 clk=~clk;

//inital setting;
initial begin
    clk=1;
    rst=1;
    wr_en=0;
    rd_en=0;
    data_in='b0;
end

//reset,time < 30;
initial begin
    #15     rst=0;
    #10     rst=1;
end

//write data
initial begin
    #30     begin wr_en=1;data_in='b1;end
    #10     data_in='d2;
    #10     data_in='d3;
    #10     data_in='d4;
    #10     data_in='d5;
    #10     data_in='d6;
    #10     data_in='d7;
    #10     data_in='d8;
    #10     data_in='d9;
    #10     data_in='d10;
    #10     data_in='d11;
    #10     data_in='d12;
    #10     data_in='d13;
    #10     data_in='d14;
    #10     data_in='d15;
    #10     data_in='d16;
    #10     data_in='d17;
    #10     data_in='d18;
    #10     wr_en=0;
end

//read data
initial begin
    #260    rd_en=1;
    #500    rd_en=0;
    #10     $finish;
end

initial begin $dumpfile("tb_sync_fifo.vcd");$dumpvars(0,tb_sync_fifo);end

endmodule
