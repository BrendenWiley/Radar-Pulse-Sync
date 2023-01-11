module syncdelay (output switch, input pmt, input sysclk, input [0:0] btn);
//variables
reg [1:0] ja;
assign switch = ja[1];
reg [11:0] count = 0;
reg pmt_detected, high = 1, low;
reg [11:0] cpi = 0;

//Constants
parameter PRTWIDTH = 2400; //200us time in clock cycles
//parameter PRTDELAY = 600;   //50us time in clock cycles
parameter DELAY = 1;
//parameter CPILENGTH = 99;

always @(posedge sysclk) begin

    if(pmt == 1'b1) begin
        pmt_detected <= 1;
    end
  
    if(count > PRTWIDTH - DELAY) begin
        pmt_detected <= 0;
        count <= 0;
        cpi <= cpi + 1;
    end
    
//    if(cpi > 99) begin
//        cpi <= 0;
//        end
    
    if (btn[0]) begin;
         pmt_detected <= 0;
          count <= 0;
         cpi <= 0;
    end 

    if(pmt_detected == 1) begin
         count <= count + 1;
   end
end

    always @(posedge sysclk) begin
    
        if(count == PRTWIDTH - DELAY && (high == 1)) begin
            ja[1] <= 1'b1;      
            high <= 0;  
            low <= 1;   
               end
      //Initiate switch logic low alternating
      else if (count == PRTWIDTH - DELAY && (low == 1)) begin
           ja[1] <= 1'b0;
           high <= 1;  
           low <= 0; 
         end
         end 
endmodule