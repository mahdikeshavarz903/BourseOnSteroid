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

bool enterOnShowFunction = true;
int  domMapCoordinates[][6][2];
bool updateTableFlag=false;
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

   int               m_yesterdayPrice;
   int               m_tickSize;   // Rial or Toman
   DOM               dom[36];
   int               mapCoordinates[26][6][2];
   int               mapPriceToDomRow[][2];
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
      //Hide();
      // m_elements.Clear();
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
   if(updateTableFlag)
     {
      updateTable();
      updateTableFlag = false;
      enterOnShowFunction = true;
     }

   if(enterOnShowFunction)
     {
      int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
      ArrayResize(domMapCoordinates, ArraySize(dom));

      m_elements.Clear();
      long best_bid=MarketBook.InfoGetInteger(MBOOK_BEST_BID_INDEX);
      double best_bid_price = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
      double best_ask_price = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);

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

      for(int i=0; i< ArraySize(dom); i++)
        {
         YCoordinate = i * 20 + 20+YCoord();

         if(i<13 || i>=13 + total)
           {
            //if(i==13 + total)
            //   index = i - total;

            CBookCell *volumeCells=new CBookCell(1, volumeXCoordinate, YCoordinate, dom[i].volume, dom[i].type, "volume");
            m_elements.Add(volumeCells);
            volumeCells.Show();
            volumeCells.OnRefresh2(refresh);

            CBookCell *priceCells=new CBookCell(0, priceXCoordinate,YCoordinate,0,dom[i].price, dom[i].type, "price");
            m_elements.Add(priceCells);
            priceCells.Show();
            priceCells.OnRefresh2(refresh);

            CBookCell *bidCells=new CBookCell(1, bidXCoordinate,YCoordinate,dom[i].bidVol, dom[i].type, "bidVol");
            m_elements.Add(bidCells);
            bidCells.Show();
            bidCells.OnRefresh2(refresh);

            CBookCell *sellerCells=new CBookCell(1, sellerVolXCoordinate,YCoordinate,dom[i].sellerVol, dom[i].type, "sellerVol");
            m_elements.Add(sellerCells);
            sellerCells.Show();
            sellerCells.OnRefresh2(refresh);

            CBookCell *buyerCells=new CBookCell(1, buyerVolXCoordinate,YCoordinate,dom[i].buyerVol, dom[i].type, "buyerVol");
            m_elements.Add(buyerCells);
            buyerCells.Show();
            buyerCells.OnRefresh2(refresh);

            CBookCell *askCells=new CBookCell(1, askVolXCoordinate,YCoordinate,dom[i].askVol, dom[i].type, "askVol");
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

         domMapCoordinates[i][0][0] = volumeXCoordinate;
         domMapCoordinates[i][1][0] = priceXCoordinate;
         domMapCoordinates[i][2][0] = bidXCoordinate;
         domMapCoordinates[i][3][0] = sellerVolXCoordinate;
         domMapCoordinates[i][4][0] = buyerVolXCoordinate;
         domMapCoordinates[i][5][0] = askVolXCoordinate;

         for(int z=0; z<=5; z++)
            domMapCoordinates[i][z][1] = YCoordinate;
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
      
      enterOnShowFunction = false;
     }

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
               m_tickSize = StringToInteger(js.m_e[9].m_sv);
               m_yesterdayPrice = StringToInteger(js.m_e[10].m_sv);

               int diff = highAllowedPrice-lowAllowedPrice+1;
               ArrayResize(cMainTable, diff+1);

               int temp = highAllowedPrice;
               for(int i=0; i<=diff; i++)
                 {
                  CBookCell *cell=new CBookCell();

                  CMainTable *cmt = new CMainTable();
                  cmt.SetPrice(temp);
                  cmt.SetDomRowId(-1);

                  cMainTable[i] = GetPointer(cmt);

                  temp = temp - m_tickSize;
                 }

               cMainTable[0].SetDomRowId(StringToInteger(js.m_e[2].m_sv));
               cMainTable[1].SetDomRowId(StringToInteger(js.m_e[4].m_sv));
               cMainTable[ArraySize(cMainTable)-3].SetDomRowId(StringToInteger(js.m_e[6].m_sv));
               cMainTable[ArraySize(cMainTable)-2].SetDomRowId(StringToInteger(js.m_e[8].m_sv));

               CEventRefresh *refresh = new CEventRefresh();

               int indexs[] = {0, 1, (ArraySize(cMainTable)-3), (ArraySize(cMainTable)-2)};
               int prices[] = {highAllowedPrice, belowHighAllowedPrice, aboveLowAllowedPrice, lowAllowedPrice};
               int domRowIdList[] = {StringToInteger(js.m_e[2].m_sv), StringToInteger(js.m_e[4].m_sv), StringToInteger(js.m_e[6].m_sv), StringToInteger(js.m_e[8].m_sv)};
               int values;
               int askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
               int bidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);

               for(int j=0; j<4; j++)
                 {
                  if((askPrice!=prices[j] && (askPrice+m_tickSize)!=prices[j]) && (bidPrice!=prices[j] && (bidPrice-m_tickSize)!=prices[j]))
                    {
                     CBookCell *bookCell=new CBookCell();

                     cMainTable[indexs[j]].SetPrice(prices[j]);

                     cMainTable[indexs[j]].GetBookCell(bookCell, 1);
                     bookCell.SetVariables(domMapCoordinates[cMainTable[indexs[j]].GetDomRowId()][1][0], domMapCoordinates[cMainTable[indexs[j]].GetDomRowId()][1][1], 0, prices[j], (cMainTable[indexs[j]].GetDomRowId()<13)?0:1, 1);
                     cMainTable[indexs[j]].SetBookCell(bookCell, 1);
                     bookCell.Show();
                     bookCell.OnRefresh2(refresh);

                     int type = (cMainTable[indexs[j]].GetDomRowId()<13)?0:1;
                     int values[] = {cMainTable[indexs[j]].GetVolume(), 0, (cMainTable[indexs[j]].GetDomRowId()<13)?-1:cMainTable[indexs[j]].GetBidVolume(), (cMainTable[indexs[j]].GetDomRowId()<13)?-1:cMainTable[indexs[j]].GetSellerVolume(), (cMainTable[indexs[j]].GetDomRowId()>13)?-1:cMainTable[indexs[j]].GetBuyerVolume(), (cMainTable[indexs[j]].GetDomRowId()>13)?-1:cMainTable[indexs[j]].GetAskVolume()};

                     for(int i=0; i<6; i++)
                       {
                        if(i!=1)
                          {
                           bookCell=new CBookCell();
                           cMainTable[indexs[j]].GetBookCell(bookCell, i);
                           bookCell.SetVariables(domMapCoordinates[cMainTable[indexs[j]].GetDomRowId()][i][0], domMapCoordinates[cMainTable[indexs[j]].GetDomRowId()][i][1], values[i], type, i);
                           cMainTable[indexs[j]].SetBookCell(bookCell, i);
                           bookCell.Show();
                           bookCell.OnRefresh2(refresh);
                          }
                       }
                    }

                 }

               delete refresh;
              }
            else
               if(js.m_e[0].m_sv=="2")
                 {
                  Print("Code2");

                  double price = StringToDouble(js.m_e[1].m_sv);
                  int domRowId = StringToInteger(js.m_e[2].m_sv);

                  for(int i=0; i<ArraySize(cMainTable); i++)
                    {
                     if(cMainTable[i].GetPrice() == price && cMainTable[i].GetDomRowId() != domRowId)
                       {
                        CBookCell *bookCell;
                        CEventRefresh *refresh = new CEventRefresh();

                        for(int z=0; z<6; z++)
                          {
                           bookCell=new CBookCell();
                           cMainTable[i].GetBookCell(bookCell, z);
                           cMainTable[i].SetBookCell(bookCell, z);
                           bookCell.Hide();
                           bookCell.OnRefresh2(refresh);
                          }

                        bookCell=new CBookCell();

                        cMainTable[i].SetDomRowId(domRowId);
                        cMainTable[i].SetPrice(price);

                        cMainTable[i].GetBookCell(bookCell, 1);
                        bookCell.SetVariables(domMapCoordinates[cMainTable[i].GetDomRowId()][1][0], domMapCoordinates[cMainTable[i].GetDomRowId()][1][1], 0, price, (cMainTable[i].GetDomRowId()<13)?0:1, 1);
                        cMainTable[i].SetBookCell(bookCell, 1);
                        bookCell.Show();
                        bookCell.OnRefresh2(refresh);

                        int values[] = {cMainTable[i].GetVolume(), 0, (cMainTable[i].GetDomRowId()<13)?-1:cMainTable[i].GetBidVolume(), (cMainTable[i].GetDomRowId()<13)?-1:cMainTable[i].GetSellerVolume(), (cMainTable[i].GetDomRowId()>13)?-1:cMainTable[i].GetBuyerVolume(), (cMainTable[i].GetDomRowId()>13)?-1:cMainTable[i].GetAskVolume()};

                        for(int j=0; j<6; j++)
                          {
                           if(j!=1)
                             {
                              bookCell=new CBookCell();
                              cMainTable[i].GetBookCell(bookCell, j);
                              bookCell.SetVariables(domMapCoordinates[cMainTable[i].GetDomRowId()][j][0], domMapCoordinates[cMainTable[i].GetDomRowId()][j][1], values[j], (cMainTable[i].GetDomRowId()<13)?0:1, j);
                              cMainTable[i].SetBookCell(bookCell, j);
                              bookCell.Show();
                              bookCell.OnRefresh2(refresh);
                             }
                          }

                        delete refresh;
                        //delete bookCell;

                        break;

                       }
                    }

                 }
               else
                  if(js.m_e[0].m_sv=="3")
                    {
                     Print("Code3");

                     int price = StringToInteger(js.m_e[1].m_sv);
                     int orderVolume = StringToInteger(js.m_e[2].m_sv);
                     int orderPlace = StringToInteger(js.m_e[3].m_sv);
                     int domRowId = StringToInteger(js.m_e[4].m_sv);

                     for(int i=0; i<ArraySize(cMainTable); i++)
                       {
                        if(price == cMainTable[i].GetPrice() && cMainTable[i].GetDomRowId() != -1 && cMainTable[i].GetDomRowId() == domRowId)
                          {
                           CEventRefresh *refresh = new CEventRefresh();

                           CBookCell *bookCell=new CBookCell();

                           int type = (cMainTable[i].GetDomRowId()<13)?0:1;
                           if(type == 0)
                             {
                              cMainTable[i].GetBookCell(bookCell, 5);

                              bookCell.SetVariables(domMapCoordinates[cMainTable[i].GetDomRowId()][5][0], domMapCoordinates[cMainTable[i].GetDomRowId()][5][1],orderVolume, type, 1);
                              cMainTable[i].SetAskVolume(orderVolume);

                              cMainTable[i].SetBookCell(bookCell, 5);
                              bookCell.Show();
                              bookCell.OnRefresh2(refresh);
                             }
                           else
                             {
                              cMainTable[i].GetBookCell(bookCell, 2);

                              bookCell.SetVariables(domMapCoordinates[cMainTable[i].GetDomRowId()][2][0], domMapCoordinates[cMainTable[i].GetDomRowId()][2][1],orderVolume, type, 1);
                              cMainTable[i].SetBidVolume(orderVolume);

                              cMainTable[i].SetBookCell(bookCell, 2);
                              bookCell.Show();
                              bookCell.OnRefresh2(refresh);
                             }

                           delete refresh;
                           //delete bookCell;

                           break;
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
   int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);

   for(int i=0; i<ArraySize(dom); i++)
     {
      if(i<13)
         dom[i].type = 0;
      else
         dom[i].type = 1;

      if(i==0 || i==1 || i==4 || i==7 || i==10 || i==25 || i== 28 || i==31 || i==34 || i==35)
        {
         dom[i].volume = 0;
         dom[i].price = 0;

         if(i<13)
           {
            dom[i].bidVol = -1;
            dom[i].sellerVol = -1;
            dom[i].buyerVol = 0;
            dom[i].askVol = 0;
           }
         else
           {
            dom[i].bidVol = 0;
            dom[i].sellerVol = 0;
            dom[i].buyerVol = -1;
            dom[i].askVol = -1;
           }
        }
      else
         if(i==2 || i==3 || i==5 || i==6 || i==8 || i==9 || i==11 || i==12 || i==23 || i==24 || i==26 || i==27 || i==29 || i==30 || i==32 || i==33)
           {
            dom[i].volume = -1;
            dom[i].price = -1;
            dom[i].bidVol = -1;
            dom[i].sellerVol = -1;
            dom[i].buyerVol = -1;
            dom[i].askVol = -1;
           }

     }

  }
//+------------------------------------------------------------------+
