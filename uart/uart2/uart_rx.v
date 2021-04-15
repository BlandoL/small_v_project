module uart_rx(rxd,clk,rst,data_i,receive_ack,data_error);
 input rxd;//???bit
 input clk;
 input rst;
 output [7:0] data_i;
 output receive_ack;
 output data_error;//????????????
 
 reg [7:0] data_i;
 reg [3:0] count;
 reg data_error;
 //??????4???:??????????????????
 parameter IDLE=4'b0001,RECEIVE_DATA=4'b0010,RECEIVE_CHECK=4'b0100,RCEIVE_END=4'b1000;
 parameter IDLE_POS=2'd0,RECEIVE_DATA_POS=2'd1,RECEIVE_CHECK_POS=2'd2,RCEIVE_END_POS=2'd3;
 reg [3:0] cs,ns;
 //????
 always @(posedge clk)
  begin
       if(rst)
	      cs <= IDLE;
	   else
	      cs <= ns;
  end
  //?????
 always @(*)
   begin
      if(rst)
	    ns = IDLE;
	  else
	    begin
		   ns = cs;//???
		   case(1'b1)
		      cs[IDLE_POS]:if(~rxd) ns = RECEIVE_DATA;
			  cs[RECEIVE_DATA_POS]:if(count == 7) ns = RECEIVE_CHECK;
			  cs[RECEIVE_CHECK_POS]: ns = RCEIVE_END;
			  cs[RCEIVE_END_POS]: begin
						             if(~rxd) ns = RECEIVE_DATA;
									 else ns = IDLE;
                                  end
			  default: ns = IDLE;
           endcase								  
		end
   end
 //??
 reg presult;//????
 always @(posedge clk)
  begin
     if(rst)
	   begin
	     count <= 4'd0;
		 presult <= 1'b0;
		 data_error <= 1'b0;
	   end
	 else if(cs == RECEIVE_DATA)
	   begin
	      if(count == 7)
		     count <= 4'd0;
		  else
		     count <= count + 1'b1;
	   end
	 else
	   count <= 4'd0;
  end
  //???????????
  always @(posedge clk)
    begin
	    if(rst)
		  data_i <= 8'd0;
        else if(cs == RECEIVE_DATA)
          begin
		       data_i[7] <= rxd;
			   data_i[6:0] <= data_i[7:1];
			   presult <= presult ^ rxd;
          end
        else if(cs == RECEIVE_CHECK)
          begin
		       if(presult == rxd)
			      data_error <= 1'b0;
			   else
			      data_error <= 1'b1;
          end
        else
          data_i <= 8'd0;		
	end
 assign receive_ack = (cs == RECEIVE_CHECK)? 1'b1:1'b0;
endmodule
