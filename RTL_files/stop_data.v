module fsm_tx (
    input clk,
    input rst,
    input full_flag,
    output reg w_en
);

always @ (posedge clk) begin
    
    if (!rst) begin 
        w_en <= 0 ;
    end 
    else begin 
        if (full_flag == 1'b1) begin
            w_en <= 0;
        end
        
        else begin
                w_en <= 1'b1 ;
        end
    end
end 

endmodule
 
