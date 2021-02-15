//+------------------------------------------------------------------+
//|                                                       EMATry.mq4 |
//|                                         author    "Joshua Aroke" |
//+------------------------------------------------------------------+
#property link      "https://github.com/olyjosh"
#property version   "1.00"
#property version   "1.00"
#property strict

input int    MovingPeriod  =4;
input int    MovingPeriod2  =8;
input int    MovingShift   =0;

input double Thresh_hold_pips = 0.005;//"Thresh_hold_pips"
input double close_Trade_Thresh_hold_pips = 0.000;//"Thresh_hold_pips"
input double Lot_SIZE = 1; //"Lot_SIZE"

input int    PriceDecimal   = 3;

const string COMMENT = "EMA Crossing";
const int MAGIC = 20210208;

bool created = false;
bool creating = false;


string           BuyName="BUY";            // Button name
string           SellName="SELL";  

//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

   void createBuySellBut(){
     
      ENUM_BASE_CORNER InpCorner=CORNER_LEFT_UPPER; // Chart corner for anchoring
                // Priority for mouse click
      string           InpFont="Arial";             // Font
      int              InpFontSize=14;              // Font size
      color            InpColor=clrBlack;           // Text color
      color            InpBackColor=C'236,233,216'; // Background color
      color            InpBorderColor=clrNONE;      // Border color
      bool             InpState=false;              // Pressed/Released
      bool             InpBack=false;               // Background object
      bool             InpSelection=false;          // Highlight to move
      bool             InpHidden=true;              // Hidden in the object list
      long             InpZOrder=0; 
     
      ButtonCreate(0,BuyName,0,10,20,150,50,InpCorner,BuyName,InpFont,InpFontSize,
         clrAliceBlue,clrBlue,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);     
   
      ButtonCreate(0,SellName,0,170,20,150,50,InpCorner,SellName,InpFont,InpFontSize,
         clrAliceBlue,clrTomato,InpBorderColor,InpState,InpBack,InpSelection,InpHidden,InpZOrder);

   }


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   createBuySellBut();
   createBuySellBut();
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ma = iMA(NULL,0,MovingPeriod,MovingShift,MODE_EMA,PRICE_TYPICAL,0);
   double ma2 = iMA(NULL,0,MovingPeriod2,MovingShift,MODE_EMA,PRICE_TYPICAL,0);
   
   double diff = ma - ma2;
   int count = getCount();
   if(count == 0){
      if(diff > 0  && diff > Thresh_hold_pips){
         // BUY case EMA 4 > 8 
         //openTrade(OP_BUY);
         //Alert("Possible Buy"); 
      }
      if(diff < 0 && MathAbs(diff) < Thresh_hold_pips){
         // SELL case EMA 8 > 4
         //openTrade(OP_SELL); 
         //Alert("Possible Sell");
      }
   }else{
      diff = NormalizeDouble(diff, PriceDecimal-1 );
      if(diff >= Thresh_hold_pips){
         //close SELL case EMA 8 > 4 
         close(OP_SELL); 
      }
      if(diff <= Thresh_hold_pips){
         //close BUY case EMA 8 < 4
         close(OP_BUY); 
      }
   }
   
   
   
   //Print("EMA:::: ","PERIOD "+ MovingPeriod+": "+ ma, " PERIOD "+ MovingPeriod2+": "+ ma2);
   //MessageBox("Shall order be placed ?","Expert Advisor XYZ",MB_DEFBUTTON1);
   
  }
//+------------------------------------------------------------------+

void close(int OP){
      //Update the exchange rates before closing the orders
   RefreshRates();
      
   //Start a loop to scan all the orders
   //The loop starts from the last order proceeding backwards, otherwise it would miss some orders
   for(int i=(OrdersTotal()-1);i>=0;i--){
      
      //If the order cannot be selected throw and log an error
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      } 
      
      //Allowed Slippage, which is the difference between current price and close price
      int Slippage=0;
      
      //Bid and Ask Price for the Instrument of the order
      double BidPrice=MarketInfo(OrderSymbol(),MODE_BID);
      double AskPrice=MarketInfo(OrderSymbol(),MODE_ASK);
 
      //Closing the order using the correct price depending on the type of order
      if(OrderType()==OP){
         Print("Closing BUY: ",OrderTicket());
         OrderClose(OrderTicket(),OrderLots(),BidPrice,Slippage);
      }
   }
}

void closeAllOpenTrades(){
   close(OP_BUY);
   close(OP_SELL);
}

void openTrade(int OP){
   if(creating != true){
      creating = true;
      double openPrice = MarketInfo(NULL, MODE_BID);
      OrderSend(NULL, OP, Lot_SIZE, openPrice, 0, 0, 0, COMMENT, MAGIC, 0, NULL);
   }
   created = true;
   creating = false;
}



int getCount(){
   int count = 0;
   for (int pos=0; pos<OrdersTotal();pos++){
      if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES))
         continue;

      if((OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderMagicNumber() == MAGIC ){
         count++;
      }
   }
   return(count);
}
 
 //+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam){

   if(id==CHARTEVENT_OBJECT_CLICK){
      if(sparam==BuyName){
         
         openTrade(OP_BUY); 
         ObjectSetInteger(0,BuyName,OBJPROP_STATE,false);
      }
      if(sparam==SellName){
         
         openTrade(OP_SELL); 
         ObjectSetInteger(0,SellName,OBJPROP_STATE,false);
      }
   }
  
}