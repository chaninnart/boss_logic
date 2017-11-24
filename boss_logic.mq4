//+------------------------------------------------------------------+
//|002                                              2018 Stategy.mq4 |
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
input int zigzag_Depth_LineA = 30 ; // Zigzag Depth Value
input int zigzag_Deviation_LineA =0 ; // Zigzag Deviation Value
input int zigzag_Backstep_LineA =0; // Zigzag Backstep Value

double zigzag_Last_Value = 0;
int zigzag_pivot_bar_index[5];
double zigzag_pivot_bar_index_value[5];
bool   zigzag_last_pivot_is_low ;


double zigzag_current_val_lineA0,zigzag_current_val_lineA1,zigzag_current_val_lineA2,zigzag_current_val_lineA3,zigzag_current_val_lineA4,zigzag_current_val_lineA5;
double zigzag_current_val_lineA6,zigzag_current_val_lineA7,zigzag_current_val_lineA8,zigzag_current_val_lineA9,zigzag_current_val_lineA10;
bool zigzag_flag_to_open_order = false;
bool zigzag_met_within_8_bars =false ;


//+------------------------------------------------------------------+
//| Custom Indicator Variable                                  |
//+------------------------------------------------------------------+

//1. custom indicator1 = "TheTurtleTradingChannel-short"
double custom_indicator1_val_pre0[3],custom_indicator1_val_pre1[3],custom_indicator1_val_pre2[3],custom_indicator1_val_pre3[3],custom_indicator1_val_pre4[3],custom_indicator1_val_pre5[3];
bool custom_indicator1_pivot_to_buy , custom_indicator1_pivot_to_sell;
input int TurtleTradePeriod = 2;
input int TurtleStopPeriod = 0;
bool custom_indicator1_repeat_3bars,custom_indicator1_repeat_4bars;
bool custom_indicator1_bar0_is_low =false;
bool custom_indicator1_last_pivot_is_low ;
double custom_indicator1_last_pivot_val ;

//2. custom indicator2 = = "TheTurtleTradingChannel-long"
double custom_indicator2_val_pre0[3],custom_indicator2_val_pre1[3],custom_indicator2_val_pre2[3],custom_indicator2_val_pre3[3],custom_indicator2_val_pre4[3],custom_indicator2_val_pre5[3];
bool custom_indicator2_pivot_to_buy , custom_indicator2_pivot_to_sell;
input int TurtleTradePeriod_L = 10;
input int TurtleStopPeriod_L = 0;
bool custom_indicator2_bar0_is_low =false;
bool custom_indicator2_last_pivot_is_low ;
double custom_indicator2_last_pivot_val ;

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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
     //draw a line to detect zigzag 30 behavior
           ObjectCreate("HLine", OBJ_HLINE , 0,Time[0], 0);
           ObjectSet("HLine", OBJPROP_STYLE, STYLE_DOT);
           ObjectSet("HLine", OBJPROP_COLOR, Red);
           ObjectSet("HLine", OBJPROP_WIDTH, 1); 

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
void OnTick()
  {
   getAllParameter(); //Retreive all required data  
   checkCondition(); //Conditions 
   printInfo();  
   resetAll();  
  }
  
//+------------------------------------------------------------------+  
void  getAllParameter(){ 
   DetectNewBar(); //Function detecting new bar 
   getZigzag_Value(); 
   getIndicator_Value(); 
   getIndicator2_Value();
    
}

//---------------Parameter-----------------


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
   
   zigzag_met_within_8_bars = ((zigzag_current_val_lineA0 != 0 )|| (zigzag_current_val_lineA1 != 0 )||
                               (zigzag_current_val_lineA2 != 0 )|| (zigzag_current_val_lineA3 != 0 )||
                               (zigzag_current_val_lineA4 != 0 )|| (zigzag_current_val_lineA5 != 0 )||
                               (zigzag_current_val_lineA6 != 0 )|| (zigzag_current_val_lineA7 != 0 )||
                               (zigzag_current_val_lineA8 != 0 ) ); 

   
      int i=0; int n = 0;
         while(i<4){
            double zigzag_temp1 = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,n);          
           
            if (zigzag_temp1 !=0) {
               zigzag_pivot_bar_index[i] = n ;
               zigzag_pivot_bar_index_value[i] = iCustom(Symbol(),0,"zigzag",zigzag_Depth_LineA,zigzag_Deviation_LineA,zigzag_Backstep_LineA,0,n);
               i++ ;
            }
            n++;
      }
      
      zigzag_last_pivot_is_low = zigzag_pivot_bar_index_value[0] < zigzag_pivot_bar_index_value[1];


drawLine();  //draw zigzag vertical line for testing

}


void getIndicator_Value(){ 
   
   
   custom_indicator1_val_pre0[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 0,0 );
   custom_indicator1_val_pre0[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 1,0 );    
   custom_indicator1_val_pre0[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 2,0 ); 

   custom_indicator1_val_pre1[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 0,1 );
   custom_indicator1_val_pre1[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 1,1 );    
   custom_indicator1_val_pre1[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 2,1 ); 
   
   custom_indicator1_val_pre2[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 0,2 );
   custom_indicator1_val_pre2[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 1,2 );    
   custom_indicator1_val_pre2[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 2,2 ); 
    
   custom_indicator1_val_pre3[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 0,3 );
   custom_indicator1_val_pre3[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 1,3 );    
   custom_indicator1_val_pre3[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 2,3 );    

   custom_indicator1_val_pre4[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 0,4 );
   custom_indicator1_val_pre4[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 1,4 );    
   custom_indicator1_val_pre4[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 2,4 );    
   
   custom_indicator1_val_pre5[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 0,5 );
   custom_indicator1_val_pre5[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 1,5 );    
   custom_indicator1_val_pre5[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod,TurtleStopPeriod, false,false, 2,5 );  
  
  
   custom_indicator1_pivot_to_buy = (custom_indicator1_val_pre1[0]!= 2147483647 && custom_indicator1_val_pre2[0] == 2147483647);
   custom_indicator1_pivot_to_sell = (custom_indicator1_val_pre1[0]== 2147483647 && custom_indicator1_val_pre2[0] != 2147483647); 
   

   custom_indicator1_repeat_3bars = (custom_indicator1_val_pre2[0]!= 2147483647 && custom_indicator1_val_pre3[0] !=2147483647 && custom_indicator1_val_pre4[0] !=2147483647)
                                  || (custom_indicator1_val_pre2[0]== 2147483647 && custom_indicator1_val_pre3[0] ==2147483647 && custom_indicator1_val_pre4[0] ==2147483647) ;

   custom_indicator1_repeat_4bars = (custom_indicator1_val_pre2[0]!= 2147483647 && custom_indicator1_val_pre3[0] !=2147483647 && custom_indicator1_val_pre4[0] !=2147483647&& custom_indicator1_val_pre5[0] !=2147483647)
                                  || (custom_indicator1_val_pre2[0]== 2147483647 && custom_indicator1_val_pre3[0] ==2147483647 && custom_indicator1_val_pre4[0] ==2147483647&& custom_indicator1_val_pre5[0] ==2147483647) ;


   custom_indicator1_bar0_is_low = (custom_indicator1_val_pre0[0] != 2147483647) && (custom_indicator1_val_pre0[1] == 2147483647) ;

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
 

 
void getIndicator2_Value(){  
   custom_indicator2_val_pre0[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,0 );
   custom_indicator2_val_pre0[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,0 );    
   custom_indicator2_val_pre0[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,0 ); 

   custom_indicator2_val_pre1[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,1 );
   custom_indicator2_val_pre1[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,1 );    
   custom_indicator2_val_pre1[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,1 ); 
   
   custom_indicator2_val_pre2[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,2 );
   custom_indicator2_val_pre2[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,2 );    
   custom_indicator2_val_pre2[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,2 ); 
    
   custom_indicator2_val_pre3[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,3 );
   custom_indicator2_val_pre3[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,3 );    
   custom_indicator2_val_pre3[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,3 );    

   custom_indicator2_val_pre4[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,4 );
   custom_indicator2_val_pre4[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,4 );    
   custom_indicator2_val_pre4[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,4 );    
   
   custom_indicator2_val_pre5[0] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 0,5 );
   custom_indicator2_val_pre5[1] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 1,5 );    
   custom_indicator2_val_pre5[2] = iCustom ( NULL, 0, "TheTurtleTradingChannel",TurtleTradePeriod_L,TurtleStopPeriod_L, false,false, 2,5 );  
  
   custom_indicator2_pivot_to_buy = (custom_indicator2_val_pre1[0]!= 2147483647 && custom_indicator2_val_pre2[0] == 2147483647);
   custom_indicator2_pivot_to_sell = (custom_indicator2_val_pre1[0]== 2147483647 && custom_indicator2_val_pre2[0] != 2147483647); 
     
   custom_indicator2_bar0_is_low = (custom_indicator2_val_pre0[0] != 2147483647) && (custom_indicator2_val_pre0[1] == 2147483647) ;
   
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
}

double pipCalculation(double price_to_convert_to_pip){
   int point_compat = 1;
   if(Digits == 3 || Digits == 5) point_compat = 10;   
   //double DiffPips = MathAbs((NormalizeDouble(((price_to_convert_to_pip)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/point_compat); 
   double DiffPips = (NormalizeDouble(((price_to_convert_to_pip)/MarketInfo(Symbol(),MODE_POINT)),MarketInfo(Symbol(),MODE_DIGITS)))/point_compat;    
   return DiffPips; 
}


//+-------------------------------------------------------------------------------------------------------------------->>>>>>>>>>>>
void  checkCondition(){    

//text[1] = "B,A,O,C,H,L: "+ Bid+"," + Ask+"," + Open[0]+"," +Close[0]+"," + High[0]+"," + Low[0];
//--------------------------
emergency_Exit();  // call emergency stop function.
//--------------------------    
collectionOrder(); // call collection order function.
//--------------------------         
    
// Strategy M1: Normal Open Order ***************************************************************
//1. TT repeat 3 bars since bar 2 - 4 //2. TT's short pivot at bar 1 and bar 2 //3. zigzag has value within 8 bars 0-8 (actually 9 bars)//4. when the different between TT's short upper line and lower line > 20 pips 
//5. Close All existing orders. //6. Open order on reverse TT //7. stop loss when price exceed ZZ
zigzag_last_pivot_is_low = zigzag_pivot_bar_index_value[0] < zigzag_pivot_bar_index_value[1];
double diff_lastZigzag_with_TT;
   if (zigzag_last_pivot_is_low) {
      if (custom_indicator1_val_pre2[1]!= 2147483647){
      diff_lastZigzag_with_TT = custom_indicator1_val_pre2[1]-zigzag_pivot_bar_index_value[0]; }} // below
   else {
      if (custom_indicator1_val_pre2[0]!= 2147483647){
      diff_lastZigzag_with_TT = zigzag_pivot_bar_index_value[0] - custom_indicator1_val_pre2[0]; // upper
   }}
double pip= pipCalculation(diff_lastZigzag_with_TT);
   if ((pip>19)&&(custom_indicator1_repeat_3bars && custom_indicator1_pivot_to_buy && zigzag_met_within_8_bars && custom_indicator1_bar0_is_low && !custom_indicator2_bar0_is_low && justOpen_Cliteria())){
      double stoploss;
      closeAllSellOrder();
      if(custom_indicator1_bar0_is_low && !custom_indicator2_bar0_is_low){
         openBuyWithSL ("BUY MAJOR ZZ",zigzag_pivot_bar_index_value[0]-(30*Point));      
      }
      bar_last_open_contact = barCount; 
      //text[4] = "BUY MINOR :" + " at "+ TimeCurrent()+","+" SL at: " + (zigzag_pivot_bar_index_value[0]-(30*Point));
      return;
   }
   if ((pip>19)&&(custom_indicator1_repeat_3bars && custom_indicator1_pivot_to_sell&& zigzag_met_within_8_bars && !custom_indicator1_bar0_is_low && custom_indicator2_bar0_is_low &&  justOpen_Cliteria())){
      double stoploss;
      closeAllBuyOrder();      
      if(!custom_indicator1_bar0_is_low && custom_indicator2_bar0_is_low){
         openSellWithSL ("SELL MAJOR ZZ",zigzag_pivot_bar_index_value[0]+(30*Point));   
      }
      
      bar_last_open_contact = barCount; 
      //text[5] = "SELL MINOR :" + " at "+ TimeCurrent()+","+" SL at: "+zigzag_pivot_bar_index_value[0]+(30*Point);
      return;
   }   
   
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
   text[4] = "-------------------------------";
   text[5] = "Diff TT long lower bar2 - TT long upper bar0: "+(d-a);
   text[6] = "Diff in pip: "+ dif_pip_TT2pre2Lower_TT2pre0Upper;
   text[7] = "at time: "+TimeCurrent();      
} else{dif_pip_TT2pre2Lower_TT2pre0Upper = 0;}
if ((b != 2147483647) && (c!=2147483647)){
      dif_pip_TT2pre0Lower_TT2pre2Upper = pipCalculation(b-c); 
   text[8] = "-------------------------------";
   text[9] = "Diff TT long lower bar0 - TT long upper bar2: "+(b -c);
   text[10] = "Diff in pip: "+ dif_pip_TT2pre0Lower_TT2pre2Upper;
   text[11] = "at time: "+TimeCurrent();       
}else{dif_pip_TT2pre0Lower_TT2pre2Upper;}
if ((a != 2147483647) && (f!=2147483647)){
       dif_pip_TT1pre2Lower_TT2pre0Upper = pipCalculation(f-a);
   text[12] = "-------------------------------";
   text[13] = "Diff TT short lower bar2 - TT long upper bar0 : "+(f-a);   
   text[14] = "Diff in pip: "+ dif_pip_TT1pre2Lower_TT2pre0Upper;
   text[15] = "at time: "+TimeCurrent();        
}else{dif_pip_TT1pre2Lower_TT2pre0Upper;} 
if ((b != 2147483647) && (e!=2147483647)){
       dif_pip_TT2pre0Lower_TT1pre2Upper = pipCalculation(b-e);
   text[16] = "-------------------------------";
   text[17] = "Diff TT long upper bar0 - TT short upper bar2 : "+(b -e);   
   text[18] = "Diff in pip: "+ dif_pip_TT2pre0Lower_TT1pre2Upper;
   text[19] = "at time: "+TimeCurrent(); 
}else{dif_pip_TT2pre0Lower_TT1pre2Upper;}
    
int limit = 20;
bool is_dif_TT0_and_TT2_greater_than_limit = (((dif_pip_TT2pre2Lower_TT2pre0Upper >= limit)) ||
                                              ((dif_pip_TT2pre0Lower_TT2pre2Upper >= limit)) ||
                                              ((dif_pip_TT1pre2Lower_TT2pre0Upper >= limit)) ||
                                              ((dif_pip_TT2pre0Lower_TT1pre2Upper >= limit)));  
                                              
text[20] = is_dif_TT0_and_TT2_greater_than_limit+","+dif_pip_TT2pre2Lower_TT2pre0Upper+","+dif_pip_TT2pre0Lower_TT2pre2Upper+","+dif_pip_TT1pre2Lower_TT2pre0Upper+","+dif_pip_TT2pre0Lower_TT1pre2Upper;
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

}


//12.59
void emergency_Exit(){

/* 
//---------------------------------------------------------------------------------   
// Strategy EX1: follow trend strategy
// if current TT is higher or lower than the last pivot do something!
//---------------------------------------------------------------------------------
   
   if(custom_indicator1_bar0_is_low && (custom_indicator1_val_pre1[0] > custom_indicator1_last_pivot_val)&& (countOrder(0)==0)){
      closeAllSellOrder();
      openBuy("BUY ES");            
      text[14] = "Open Buy Upperline cross TT up at: "+ TimeCurrent();
      return;
   }

   if(!custom_indicator1_bar0_is_low && (custom_indicator1_val_pre1[1] < custom_indicator1_last_pivot_val)&& (countOrder(1)==0)){
      closeAllBuyOrder();
      openSell("SELL ES");
      text[15] = "Open Sell Lowerline cross TT cross down at: "+ TimeCurrent();
      return;
   }*/
   
//---------------------------------------------------------------------------------
//strategy EX2 : "Emergency Exit Realtime"
// - if realtime price is break the TT long line more than 8 pip, action
//---------------------------------------------------------------------------------
/*
text[1] = "Bid,Ask: "+ Bid +","+ Ask;
text[2] = custom_indicator2_val_pre0[0]+","+ custom_indicator2_val_pre0[1];
text[3] = (custom_indicator2_val_pre0[1]-Bid)+","+(Ask - custom_indicator2_val_pre0[0]);

   if ((pipCalculation(custom_indicator2_val_pre0[1]-Bid)>8)&&((custom_indicator2_val_pre0[1]-Bid) > 0)&&(countOrder(0)==0)&& onceAbar){
      closeAllSellOrder();
      openBuy("BUY ST4");
      return;
   }
   
   if ((pipCalculation(Ask - custom_indicator2_val_pre0[0])>8)&& ((Ask - custom_indicator2_val_pre0[0]) >0)&&(countOrder(1)==0)&& onceAbar){
      closeAllBuyOrder();
      openSell("SELL ST4");
      return;
   }
*/


//---------------------------------------------------------------------------------   
/*   // Exit 1. if the close price of the both previous two bars confirmed their direction
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
//---------------------------------------------------------------------------------
// Strategy C1: 
// condition checking when just open order but It's seem wrong as it still sideway within 3 bars
//---------------------------------------------------------------------------------

   if (countBarFromLastOrder()<=3 ){
      if((lastOrderType()== 0)&& (custom_indicator1_val_pre0[1] !=  2147483647)) {
      closeAllBuyOrder();
      openSell("SELL 1");
      //text[17] = "Hit Hit Hit Close Buy Open Sell: "+TimeCurrent();
      return;
      }
   }

   if (countBarFromLastOrder()<=3 ){
      if((lastOrderType()== 1)&& (custom_indicator1_val_pre0[0] !=  2147483647)) {
      closeAllSellOrder();
      openBuy("BUY 1");
      //text[17] = "Hit Hit Hit Close Sell Open Buy: "+TimeCurrent();
      return;
      }
   }


//---------------------------------------------------------------------------------
// Strategy C2: Collection Order
// - at bar0 have TT short and long on the same side.
// - no right direction's order 
// - (lower case) close at bar1 > TT short +100 / (upper case) Close at bar1 < TT short-100
// - close incorrect direction's order and open right direction's order.
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
// Strategy C3: 
// - at bar0 have TT short and long on the same side.
// - have right direction's order 
// - (lower case) close at bar1 > TT long bar2 / (upper case) Close at bar1 < TT long bar2
// - close the right order and open reverse
//---------------------------------------------------------------------------------



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
Comment("Open "+ comment);    
}

void openSell(string comment){
   double tp = Bid-(TP*Point);
   double sl = Ask+(SL*Point); //setting stop loss when open buy 100   
   if (TP == 0) { tp =0;}
   if (SL == 0) { sl =0;}
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_SELL,Lotsize ,Bid,3,sl,tp,comment,MagicNumber,0,clrRed);  
Comment("Open "+comment);       
}

void openBuyWithSL (string comment,double stopLossPrice) { 
   double tp = Ask+(TP*Point);  
   if (TP == 0) { tp =0;} //if TP == 0 do set the TP to 0 avoiding error 130   
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_BUY,Lotsize ,Ask,3,stopLossPrice,tp,comment,MagicNumber,0,clrGreen);   
Comment("Open "+ comment);    
//text[16] = "Open Buy: " +Ask+"," + stopLossPrice; 
}

void openSellWithSL(string comment,double stopLossPrice){
   double tp = Bid-(TP*Point);
   if (TP == 0) { tp =0;}   
   RefreshRates(); //try to avoid error 138 "http://www.earnforex.com/blog/ordersend-error-138-requote/"
   OrderSend(Symbol(),OP_SELL,Lotsize ,Bid,3,stopLossPrice,tp,comment,MagicNumber,0,clrRed); 
Comment("Open "+comment);     
//text[16] = "Open Sell: " +Bid+"," + stopLossPrice;   
}


void closeAllBuyOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){ 
      string orderComment = StringSubstr(OrderComment(),0,9);    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0); 
Comment("Close All Buy");                                  
            }
         }
      }
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
}


void closeAllBuyMajorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){  
      string orderComment = StringSubstr(OrderComment(),0,9);
         if (orderComment == "BUY MAJOR"){    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0); 
Comment("Close All Buy Major");                                  
            }
         }
      }
   }
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
Comment("Close All Sell Major");             
            }
         }
      }
   }
}

void closeAllBuyMinorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){  
      string orderComment = StringSubstr(OrderComment(),0,9);
         if (orderComment == "BUY MINOR"){    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0); 
Comment("Close All Buy Minor");                                  
            }
         }
      }
   }
}


void closeAllSellMinorOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){
      string orderComment = StringSubstr(OrderComment(),0,10);
         if (orderComment == "SELL MINOR"){    
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
Comment("Close All Sell Minor");             
            }
         }
      }
   }
}

void closeAllBuyESOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {  
      if (OrderSelect(i,SELECT_BY_POS) == true){  
      string orderComment = StringSubstr(OrderComment(),0,9);
         if (orderComment == "BUY ES"){    
            if(OrderType() == OP_BUY && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,0); 
Comment("Close All Buy Minor");                                  
            }
         }
      }
   }
}


void closeAllSellESOrder(){
   for(int i = OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i,SELECT_BY_POS) == true){
      string orderComment = StringSubstr(OrderComment(),0,10);
         if (orderComment == "SELL ES"){    
            if(OrderType() == OP_SELL && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()){ 
               RefreshRates();
               OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,0);
Comment("Close All Sell Minor");             
            }
         }
      }
   }
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
Comment ("Close All Order");   
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
            text[21] = OrderType();
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
   ObjectSet(name2, OBJPROP_COLOR,Green);   
}

void drawLine(){
ObjectSet("HLine", OBJPROP_PRICE1,zigzag_pivot_bar_index_value[0]) ;   
}




void resetAll(){
   thisIsNewBar = false;
   
   custom_indicator2_pivot_to_buy = false;
   custom_indicator2_pivot_to_sell = false;
//   zigzag_flag_to_open_order = false;   
}
