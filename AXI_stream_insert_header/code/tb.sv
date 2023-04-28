`timescale 1 ns/1 ns
class MYclass;
   rand logic [31:0] data_in_buffer;
   rand logic [31:0] data_insert_buffer;
   randc logic [3 : 0] keep_insert_buffer;
   randc logic  [3:0] keep_in_buffer;
   constraint c1 {keep_insert_buffer inside {4'b0001,4'b0011,4'b0111,4'b1111};}
   constraint c2 {keep_in_buffer inside {4'b1111,4'b1110,4'b1100,4'b1000};}
   function automatic new();      
      endfunction //new()
endclass //className

module tb ();
     parameter DATA_WD = 32;
     parameter DATA_BYTE_WD = DATA_WD / 8;       //4
     parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);
     parameter BURST_LENGTH=8;
     reg clk,rst_n,valid_in,last_in,ready_out,valid_insert;
     reg [DATA_BYTE_WD-1 : 0] keep_in;
     reg [BYTE_CNT_WD-1 : 0] byte_insert_cnt;
     reg [DATA_WD-1:0] data_in;
     reg [DATA_WD-1:0] data_insert;
     reg [DATA_BYTE_WD-1  : 0] keep_insert;
     wire ready_in,valid_out,last_out,ready_insert;
     wire [DATA_BYTE_WD-1 : 0] keep_out;
     wire [DATA_WD-1 : 0] data_out;
     axi_stream_insert_header u1(
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .last_in(last_in),
        .ready_out(ready_out),
        .valid_insert(valid_insert),
        .data_in(data_in),
        .data_insert(data_insert),
        .keep_in(keep_in),
        .keep_insert(keep_insert),
        .byte_insert_cnt(byte_insert_cnt),
        .ready_in(ready_in),
        .valid_out(valid_out),
        .keep_out(keep_out),
        .last_out(last_out),
        .ready_insert(ready_insert),
        .data_out(data_out)
     );

     always #5 clk = ~clk;
     //Verifying four burst transmission data using CRV
     initial begin
        automatic MYclass m1=new(); 
        //The first burst transmits data
        data_in=32'h00000000; data_insert=32'h00000000; keep_insert=4'h0;keep_in=4'h0;
        clk=1;rst_n=0;valid_in=1;last_in=0;valid_insert=1;ready_out=1; byte_insert_cnt=2'b00;
        #9
        m1.randomize();
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
        2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        #1
        rst_n=1;keep_in=4'b1111;        
        repeat(BURST_LENGTH-2) #10 begin
             m1.randomize();
             data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
             byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        end 
        #10      
        m1.randomize();last_in=1;keep_in=m1.keep_in_buffer;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        //The second burst transmits data
        #9
        rst_n=0; m1.randomize();keep_in=4'b1111;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        #1
        rst_n=1;
        repeat(BURST_LENGTH-2) #10 begin
             m1.randomize();
             data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;keep_in=4'b1111;  
             byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        end  
        #10
        m1.randomize();keep_in=m1.keep_in_buffer;last_in=1;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        //The third burst transmits data
        #9
        rst_n=0; m1.randomize();keep_in=4'b1111;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        #1
        rst_n=1;
        repeat(BURST_LENGTH-2) #10 begin
             m1.randomize();
             data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;keep_in=4'b1111;  
             byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        end  
        #10
        m1.randomize();keep_in=m1.keep_in_buffer;last_in=1;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        //The fourth burst transmits data
        #9
        rst_n=0; m1.randomize();keep_in=4'b1111;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        #1
        rst_n=1;
        repeat(BURST_LENGTH-2) #10 begin
             m1.randomize();
             data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;keep_in=4'b1111;  
             byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));
        end  
        #10
        m1.randomize();keep_in=m1.keep_in_buffer;last_in=1;
        data_in=m1.data_in_buffer; data_insert=m1.data_insert_buffer; keep_insert=m1.keep_insert_buffer;
        byte_insert_cnt=((keep_insert==4'b1111)?2'b11:((keep_insert==4'b0111)?
             2'b10:((keep_insert==4'b0011)?2'b01:((keep_insert==4'b0001)?2'b00:2'b00))));


        #50 $finish;
     end
endmodule //tb