//+------------------------------------------------------------------+
//|                                             TenPipsPlusDaily.mq4 |
//|                                         author    "Joshua Aroke" |
//+------------------------------------------------------------------+
#property link      "https://github.com/olyjosh"
#property version   "1.00"

#property strict
#property show_inputs


//extern bool    Bool_Linger = True;
input string Expected_Trigger_Time = "01:00:00";//Expected_Trigger_Time: 1:00 on ICMarket
input double Thresh_hold_pips = 0.0010;//Thresh_hold_pips
input double Target_TP_pips = 0.0010;//Target_TP_pips
input double Lot_SIZE = 1; //Lot_SIZE


#define HR2400 86400       // 24 * 3600


const int INVALID_TICKET = -1;

const int ID = StrToInteger(Year() + "" + Month() + "" + Day());
const string CURRENT_SYMBOL = Symbol();//"GBPUSD"; //Symbol(); //OrderSymbol

int buyTicket = INVALID_TICKET;
int sellTicket = INVALID_TICKET;


bool created = false;
bool creating = false;


  int      TimeOfDay(datetime when){  return( when % HR2400          );         }
  datetime DateOfDay(datetime when){  return( when - TimeOfDay(when) );         }
  datetime Today(){                   return(DateOfDay( TimeCurrent() ));       }
  datetime Tomorrow(){                return(Today() + HR2400);                 }
  datetime Yesterday(){               return( iTime(NULL, PERIOD_D1, 1) );      }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//   if(created == true){
//      EventSetMillisecondTimer(250);
//   }else{
//      EventSetMillisecondTimer(500);
//   }

 EventSetMillisecondTimer(500);
 notify("initialized");


//---
   return(INIT_SUCCEEDED);
  }

   int getCount(){
      int count = 0;
      for (int pos=0; pos<OrdersTotal();pos++){
         if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES))
            continue;

         if((OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_SELL || OrderType() ==  OP_SELLSTOP) && OrderMagicNumber()== ID){
            count++;
         }
      }
      return(count);
  }


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
  void OnTick()
  {
    checkForClosure();
    //OnTimer();
  }

  bool checkForClosure(){

        int count = getCount();
        if(count == 1 && created == true){
            CloseOrders();
        }

        return(true);

  }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//---
   string timeNow = TimeToStr(TimeCurrent(), TIME_SECONDS);
   //if (timeNow == "01:00:00") {
   if (timeNow == Expected_Trigger_Time) {
        createPendingOrder();
   }

   checkForClosure();
  }

  void createPendingOrder(){
   if(creating == false && created == false ){
    creating = true;
         //double openPrice = iOpen(CURRENT_SYMBOL, PERIOD_H1, 0);
    double openPrice = MarketInfo(CURRENT_SYMBOL, MODE_BID);

    double sellPrice = openPrice - Thresh_hold_pips;
    double sellPriceTp = sellPrice - Target_TP_pips;
    double buyPrice = openPrice + Thresh_hold_pips;
    double buyPriceTp = buyPrice + Target_TP_pips;
    //double sellPriceSl = buyPriceTp + 0.0001;
    //double buyPriceSl = sellPriceTp - 0.0001;

    datetime expiry = StrToTime(Year()+"."+Month()+"."+Day()+" 23:59:58");
    buyTicket = OrderSend(CURRENT_SYMBOL, OP_BUYSTOP, Lot_SIZE, buyPrice, 0, 0, buyPriceTp, "10pips buy on ", ID, expiry, Green);
    sellTicket = OrderSend(CURRENT_SYMBOL, OP_SELLSTOP, Lot_SIZE, sellPrice, 0, 0 , sellPriceTp, "10pips sell on ", ID, expiry, Green);
    created = true;
    creating = false;
    notify("Pending Order Placed :)");
   }
  }
  
  void notify(string msg){
   if(SendNotification(WindowExpertName()+ " "+msg)==false){
      Print("Unable to send notification ",GetLastError());
   }
  }
  
  void CloseOrders(){
   
   //Update the exchange rates before closing the orders
   RefreshRates();
      //Log in the terminal the total of orders, current and past
   Print(OrdersTotal());
      
   //Start a loop to scan all the orders
   //The loop starts from the last order proceeding backwards, otherwise it would miss some orders
   for(int i=(OrdersTotal()-1);i>=0;i--){
      
      //If the order cannot be selected throw and log an error
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){
         Print("ERROR - Unable to select the order - ",GetLastError());
         break;
      } 
      if(OrderMagicNumber() != ID){
         continue;
      }
 
      //Create the required variables
      //Result variable, to check if the operation is successful or not
      bool res=false;
      
      //Allowed Slippage, which is the difference between current price and close price
      int Slippage=0;
      
      //Bid and Ask Price for the Instrument of the order
      double BidPrice=MarketInfo(OrderSymbol(),MODE_BID);
      double AskPrice=MarketInfo(OrderSymbol(),MODE_ASK);
 
      //Closing the order using the correct price depending on the type of order
      if(OrderType()==OP_BUY){
         Print("Closing second position BUY: ",OrderTicket());
         res=OrderClose(OrderTicket(),OrderLots(),BidPrice,Slippage);
      }
      if(OrderType()==OP_SELL){
         Print("Closing second position SELL: ",OrderTicket());
         res=OrderClose(OrderTicket(),OrderLots(),AskPrice,Slippage);
      }
      if(OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP ){
         Print("Deleting a pending order: ",OrderTicket());
         res=OrderDelete(OrderTicket());
      }

      
      //If there was an error log it
      if(res==false) 
         Print("ERROR - Unable to close the order - ",OrderTicket()," - ",GetLastError());
      else 
         created = false;
   }
}
  

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
 }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
