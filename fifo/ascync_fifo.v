/****************************
        >Title:async_fifo

****************************/
module ASYNC_FIFO(rst,rd_clk,wr_clk,
            rd_en,wr_en,
            data_in,data_out,
            f_empty,f_full);
parameter   DATAWIDTH = 8;
parameter   ADDRWIDTH = 9;

input       rst,rd_clk,wr_clk;
input       rd_en,wr_en;
input   [DATAWIDTH-1:0]     data_in;
output  [DATAWIDTH-1:0]     data_out;
output      f_full,f_empty;

reg         f_full,f_empty;
reg     [ADDRWIDTH-1:0]     wr_addrgray;
reg     [ADDRWIDTH-1:0]     wr_nextgray;
reg     [ADDRWIDTH-1:0]     rd_addrgray;
reg     [ADDRWIDTH-1:0]     rd_nextgray;
reg     [ADDRWIDTH-1:0]     rd_lastgray;

wire        rd_allow,wr_allow


