//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property strict

//#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElChart.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElButton.mqh>
#include "MBookCell.mqh"
#include "GlobalMarketBook.mqh"
#include "GlobalMainTable.mqh"
#include <socket-library-mt4-mt5.mqh>
#include <JAson.mqh>


struct DOM
  {
   int               type;
   int               volume;
   double            price;
   int               bidVol;
   int               sellerVol;
   int               buyerVol;
   int               askVol;
  };


// --------------------------------------------------------------------
// Global variables and constants
// --------------------------------------------------------------------
#define SOCKET_LIBRARY_USE_EVENTS

ushort   ServerPort = 63146;  // Server port

// Frequency for EventSetMillisecondTimer(). Doesn't need to
// be very frequent, because it is just a back-up for the
// event-driven handling in OnChartEvent()
#define TIMER_FREQUENCY_MS    1000

// Server socket
ServerSocket * glbServerSocket = NULL;

// Array of current clients
ClientSocket * glbClients[];

// Watch for need to create timer;
bool glbCreatedTimer = false;
CJAVal js(NULL, jtUNDEF);
bool b;

//+------------------------------------------------------------------+
//| The class implements presentation of Market Depth as a graphical |
//| order book consisting of cells showing prices and volumes        |
//| of limit orders.                                                 |
//+------------------------------------------------------------------+
class CBookGraphTable : public CElChart
  {
protected:
   CElChart          m_book_line;         // The separation line of the Market Depth
   long              m_prev_ask_total;    // The previous Ask depth
   long              m_prev_bid_total;    // The previous Bid depth
   long              m_limit_y;
   bool              m_pos_by_central;    // Positioning in the center
   double            m_prev_last;
   bool              IsLastTick(MqlTick& tick);

   int               tickSize;   // Rial or Toman
   DOM               dom[26];

public:
                     CBookGraphTable(void);
   virtual void      OnShow();
   virtual void      OnRefresh(CEventRefresh* refresh);
   void              LimitHeight(int y_pips);
   int               LimitHeight(void);
   long              YCenterDelta(void);
   void              AcceptNewConnections();
   void              HandleSocketIncomingData(int idxClient);
   void              updateTable();
  };
//+------------------------------------------------------------------+
//| Creates an instance of the order book                            |
//+------------------------------------------------------------------+
CBookGraphTable::CBookGraphTable(void) : CElChart(OBJ_LABEL),
   m_book_line(OBJ_RECTANGLE_LABEL),
   m_limit_y(0)
  {
   Text(" ");
   m_prev_ask_total = -1;
   m_prev_bid_total = -1;
   m_pos_by_central = true;

   updateTable();

// If the EA is being reloaded, e.g. because of change of timeframe,
// then we may already have done all the setup. See the
// termination code in OnDeinit.
   if(glbServerSocket)
     {
      Print("Reloading EA with existing server socket");
     }
   else
     {
      // Create the server socket
      glbServerSocket = new ServerSocket(ServerPort, false);
      if(glbServerSocket.Created())
        {
         Print("Server socket created");

         // Note: this can fail if MT4/5 starts up
         // with the EA already attached to a chart. Therefore,
         // we repeat in OnTick()
         glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
        }
      else
        {
         Print("Server socket FAILED - is the port already in use?");
        }
     }
  }
//+------------------------------------------------------------------+
//| Redraws the order book if number of elements changed             |
//+------------------------------------------------------------------+
void CBookGraphTable::OnRefresh(CEventRefresh *refresh)
  {
   if(!IsShowed())
      return;
   if(MarketBook.InfoGetInteger(MBOOK_DEPTH_ASK)!=m_prev_ask_total ||
      MarketBook.InfoGetInteger(MBOOK_DEPTH_BID)!=m_prev_bid_total)
     {
      Hide();
      m_elements.Clear();
      Show();
     }

// Accept any new pending connections
   AcceptNewConnections();

// Process any incoming data on each client socket,
// bearing in mind that HandleSocketIncomingData()
// can delete sockets and reduce the size of the array
// if a socket has been closed

   for(int i = ArraySize(glbClients) - 1; i >= 0; i--)
     {
      HandleSocketIncomingData(i);
     }
  }
//+------------------------------------------------------------------+
//| Returns true if the last tick was initiated by buying or         |
//| by selling                                                       |
//+------------------------------------------------------------------+
bool CBookGraphTable::IsLastTick(MqlTick &tick)
  {
   bool last = (tick.flags & TICK_FLAG_LAST) == TICK_FLAG_LAST;
   bool is_buy = (tick.flags & TICK_FLAG_BUY) == TICK_FLAG_BUY;
   bool is_sell = (tick.flags & TICK_FLAG_SELL) == TICK_FLAG_SELL;
   return (last && (is_buy || is_sell));
  }
//+------------------------------------------------------------------+
//| Returns shift of market depth middle relative to its beginning   |
//| along Y                                                           |
//+------------------------------------------------------------------+
long CBookGraphTable::YCenterDelta(void)
  {
   return MarketBook.InfoGetInteger(MBOOK_DEPTH_ASK)*15;
  }
//+------------------------------------------------------------------+
//| Creates an array of cells an an order book after each click      |
//| on the panel opening button                                      |
//+------------------------------------------------------------------+
void CBookGraphTable::OnShow(void)
  {
   m_elements.Clear();
   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
   long best_bid=MarketBook.InfoGetInteger(MBOOK_BEST_BID_INDEX);
   double best_bid_price = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
   double best_ask_price = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);

// This price should be py(Yesterday price) and for now we set it to best_bid_price
   double lowAllowedPrice = best_bid_price * 0.95;
   double highAllowedPrice = best_bid_price * 1.05;
   int totalRowsOfPriceColumn = (int)(highAllowedPrice - lowAllowedPrice);

   for(int i=0; i<ArraySize(mainTable) &&  ArraySize(MarketBook.LastTicks); i++)
     {
      if(mainTable[i].price==MarketBook.LastTicks[0].last)
        {
         int lastIndex = ArraySize(MarketBook.LastTicks)-1;

         if(lastIndex>=0)
           {
            if(MarketBook.LastTicks[0].flags == TICK_FLAG_BUY)
               Print("TICK_FLAG_BUY: ", MarketBook.LastTicks[0].flags);
            else
               if(MarketBook.LastTicks[0].flags == TICK_FLAG_SELL)
                  Print("TICK_FLAG_SELL: ", MarketBook.LastTicks[0].flags);
               else
                  if(MarketBook.LastTicks[0].flags == TICK_FLAG_BID)
                     Print("TICK_FLAG_BID: ", MarketBook.LastTicks[0].flags);
                  else
                     if(MarketBook.LastTicks[0].flags == TICK_FLAG_ASK)
                        Print("TICK_FLAG_ASK: ", MarketBook.LastTicks[0].flags);
                     else
                        if(MarketBook.LastTicks[0].flags == TICK_FLAG_LAST)
                           Print("TICK_FLAG_LAST: ", MarketBook.LastTicks[0].flags);
                        else
                           if(MarketBook.LastTicks[0].flags == TICK_FLAG_VOLUME)
                              Print("TICK_FLAG_VOLUME: ", MarketBook.LastTicks[0].flags);

            if(MarketBook.LastTicks[0].flags == TICK_FLAG_BID)
              {
               mainTable[i].buyerVol = MarketBook.LastTicks[lastIndex].volume;
               mainTable[i].volume += mainTable[i].buyerVol;
              }
            else
               if(MarketBook.LastTicks[0]. flags == TICK_FLAG_ASK)
                 {
                  mainTable[i].sellerVol = MarketBook.LastTicks[lastIndex].volume;
                  mainTable[i].volume += mainTable[i].sellerVol;
                 }
           }

        }
     }

   CEventRefresh* refresh = new CEventRefresh();

   long volumeXCoordinate;
   long priceXCoordinate;
   long bidXCoordinate;
   long sellerVolXCoordinate;
   long buyerVolXCoordinate;
   long askVolXCoordinate;

   long YCoordinate;

   volumeXCoordinate = 20 + XCoord()-500;
   priceXCoordinate = 20 + XCoord()-380;
   bidXCoordinate = 20 + XCoord()-260;
   sellerVolXCoordinate = 20 + XCoord()-140;
   buyerVolXCoordinate = 20 + XCoord()-20;
   askVolXCoordinate = 20 + XCoord()+100;

   int index=0;

   for(int i=0; i< ArraySize(dom)+total; i++)
     {
      YCoordinate = i * 20 + 20+YCoord();

      if((i<13 || i>=13 + total) && index < 26)
        {
         if(i==13 + total)
            index = i - total;

         CBookCell *volumeCells=new CBookCell(1, volumeXCoordinate, YCoordinate, 0, dom[index].volume, dom[index].type, "volume");
         m_elements.Add(volumeCells);
         volumeCells.Show();
         volumeCells.OnRefresh2(refresh);

         CBookCell *priceCells=new CBookCell(0, priceXCoordinate,YCoordinate,0,dom[index].price, dom[index].type, "price");
         m_elements.Add(priceCells);
         priceCells.Show();
         priceCells.OnRefresh2(refresh);

         CBookCell *bidCells=new CBookCell(1, bidXCoordinate,YCoordinate,0,dom[index].bidVol, dom[index].type, "bidVol");
         m_elements.Add(bidCells);
         bidCells.Show();
         bidCells.OnRefresh2(refresh);

         CBookCell *sellerCells=new CBookCell(1, sellerVolXCoordinate,YCoordinate,0,dom[index].sellerVol, dom[index].type, "sellerVol");
         m_elements.Add(sellerCells);
         sellerCells.Show();
         sellerCells.OnRefresh2(refresh);

         CBookCell *buyerCells=new CBookCell(1, buyerVolXCoordinate,YCoordinate,0,dom[index].buyerVol, dom[index].type, "buyerVol");
         m_elements.Add(buyerCells);
         buyerCells.Show();
         buyerCells.OnRefresh2(refresh);

         CBookCell *askCells=new CBookCell(1, askVolXCoordinate,YCoordinate,0,dom[index].askVol, dom[index].type, "askVol");
         m_elements.Add(askCells);
         askCells.Show();
         askCells.OnRefresh2(refresh);

         index++;
        }
      else
         if(i>=13 && i< 13 + total)
           {
            if(i==13)
               index = 0;

            CBookCell *volumeCells=new CBookCell(1, volumeXCoordinate, YCoordinate, index, &MarketBook, "volume");
            m_elements.Add(volumeCells);
            volumeCells.Show();
            volumeCells.OnRefresh(refresh);

            CBookCell *priceCells=new CBookCell(0, priceXCoordinate,YCoordinate,index,&MarketBook, "price");
            m_elements.Add(priceCells);
            priceCells.Show();
            priceCells.OnRefresh(refresh);

            CBookCell *bidCells=new CBookCell(1, bidXCoordinate,YCoordinate,index,&MarketBook, "bidVol");
            m_elements.Add(bidCells);
            bidCells.Show();
            bidCells.OnRefresh(refresh);

            CBookCell *sellerCells=new CBookCell(1, sellerVolXCoordinate,YCoordinate,index, &MarketBook, "sellerVol");
            m_elements.Add(sellerCells);
            sellerCells.Show();
            sellerCells.OnRefresh(refresh);

            CBookCell *buyerCells=new CBookCell(1, buyerVolXCoordinate,YCoordinate,index, &MarketBook, "buyerVol");
            m_elements.Add(buyerCells);
            buyerCells.Show();
            buyerCells.OnRefresh(refresh);

            //XCoord()+230
            CBookCell *askCells=new CBookCell(1, askVolXCoordinate,YCoordinate,index,&MarketBook, "askVol");
            m_elements.Add(askCells);
            askCells.Show();
            askCells.OnRefresh(refresh);

            index++;
           }

     }

   delete refresh;
   best_bid=MarketBook.InfoGetInteger(MBOOK_BEST_BID_INDEX);
   long y=best_bid*15+YCoord()+10;
   m_book_line.YCoord(y);
   m_book_line.XCoord(XCoord());
   m_book_line.Width(Width());
   m_book_line.Height(1);
   m_book_line.BackgroundColor(clrBlack);
   m_book_line.BorderColor(clrBlack);
   m_book_line.BorderType(BORDER_FLAT);
   m_book_line.Show();
   m_elements.Add(GetPointer(m_book_line));
   m_prev_ask_total = MarketBook.InfoGetInteger(MBOOK_DEPTH_ASK);
   m_prev_bid_total = MarketBook.InfoGetInteger(MBOOK_DEPTH_BID);
   int need_height = total*15+20;
   Height(need_height);
  }

// --------------------------------------------------------------------
// Accepts new connections on the server socket, creating new
// entries in the glbClients[] array
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBookGraphTable::AcceptNewConnections()
  {
// Keep accepting any pending connections until Accept() returns NULL
   ClientSocket * pNewClient = NULL;
   do
     {
      pNewClient = glbServerSocket.Accept();
      if(pNewClient != NULL)
        {
         int sz = ArraySize(glbClients);
         ArrayResize(glbClients, sz + 1);
         glbClients[sz] = pNewClient;
         Print("New client connection");
        }

     }
   while(pNewClient != NULL);
  }


// --------------------------------------------------------------------
// Handles any new incoming data on a client socket, identified
// by its index within the glbClients[] array. This function
// deletes the ClientSocket object, and restructures the array,
// if the socket has been closed by the client
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBookGraphTable::HandleSocketIncomingData(int idxClient)
  {
   ClientSocket * pClient = glbClients[idxClient];

// Keep reading CRLF-terminated lines of input from the client
// until we run out of new data
   bool bForceClose = false; // Client has sent a "close" message
   string strCommand;
   do
     {
      strCommand = pClient.Receive("\r\n");

      if(StringLen(strCommand)!=0)
        {
         b=js.Deserialize(strCommand); // deserialized
         if(b==true)
           {
            if(js.m_e[0].m_sv=="1")
              {
               int highAllowedPrice = StringToInteger(js.m_e[1].m_sv);
               int belowHighAllowedPrice = StringToInteger(js.m_e[3].m_sv);
               int aboveLowAllowedPrice = StringToInteger(js.m_e[5].m_sv);
               int lowAllowedPrice = StringToInteger(js.m_e[7].m_sv);
               tickSize = StringToInteger(js.m_e[9].m_sv);

               int diff = highAllowedPrice-lowAllowedPrice+1;
               ArrayResize(mainTable, diff);

               int temp = highAllowedPrice;
               for(int i=0; i<diff; i++)
                 {
                  mainTable[i].price = temp;
                  mainTable[i].domRowId = -1;
                  temp = temp - tickSize;
                 }

               mainTable[0].domRowId = StringToInteger(js.m_e[2].m_sv);
               mainTable[1].domRowId = StringToInteger(js.m_e[4].m_sv);
               mainTable[ArraySize(mainTable)-2].domRowId = StringToInteger(js.m_e[6].m_sv);
               mainTable[ArraySize(mainTable)-1].domRowId = StringToInteger(js.m_e[8].m_sv);

               dom[0].price = highAllowedPrice;
               dom[1].price = belowHighAllowedPrice;
               dom[ArraySize(dom)-2].price = aboveLowAllowedPrice;
               dom[ArraySize(dom)-1].price = lowAllowedPrice;

              }
            else
               if(js.m_e[0].m_sv=="2")
                 {
                  int price = StringToInteger(js.m_e[1].m_sv);

                  for(int i=0; i<ArraySize(mainTable); i++)
                    {
                     if(mainTable[i].price == price)
                       {
                        if(mainTable[i].domRowId != StringToInteger(js.m_e[2].m_sv))
                          {
                           mainTable[i].domRowId = StringToInteger(js.m_e[2].m_sv);
                           dom[mainTable[i].domRowId].price = price;
                          }

                       }
                    }

                 }
               else
                  if(js.m_e[0].m_sv=="3")
                    {
                     int price = StringToInteger(js.m_e[1].m_sv);
                     int orderVolume = StringToInteger(js.m_e[2].m_sv);
                     int orderPlace = StringToInteger(js.m_e[3].m_sv);

                     for(int i=0; i<ArraySize(mainTable); i++)
                       {
                        if(price == mainTable[i].price)
                          {
                           if(mainTable[i].domRowId != -1 && dom[mainTable[i].domRowId].price==price)
                             {
                              if(dom[mainTable[i].domRowId].type == 0)
                                 dom[mainTable[i].domRowId].askVol = orderVolume;
                              else
                                 dom[mainTable[i].domRowId].bidVol = orderVolume;
                             }

                          }
                       }

                    }
           }


         // OnShow();
        }
     }
   while(strCommand != "");

// If the socket has been closed, or the client has sent a close message,
// release the socket and shuffle the glbClients[] array
   if(!pClient.IsSocketConnected() || bForceClose)
     {
      Print("Client has disconnected");

      // Client is dead. Destroy the object
      delete pClient;

      // And remove from the array
      int ctClients = ArraySize(glbClients);
      for(int i = idxClient + 1; i < ctClients; i++)
        {
         glbClients[i - 1] = glbClients[i];
        }
      ctClients--;
      ArrayResize(glbClients, ctClients);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBookGraphTable::updateTable()
  {
// HighAllowedPrice
   dom[0].type = 0;
   dom[0].volume = 0;
   dom[0].price = 0;
   dom[0].bidVol = -1;
   dom[0].sellerVol = -1;
   dom[0].buyerVol = 0;
   dom[0].askVol = 0;

// BelowHighAllowedPrice
   dom[1].type = 0;
   dom[1].volume = 0;
   dom[1].price = 0;
   dom[1].bidVol = -1;
   dom[1].sellerVol = -1;
   dom[1].buyerVol = 0;
   dom[1].askVol = 0;


   dom[2].type = 0;
   dom[2].volume = -1;
   dom[2].price = -1;
   dom[2].bidVol = -1;
   dom[2].sellerVol = -1;
   dom[2].buyerVol = -1;
   dom[2].askVol = -1;

   dom[3].type = 0;
   dom[3].volume = -1;
   dom[3].price = -1;
   dom[3].bidVol = -1;
   dom[3].sellerVol = -1;
   dom[3].buyerVol = -1;
   dom[3].askVol = -1;

// AskFourPercent
   dom[4].type = 0;
   dom[4].volume = 0;
   dom[4].price = 0;
   dom[4].bidVol = -1;
   dom[4].sellerVol = -1;
   dom[4].buyerVol = 0;
   dom[4].askVol = 0;

   dom[5].type = 0;
   dom[5].volume = -1;
   dom[5].price = -1;
   dom[5].bidVol = -1;
   dom[5].sellerVol = -1;
   dom[5].buyerVol = -1;
   dom[5].askVol = -1;

   dom[6].type = 0;
   dom[6].volume = -1;
   dom[6].price = -1;
   dom[6].bidVol = -1;
   dom[6].sellerVol = -1;
   dom[6].buyerVol = -1;
   dom[6].askVol = -1;

// AskThreePercent
   dom[7].type = 0;
   dom[7].volume = 0;
   dom[7].price = 0;
   dom[7].bidVol = -1;
   dom[7].sellerVol = -1;
   dom[7].buyerVol = 0;
   dom[7].askVol = 0;

   dom[8].type = 0;
   dom[8].volume = -1;
   dom[8].price = -1;
   dom[8].bidVol = -1;
   dom[8].sellerVol = -1;
   dom[8].buyerVol = -1;
   dom[8].askVol = -1;

   dom[9].type = 0;
   dom[9].volume = -1;
   dom[9].price = -1;
   dom[9].bidVol = -1;
   dom[9].sellerVol = -1;
   dom[9].buyerVol = -1;
   dom[9].askVol = -1;

// AskTwoPercent
   dom[10].type = 0;
   dom[10].volume = 0;
   dom[10].price = 0;
   dom[10].bidVol = -1;
   dom[10].sellerVol = -1;
   dom[10].buyerVol = 0;
   dom[10].askVol = 0;

   dom[11].type = 0;
   dom[11].volume = -1;
   dom[11].price = -1;
   dom[11].bidVol = -1;
   dom[11].sellerVol = -1;
   dom[11].buyerVol = -1;
   dom[11].askVol = -1;

   dom[12].type = 0;
   dom[12].volume = -1;
   dom[12].price = -1;
   dom[12].bidVol = -1;
   dom[12].sellerVol = -1;
   dom[12].buyerVol = -1;
   dom[12].askVol = -1;

   dom[13].type = 1;
   dom[13].volume = -1;
   dom[13].price = -1;
   dom[13].bidVol = -1;
   dom[13].sellerVol = -1;
   dom[13].buyerVol = -1;
   dom[13].askVol = -1;

   dom[14].type = 1;
   dom[14].volume = -1;
   dom[14].price = -1;
   dom[14].bidVol = -1;
   dom[14].sellerVol = -1;
   dom[14].buyerVol = -1;
   dom[14].askVol = -1;

// BidTwoPercent
   dom[15].type = 1;
   dom[15].volume = 0;
   dom[15].price = 0;
   dom[15].bidVol = 0;
   dom[15].sellerVol = 0;
   dom[15].buyerVol = -1;
   dom[15].askVol = -1;

   dom[16].type = 1;
   dom[16].volume = -1;
   dom[16].price = -1;
   dom[16].bidVol = -1;
   dom[16].sellerVol = -1;
   dom[16].buyerVol = -1;
   dom[16].askVol = -1;

   dom[17].type = 1;
   dom[17].volume = -1;
   dom[17].price = -1;
   dom[17].bidVol = -1;
   dom[17].sellerVol = -1;
   dom[17].buyerVol = -1;
   dom[17].askVol = -1;

// BidThreePercent
   dom[18].type = 1;
   dom[18].volume = 0;
   dom[18].price = 0;
   dom[18].bidVol = 0;
   dom[18].sellerVol = 0;
   dom[18].buyerVol = -1;
   dom[18].askVol = -1;

   dom[19].type = 1;
   dom[19].volume = -1;
   dom[19].price = -1;
   dom[19].bidVol = -1;
   dom[19].sellerVol = -1;
   dom[19].buyerVol = -1;
   dom[19].askVol = -1;

   dom[20].type = 1;
   dom[20].volume = -1;
   dom[20].price = -1;
   dom[20].bidVol = -1;
   dom[20].sellerVol = -1;
   dom[20].buyerVol = -1;
   dom[20].askVol = -1;

// BidFourPercent
   dom[21].type = 1;
   dom[21].volume = 0;
   dom[21].price = 0;
   dom[21].bidVol = 0;
   dom[21].sellerVol = 0;
   dom[21].buyerVol = -1;
   dom[21].askVol = -1;

   dom[22].type = 1;
   dom[22].volume = -1;
   dom[22].price = -1;
   dom[22].bidVol = -1;
   dom[22].sellerVol = -1;
   dom[22].buyerVol = -1;
   dom[22].askVol = -1;

   dom[23].type = 1;
   dom[23].volume = -1;
   dom[23].price = -1;
   dom[23].bidVol = -1;
   dom[23].sellerVol = -1;
   dom[23].buyerVol = -1;
   dom[23].askVol = -1;

// AboveLowAllowedPrice
   dom[24].type = 1;
   dom[24].volume = 0;
   dom[24].price = 0;
   dom[24].bidVol = 0;
   dom[24].sellerVol = 0;
   dom[24].buyerVol = -1;
   dom[24].askVol = -1;

// LowAllowedPrice
   dom[25].type = 1;
   dom[25].volume = 0;
   dom[25].price = 0;
   dom[25].bidVol = 0;
   dom[25].sellerVol = 0;
   dom[25].buyerVol = -1;
   dom[25].askVol = -1;
  }
//+------------------------------------------------------------------+
