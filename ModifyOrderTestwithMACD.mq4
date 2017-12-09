//+------------------------------------------------------------------+
//|                                                  MACD Sample.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"

input double TakeProfit    =10000;
input double Lots          =0.1;
input double TrailingStop  =10000;
input double MACDOpenLevel =3;
input double MACDCloseLevel=2;
input int    MATrendPeriod =26;



//Allowed Slippage
extern double Slippage=3;  //Allowed Slippage 
extern int Take_Profit=20;  //Take profit in pips
extern int StopLoss=100;    //Stop loss in pips
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   double MacdCurrent,MacdPrevious;
   double SignalCurrent,SignalPrevious;
   double MaCurrent,MaPrevious;
   int    cnt,ticket,total;
//---
// initial data checks
// it is important to make sure that the expert works with a normal
// chart and the user did not make any mistakes setting external 
// variables (Lots, StopLoss, TakeProfit, 
// TrailingStop) in our case, we check TakeProfit
// on a chart of less than 100 bars
//---

UpdateOpenOrders();

   if(Bars<100)
     {
      Print("bars less than 100");
      return;
     }
   if(TakeProfit<10)
     {
      Print("TakeProfit less than 10");
      return;
     }
//--- to simplify the coding and speed up access data are put into internal variables
   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);

   total=OrdersTotal();
   if(total<1)
     {
      //--- no opened orders identified
      if(AccountFreeMargin()<(1000*Lots))
        {
         Print("We have no money. Free Margin = ",AccountFreeMargin());
         return;
        }
      //--- check for long position (BUY) possibility
      if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && 
         MathAbs(MacdCurrent)>(MACDOpenLevel*Point) && MaCurrent>MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("BUY order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening BUY order : ",GetLastError());
         return;
        }
      //--- check for short position (SELL) possibility
      if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
         MacdCurrent>(MACDOpenLevel*Point) && MaCurrent<MaPrevious)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
               Print("SELL order opened : ",OrderOpenPrice());
           }
         else
            Print("Error opening SELL order : ",GetLastError());
        }
      //--- exit from the "no opened orders" block
      return;
     }
//--- it is important to enter the market correctly, but it is more important to exit it correctly...   
   for(cnt=0;cnt<total;cnt++)
     {
      if(!OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
         continue;
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         //--- long position is opened
         if(OrderType()==OP_BUY)
           {
            //--- should it be closed?
            if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious && 
               MacdCurrent>(MACDCloseLevel*Point))
              {
               //--- close order and exit
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
         else // go to short position
           {
            //--- should it be closed?
            if(MacdCurrent<0 && MacdCurrent>SignalCurrent && 
               MacdPrevious<SignalPrevious && MathAbs(MacdCurrent)>(MACDCloseLevel*Point))
              {
               //--- close order and exit
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet))
                  Print("OrderClose error ",GetLastError());
               return;
              }
            //--- check for trailing stop
            if(TrailingStop>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                    {
                     //--- modify order and exit
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red))
                        Print("OrderModify error ",GetLastError());
                     return;
                    }
                 }
              }
           }
        }
     }
//---
  }

  
//+------------------------------------------------------------------+
//normalize the digits to properly calculate take profit and stop loss
double CalculateNormalizedDigits()
{
   if(Digits<=3){
      return(0.01);
   }
   else if(Digits>=4){
      return(0.0001);
   }
   else return(0);
}
 
//UpdateOpenOrders for return the number of orders that have been updated
int UpdateOpenOrders(){
 
   int TotalUpdated=0;  //count closed orders 
   
   double nDigits=CalculateNormalizedDigits();
   
   //Normalization of the slippage
   if(Digits==3 || Digits==5){
      Slippage=Slippage*10;
   }
   
   //scan all the orders backwards
   for( int i=OrdersTotal()-1;i>=0;i-- ) {
      
      //select the order of index i selecting by position and from the pool of market trades
      //If the selection is successful we proceed with the update
      if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES )){
         //check if the order is for the same currency pair of the chart where the script is run
         if(OrderSymbol()==Symbol()){
            double OpenPrice=0;
            double StopLossPrice=0;
            double TakeProfitPrice=0;
            //get the open price
            OpenPrice=OrderOpenPrice();
            
            //calculate the stop loss and take profit price depending on the type of order
            if(OrderType()==OP_BUY){
               StopLossPrice=NormalizeDouble(OpenPrice-StopLoss*nDigits,Digits);
               TakeProfitPrice=NormalizeDouble(OpenPrice+Take_Profit*nDigits,Digits);
            }
            if(OrderType()==OP_SELL){
               StopLossPrice=NormalizeDouble(OpenPrice+StopLoss*nDigits,Digits);
               TakeProfitPrice=NormalizeDouble(OpenPrice-Take_Profit*nDigits,Digits);
            }         
            if(OrderModify(OrderTicket(),OpenPrice,StopLossPrice,TakeProfitPrice,CLR_NONE)){
               TotalUpdated++;
            }
            else{ //print error to capture what's wrong
               Print("Order failed to update with error - ",GetLastError());
            }
 
         }
 
         //If the order is updated correcly we increment the counter of updated orders
         //If the order fails to be updated we print the error
     }
      //If the OrderSelect() fails we return the cause
      else{
         Print("Failed to select the order - ",GetLastError());
      }  
      
      //We can have a delay if the execution is too fast, Sleep will wait x milliseconds before proceed with the code
      //Sleep(300);
   }
   //If the loop finishes it means there were no more open orders for that pair
   return(TotalUpdated);
}
 
 
void OnStart()
{
   Print("How many orders have been modified ? ",UpdateOpenOrders());
}