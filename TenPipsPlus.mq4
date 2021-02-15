//+------------------------------------------------------------------+
//|                                                  TenPipsPlus.mq4 |
//|                                         author    "Joshua Aroke" |
//+------------------------------------------------------------------+
#property link      "https://github.com/olyjosh"
#property version   "1.00"
#property strict

#define HR2400 86400       // 24 * 3600


const int INVALID_TICKET = -1;
const double LOT_SIZE = 1;
const int ID = StrToInteger(Year() + "" + Month() + "" + Day());
const string CURRENT_SYMBOL = Symbol();//"GBPUSD"; //Symbol(); //OrderSymbol

int buyTicket = INVALID_TICKET;
int sellTicket = INVALID_TICKET;
string expectedTime = "01:00:00";

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
//--- create timer
      //loadOpen10Pips();
   //EventSetTimer(1);
   if(created == true){
      EventSetMillisecondTimer(250);
   }else{
      EventSetMillisecondTimer(500);
   }
   
   
//---
   return(INIT_SUCCEEDED);
  }
  
  void loadOpen10Pips(){
   for (int pos=0; pos<OrdersTotal();pos++){
      if (!OrderSelect(pos, SELECT_BY_POS))  
         continue;
      if(OrderMagicNumber() == ID){
         if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP){
            buyTicket = OrderTicket();
         }else{
            sellTicket = OrderTicket();
         }
      }  
   }   
   Print("Sell Ticket: ", sellTicket, " Buy Ticket: ", buyTicket);
  }
  
   int getCount(){
      int count = 0;
      for (int pos=0; pos<OrdersTotal();pos++){
         if (!OrderSelect(pos, SELECT_BY_POS, MODE_TRADES))  
            continue;

         if(OrderType() == OP_BUY || OrderType() == OP_BUYSTOP || OrderType() == OP_SELL || OrderType() ==  OP_SELLSTOP){
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
//         if(sellTicket == INVALID_TICKET && buyTicket == INVALID_TICKET){
//            return(false);
//         }
//
//
//        double askPrice = MarketInfo(CURRENT_SYMBOL, MODE_ASK);
//        double bidPrice = MarketInfo(CURRENT_SYMBOL, MODE_BID);
//
//        if(buyTicket == INVALID_TICKET && sellTicket != INVALID_TICKET){
//         closeOrDelete(sellTicket, askPrice);
//        }
//
//        if(sellTicket == INVALID_TICKET && buyTicket != INVALID_TICKET){
//         closeOrDelete(buyTicket, bidPrice);
//        }
//
//        if (sellTicket != INVALID_TICKET && buyTicket != INVALID_TICKET) {
//           if(closeSecondPosition(buyTicket, sellTicket, askPrice)== false){
//            closeSecondPosition(sellTicket, buyTicket, bidPrice);
//           }
//        }
//
//        if(GetLastError()!= 0){
//         Print("OrderSelect failed error code is: ",GetLastError());
//        }


        int count = getCount();
        if((count == 1 || count > 2)  && created == true){
            CloseOrders();
        }

        return(true);

  }

  bool closeSecondPosition(int ticket1, int secondTicket, double closePrice){
     if(OrderSelect(ticket1,SELECT_BY_TICKET)==true)
       {
        datetime ctm=OrderCloseTime();
        string ctmString = TimeToStr(ctm, TIME_SECONDS);
        if(ctmString != "00:00:00"){
           // Close the second position             
           return closeOrDelete(secondTicket, closePrice);
       }
     }
          
     return(false);
  }
  
  bool closeOrDelete(int secondTicket, double closePrice){
      bool closeStatus = false;
             if(OrderSelect(secondTicket,SELECT_BY_TICKET)==true){
                int orderType = OrderType();
                if(orderType < 2){
                    Print("Closing second position : ", orderType);
                    CloseOrders();
                    //closeStatus = OrderClose(secondTicket, LOT_SIZE, closePrice, Purple);
                    //if(GetLastError()!= 0){
                    //   Print("OrderSelect failed error code is: ",GetLastError(), " ::: Close STATUS: ", closeStatus);
                    //}
                } else {
                    Print("Deleting second pending position : ", orderType);
                    closeStatus = OrderDelete(secondTicket);
                }
                buyTicket = INVALID_TICKET;
                sellTicket = INVALID_TICKET;
             }
           return(closeStatus);
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
   if (timeNow == expectedTime) {
        createPendingOrder();
   }
   
   checkForClosure();
  }

  void createPendingOrder(){
   if(creating != true){
    creating = true;
         //double openPrice = iOpen(CURRENT_SYMBOL, PERIOD_H1, 0);    
    double openPrice = MarketInfo(CURRENT_SYMBOL, MODE_BID);
    double thresh_hold = 0.0005;
    double sellPrice = openPrice - thresh_hold;
    double sellPriceTp = sellPrice - thresh_hold;
    double buyPrice = openPrice + thresh_hold;
    double buyPriceTp = buyPrice + thresh_hold;
    //double sellPriceSl = buyPriceTp + 0.0001;
    //double buyPriceSl = sellPriceTp - 0.0001;

    datetime expiry = StrToTime(Year()+"."+Month()+"."+Day()+" 23:59:58");
    buyTicket = OrderSend(CURRENT_SYMBOL, OP_BUYSTOP, LOT_SIZE, buyPrice, 0, 0, buyPriceTp, "10pips buy on ", ID, expiry, Green);
    sellTicket = OrderSend(CURRENT_SYMBOL, OP_SELLSTOP, LOT_SIZE, sellPrice, 0, 0 , sellPriceTp, "10pips sell on ", ID, expiry, Green);
    created = true;
    creating = false;
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
