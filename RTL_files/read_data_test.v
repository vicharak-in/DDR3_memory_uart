module read_data_test (
    input wire clk,        // Clock signal
    input wire reset,      // Reset signal
    input wire [255:0] data_in, // 256-bit data input
    output reg [255:0] data_out,
    output reg r_led ,
    output reg trigger    // External trigger signal
);

reg [7:0] count = 8'b0; // Initialize a counter

always @(posedge clk ) begin
    if (~reset) begin
        data_out <= data_in ;
        count <= 8'b0; // Reset the counter
        r_led <= 1'b0;
        trigger <= 1'b0; // Reset the trigger signal
    end 
    
    else begin
        // Increment the counter on each clock cycle
        r_led <= 1;
        count <= count + 1'b1;
        
        if (count == 8'hFF) begin
            // When the counter reaches 256 (8'hFF), trigger an action
            trigger <= 1'b1;
            
        end 
        
        else begin
            // If the counter is not 256, keep the trigger signal low
            trigger <= 1'b0;
        end
    end
end

endmodule 