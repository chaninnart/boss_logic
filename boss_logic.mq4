//+------------------------------------------------------------------+
//|  1.09                                            2018 Stategy.mq4 |
//|                                       Copyright 2018, Chaninnart |
//|                                             chaninnart@gmail.com
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Chaninnart"
#property strict
//+------------------------------------------------------------------+
//| Global Variable Declaration                                   |
//+------------------------------------------------------------------+

//--- Timer parameters checking new bar.
bool thisIsNewBar = false;
// show info on screen
bool ShowInfo = true; 
string text[30]; //Array of String store custom texts on screen

//+------------------------------------------------------------------+
//| Indicator Variable                                  |
//+------------------------------------------------------------------+
//1. Zigzag Indicator variable 
input int zigzag_Depth_LineA = 60 ; // Zigzag Depth Value
input int zigzag_Deviation_LineA =0 ; // Zigzag Deviation Value
input int zigzag_Backstep_LineA =0; // Zigzag Backstep Value

double zigzag_Last_Value = 0;
int zigzag_pivot_bar_index[5];
double zigzag_pivot_bar_index_value[5];
bool   zigzag_last_pivot_is_low ;


double zigzag_current_val_lineA0,zigzag_current_val_lineA1,zigzag_current_val_lineA2,zigzag_current_val_lineA3,zigzag_current_val_lineA4,zigzag_current_val_lineA5;
double zigzag_current_val_lineA6,zigzag_current_val_lineA7,zigzag_current_val_lineA8,zigzag_current_val_lineA9,zigzag_current_val_lineA10;
double zigzag_current_val_lineA11,zigzag_current_val_lineA12,zigzag_current_val_lineA13,zigzag_current_val_lineA14,zigzag_current_val_lineA15;
double zigzag_current_val_lineA16,zigzag_current_val_lineA17,zigzag_current_val_lineA18,zigzag_current_val_lineA19,zigzag_current_val_lineA20;
double zigzag_current_val_lineA21,zigzag_current_val_lineA22,zigzag_current_val_lineA23,zigzag_current_val_lineA24,zigzag_current_val_lineA25;


bool zigzag_flag_to_open_order = false;
bool zigzag_met_within_8_bars =false ;
bool zigzag_met_within_10_bars =false ;
bool zigzag_met_within_14_bars =false ;
bool zigzag_met_within_18_bars =false ;
bool zigzag_met_within_20_bars =false ;
bool zigzag_met_within_25_bars = false;

double pip ;

//2. MACD Variable
int fast_ema_period = 21 ;
int slow_ema_period = 60 ;
int signal_line = 9 ;

double MACD_val_pre0[3],MACD_val_pre1[3],MACD_val_pre2[3];

int MACD_pivot_bar_index[5];
double MACD_pivot_bar_index_value_ModeMain[5];
double MACD_pivot_bar_index_value_ModeSignal[5];


//+------------------------------------------------------------------+
//| Custom Indicator Variable                                  |
//+------------------------------------------------------------------+

//1. custom indicator1 = "TheTurtleTradingChannel-short"
double custom_indicator1_val_pre0[3],custom_indicator1_val_pre1[3],custom_indicator1_val_pre2[3],custom_indicator1_val_pre3[3],custom_indicator1_val_pre4[3],custom_indicator1_val_pre5[3];
bool custom_indicator1_pivot_to_buy , custom_indicator1_pivot_to_sell;
input int TurtleTradePeriod_S = 2;
input int TurtleStopPeriod_S = 0;

bool custom_indicator1_repeat_3bars,custom_indicator1_repeat_4bars;
bool custom_indicator1_bar0_is_low =false;
bool custom_indicator1_bar1_is_low =false;
bool custom_indicator1_bar2_is_low =false;
bool custom_indicator1_bar3_is_low =false;
bool custom_indicator1_last_pivot_is_low ;
double custom_indicator1_last_pivot_val ;

//2. custom indicator2 = = "TheTurtleTradingChannel-long"
double custom_indicator2_val_pre0[3],custom_indicator2_val_pre1[3],custom_indicator2_val_pre2[3],custom_indicator2_val_pre3[3],custom_indicator2_val_pre4[3],custom_indicator2_val_pre5[3];
bool custom_indicator2_pivot_to_buy , custom_indicator2_pivot_to_sell;
input int TurtleTradePeriod_M = 10;
input int TurtleStopPeriod_M = 0;

bool custom_indicator2_bar0_is_low =false;
bool custom_indicator2_bar1_is_low =false;
bool custom_indicator2_bar2_is_low =false;
bool custom_indicator2_bar3_is_low =false;
bool custom_indicator2_last_pivot_is_low ;
double custom_indicator2_last_pivot_val ;
double custom_indicator2_diff_pre2_pre1_buy ;
double custom_indicator2_diff_pre2_pre1_sell;
bool TT_ShortAndLong_Meet_FirstBar_is_low; // these variables use for checking TT at the sameside on first met bar
int TT_ShortAndLong_Meet_FirstBar_Type; // 1. same time , 2. short before long, 3. long befor short

//3. custom indicator3 = = "TheTurtleTradingChannel-long"
double custom_indicator3_val_pre0[3],custom_indicator3_val_pre1[3],custom_indicator3_val_pre2[3],custom_indicator3_val_pre3[3],custom_indicator3_val_pre4[3],custom_indicator3_val_pre5[3];
bool custom_indicator3_pivot_to_buy , custom_indicator3_pivot_to_sell;
int TurtleTradePeriod_L = 30;
int TurtleStopPeriod_L = 0;


//+------------------------------------------------------------------+
//| Order Setting                                  |
//+------------------------------------------------------------------+
int      MagicNumber  = 2017;     //Magic Number
extern double   Lotsize = 0.1;     //Order Setting (Lot Size)
extern double   SL   = 00;     //Stop Loss (in Points)
extern double   TP   = 00;     //Take Profit (in Points)
extern int TS = 0; //Trailing Stop (in Points)

//+------------------------------------------------------------------+
//| Other Parameters                             |
//+------------------------------------------------------------------+

int barCount ; //just for debuging new Bar
int bar_last_open_contact ;
bool onceAbar =false;
datetime debug_0,debug_1 ,debug_2 ; //for testing only can be remove

//+------------------------------------------------------------------+
//| checkProfit and takeProfit parameters                            |
//+------------------------------------------------------------------+
//extern double Profit_Target_Default= 15;     //The amount of money profit at which you want to close ALL open trades.
//extern double StopLoss_Target_Default = -20;
//double StopLoss_Target ;
/*
extern int profit_target = 20 ;
extern int stoploss_target = -20;
extern int increment_profit_target = 10 ; // to get more profit, let's step up 
extern int retrace_val = 20; // if price drop from the best_profit do something !*/

int profit_target = 30 ;
int stoploss_target = -30;
int increment_profit_target = 10 ; // to get more profit, let's step up 
int retrace_val = 20; // if price drop from the best_profit do something !

int tp_counter =0; //check how many tp has been update
int best_profit = 0;

int profit_target_default;

extern int tp_slippage = 5;






//-----------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //Profit_Target = Profit_Target_Default;
   //StopLoss_Target =StopLoss_Target_Default;
   
   profit_target_default = profit_target;

   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit(){
   ObjectsDeleteAll(); 
   return(0);
}  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {  
text [3] = (countOrder(0))+","+(countOrder(1));
lastOrderDetailed();
   getAllParameter(); //Retreive all required data   
   checkProfit();   
   printInfo();  
   resetAll();  
}




void checkProfit(){    
   if (AccountProfit() > best_profit){ best_profit = AccountProfit();}
   
text[1] = "Counter: "+ tp_counter + " Profit: " + AccountProfit()+" (CTP = "+profit_target +" ,retrace = "+ retrace_val+")"; 
text[2]= "best profit: "+ best_profit + " , close when profit <: " + (best_profit - retrace_val);
    
   int orders_management = 0;
      if (AccountProfit() > profit_target){orders_management = 1;}
 //*********** i'm by pass tp_counter>=1 to 0 here*********//     
      if ((AccountProfit() < stoploss_target) || (tp_counter>=0)&& (AccountProfit() < best_profit - retrace_val)){ orders_management = 2;}
      
      if (((zigzag_last_pivot_is_low)&&(zigzag_pivot_bar_index_value[0] < zigzag_pivot_bar_index_value[2])) ||
           ((!zigzag_last_pivot_is_low)&&(zigzag_pivot_bar_index_value[0] > zigzag_pivot_bar_index_value[2])) ){ 
          // text [11] = "Skip CheckProfit(zigzag break): "+TimeCurrent();
           orders_management = 0;}

//by pass tempolary
//orders_management = 0; //*************************************
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// ADD R3 case1: TT short has pivot , ZZ - Bid > 6 , within ZZ <= 16 bars (Realtime)         
      switch (orders_management){
      //   case 1 : increaseProfitTarget();break;
      
         case 2 : closeOrderToTakeProfit();break;
         default: checkCondition(); //Do normal process;  
      }
}

void increaseProfitTarget(){
   tp_counter++;
   profit_target = profit_target + increment_profit_target ;   
}

void reset_checkProfitParameter(){
   //reset related tp,sl parameters;
   //Profit_Target = Profit_Target_Default;
   //StopLoss_Target = StopLoss_Target_Default;
   tp_counter = 0;
   best_profit = 0;
   profit_target = profit_target_default; 
}


void closeOrderToTakeProfit(){
    for(int i=OrdersTotal()-1;i>=0;i--) {
       OrderSelect(i, SELECT_BY_POS);
       int type   = OrderType();               
       bool result = false;              
       switch(type)
          {
          //Close opened long positions
          case OP_BUY  : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),tp_slippage,Gray);
            //text[4] = "SL: Close All BUY orders at price: "+ MarketInfo(OrderSymbol(),MODE_BID)+ " at: "+ TimeCurrent(); 
            reset_checkProfitParameter();
            break; 
               
          //Close opened short positions
          case OP_SELL : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),tp_slippage,Gray);
            //text[4] = "SL: Close All SELL orders at price: "+ MarketInfo(OrderSymbol(),MODE_ASK)+ " at: "+ TimeCurrent();
            reset_checkProfitParameter();
          }
           
       if(result == false)
          {
            Sleep(0);
          }  
       }      
      //return(0); //Returns true if successful, otherwise false. To get additional error information, one has to call the GetLastError() function.
}

  
//+------------------------------------------------------------------+  
void  getAllParameter(){ 
   DetectNewBar(); //Function detecting new bar 
   getZigzag_Value();
   getMACD_Value(); 
   getIndicator1_Value(); 
   getIndicator2_Value();
   getIndicator3_Value();    
}

//---------------Parameter-----------------




bool justOpen_Cliteria(){
   
   bool result = false; bool criteria_1 = true; bool criteria_2 = true;
   
   criteria_1 = true ; //thisIsNewBar;
   criteria_2 = (barCount - bar_last_open_contact >3);  
   
   if (criteria_1 && criteria_2){
      result = true;
   }
   
   return result;
}

void  getZigzag_Value(){
   
   zigzag_current_val_lineA0 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,0);
   zigzag_current_val_lineA1 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,1);
   zigzag_current_val_lineA2 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,2); 
   zigzag_current_val_lineA3 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,3); 
   zigzag_current_val_lineA4 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,4); 
   zigzag_current_val_lineA5 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,5); 
   zigzag_current_val_lineA6 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,6);  
   zigzag_current_val_lineA7 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,7);   
   zigzag_current_val_lineA8 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,8);   
   zigzag_current_val_lineA9 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,9);
   zigzag_current_val_lineA10 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,10);
   zigzag_current_val_lineA11 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,11);
   zigzag_current_val_lineA12 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,12);
   zigzag_current_val_lineA13 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,13);
   zigzag_current_val_lineA14 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,14);
   zigzag_current_val_lineA15 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,15);
   zigzag_current_val_lineA16 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,16);
   zigzag_current_val_lineA17 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,17);
   zigzag_current_val_lineA18 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,18);
   zigzag_current_val_lineA19 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,19);
   zigzag_current_val_lineA20 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,20);
   zigzag_current_val_lineA21 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,21);
   zigzag_current_val_lineA22 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,22);
   zigzag_current_val_lineA23 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,23);
   zigzag_current_val_lineA24 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,24);
   zigzag_current_val_lineA25 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,25);

/*
text[11] = zigzag_current_val_lineA0;
text[12] = zigzag_current_val_lineA1;
text[13] = zigzag_current_val_lineA2;
text[14] = zigzag_current_val_lineA3;
text[15] = zigzag_current_val_lineA4;
text[16] = zigzag_current_val_lineA5;
text[17] = zigzag_current_val_lineA6;
text[18] = zigzag_current_val_lineA7;
text[19] = zigzag_current_val_lineA8;
text[20] = zigzag_current_val_lineA9;*/

   
   zigzag_met_within_8_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 ) ); 


   zigzag_met_within_10_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 )|| (zigzag_current_val_lineA9 != 0 )||
                               (zigzag_current_val_lineA10 != 0 ) );

   zigzag_met_within_14_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 )|| (zigzag_current_val_lineA9 != 0 )||
                               (zigzag_current_val_lineA10 != 0 )|| (zigzag_current_val_lineA11 != 0 )||
                               (zigzag_current_val_lineA12 != 0 )|| (zigzag_current_val_lineA13 != 0 )||
                               (zigzag_current_val_lineA14 != 0 ) );


   zigzag_met_within_18_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 )|| (zigzag_current_val_lineA9 != 0 )||
                               (zigzag_current_val_lineA10 != 0 )|| (zigzag_current_val_lineA11 != 0 )||
                               (zigzag_current_val_lineA12 != 0 )|| (zigzag_current_val_lineA13 != 0 )||
                               (zigzag_current_val_lineA14 != 0 )|| (zigzag_current_val_lineA15 != 0 )||
                               (zigzag_current_val_lineA16 != 0 )|| (zigzag_current_val_lineA17 != 0 )||
                               (zigzag_current_val_lineA18 != 0 ) );


   zigzag_met_within_20_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 )|| (zigzag_current_val_lineA9 != 0 )||
                               (zigzag_current_val_lineA10 != 0 )|| (zigzag_current_val_lineA11 != 0 )||
                               (zigzag_current_val_lineA12 != 0 )|| (zigzag_current_val_lineA13 != 0 )||
                               (zigzag_current_val_lineA14 != 0 )|| (zigzag_current_val_lineA15 != 0 )||
                               (zigzag_current_val_lineA16 != 0 )|| (zigzag_current_val_lineA17 != 0 )||
                               (zigzag_current_val_lineA18 != 0 )|| (zigzag_current_val_lineA19 != 0 )||
                               (zigzag_current_val_lineA20 != 0 ) );

   zigzag_met_within_25_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 )|| (zigzag_current_val_lineA9 != 0 )||
                               (zigzag_current_val_lineA10 != 0 )|| (zigzag_current_val_lineA11 != 0 )||
                               (zigzag_current_val_lineA12 != 0 )|| (zigzag_current_val_lineA13 != 0 )||
                               (zigzag_current_val_lineA14 != 0 )|| (zigzag_current_val_lineA15 != 0 )||
                               (zigzag_current_val_lineA16 != 0 )|| (zigzag_current_val_lineA17 != 0 )||
                               (zigzag_current_val_lineA18 != 0 )|| (zigzag_current_val_lineA19 != 0 )||
                               (zigzag_current_val_lineA20 != 0 )|| (zigzag_current_val_lineA21 != 0 )|| 
                               (zigzag_current_val_lineA22 != 0 )|| (zigzag_current_val_lineA23 != 0 )|| 
                               (zigzag_current_val_lineA24 != 0 )|| (zigzag_current_val_lineA25 != 0 ) );
 
getZigzag_Last_Pivot();  // call function for clean code
//drawLine();  //draw zigzag vertical line for testing 
}//end function

void getMACD_Value(){
   // get value from loop within function getZigzag_Last_Pivot(){
//   MACD_pivot_bar_index_value_ModeMain[0]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_MAIN,0);
//   MACD_pivot_bar_index_value_ModeSignal[0]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_SIGNAL,0);

   MACD_val_pre0[0]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_MAIN,0);   
   MACD_val_pre0[1]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_SIGNAL,0);
   
   MACD_val_pre1[0]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_MAIN,1);   
   MACD_val_pre1[1]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_SIGNAL,1);

   MACD_val_pre2[0]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_MAIN,2);   
   MACD_val_pre2[1]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_SIGNAL,2);
   
  
}



void getIndicator1_Value(){ 
   
   
   custom_indicator1_val_pre0[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,0 );
   custom_indicator1_val_pre0[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 1,0 );    
   custom_indicator1_val_pre0[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 2,0 ); 

   custom_indicator1_val_pre1[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,1 );
   custom_indicator1_val_pre1[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 1,1 );    
   custom_indicator1_val_pre1[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 2,1 ); 
   
   custom_indicator1_val_pre2[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,2 );
   custom_indicator1_val_pre2[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 1,2 );    
   custom_indicator1_val_pre2[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 2,2 ); 
    
   custom_indicator1_val_pre3[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,3 );
   custom_indicator1_val_pre3[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 1,3 );    
   custom_indicator1_val_pre3[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 2,3 );    

   custom_indicator1_val_pre4[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,4 );
   custom_indicator1_val_pre4[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 1,4 );    
   custom_indicator1_val_pre4[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 2,4 );    
   
   custom_indicator1_val_pre5[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 0,5 );
   custom_indicator1_val_pre5[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 1,5 );    
   custom_indicator1_val_pre5[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_S,TurtleStopPeriod_S, false,false, 2,5 );  
 
   custom_indicator1_pivot_to_buy = (custom_indicator1_val_pre1[0]!= 2147483647 && custom_indicator1_val_pre2[0] == 2147483647);
   custom_indicator1_pivot_to_sell = (custom_indicator1_val_pre1[0]== 2147483647 && custom_indicator1_val_pre2[0] != 2147483647); 
   

   custom_indicator1_repeat_3bars = (custom_indicator1_val_pre2[0]!= 2147483647 && custom_indicator1_val_pre3[0] !=2147483647 && custom_indicator1_val_pre4[0] !=2147483647)
                                  || (custom_indicator1_val_pre2[0]== 2147483647 && custom_indicator1_val_pre3[0] ==2147483647 && custom_indicator1_val_pre4[0] ==2147483647) ;

   custom_indicator1_repeat_4bars = (custom_indicator1_val_pre2[0]!= 2147483647 && custom_indicator1_val_pre3[0] !=2147483647 && custom_indicator1_val_pre4[0] !=2147483647&& custom_indicator1_val_pre5[0] !=2147483647)
                                  || (custom_indicator1_val_pre2[0]== 2147483647 && custom_indicator1_val_pre3[0] ==2147483647 && custom_indicator1_val_pre4[0] ==2147483647&& custom_indicator1_val_pre5[0] ==2147483647) ;


   custom_indicator1_bar0_is_low = (custom_indicator1_val_pre0[0] != 2147483647) && (custom_indicator1_val_pre0[1] == 2147483647) ;
   custom_indicator1_bar1_is_low = (custom_indicator1_val_pre1[0] != 2147483647) && (custom_indicator1_val_pre1[1] == 2147483647) ;
   custom_indicator1_bar2_is_low = (custom_indicator1_val_pre2[0] != 2147483647) && (custom_indicator1_val_pre2[1] == 2147483647) ;
   custom_indicator1_bar3_is_low = (custom_indicator1_val_pre3[0] != 2147483647) && (custom_indicator1_val_pre3[1] == 2147483647) ;


   // if TT-short bar2 has upperline and bar1 has lowerline, The last pivot is low and have value at bar2[0]
   if (((custom_indicator1_val_pre2[0] != 2147483647) && (custom_indicator1_val_pre2[1] == 2147483647))&& 
      ((custom_indicator1_val_pre1[0] == 2147483647) && (custom_indicator1_val_pre1[1] != 2147483647))){
      custom_indicator1_last_pivot_is_low = true; 
      custom_indicator1_last_pivot_val = custom_indicator1_val_pre2[0];
      //text[4] = "inside 1 loop: "+TimeCurrent();
   
   }

   // if TT-short bar2 has lowerline and bar1 has upperline, The last pivot is high and have value at bar2[0]
   if (((custom_indicator1_val_pre2[0] == 2147483647) && (custom_indicator1_val_pre2[1] != 2147483647))&& 
      ((custom_indicator1_val_pre1[0] != 2147483647) && (custom_indicator1_val_pre1[1] == 2147483647))){
      custom_indicator1_last_pivot_is_low = false; 
      custom_indicator1_last_pivot_val = custom_indicator1_val_pre2[1];
      //text[5] = "inside 2 loop: " + TimeCurrent();
   }

} 
 
void getZigzag_Last_Pivot(){
      int i=0; int n = 0;
      int debug = 3; //this variable can delete for debug purpose
         while(i<5){
            double zigzag_temp1 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,n);
            if (zigzag_temp1 !=0) {
               zigzag_pivot_bar_index[i] = n ;
               MACD_pivot_bar_index[i] = n ;
               zigzag_pivot_bar_index_value[i] = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,n);
               
               //show value for analysis
               //text[debug] = zigzag_pivot_bar_index_value[i]+" at bar: "+ zigzag_pivot_bar_index[i];
                              
               MACD_pivot_bar_index_value_ModeMain[i]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_MAIN,n);
               MACD_pivot_bar_index_value_ModeSignal[i]= iMACD(NULL,0,fast_ema_period, slow_ema_period, signal_line,PRICE_CLOSE,MODE_SIGNAL,n);
               
//text[debug] = MACD_pivot_bar_index_value_ModeMain[i]+" at bar: "+ MACD_pivot_bar_index[i];
               
               i++ ;
               debug++; //this variable can delete for debug purpose
            }            
            n++;            
         }
      zigzag_last_pivot_is_low = zigzag_pivot_bar_index_value[0] < zigzag_pivot_bar_index_value[1]; 


      double diff_lastZigzag_with_TT;
         if (zigzag_last_pivot_is_low) {
            if (custom_indicator1_val_pre2[1]!= 2147483647){
            diff_lastZigzag_with_TT = custom_indicator1_val_pre2[1]-zigzag_pivot_bar_index_value[0]; }} // below
         else {
            if (custom_indicator1_val_pre2[0]!= 2147483647){
            diff_lastZigzag_with_TT = zigzag_pivot_bar_index_value[0] - custom_indicator1_val_pre2[0]; // upper
         }}
      pip= pipCalculation(diff_lastZigzag_with_TT);
            
      string lol = "";
      string hih = "";
      if ((zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[2])){ 
              lol= "True at " + TimeCurrent();
      
      } else { lol = "False";}
      if ((zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[2])){ 
              hih= "True at "+ TimeCurrent();      
      } else { hih = "False";}        
}

 
void getIndicator2_Value(){  
   custom_indicator2_val_pre0[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,0 );
   custom_indicator2_val_pre0[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 1,0 );    
   custom_indicator2_val_pre0[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 2,0 ); 

   custom_indicator2_val_pre1[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,1 );
   custom_indicator2_val_pre1[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 1,1 );    
   custom_indicator2_val_pre1[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 2,1 ); 
   
   custom_indicator2_val_pre2[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,2 );
   custom_indicator2_val_pre2[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 1,2 );    
   custom_indicator2_val_pre2[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 2,2 ); 
    
   custom_indicator2_val_pre3[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,3 );
   custom_indicator2_val_pre3[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 1,3 );    
   custom_indicator2_val_pre3[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 2,3 );    

   custom_indicator2_val_pre4[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,4 );
   custom_indicator2_val_pre4[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 1,4 );    
   custom_indicator2_val_pre4[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 2,4 );    
   
   custom_indicator2_val_pre5[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 0,5 );
   custom_indicator2_val_pre5[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 1,5 );    
   custom_indicator2_val_pre5[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_M,TurtleStopPeriod_M, false,false, 2,5 );  
  
   custom_indicator2_pivot_to_buy = (custom_indicator2_val_pre1[0]!= 2147483647 && custom_indicator2_val_pre2[0] == 2147483647);
   custom_indicator2_pivot_to_sell = (custom_indicator2_val_pre1[0]== 2147483647 && custom_indicator2_val_pre2[0] != 2147483647); 
     
   custom_indicator2_bar0_is_low = (custom_indicator2_val_pre0[0] != 2147483647) && (custom_indicator2_val_pre0[1] == 2147483647) ;
   custom_indicator2_bar1_is_low = (custom_indicator2_val_pre1[0] != 2147483647) && (custom_indicator2_val_pre1[1] == 2147483647) ;   
   custom_indicator2_bar2_is_low = (custom_indicator2_val_pre2[0] != 2147483647) && (custom_indicator2_val_pre2[1] == 2147483647) ;   
   custom_indicator2_bar3_is_low = (custom_indicator2_val_pre3[0] != 2147483647) && (custom_indicator2_val_pre3[1] == 2147483647) ;   

/// variable for M3 use//
   custom_indicator2_diff_pre2_pre1_buy = pipCalculation(custom_indicator2_val_pre2[1] - custom_indicator2_val_pre1[0]);
   custom_indicator2_diff_pre2_pre1_sell = pipCalculation(custom_indicator2_val_pre1[0] - custom_indicator2_val_pre0[1]); 
/// end variable for M3 use//

//text [4] = custom_indicator2_pivot_to_buy ;
//text [5] = custom_indicator2_pivot_to_sell ;

      // if TT-long bar2 has upperline and bar1 has lowerline, The last pivot is low and have value at bar2[0]
   if (((custom_indicator2_val_pre2[0] != 2147483647) && (custom_indicator2_val_pre2[1] == 2147483647))&& 
      ((custom_indicator2_val_pre1[0] == 2147483647) && (custom_indicator2_val_pre1[1] != 2147483647))){
      custom_indicator2_last_pivot_is_low = true; 
      custom_indicator2_last_pivot_val = custom_indicator2_val_pre2[0];
//      text[5] = "inside 1 loop: "+TimeCurrent();
   
   }

   // if TT-long bar2 has lowerline and bar1 has upperline, The last pivot is high and have value at bar2[0]
   if (((custom_indicator2_val_pre2[0] == 2147483647) && (custom_indicator2_val_pre2[1] != 2147483647))&& 
      ((custom_indicator2_val_pre1[0] != 2147483647) && (custom_indicator2_val_pre1[1] == 2147483647))){
      custom_indicator2_last_pivot_is_low = false; 
      custom_indicator2_last_pivot_val = custom_indicator2_val_pre2[1];
//      text[5] = "inside 2 loop: " + TimeCurrent();
   } 

//bool TT_ShortAndLong_Meet_FirstBar_is_low;
//int TT_ShortAndLong_Meet_FirstBar_Type; // 1. same time , 2. short before long, 3. long befor short-----------------------------------------------------------------------------

//case1: TTshort bar1 = high, TTlong bar1 = high ,TTshort bar2=low, TTlong bar2 =high
if (!custom_indicator1_bar1_is_low && !custom_indicator2_bar1_is_low && custom_indicator1_bar2_is_low &&  !custom_indicator2_bar2_is_low){   
   TT_ShortAndLong_Meet_FirstBar_is_low = false;
   TT_ShortAndLong_Meet_FirstBar_Type = 1; 
}  
 
//case1: TTshort bar1 = low, TTlong bar1 = low , TTshort bar2=high, TTlong bar2 =low
if (custom_indicator1_bar1_is_low && custom_indicator2_bar1_is_low && !custom_indicator1_bar2_is_low && custom_indicator2_bar2_is_low) { 
   TT_ShortAndLong_Meet_FirstBar_is_low = true;
   TT_ShortAndLong_Meet_FirstBar_Type = 1; 
}
//case2: TTshort bar1 = high, TTlong bar1 = high ,TTshort bar2=high, TTlong bar2 =low
if (!custom_indicator1_bar1_is_low && !custom_indicator2_bar1_is_low && !custom_indicator1_bar2_is_low  &&  custom_indicator2_bar2_is_low){   
   TT_ShortAndLong_Meet_FirstBar_is_low = false;
   TT_ShortAndLong_Meet_FirstBar_Type = 2; 
} 
  
//case2: TTshort bar1 = low, TTlong bar1 = low ,TTshort bar2=low, TTlong bar2 =high
if (custom_indicator1_bar1_is_low && custom_indicator2_bar1_is_low && custom_indicator1_bar2_is_low &&  !custom_indicator2_bar2_is_low) { 
   TT_ShortAndLong_Meet_FirstBar_is_low = true;
   TT_ShortAndLong_Meet_FirstBar_Type = 2; 
}
//case3: TTshort bar1 = high, TTlong bar1 = high ,TTshort bar2=low TTlong bar2 =low
if (!custom_indicator1_bar1_is_low && !custom_indicator2_bar1_is_low && custom_indicator1_bar2_is_low && custom_indicator2_bar2_is_low){ 
   TT_ShortAndLong_Meet_FirstBar_is_low = false;
   TT_ShortAndLong_Meet_FirstBar_Type = 3;  
}   
//case3: TTshort bar1 = low, TTlong bar1 = low ,TTshort bar2=high TTlong bar2 = high
if (custom_indicator1_bar1_is_low && custom_indicator2_bar1_is_low && !custom_indicator1_bar2_is_low && !custom_indicator2_bar2_is_low) { 
   TT_ShortAndLong_Meet_FirstBar_is_low = true;
   TT_ShortAndLong_Meet_FirstBar_Type = 3;    
}
//case4: TTshort bar1 = high, TTlong bar1 = high ,TTshort bar2=high TTlong bar2 = high
if (!custom_indicator1_bar1_is_low && !custom_indicator2_bar1_is_low && !custom_indicator1_bar2_is_low && !custom_indicator2_bar2_is_low){ 
   TT_ShortAndLong_Meet_FirstBar_is_low = false;
   TT_ShortAndLong_Meet_FirstBar_Type = 4;  
}   
//case4: TTshort bar1 = low, TTlong bar1 = low ,TTshort bar2=low TTlong bar2 = low
if (custom_indicator1_bar1_is_low && custom_indicator2_bar1_is_low && custom_indicator1_bar2_is_low && custom_indicator2_bar2_is_low) { 
   TT_ShortAndLong_Meet_FirstBar_is_low = true;
   TT_ShortAndLong_Meet_FirstBar_Type = 4;    
}     
                            
}

double pipCalculation(double price_to_convert_to_pip){
   int point_compat = 1;
   if(Digits == 3 || Digits == 5) point_compat = 10;   
   //double DiffPips = MathAbs((NormalizeDouble(((price_to_convert_to_pip)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/point_compat); 
   double DiffPips = (NormalizeDouble(((price_to_convert_to_pip)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/point_compat;    
   return DiffPips; 
}

void getIndicator3_Value(){
   custom_indicator3_val_pre0[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,0 );
   custom_indicator3_val_pre0[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,0 );    
   custom_indicator3_val_pre0[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,0 ); 

   custom_indicator3_val_pre1[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,1 );
   custom_indicator3_val_pre1[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,1 );    
   custom_indicator3_val_pre1[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,1 ); 
   
   custom_indicator3_val_pre2[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,2 );
   custom_indicator3_val_pre2[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,2 );    
   custom_indicator3_val_pre2[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,2 ); 
    
   custom_indicator3_val_pre3[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,3 );
   custom_indicator3_val_pre3[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,3 );    
   custom_indicator3_val_pre3[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,3 );    

   custom_indicator3_val_pre4[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,4 );
   custom_indicator3_val_pre4[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,4 );    
   custom_indicator3_val_pre4[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,4 );    
   
   custom_indicator3_val_pre5[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,5 );
   custom_indicator3_val_pre5[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,5 );    
   custom_indicator3_val_pre5[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,5 ); 

   custom_indicator3_pivot_to_buy = (custom_indicator3_val_pre1[0]!= 2147483647 && custom_indicator3_val_pre2[0] == 2147483647);
   custom_indicator3_pivot_to_sell = (custom_indicator3_val_pre1[0]== 2147483647 && custom_indicator3_val_pre2[0] != 2147483647);
/*
text[9] = "TT-2 Bar0: " +custom_indicator1_val_pre0[0];
text[10] = "TT-10 Bar0: " +custom_indicator2_val_pre0[0];
text[11] = "TT-30 Bar0: " +custom_indicator3_val_pre0[0];
text[12] = "TT-30 Bar0: " +custom_indicator3_val_pre1[0];
text[13] = "TT-30 Bar0: " +custom_indicator3_val_pre2[0];*/
}


//+-------------------------------------------------------------------------------------------------------------------->>>>>>>>>>>>
void  checkCondition(){   

//--------------------------
emergency_Exit();  // call emergency stop function.
//--------------------------    
collectionOrder(); // call collection order function.


//function variable using on M1 and M4
int highest_bar_14bars =iHighest(NULL,0,MODE_HIGH,14,0);
double highest_14bars = iHigh(NULL, 0, iHighest(NULL,0,MODE_HIGH,14,0) );
int lowest_bar_14bars =iLowest(NULL,0,MODE_LOW,14,0);
double lowest_14bars = iLow(NULL, 0, iLowest(NULL,0,MODE_LOW,14,0) );

/*
//---------------------------------------------------------------------------------
// Strategy M1: " Normal Open Order"BOSS
//1. TT's short pivot at bar 1 and bar 2 //2. zigzag has value within 10 bars 0-10 (actually 11 bars)//3. when the different between TT's short upper line and lower line > 190 pips 
//5. Close All existing orders. //6. Open order on reverse TT //7. stop loss when price exceed ZZ

   if (custom_indicator1_repeat_4bars && ((zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[2]) && (zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[1]) && 
   (zigzag_pivot_bar_index_value[2]< zigzag_pivot_bar_index_value[1])) && custom_indicator1_pivot_to_buy && zigzag_met_within_14_bars && custom_indicator1_bar0_is_low  && 
   justOpen_Cliteria()&& (lowest_14bars <= custom_indicator1_val_pre1[0])){
      //double stoploss;
text[15] = "inside M1 BUY"+TimeCurrent();
      closeAllSellOrder();
      if(custom_indicator1_bar0_is_low && !custom_indicator2_bar0_is_low && (countOrder(0)< 2)){
         openBuyWithSL ("BUY MAJOR ZZ",zigzag_pivot_bar_index_value[0]-(45*Point));    
      bar_last_open_contact = barCount; 
      }
      //text[4] = "BUY MINOR :" + " at "+ TimeCurrent()+","+" SL at: " + (zigzag_pivot_bar_index_value[0]-(30*Point));
      return;
   }
   if (custom_indicator1_repeat_4bars && ((zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[2])&& (zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[1]) && 
   (zigzag_pivot_bar_index_value[2]> zigzag_pivot_bar_index_value[1])) && custom_indicator1_pivot_to_sell && zigzag_met_within_14_bars && !custom_indicator1_bar0_is_low && 
   justOpen_Cliteria()&& (highest_14bars >= custom_indicator1_val_pre1[1])){
      //double stoploss;
text[16] = "inside M1 SELL"+TimeCurrent();
      closeAllBuyOrder();      
      if(!custom_indicator1_bar0_is_low && custom_indicator2_bar0_is_low && (countOrder(1)< 2)){
         openSellWithSL ("SELL MAJOR ZZ",zigzag_pivot_bar_index_value[0]+(45*Point));   
      }
      
      bar_last_open_contact = barCount; 
      //text[5] = "SELL MINOR :" + " at "+ TimeCurrent()+","+" SL at: "+zigzag_pivot_bar_index_value[0]+(30*Point);
      return;
   }   
//END--- Strategy M1: " Normal Open Order"  

/*
//---------------------------------------------------------------------------------
// Strategy M2: "Follow Big trend strategy"
// if upperline Short and Long first met on the same directions, do close wrong way and open the right way !
//---------------------------------------------------------------------------------
double a = custom_indicator2_val_pre0[0]; //TT long upper at bar 0
double b = custom_indicator2_val_pre0[1]; //TT long lower at bar 0
double c = custom_indicator2_val_pre2[0]; //TT long upper at bar 2
double d = custom_indicator2_val_pre2[1]; //TT long lower at bar 2
double e = custom_indicator1_val_pre2[0]; //TT short upper at bar 2
double f = custom_indicator1_val_pre2[1]; //TT short lower at bar 2

text[1] = "TT long at bar 0 (upper/lower): "+ a+","+b;
text[2] = "TT long at bar 2 (upper): "+c;
text[3] = "TT long at bar 2 (lower): "+d;

double dif_pip_TT2pre2Lower_TT2pre0Upper;
double dif_pip_TT2pre0Lower_TT2pre2Upper;
double dif_pip_TT1pre2Lower_TT2pre0Upper;
double dif_pip_TT2pre0Lower_TT1pre2Upper;

if ((a != 2147483647) && (d!=2147483647)){
      dif_pip_TT2pre2Lower_TT2pre0Upper = pipCalculation(d-a);
 /*  text[4] = "-------------------------------";
   text[5] = "Diff TT long lower bar2 - TT long upper bar0: "+(d-a);
   text[6] = "Diff in pip: "+ dif_pip_TT2pre2Lower_TT2pre0Upper;
   text[7] = "at time: "+TimeCurrent();      
} else{dif_pip_TT2pre2Lower_TT2pre0Upper = 0;}
if ((b != 2147483647) && (c!=2147483647)){
      dif_pip_TT2pre0Lower_TT2pre2Upper = pipCalculation(b-c); 
 /*  text[8] = "-------------------------------";
   text[9] = "Diff TT long lower bar0 - TT long upper bar2: "+(b -c);
   text[10] = "Diff in pip: "+ dif_pip_TT2pre0Lower_TT2pre2Upper;
   text[11] = "at time: "+TimeCurrent();        
}else{dif_pip_TT2pre0Lower_TT2pre2Upper;}
if ((a != 2147483647) && (f!=2147483647)){
       dif_pip_TT1pre2Lower_TT2pre0Upper = pipCalculation(f-a);
/*   text[12] = "-------------------------------";
   text[13] = "Diff TT short lower bar2 - TT long upper bar0 : "+(f-a);   
   text[14] = "Diff in pip: "+ dif_pip_TT1pre2Lower_TT2pre0Upper;
   text[15] = "at time: "+TimeCurrent();      
}else{dif_pip_TT1pre2Lower_TT2pre0Upper;} 
if ((b != 2147483647) && (e!=2147483647)){
       dif_pip_TT2pre0Lower_TT1pre2Upper = pipCalculation(b-e);
 /*  text[16] = "-------------------------------";
   text[17] = "Diff TT long upper bar0 - TT short upper bar2 : "+(b -e);   
   text[18] = "Diff in pip: "+ dif_pip_TT2pre0Lower_TT1pre2Upper;
   text[19] = "at time: "+TimeCurrent(); 
}else{dif_pip_TT2pre0Lower_TT1pre2Upper;}
    
int limit = 16;
bool is_dif_TT0_and_TT2_greater_than_limit = (((dif_pip_TT2pre2Lower_TT2pre0Upper >= limit)) ||
                                              ((dif_pip_TT2pre0Lower_TT2pre2Upper >= limit)) ||
                                              ((dif_pip_TT1pre2Lower_TT2pre0Upper >= limit)) ||
                                              ((dif_pip_TT2pre0Lower_TT1pre2Upper >= limit)));  
                                              
//text[20] = is_dif_TT0_and_TT2_greater_than_limit+","+dif_pip_TT2pre2Lower_TT2pre0Upper+","+dif_pip_TT2pre0Lower_TT2pre2Upper+","+dif_pip_TT1pre2Lower_TT2pre0Upper+","+dif_pip_TT2pre0Lower_TT1pre2Upper;
   if (is_dif_TT0_and_TT2_greater_than_limit&&(custom_indicator1_bar0_is_low && custom_indicator2_bar0_is_low) && justOpen_Cliteria()){      
      closeAllSellOrder(); 
      
      if (OrdersTotal() == 0){
         openBuy("BUY 2TT"); 
         bar_last_open_contact = barCount; 
      }

      //text[7] = "TT Buttom Close All Sell :" + " at "+ TimeCurrent();
      return;
   }   

   if (is_dif_TT0_and_TT2_greater_than_limit&&(!custom_indicator1_bar0_is_low && !custom_indicator2_bar0_is_low) &&  justOpen_Cliteria()){
      closeAllBuyOrder(); 
      
      if (OrdersTotal() == 0){
         openSell("SELL 2TT");
         bar_last_open_contact = barCount;    
      }

      //text[8] = "TT Top Close All Buy :" + " at "+ TimeCurrent();  
      return;   
            
   }       
//END-- Strategy M2: "Follow Big trend strategy"  */

/*
//---------------------------------------------------------------------------------
// Strategy M3: 
// - when TT long has pivot: 
// - TT long have differnt from Lower & Upper > 15
// - if so, close it and open right one 
//---------------------------------------------------------------------------------

text[9] = custom_indicator2_diff_pre2_pre1_buy;
text[10] =  custom_indicator2_diff_pre2_pre1_sell; 


   if (custom_indicator2_bar1_is_low && !custom_indicator2_bar2_is_low && (custom_indicator2_diff_pre2_pre1_buy>15) && onceAbar ){
      closeAllSellOrder();   
      openBuy("BUY M3");  
      return;
   }

   if (!custom_indicator2_bar1_is_low && custom_indicator2_bar2_is_low && (custom_indicator2_diff_pre2_pre1_sell>15) && onceAbar ){ 
         closeAllBuyOrder();     
         openSell("SELL M3");  
         return;            
   }

}*/

//---------------------------------------------------------------------------------
// Strategy M4: Higher High / Lower Low
// - When: Higher High , at ZZ pivot0 using MACD value > 0.0003
// - When: Lower Low , at ZZ pivot0 using MACD value < -0.0003
// - 4.1.1 HH, TT_M change from L to H, MACD cross down, First Bar -> Close Buy and Open Sell with SL zz+30
// - 4.1.2 LL, TT_M change from H to L, MACD cross up, First Bar -> Close Sell and Open Buy with SL zz-30
// - 4.2.1 HH, TT_L change from L to H  -> Close Buy and Open Sell with SL zz+30(if not exist)
// - 4.2.2 LL, TT_L change from H to L -> CloseSell and Open Buy with SL zz-30(if not exist)


bool lowerLow_flag = (zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[2])&& (zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[1]);
bool higherHigh_flag = (zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[2])&& (zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[1]);
bool TT_M_change_LtoH = custom_indicator2_pivot_to_buy;
bool TT_M_change_HtoL = custom_indicator2_pivot_to_sell;
bool TT_L_change_LtoH = custom_indicator3_pivot_to_buy;
bool TT_L_change_HtoL = custom_indicator3_pivot_to_sell;
bool MACD_cross_down = ((MACD_val_pre0[0]<MACD_val_pre0[1])&& (MACD_val_pre1[0]>MACD_val_pre1[1])&& (MACD_val_pre0[0] < -0.0003));
bool MACD_cross_up = ((MACD_val_pre0[0]>MACD_val_pre0[1])&& (MACD_val_pre1[0]<MACD_val_pre1[1])&& (MACD_val_pre0[0] > 0.0003));

text[3]= "lowerLow_flag: "+lowerLow_flag ;
text[4]= "higherHigh_flag: "+higherHigh_flag ;
text[5]= "TT_M_change_LtoH: "+TT_M_change_LtoH ;
text[6]= "TT_M_change_HtoL: "+TT_M_change_HtoL ;
text[7]= "TT_L_change_LtoH: "+TT_L_change_LtoH ;
text[8]= "TT_L_change_HtoL: "+TT_L_change_HtoL ;
text[9]= "MACD_cross_down: "+MACD_cross_down ;
text[10]= "MACD_cross_up: "+MACD_cross_up;


if (higherHigh_flag && TT_M_change_LtoH && MACD_cross_down && onceAbar){
   closeAllBuyOrder();   
   openSellWithSL ("SELL M4",zigzag_pivot_bar_index_value[0]+(30*Point));
   return;
}
if (lowerLow_flag && TT_M_change_HtoL && MACD_cross_up && onceAbar){
   closeAllSellOrder();
   openBuyWithSL ("BUY M4",zigzag_pivot_bar_index_value[0]-(30*Point));
   return;
}
if (higherHigh_flag && TT_L_change_LtoH && onceAbar){
   closeAllBuyOrder();   
   if (countOrder(1)== 0){openSellWithSL ("SELL M4",zigzag_pivot_bar_index_value[0]+(30*Point));}
   return;
}
if (lowerLow_flag && TT_L_change_HtoL && onceAbar){
   closeAllSellOrder();
   if (countOrder(0) == 0) {openBuyWithSL ("BUY M4",zigzag_pivot_bar_index_value[0]-(30*Point));}
   return;
}

 
 
/*
   if (((zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[2]) && (zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[1]) && 
   (zigzag_pivot_bar_index_value[2]< zigzag_pivot_bar_index_value[1])) && custom_indicator2_pivot_to_buy && zigzag_met_within_25_bars && onceAbar ){
//         if ((countOrder(1)>0)){
            text[11] =  "inside M4 BUY "+TimeCurrent(); 
            closeAllSellOrder();
//            openBuy("BUY M4");
            openBuyWithSL ("BUY M4",zigzag_pivot_bar_index_value[0]-(30*Point));
//            return;
//         }

   }
//   if (zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[1] && custom_indicator2_pivot_to_sell && onceAbar ){ //&& zigzag_met_within_20_bars && (zigzag_pivot_bar_index_value[0] >= custom_indicator2_val_pre1[1])&& (countOrder(0)!=0)
   if (((zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[2])&& (zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[1]) && 
   (zigzag_pivot_bar_index_value[2]> zigzag_pivot_bar_index_value[1])) && custom_indicator2_pivot_to_sell && zigzag_met_within_25_bars && onceAbar ){        
//         if ((countOrder(0)>0)){
            text[12] =  "inside M4 SELL "+TimeCurrent();
            closeAllBuyOrder();   
//            openSell("SELL M4");
            openSellWithSL ("SELL M4",zigzag_pivot_bar_index_value[0]+(30*Point));
//         return;
//         }
    }*/ 


/*
// test M5 where to put code-----------------------------------------------------
//lower low
//   if ((countOrder(0)!=0)&&(zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[2])&& (zigzag_pivot_bar_index_value[0]< zigzag_pivot_bar_index_value[1])&& (!custom_indicator1_bar1_is_low && !custom_indicator2_bar1_is_low)){ //strong trend open follow
   if ((countBarFromLastOrder()>0 ) && (countBarFromLastOrder()<=40 ) && (countOrder(0)!=0) && custom_indicator2_pivot_to_sell && onceAbar){
         closeAllBuyOrder ();
         openSell("SELL M5");
         return;
      }
//higher high      
//   if ((countOrder(1)!=0)&&(zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[2])&& (zigzag_pivot_bar_index_value[0]> zigzag_pivot_bar_index_value[1]) && (custom_indicator1_bar1_is_low && custom_indicator2_bar1_is_low)) {
   if ((countBarFromLastOrder()>0 ) && (countBarFromLastOrder()<=40 )  && (countOrder(1)!=0) && custom_indicator2_pivot_to_buy && onceAbar){
         closeAllSellOrder ();
         openBuy("BUY M5");
         return;
      }      

*/
     
}






//12.59
void emergency_Exit(){

/*
//---------------------------------------------------------------------------------   
// Strategy EX1: follow trend strategy
// if current TT is higher or lower than the last pivot do something!
// if have orders before pivot close it and open reverse
// count bar from last order within 10
//---------------------------------------------------------------------------------

   if(custom_indicator1_bar0_is_low && (custom_indicator1_val_pre1[0] > custom_indicator1_last_pivot_val) && (countOrder(0)<1) && (countOrder(1)>0) && (zigzag_met_within_10_bars)&& onceAbar){
   
      closeAllSellOrder();
      openBuy("BUY EX1");            
      //text[14] = "Open Buy Upperline cross TT up at: "+ TimeCurrent();
      return;
   }

   if(!custom_indicator1_bar0_is_low && (custom_indicator1_val_pre1[1] < custom_indicator1_last_pivot_val)&& (countOrder(1)<1) && (countOrder(0)>0) && (zigzag_met_within_10_bars)&&onceAbar){

      closeAllBuyOrder();
      openSell("SELL EX1");
      //text[15] = "Open Sell Lowerline cross TT cross down at: "+ TimeCurrent();
      return;
   }
//End-- Strategy EX1: follow trend strategy */

/*  
//---------------------------------------------------------------------------------
//strategy EX2 : "Emergency Exit Realtime"
// - if realtime price is break the TT long line more than 80 pip, action
//---------------------------------------------------------------------------------
//text[1] = "Bid,Ask: "+ Bid +","+ Ask;
//text[2] = custom_indicator2_val_pre0[0]+","+ custom_indicator2_val_pre1[1];
//text[3] = (Bid- custom_indicator2_val_pre1[1])+","+(custom_indicator2_val_pre1[0]-Ask); 


double price_bid_breakUp_TT_long = pipCalculation(Bid - custom_indicator2_val_pre1[1]);
double price_ask_breakDown_TT_long = pipCalculation(custom_indicator2_val_pre1[0]-Ask);

//text[4] = Bid - custom_indicator2_val_pre1[1];
//text[5] = custom_indicator2_val_pre1[0]-Ask; 
//text[6] = "----------------------------";
//text[7] = price_bid_breakUp_TT_long;
//text[8] = price_ask_breakDown_TT_long; 

   if ((price_bid_breakUp_TT_long>2.5)&&(countOrder(0)== 0) && onceAbar){
      //text[5] =  "inside EX2 BUY "+TimeCurrent();
      closeAllSellOrder();
      openBuy("BUY EX2");
      return;
   }
   
   if ((price_ask_breakDown_TT_long>2.5)&&(countOrder(1)==0)&& onceAbar){
      //text[6] =  "inside EX2 SELL "+TimeCurrent();   
      closeAllBuyOrder();
      openSell("SELL EX2");
      return;
   }
//End-- strategy EX2 : "Emergency Exit Realtime"*/


//---------------------------------------------------------------------------------   
/*   // Exit 1. if the close price of the both previous two bars confirmed their direction
//---------------------------------------------------------------------------------   
   if((Close[1] > custom_indicator1_val_pre1[1]) && (custom_indicator1_val_pre1[1]!=2147483647) ){ //&& (Close[2] > custom_indicator1_val_pre2[1])
      closeAllSellOrder();
      text[23] = "2 Close higher than Lowerline:"+ TimeCurrent();
      return;
   }
   
   if((Close[1] < custom_indicator1_val_pre1[0]) && (custom_indicator1_val_pre1[0]!=2147483647)){ //&& (Close[2] < custom_indicator1_val_pre2[0])
      closeAllBuyOrder(); 
      text[23] = "2 Close lower than Lowerline:"+TimeCurrent();
      return;
   }     */
   
   
/* Follow Open thru direction confirmed   
   if (custom_indicator1_repeat_3bars && custom_indicator1_bar0_is_low && custom_indicator2_bar0_is_low && thisIsNewBar){
      openBuy("BUY MINOR");     
   } 
   if (custom_indicator1_repeat_3bars && !custom_indicator1_bar0_is_low && !custom_indicator2_bar0_is_low && thisIsNewBar ){
      openSell("SELL MINOR");    
   }
 
   if ((custom_indicator1_repeat_3bars && custom_indicator1_pivot_to_buy  && custom_indicator1_bar0_is_low && custom_indicator2_bar0_is_low && thisIsNewBar)){
      openBuy("BUY MINOR");
      text[9] = "Reopen Buy :" + " at "+ TimeCurrent();      
      return;
   }


   if ((custom_indicator1_repeat_3bars && custom_indicator1_pivot_to_sell && !custom_indicator1_bar0_is_low && !custom_indicator2_bar0_is_low &&  thisIsNewBar)){
      openSell("SELL MINOR"); 
      text[10] = "Reopen Sell :" + " at "+ TimeCurrent();       
      return;
   }   */             
}

void collectionOrder(){

/*
//---------------------------------------------------------------------------------
// Strategy C1: 
// condition checking when just open order but It's seem wrong as it still sideway within 3 bars
//---------------------------------------------------------------------------------
//text[17] = countBarFromLastOrder()+","+TimeCurrent();
   if ((countBarFromLastOrder()>0 ) && (countBarFromLastOrder()<=6 ) && onceAbar){
      if((lastOrderType()== 0)&& (custom_indicator1_val_pre0[1] !=  2147483647)) {
         closeAllBuyOrder();
         openSell("SELL C1");
//text[17] = countBarFromLastOrder()+","+TimeCurrent();
      return;
      }
   }

   if ((countBarFromLastOrder()>0 ) && (countBarFromLastOrder()<=6 )&& onceAbar){
      if((lastOrderType()== 1)&& (custom_indicator1_val_pre0[0] !=  2147483647)) {
         closeAllSellOrder();
         openBuy("BUY C1");
//text[17] = countBarFromLastOrder()+","+TimeCurrent();
      return;
      }
   }
   
// End Strategy C1: 

/*
//---------------------------------------------------------------------------------
// Strategy C2: Collection Order
// - at bar1 have TT short and long on the same side.
// - no right direction's order 
// - (lower case) close at bar1 > TT short +100 / (upper case) Close at bar1 < TT short-100
// - close incorrect direction's order and open right direction's order.
//---------------------------------------------------------------------------------


//if (!custom_indicator1_bar1_is_low && !custom_indicator2_bar1_is_low && !custom_indicator1_bar2_is_low && !custom_indicator2_bar2_is_low){
if ((TT_ShortAndLong_Meet_FirstBar_Type == 4) && (TT_ShortAndLong_Meet_FirstBar_is_low = false)){
   //lower case
   if((pipCalculation(custom_indicator1_val_pre1[1]- Close[1]) > 4)&& countOrder(1) == 0){
      closeAllBuyOrder();
      openSell("SELL C2");
      return;     
   }
}   

//if (custom_indicator1_bar1_is_low && custom_indicator2_bar1_is_low && custom_indicator1_bar2_is_low && custom_indicator2_bar2_is_low) {   
if ((TT_ShortAndLong_Meet_FirstBar_Type == 4) && (TT_ShortAndLong_Meet_FirstBar_is_low = true)){ 
   //upper case
   if((pipCalculation(Close[1]-custom_indicator1_val_pre1[0]) > 4)&& countOrder(0) == 0){
      closeAllSellOrder();
      openBuy("BUY C2");
      return;
   }  
}
// End-- Strategy C2: Collection Order   */



/*
//---------------------------------------------------------------------------------
// Strategy C3: 
// - at bar2 have TT short and long on the same side.
// - have right direction's order 
// - (lower case) close at bar1 > TT long bar2 / (upper case) Close at bar1 < TT long bar2
// - close the right order and open reverse
//---------------------------------------------------------------------------------
/*
text[1] = custom_indicator1_bar2_is_low+","+custom_indicator2_bar2_is_low;
text[2] = Close[1]+","+ custom_indicator1_val_pre2[0]+","+custom_indicator1_val_pre2[1];
text[3] = (custom_indicator2_val_pre2[0]-Close[1]) > 0;
text[4] = (Close[1]-custom_indicator2_val_pre2[1]) > 0;

   if (custom_indicator1_bar2_is_low && custom_indicator2_bar2_is_low && custom_indicator1_bar3_is_low && custom_indicator2_bar3_is_low && onceAbar){
      //Both upper line TT
      if((pipCalculation(custom_indicator2_val_pre2[0]-Close[1]) > 4)&& countOrder(0) >= 1){  
         closeAllBuyOrder();
         openSell("SELL C3");
//text[6] = "HIT HIT BUTTOM: " +TimeCurrent(); 
         return;
      }
   }   
   if (!custom_indicator1_bar2_is_low && !custom_indicator2_bar2_is_low &&  !custom_indicator1_bar3_is_low && !custom_indicator2_bar3_is_low && onceAbar){   
      //Both lower line TT 
      if((pipCalculation(Close[1]-custom_indicator2_val_pre2[1]) > 4)&& countOrder(1) >= 1){ 
         closeAllSellOrder();
         openBuy("BUY C3");
//text[6] = "HIT HIT TOP: " +TimeCurrent();    
         return;
         }
      }
//End-- Strategy C3: */

/*
//---------------------------------------------------------------------------------
// Strategy C4: 
// - when TT long has pivot: lookback within 20 bars
// - if have wrong position, close it and open right one 
//---------------------------------------------------------------------------------
//text [5] ="Count from last bar: " +countBarFromLastOrder();
   if (custom_indicator2_bar1_is_low && !custom_indicator2_bar2_is_low && countBarFromLastOrder() >= 20 && countOrder(1)!=0){
      closeAllSellOrder();
//text [6] ="HIT C4: "+ TimeCurrent();      
      openBuy("BUY C4");  
      return;
   }

   if (!custom_indicator2_bar1_is_low && custom_indicator2_bar2_is_low && countBarFromLastOrder()  >= 20 && countOrder(0)!=0){
         closeAllBuyOrder();
//text [6] ="HIT C4: "+ TimeCurrent();           
         openSell("SELL C4");  
         return;            
   }

//End-- Strategy C4:*/


//---------------------------------------------------------------------------------
// Strategy C5: 
// - when TT long & short have same side: lookback more than 20 bars
// - if have wrong position, close it and open right one 
//---------------------------------------------------------------------------------
/*text [5] ="Count from last bar: " +countBarFromLastOrder();
text [5] = ((custom_indicator1_bar1_is_low) && (custom_indicator2_bar1_is_low) && (!custom_indicator1_bar2_is_low) || (!custom_indicator2_bar2_is_low) );
text [6] = ((!custom_indicator1_bar1_is_low) && (!custom_indicator2_bar2_is_low) && (custom_indicator1_bar2_is_low || custom_indicator2_bar2_is_low) ); 
text [7] = ((custom_indicator1_bar1_is_low) && (custom_indicator2_bar1_is_low) );
text [8] = ((!custom_indicator1_bar1_is_low) && (!custom_indicator2_bar2_is_low) ); 
text [9] = ( (!custom_indicator1_bar2_is_low) || (!custom_indicator2_bar2_is_low) );
text [10] = ((custom_indicator1_bar2_is_low || custom_indicator2_bar2_is_low) ); 
   if ((custom_indicator1_bar1_is_low) && (custom_indicator2_bar1_is_low) && ((!custom_indicator1_bar2_is_low) || (!custom_indicator2_bar2_is_low)) && countBarFromLastOrder() >= 10 && (countOrder(1)!=0)){
        closeAllSellOrder();
        openBuy("BUY C5");  
      return;
   }

   if ((!custom_indicator1_bar1_is_low) && (!custom_indicator2_bar1_is_low) && ((custom_indicator1_bar2_is_low) || (custom_indicator2_bar2_is_low)) && countBarFromLastOrder() >= 10 && (countOrder(0)!=0)){
         closeAllBuyOrder();
         openSell("SELL C5");  
         return;            
   }
//End-- Strategy C5: */
}


//---------------Press Order-----------------
// Order send
void openBuy (string comment) {   
   double tp = Ask+(TP*Point);
   double sl = Bid -(SL*Point); //setting stop loss when open buy 100
   if (TP == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130
   if (SL == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_BUY,Lotsize ,Ask,3,sl,tp,comment,MagicNumber,0,clrGreen); 

onceAbar = false ; 
}

void openSell(string comment){
   double tp = Bid-(TP*Point);
   double sl = Ask+(SL*Point); //setting stop loss when open buy 100   
   if (TP == 0) { tp =0;}
   if (SL == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_SELL,Lotsize ,Bid,3,sl,tp,comment,MagicNumber,0,clrRed);  

onceAbar = false ;      
}

void openBuyWithSL (string comment,double stopLossPrice) { 
   double tp = Ask+(TP*Point);  
   if (TP == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130   
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_BUY,Lotsize ,Ask,3,stopLossPrice,tp,comment,MagicNumber,0,clrGreen);   

onceAbar = false ; 
}

void openSellWithSL(string comment,double stopLossPrice){
   double tp = Bid-(TP*Point);
   if (TP == 0) { tp =0;}   
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_SELL,Lotsize ,Bid,3,stopLossPrice,tp,comment,MagicNumber,0,clrRed); 

onceAbar = false ;  
}


void closeAllBuyOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){ 
      string orderComment = StringSubstr(OrderComment(),0,9);    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);
            }
         }
      }
onceAbar = false ;       
reset_checkProfitParameter();
}

// close all opening sell order by order comment
void closeAllSellOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){
      string orderComment = StringSubstr(OrderComment(),0,10);           
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0); 
            }         
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();      
}


void closeAllBuyMajorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){  
      string orderComment = StringSubstr(OrderComment(),0,9);
         if (orderComment == "BUY MAJOR"){    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);                              
            }
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();   
}

// close all opening order
void closeAllSellMajorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){
         string orderComment = StringSubstr(OrderComment(),0,10);
         if (orderComment == "SELL MAJOR"){    
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
            }
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();   
}

void closeAllBuyMinorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){  
      string orderComment = StringSubstr(OrderComment(),0,9);
         if (orderComment == "BUY MINOR"){    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);
            }
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();   
}


void closeAllSellMinorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){
      string orderComment = StringSubstr(OrderComment(),0,10);
         if (orderComment == "SELL MINOR"){    
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
            }
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();   
}

void closeAllBuyESOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){  
      string orderComment = StringSubstr(OrderComment(),0,9);
         if (orderComment == "BUY ES"){    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0); 
            }
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();   
}


void closeAllSellESOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){
      string orderComment = StringSubstr(OrderComment(),0,10);
         if (orderComment == "SELL ES"){    
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
            }
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();   
}

// close all opening order
void closeAllOrder(int type){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){  
         if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
            RefreshRates();
            switch(type){
               case 1:
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
                  break;
                case 2:
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0);
                  break;
            }         
         }
      }
   }
onceAbar = false ;       
reset_checkProfitParameter();
}

// Order Type(0:BUY, 1SELL)
int countOrder (int type){
   int CntOrder = 0 ;
   for(int i=0;i<OrdersTotal();i++){
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
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
       /*      text[16] = "Total Order: " + OrdersTotal();
             text[17] = "Last Open Order: " + OrderOpenTime();
             text[18] = "Current Time: " + TimeCurrent();
             text[19] = TimeCurrent() - OrderOpenTime();
             text[20] = Period();
             text[21] = (TimeCurrent() - OrderOpenTime())/(Period()*60);
            //Print("order #12470 open price is ", OrderOpenPrice());
            //Print("order #12470 close price is ", OrderClosePrice());*/
//text[21] = OrderType();
            return((TimeCurrent() - OrderOpenTime())/(Period()*60));
         }
    }
    return(0);    
}

int lastOrderType(){
      if (OrdersTotal() -1 >= 0){        
         if(OrderSelect((OrdersTotal() -1 ), SELECT_BY_POS) )
         {
       /*      text[16] = "Total Order: " + OrdersTotal();
             text[17] = "Last Open Order: " + OrderOpenTime();
             text[18] = "Current Time: " + TimeCurrent();
             text[19] = TimeCurrent() - OrderOpenTime();
             text[20] = Period();
             text[21] = (TimeCurrent() - OrderOpenTime())/(Period()*60);
            //Print("order #12470 open price is ", OrderOpenPrice());
            //Print("order #12470 close price is ", OrderClosePrice());*/
            text[21] = OrderType();
            return(OrderType());
         }
    }
    return(0);    
}

//+------------------------------------------------------------------+



void printInfo()
{ 
/*   text[1] = "zigzag Line A (Depth,Devation,Backstep): " + zigzag_Depth_LineA +","+ zigzag_Deviation_LineA +","+ zigzag_Backstep_LineA;
     text[2] = "zigzag Line A (Depth,Devation,Backstep): "+ zigzag_Depth_LineB +","+ zigzag_Deviation_LineB +","+ zigzag_Backstep_LineB; 
     text[3] = "MACD (Fast Period,Slow Period,Signal Period): "+fast_period +","+slow_period+","+signal_period;
     text[4] = "MACD Value for Compare: "+macd_val; 
    text[5]= "Bar 4: "+((iCustom(Symbol(),0,"zigzag",31,5,3,0,4)!=0)&&(iCustom(Symbol(),0,"zigzag",15,5,3,0,4)!=0)&&(iCustom(Symbol(),0,"zigzag",8,5,3,0,4)!=0));
    text[6]= "Bar 5: "+((iCustom(Symbol(),0,"zigzag",31,5,3,0,5)!=0)&&(iCustom(Symbol(),0,"zigzag",15,5,3,0,5)!=0)&&(iCustom(Symbol(),0,"zigzag",8,5,3,0,5)!=0));
    text[7]= "Bar 6: "+((iCustom(Symbol(),0,"zigzag",31,5,3,0,6)!=0)&&(iCustom(Symbol(),0,"zigzag",15,5,3,0,6)!=0)&&(iCustom(Symbol(),0,"zigzag",8,5,3,0,6)!=0));
    text[12]= "--------------------------------";   
    text[13]= lowest_6_bars ;
    text[14]= highest_6_bars ;     
    text[8]= "Last Buy Major: "  ;
    text[9]= "Last Buy Minor: "  ;
    text[10]= "Last Sell Major: "  ;
    text[11]= "" ;
    text[12]= "--------------------------------";   
    text[13]= "Total Order(Buy,Ask) : " + countOrder(0)+"," + countOrder(1)+"," + countOrder(2)+"," + countOrder(3) ;
    text[14]= "SL : " + SL ;  
    text[15]= ""; 
         
    text[13]= "MACD Cross Up : " + MACD_Cross_Up ;
    text[14]= "MACD Cross Down : " + MACD_Cross_Down ;  
    text[15]= "Last Price Bid/Ask = "+LastPrice_String;
    text[16]= "Last Price = " + LastPrice;
    text[17]= "-------------------------------";    */                   
  
    int i=1, k=20;
    while (i<30)
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

void drawYellowDownArrowOnScreen(int index){ 
   int i;
   i=Bars;
   string name2 = "Dn"+string(i);
   ObjectCreate(name2,OBJ_ARROW, 0, Time[index], High[index]+10*Point); 
   ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(name2, OBJPROP_COLOR,Yellow);   
}

void drawBlueDownArrowOnScreen(int index){ 
   int i;
   i=Bars;
   string name2 = "Dn"+string(i);
   ObjectCreate(name2,OBJ_ARROW, 0, Time[index], High[index]+10*Point); 
   ObjectSet(name2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name2, OBJPROP_ARROWCODE, SYMBOL_ARROWDOWN);
   ObjectSet(name2, OBJPROP_COLOR,Blue);   
}

void drawLine(){
ObjectSet("HLine", OBJPROP_PRICE1,zigzag_pivot_bar_index_value[0]) ;   
}

void resetAll(){
   thisIsNewBar = false;
//   onceAbar = false ;
   custom_indicator2_pivot_to_buy = false;
   custom_indicator2_pivot_to_sell = false;
//   zigzag_flag_to_open_order = false; 
//reset TT detected variables  
TT_ShortAndLong_Meet_FirstBar_Type = 0;
TT_ShortAndLong_Meet_FirstBar_is_low = NULL;

//reset array variable //zigzag_pivot_bar_index_value[i]+" at bar: "+ zigzag_pivot_bar_index[i];
ArrayResize(zigzag_pivot_bar_index,0); 
ArrayResize(zigzag_pivot_bar_index_value,0);
ArrayResize(zigzag_pivot_bar_index,5); 
ArrayResize(zigzag_pivot_bar_index_value,5);
}

//Calculate Next Bar-----------------------------------------+
void DetectNewBar(void){
   static datetime time = Time[0];
   if(Time[0] > time){
      time = Time[0]; //newbar, update time
      thisIsNewBar = true;
      barCount++;
onceAbar = true;
//text[20]= barCount +","+bar_last_open_contact;
   }
}  

void lastOrderDetailed(){
   int last_trade=OrdersTotal(); 
   
text[19] ="Total Order (s) = " + OrdersTotal();
   if(last_trade>0)
     {
      if(OrderSelect(last_trade-1,SELECT_BY_POS,MODE_TRADES)==true)
        {
             text[14] ="Last Order is = " + OrderComment();
             text[15] ="Last Open price is = " + OrderOpenPrice();
             text[16] ="Last Order Time is = " + OrderOpenTime();
//             text[17] ="Last Order Close price is = " + OrderClosePrice();
             text[18] ="Last Order Profit = " + OrderProfit();

        }

     }
}
/* this function using for check SL orders-- never test it yet, 
// this function is called inside the start() in expert advisor.  This means it is called every tick. 
// returns -1 if no stop loss on latest open order
// returns 0 if stop loss on a latest BUY order
// returns 1 if stop loss on latest SELL order
// the "BUY_SL_COMMENT" is defined to be "*****[sl]" where the ***** are strings I use to ensure they are my orders

int stopLossHit(){
   if (currOrderTicket == -1){ // no open orders
      // possibility of stop loss, check further..
      
      for (int i=0; i<OrdersHistoryTotal(); i++){
         OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
         Print("Looking for stop loss order, curr order = ");
         OrderPrint();
         if (OrderOpenTime() == lastOrderTimeSent &&
             OrderMagicNumber() == MAGIC_NUMBER) {
            if (OrderComment() == BUY_SL_COMMENT && OrderType() == OP_BUY){
                Print("Stop loss encountered on previous BUY order.");
               workingStopLossTicket = OrderTicket();
               return (OP_BUY); // hit stop loss on previous BUY order
            }
            else if (OrderComment() == SELL_SL_COMMENT && OrderType() == OP_SELL){
               Print("Stop loss encountered on previous SELL order.");
               workingStopLossTicket = OrderTicket();
               return (OP_SELL); // hit stop loss on previous SELL order
            }
         }
      }
   }
   return (-1);*/