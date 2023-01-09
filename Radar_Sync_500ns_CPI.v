//ja[0] = pmt sync output on pmod pin 1
//ja[1] = switch control output on pmod pin 2
//btn[0] = reset button on fpga
//sysclk = internal clock
//cpi = manages 100 pulses (99 200us 1 250us) and switch high/low alternate

module syncdelay (output reg [1:0] ja, input sysclk, input [0:0] btn);

//Counter
reg [11:0] count = 0;

//CPI counter and switch high/low tracker
reg [7:0] cpi = 0;

//Manage clock, counter, CPI, reset
always @(posedge sysclk) begin

    //Reset CPI
    if(cpi >= 100) begin
         cpi <= 0;
    end

    //Reset counter and increment CPI for 200us pulse length
    if(cpi != 99 && count >= 2400) begin
         count <= 0;
         cpi <= cpi + 1;
    end
    
    //Reset counter and increment CPI for 250us pulse length
    else if(cpi == 99 && count >= 3000) begin
        count <= 0;
        cpi <= cpi + 1;
    end
    
    //Reset Button Logic
    else if (btn[0]) begin
         count <= 0;
    end 
      
    //Increment counter
    else begin
         count <= count + 1;
    end  
end

    //Generates PMT Sync
always @* begin

   //PMT sync pulse (40us)
   if (count < 480) begin
         ja[0] = 1;
   end 
   
  //Break PMT length 200us
  if(count >= 480 && count < 2400 && cpi != 99) begin
        ja[0] = 0;
        end
        
  //Break PMT length 250us      
  if(count >= 480 && count < 3000 && cpi == 99) begin
        ja[0] = 0;
        end
end
 
//Generates switch control
always @* begin

    //Block for length 200us
    if(cpi != 99) begin
    
         //Initiate switch logic high alternating
         if (count < 2395 && (cpi == 0 || cpi%2 == 0)) begin
               ja[1] = 1;
         end 
   
        //Initiate switch logic low alternating
         if (count < 2395 && (cpi%2 != 0)) begin
              ja[1] = 0;
         end
   
        //Add 500ns delay before PMT Switch       
        if ((count >= 2395 && cpi%2 != 0) || (count == 0 && cpi%2 == 0 )) begin
             ja[1] = 1;
        end
     end

   //Block for length 250us
   else if(cpi == 99) begin
   
        //Initiate switch logic low
        if (count < 2995) begin
            ja[1] = 0;
        end
   
       //Add 500ns delay before PMT Switch       
       if ((count >= 2995)) begin
            ja[1] = 1;
       end 
    end
end
endmodule