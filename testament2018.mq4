//+------------------------------------------------------------------+
//|                                                testament2018.mq4 |
//|                                       Copyright 2018, Chaninnart |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Chaninnart"
#property link      ""
#property version   "1.00"
#property strict




//+------------------------------------------------------------------+
//| Global Variable Declration                                              |
//+------------------------------------------------------------------+

//--- Global Indicator variables----------------------------------+
   //--- 1. MACD
      input int fast_ema_period = 21 ;       // MACD fast ema period
      input int slow_ema_period = 60 ;       // MACD slow ema period
      input int signal_line = 9 ;            // MACD signal line
      
      double macd_main_val[10];     // amount of MACD main required
      double macd_signal_val[10];     // amount of MACD signal required 
   //--- 2. Zigzag
      input int zigzag_Depth_LineA = 60 ;    // Zigzag Depth Value
      input int zigzag_Deviation_LineA =0 ;  // Zigzag Deviation Value
      input int zigzag_Backstep_LineA =0;    // Zigzag Backstep Value
      
      double zigzag_val[10];     // amount of zigzag required            
      int zigzag_pivot_bar[5];
      double zigzag_pivot_bar_value[5];

   //--- 3. TT
      input int TurtleTradePeriod_S = 2;     // TT's short Trade Period
      input int TurtleStopPeriod_S = 0;      // TT's short Stop Period
      input int TurtleTradePeriod_M = 10;    // TT's middle Trade Period
      input int TurtleStopPeriod_M = 0;      // TT's middle Stop Period  
      input int TurtleTradePeriod_L = 30;    // TT's long Trade Period
      input int TurtleStopPeriod_L = 0;      // TT's long Stop Period

      double tt_S_val[10];     // amount of tt short required  
      double tt_M_val[10];     // amount of tt medium required  
      double tt_L_val[10];     // amount of tt long required    
   
//--- Order's variables----------------------------------+ 
      int      MagicNumber  = 2017;          //Magic Number
      extern double   Lotsize = 0.1;         //Order Setting (Lot Size)
      extern double   SL   = 00;             //Stop Loss (in Points)
      extern double   TP   = 00;             //Take Profit (in Points)
      extern int      TS = 0;                     //Trailing Stop (in Points)
      
//--- Others variables----------------------------------+   

      bool thisIsNewBar = false ;   //--- Timer parameters checking new bar.
      int barCount ;                //just for debuging new Bar
      bool onceAbar =false ;        //variable control do one order action per bar
      string text[20];              //Array of String store custom texts on screen  
      
      int debug;                    //debug variable 

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

 
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- start workflow in every tick here
      DetectNewBar();
      getVariable_MACD();
      getVariable_Zigzag();
      getVariable_TT();
      
//--- start calling business logic here      
      flowchart();

//--- do routines stuff here      
      printInfo(); // print debug text on screen
  }

  
void flowchart(){
      // collect using variables
      bool hh_M1 = ((zigzag_pivot_bar_value[0] > zigzag_pivot_bar_value[2]) && (zigzag_pivot_bar_value[2] > zigzag_pivot_bar_value[4])) ;
      bool ll_M1 = ((zigzag_pivot_bar_value[0] < zigzag_pivot_bar_value[2]) && (zigzag_pivot_bar_value[2] < zigzag_pivot_bar_value[4])) ;
      bool hh_M2 = ((zigzag_pivot_bar_value[0] > zigzag_pivot_bar_value[2]) && (zigzag_pivot_bar_value[2] > zigzag_pivot_bar_value[1])) ;
      bool ll_M2 = ((zigzag_pivot_bar_value[0] < zigzag_pivot_bar_value[2]) && (zigzag_pivot_bar_value[2] < zigzag_pivot_bar_value[1])) ;      
      if (hh_M1){text [11] = "Higher High: "+ TimeCurrent();} if (ll_M1){text [12] = "Lower Low: "+ TimeCurrent();}  //debug variable

      int condition;      
      if (hh_M1||ll_M1){condition = 1;}      
           
      // logic
      switch (condition){
         case 1: M1_The_Long_Trend (); break;
         case 2: M2_The_Trend_Beginning (); break;         
      }
} 
  
//+------------------------------------------------------------------+
//| Business logic                                                   |
//+------------------------------------------------------------------+
   void M1_The_Long_Trend (){
      bool tt_L_is_below = (tt_L_val[0] != 2147483647);
      switch(tt_L_is_below){
         case true:
            closeAllSellOrder();
            if(countOrder(0) == 0){openBuy("BUY M1");}
            break;
         case false: 
            closeAllBuyOrder();           
            if(countOrder(1) == 0){openSell("SELL M1");}
            break;
         }    
   }

//---
   void M2_The_Trend_Beginning (){
    
   }

//---   

//+------------------------------------------------------------------+

  
//+------------------------------------------------------------------+
//| Indicator's function                                             |
//+------------------------------------------------------------------+

   //--- 1. MACD
      void getVariable_MACD(){         
           for(int i=0; i < ArraySize(macd_main_val) ; i++){
               macd_main_val[i] = iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_MAIN,i);
               macd_signal_val[i] = iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_SIGNAL,i);  
               //text[i] = DoubleToStr(macd_main_val[i],5)+ "," + DoubleToStr(macd_signal_val[i],5);
           }        
      }   
   //--- 2. Zigzag
      void getVariable_Zigzag(){      
           for(int i=0; i < ArraySize(zigzag_val) ; i++){
               zigzag_val[i] = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,i);
           } 
         getZigzag_Last_Pivot();         
      }

      void getZigzag_Last_Pivot(){            
            int i=0; int n = 0;            
               while(i<5){
                  double zigzag_temp1 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,n);
                  if (zigzag_temp1 !=0) {
                     zigzag_pivot_bar[i] = n ;
                     zigzag_pivot_bar_value[i] = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,n); //debug variable
                     //text[i] = zigzag_pivot_bar[i]+" at bar: "+ zigzag_pivot_bar_value[i];
                     i++ ;                     
                  }            
                  n++;                              
               }
      }
      
   //--- 3. TT
      void getVariable_TT(){      
           for(int i=0; i < ArraySize(tt_S_val) ; i++){
               tt_S_val[i] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,i );
           } 
           for(int i=0; i < ArraySize(tt_M_val) ; i++){
               tt_M_val[i] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,i );
           }
           for(int i=0; i < ArraySize(tt_L_val) ; i++){
               tt_L_val[i] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,i );
           }
           //for(int i=0; i < 10 ; i++){text[i] = DoubleToStr(tt_S_val[i],5)+ "," + DoubleToStr(tt_M_val[i],5)+ "," + DoubleToStr(tt_L_val[i],5);}        
      } 

   

//+------------------------------------------------------------------+  

//+------------------------------------------------------------------+
//| Order's function                                              |
//+------------------------------------------------------------------+
   void openBuy (string comment) {   
      bool result = false;  // avoid gentle warning return value should be checked
      double tp = Ask+(TP*Point);
      double sl = Bid -(SL*Point); //setting stop loss when open buy 100
      if (TP == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130
      if (SL == 0) { sl =0;}
      RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
      result = OrderSend(Symbol(),OP_BUY,Lotsize ,Ask,3,sl,tp,comment,MagicNumber,0,clrGreen); 
   
   onceAbar = false ; 
   }
   
   void openSell(string comment){
      bool result = false;  // avoid gentle warning return value should be checked
      double tp = Bid-(TP*Point);
      double sl = Ask+(SL*Point); //setting stop loss when open buy 100   
      if (TP == 0) { tp =0;}
      if (SL == 0) { sl =0;}
      RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
      result = OrderSend(Symbol(),OP_SELL,Lotsize ,Bid,3,sl,tp,comment,MagicNumber,0,clrRed);  
   
   onceAbar = false ;      
   }
   
   void openBuyWithSL (string comment,double stopLossPrice) { 
      bool result = false;  // avoid gentle warning return value should be checked
      double tp = Ask+(TP*Point);  
      if (TP == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130   
      RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
      result = OrderSend(Symbol(),OP_BUY,Lotsize ,Ask,3,stopLossPrice,tp,comment,MagicNumber,0,clrGreen);   
   
   onceAbar = false ; 
   }
   
   void openSellWithSL(string comment,double stopLossPrice){
      bool result = false;  // avoid gentle warning return value should be checked   
      double tp = Bid-(TP*Point);
      if (TP == 0) { tp =0;}   
      RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
      result = OrderSend(Symbol(),OP_SELL,Lotsize ,Bid,3,stopLossPrice,tp,comment,MagicNumber,0,clrRed); 
   
   onceAbar = false ;  
   }
   
   
   void closeAllBuyOrder(){
      bool result = false;  // avoid gentle warning return value should be checked
      for(int i = OrdersTotal()-1; i>=0; i--) {  
         if (OrderSelect(i,SELECT_BY_POS) == true){ 
         string orderComment = StringSubstr(OrderComment(),0,9);    
               if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
                  RefreshRates();
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);
               }
            }
         }
   onceAbar = false ;       
   }
   
   // close all opening sell order by order comment
   void closeAllSellOrder(){
      bool result = false;  // avoid gentle warning return value should be checked   
      for(int i = OrdersTotal()-1; i>=0; i--) {
         if (OrderSelect(i,SELECT_BY_POS) == true){
         string orderComment = StringSubstr(OrderComment(),0,10);           
               if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
                  RefreshRates();
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0); 
               }         
         }
      }
   onceAbar = false ; 
   }
   
   
   void closeAllBuyCommentOrder(string comment){
      bool result = false;  // avoid gentle warning return value should be checked   
      for(int i = OrdersTotal()-1; i>=0; i--) {  
         if (OrderSelect(i,SELECT_BY_POS) == true){  
         string orderComment = StringSubstr(OrderComment(),0,9);
            if (orderComment == comment){    
               if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
                  RefreshRates();
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);                              
               }
            }
         }
      }
   onceAbar = false ;  
   }
   
   
   void closeAllSellCommentOrder(string comment){
      bool result = false;  // avoid gentle warning return value should be checked
      for(int i = OrdersTotal()-1; i>=0; i--) {
         if (OrderSelect(i,SELECT_BY_POS) == true){
            string orderComment = StringSubstr(OrderComment(),0,10);
            if (orderComment == comment){    
               if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
                  RefreshRates();
                  result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
               }
            }
         }
      }
   onceAbar = false ;  
   }
   
   // close all opening order
   void closeAllOrder(int type){
      bool result = false;  // avoid gentle warning return value should be checked
      for(int i = OrdersTotal()-1; i>=0; i--) {
         if (OrderSelect(i,SELECT_BY_POS) == true){  
            if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               switch(type){
                  case 1:
                     result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
                     break;
                   case 2:
                     result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);
                     break;
               }         
            }
         }
      }
   onceAbar = false ; 
   }
   

//+------------------------------------------------------------------+





  
//+------------------------------------------------------------------+
//| Helper function                                              |
//+------------------------------------------------------------------+
   double RoundNumber(double number, int digits) {
      number = MathFloor((number * MathPow(10, digits)) + 0.4);
      return (number * MathPow(10, -digits));
   }

   // Count Order Type(0 = BUY, 1 = SELL)
   int countOrder (int type){
      bool result = false;  // avoid gentle warning return value should be checked
      int CntOrder = 0 ;
      for(int i=0;i<OrdersTotal();i++){
         result = OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderType() == type && OrderMagicNumber() == MagicNumber){
            if(OrderSymbol() == Symbol()){
               CntOrder++ ;
            }
         }
      }
      //Comment (IntegerToString(CntOrder));
      return(CntOrder);
   }

   int countBarFromLastOrder(){
         if (OrdersTotal() -1 >= 0){        
            if(OrderSelect((OrdersTotal() -1 ), SELECT_BY_POS) )
            {
               return((TimeCurrent() - OrderOpenTime())/(Period()*60));
            }
       }
       return(0);    
   }

   int lastOrderType(){
         if (OrdersTotal() -1 >= 0){        
            if(OrderSelect((OrdersTotal() -1 ), SELECT_BY_POS) )
            {return(OrderType());}
       }
       return(0);    
   }

//+------------------------------------------------------------------+
   void printInfo(){ 
       int i=0, k=20;
       while (i<20)
       {
          string ChartInfo = DoubleToStr(i, 0);
          ObjectCreate(ChartInfo, OBJ_LABEL, 0, 0, 0);
          ObjectSetText(ChartInfo, text[i], 14, "Arial", Orange);
          ObjectSet(ChartInfo, OBJPROP_CORNER, 0);   
          ObjectSet(ChartInfo, OBJPROP_XDISTANCE, 7);  
          ObjectSet(ChartInfo, OBJPROP_YDISTANCE, k+7);
          i++;
          k=k+20;
       } 
   }

   void drawWhiteDownArrowOnScreen(int index){ 
      int i;
      i=Bars;
      string name2 = "Dn"+string(i);
      ObjectCreate(name2,OBJ_ARROW, 0, Time[index], High[index]+10*Point); 
      ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
      ObjectSet(name2, OBJPROP_COLOR,White);   
   }

   //Calculate Next Bar-----------------------------------------+
   void DetectNewBar(void){
      static datetime time = Time[0];
      if(Time[0] > time){
         time = Time[0]; //newbar, update time
         thisIsNewBar = true;
         barCount++;
         onceAbar = true;
      }
   }    

//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//|   NOT OFTEN USE                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      ObjectsDeleteAll(); 
      return;   
  }