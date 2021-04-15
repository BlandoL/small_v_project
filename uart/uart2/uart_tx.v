module uart_tx(clk,rst,receive_ack,data_o,txd);
 input clk;
 input rst;
 input receive_ack;//????????????
 input [7:0] data_o;//8????
 output txd;//????
 
 reg txd;
 reg [3:0] count;
 reg presult;//????
 //assign presult = CHECK_EVEN^data_o[0]^data_o[1]^data_o[2]^data_o[3]^data_o[4]^data_o[5]^data_o[6]^data_o[7];
 //parameter CHECK_EVEN = 1'b0;//???
 
 //??????5????????????????????????????????
 parameter IDLE=5'b00001,SEND_START=5'b00010,SEND_DATA=5'b00100,SEND_CHECK=5'b01000,SEND_END=5'b10000;
 parameter IDLE_POS=3'd0,SEND_START_POS=3'd1,SEND_DATA_POS=3'd2,SEND_CHECK_POS=3'd3,SEND_END_POS=3'd4;
 reg [4:0] cs,ns;
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
		  cs[IDLE_POS]: if(receive_ack) ns = SEND_START;//?????????????????????????????
		  cs[SEND_START_POS]: ns = SEND_DATA;
		  cs[SEND_DATA_POS]: if(count == 7) ns = SEND_CHECK;//???????????????
		  cs[SEND_CHECK_POS]: ns = SEND_END;
		  cs[SEND_END_POS]: if(receive_ack) ns = SEND_START;
		  default: ns = IDLE;
		endcase
	  end
  end
  //??
 always @(posedge clk)
  begin
     if(rst)
	   begin
	      presult <= 1'b0;//???0?????
	      count <= 4'd0;
	   end
	 else if(cs == SEND_DATA)
	   begin
	      if(count == 7)
		     count <= 4'd0;
		  else
		     count <= count + 1'b1;
	   end
	 else
	   count <= 4'd0;
  end
 //?????
 reg [7:0] data_o_temp;
 always @(posedge clk)
  begin
     if(rst)
	   data_o_temp <= 8'd0;
	 else if(cs == SEND_START)
	   data_o_temp <= data_o;
	 else if (cs == SEND_DATA)
	   data_o_temp [6:0] <= data_o_temp [7:1];//??
	 else
	   data_o_temp <= 8'd0;
  end
 //????
 always @(posedge clk)
   begin
       if(rst)
	     txd <= 1'b1;//?????????
	   else if(cs == SEND_START)
	     txd <= 1'b0;//???????
	   else if(cs == SEND_DATA)
	     begin
		      txd <= data_o_temp[0];
			  presult <= presult ^ data_o_temp[0];
	     end
	   else if(cs == SEND_CHECK)//?????????????
	     txd <= presult;
	   else if(cs == SEND_END)//?????
	     txd <= 1'b1;
	   else
	     txd <= 1'b1;
   end
endmodule
