//sync_fifo design example
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
        r_addr_a<=(ADDRWIDTH+1)'b0;
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
        w_addr_a<=(ADDRWIDTH+1)'b0;
    end
    else begin
        if(wr_en&&(!f_full))begin
            mem[r_addr]<=data_in;
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
