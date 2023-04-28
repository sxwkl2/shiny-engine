module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8,         //4
    parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD),  //2
    parameter BURST_LENGTH=8                   //burst length
) (
    input clk,
    input rst_n,
    // AXI Stream input original data
    input valid_in,
    input [DATA_WD-1 : 0] data_in,
    input [DATA_BYTE_WD-1 : 0] keep_in,
    input last_in,
    output ready_in,
    // AXI Stream output with header inserted
    output valid_out,
    output [DATA_WD-1 : 0] data_out,
    output [DATA_BYTE_WD-1 : 0] keep_out,
    output last_out,
    input ready_out,
    // The header to be inserted to AXI Stream input
    input valid_insert,
    input [DATA_WD-1 : 0] data_insert,
    input [DATA_BYTE_WD-1 : 0] keep_insert,
    input [BYTE_CNT_WD-1 : 0] byte_insert_cnt,
    output ready_insert
);
// Your code here
    reg [BURST_LENGTH-1:0]cnt;
    reg [DATA_WD-1 : 0] buffer;
    reg [DATA_WD-1 : 0] buffer1;
    
    assign   ready_in=1'b1;
    assign   ready_insert=1'b1;
    assign   keep_out=keep_in;
    assign   last_out=last_in;
    //first beat data
    always @(*) begin        
            case (keep_insert)
                4'b0001:buffer<={data_in[23:0],data_insert[7:0]};
                4'b0011:buffer<={data_in[15:0],data_insert[15:0]};
                4'b0111:buffer<={data_in[7:0],data_insert[23:0]};
                4'b1111:buffer<=data_insert;
            default: buffer <= data_in;                
            endcase                       
    end

    always @(posedge clk or negedge rst_n) begin  
        if(!rst_n)     begin
               cnt<=0;
               buffer1<=0;
        end
        else begin
            if(valid_in && valid_insert)begin
               if(cnt==0)begin
                   buffer1<=buffer;//
                   cnt<=cnt+1;
               end
               else begin
                    cnt<=cnt+1;
                    //last beat data
                    if(last_in) begin
                       case (keep_in) 
                            4'b1111:buffer1<=data_in;
                            4'b1110:buffer1<={data_in[23:0],8'h00};
                            4'b1100:buffer1<={data_in[15:0],16'h0000};
                            4'b1000:buffer1<={data_in[7:0],24'h000000};
                            default: buffer1 <= data_in; 
                       endcase
                       if(cnt==BURST_LENGTH-'b1)
                            cnt<=0;
                    end
                    else
                        buffer1 <= data_in;  
               end              
            end
        end
    end
    assign  valid_out=1'b1;
    assign  data_out=buffer1;
endmodule