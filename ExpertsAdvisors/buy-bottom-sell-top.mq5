//+------------------------------------------------------------------+
//|                                          buy-bottom-sell-top.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+

//--- input parameters
input ulong ExtCollectTime   =30;  // test time in seconds
input ulong ExtSkipFirstTicks=10;  // number of ticks skipped at start
//--- flag of subscription to BookEvent events
bool book_subscribed=false;
//--- array for accepting requests from the market depth
MqlBookInfo  book[];
MqlBookInfo  x[];
int BHRSI_handle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
   //CSignalMACD *signal=new CSignalMACD;
   BHRSI_handle=iCustom(Symbol(),
                        0,
                        "\Indicators\Shared Projects\BourseOnSteroid\Indicators\BHRSI",
                        50,
                        50,
                        10,
                        10
                        );
   
   //--- show the start
   Comment(StringFormat("Waiting for the first %I64u ticks to arrive",ExtSkipFirstTicks));
   PrintFormat("Waiting for the first %I64u ticks to arrive",ExtSkipFirstTicks);
   //--- enable market depth broadcast
   if(MarketBookAdd(_Symbol))
     {
      book_subscribed=true;
      PrintFormat("%s: MarketBookAdd(%s) function returned true",__FUNCTION__,_Symbol);
     }
   else
      PrintFormat("%s: MarketBookAdd(%s) function returned false! GetLastError()=%d",__FUNCTION__,_Symbol,GetLastError());
   //--- successful initialization
   
   printf("OnInit!");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  printf("OnDeinit!");
  
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool getBook=MarketBookGet(NULL,book);
   if(getBook)
     {
      int size=ArraySize(book);
      Print("MarketBookInfo for ",Symbol());
      for(int i=0;i<size;i++)
        {
         //Print("OnTick => ", i+":",book[i].price
         //      +"    Volume = "+book[i].volume,
         //      " type = ",book[i].type);
        }
     }
   else
     {
      //Print("Could not get contents of the symbol DOM ",Symbol());
     }
     
   MqlTick last_tick;
   
   if(SymbolInfoTick(Symbol(), last_tick))
     {
      //Print("OnTick called => ", last_tick.time,": Bid = ",last_tick.bid,
      //      " Ask = ",last_tick.ask,"  Volume = ",last_tick.volume);
     }
   else Print("SymbolInfoTick() failed, error = ",GetLastError());
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
  // Print("OnTimer");
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   printf("OnTrade!");
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   printf("OnTradeTransaction!");
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---
   printf("OnTester!");
//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   printf("OnTesterInit!");
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   printf("OnTesterPass!");
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   printf("OnTesterDeinit!");
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
   printf("OnChartEvent!");
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   // printf("OnBookEvent!");

   if(ArraySize(book)>0 && ArraySize(x)>0)
   {
   Print("Book: ", book[0].price, book[1].price, book[2].price, book[3].price, book[4].price, book[5].price, book[6].price, book[7].price, book[8].price, book[9].price);
   Print("x: ", x[0].price, x[1].price, x[2].price, x[3].price, x[4].price, x[5].price, x[6].price, x[7].price, x[8].price, x[9].price);
   
   for(int i=0;i<ArraySize(book);i++){
      if(book[i].price != x[i].price){
         Print(book[i].price, " - " , x[i].price);
      }
      
   }
   
   }
   
   ArrayCopy(x,book,0,0,WHOLE_ARRAY);
  
   static ulong starttime=0;             // test start time 
   static ulong tickcounter=0;           // market depth update counter 
//--- work with depth market events only if we subscribed to them ourselves 
   if(!book_subscribed) 
      return; 
//--- count updates only for a certain symbol 
   if(symbol!=_Symbol) 
      return; 
//--- skip first ticks to clear the queue and to prepare 
   tickcounter++; 
   if(tickcounter<ExtSkipFirstTicks) 
      return; 
//--- remember the start time 
   if(tickcounter==ExtSkipFirstTicks)  
      starttime=GetMicrosecondCount(); 
//--- request for the market depth data 
   MarketBookGet(symbol,book); 
//--- when to stop?   
   ulong endtime=GetMicrosecondCount()-starttime; 
   ulong ticks  =1+tickcounter-ExtSkipFirstTicks; 
// how much time has passed in microseconds since the start of the test? 
   if(endtime>ExtCollectTime*1000*1000)  
     { 
      PrintFormat("%I64u ticks for %.1f seconds: %.1f ticks/sec ",ticks,endtime/1000.0/1000.0,ticks*1000.0*1000.0/endtime); 
      ExpertRemove(); 
      return; 
     } 
//--- display the counters in the comment field 
   if(endtime>0) 
      Comment(StringFormat("%I64u ticks for %.1f seconds: %.1f ticks/sec ",ticks,endtime/1000.0/1000.0,ticks*1000.0*1000.0/endtime));
  }
//+------------------------------------------------------------------+
