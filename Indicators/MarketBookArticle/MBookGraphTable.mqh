//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property strict

//#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
#include "GlobalMainTable.mqh"
#include "MBookCell.mqh"
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElButton.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElChart.mqh>
#include "GlobalMarketBook.mqh"
#include "../../Include/socket-library-mt4-mt5.mqh"
#include "../../Include/JAson.mqh"

bool enterOnShowFunction = false;   // This flag is used to control access to part of the OnShow function
int  domMapCoordinates[][7][2];     // The variable that holds all coordinates of cells
bool updateTableFlag=false;         // This flag is used to control enterOnShowFunction flag
const int PRIMARY_DEPTH_LENGTH=36;
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
   int               m_yesterdayPrice;    // PY(price yesterday), The value of this variable comes from Nodejs
   int               m_tickSize;          // Rial or Toman , The value of this variable comes from Nodejs

public:
                     CBookGraphTable(void);
   virtual void      OnShow();
   virtual void      OnRefresh(CEventRefresh* refresh);
   void              LimitHeight(int y_pips);
   int               LimitHeight(void);
   long              YCenterDelta(void);
   void              AcceptNewConnections();
   void              HandleSocketIncomingData(int idxClient);
   void              FindMinMaxInMainTable() const;
   string            TempFunction(int volumeLegnth) const;
   void              ShowCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type) const;
   void              HideCellBook(CMainTable &value, int cellNumber, CEventRefresh *refresh, double price);
   void              ShiftCells(int start, int end) const;
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
   /* After custom DOM is opened, the updateTableFlag flag becomes true and then the enterOnShowFunction
   flag becomes true */
   if(updateTableFlag)
     {
      updateTableFlag = false;
      enterOnShowFunction = true;
     }

   if(enterOnShowFunction)
     {
      int total = (int)MarketBook.InfoGetInteger(MBOOK_DEPTH_TOTAL);
      ArrayResize(domMapCoordinates, PRIMARY_DEPTH_LENGTH);

      m_elements.Clear();
      long best_bid=MarketBook.InfoGetInteger(MBOOK_BEST_BID_INDEX);
      double best_bid_price = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);
      double best_ask_price = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);

      CEventRefresh* refresh = new CEventRefresh();

      /* y-axis variables */
      long YCoordinate;

      /* Determine coordinates of each variable for X-axis */
      long volumeXCoordinate = 100 + 20 + XCoord()-500;
      long priceXCoordinate = 100 + 20 + XCoord()-380;
      long pricePercentageXCoordinate = 100 + 20 + XCoord()-260;
      long bidXCoordinate = 100 + 20 + XCoord()-140;
      long sellerVolXCoordinate = 100 + 20 + XCoord()-20;
      long buyerVolXCoordinate = 100 + 20 + XCoord()+100;
      long askVolXCoordinate = 100 + 20 + XCoord()+220;

      int xCoordinates[] = {volumeXCoordinate, priceXCoordinate, pricePercentageXCoordinate, bidXCoordinate,
                            sellerVolXCoordinate, buyerVolXCoordinate, askVolXCoordinate
                           };

      /* 0: price, 1: volume , 2: pricePercentage */
      int type[] = {1, 0, 2, 1, 1, 1, 1};
      string column[] = {"volume", "price", "pricePercentage", "bidVol", "sellerVol", "buyerVol", "askVol"};

      /* Find min and max for hundred and below hundred, thousands, Millions, Billions */
      FindMinMaxInMainTable();

      CMainTable *value;
      int index=0;

      for(int i=0; i< PRIMARY_DEPTH_LENGTH; i++)
        {
         YCoordinate = i * 20 + 20+YCoord();

         if(i<13 || i>=13 + total)
           {
            for(int j=0; j< TOTAL_COLUMN; j++)
              {
               CBookCell *cell=new CBookCell(type[j], xCoordinates[j], YCoordinate, 0, (i<13)?0:1, column[j]);
               m_elements.Add(cell);
               cell.Show();
               cell.OnRefresh2(refresh);
              }
           }
         else
            if(i>=13 && i< 13 + total)
              {
               if(i==13)
                  index = 0;

               for(int j=0; j< TOTAL_COLUMN; j++)
                 {
                  CBookCell *cell=new CBookCell(type[j], xCoordinates[j], YCoordinate, index, &MarketBook, column[j], 0);
                  m_elements.Add(cell);
                  cell.Show();
                  cell.OnRefresh(refresh);
                 }

               index++;
              }

         for(int z=0; z<TOTAL_COLUMN; z++)
           {
            domMapCoordinates[i][z][1] = YCoordinate;
            domMapCoordinates[i][z][0] = xCoordinates[z];
           }
        }

      /*
      delete refresh;
      */
      delete refresh;

      best_bid=MarketBook.InfoGetInteger(MBOOK_BEST_BID_INDEX);
      long y=best_bid*15+YCoord()+305;
      m_book_line.YCoord(y);
      m_book_line.XCoord(XCoord()-500);
      m_book_line.Width(920);
      m_book_line.Height(1);
      m_book_line.BackgroundColor(clrBlack);
      m_book_line.BorderColor(clrBlack);
      m_book_line.BorderType(BORDER_FLAT);
      m_book_line.Show();
      m_elements.Add(GetPointer(m_book_line));
     }
  }

//+--------------------------------------------------------------------+
//| Accepts new connections on the server socket, creating new          |
//| entries in the glbClients[] array                                   |
//+--------------------------------------------------------------------+
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


//+--------------------------------------------------------------+
//| Handles any new incoming data on a client socket, identified |
//| by its index within the glbClients[] array. This function    |
//| deletes the ClientSocket object, and restructures the array, |
//| if the socket has been closed by the client                  |
//+--------------------------------------------------------------+
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
            /* Code1: Initial some variables and create CMainTable */
            if(js.m_e[0].m_sv=="1")
              {
               int highAllowedPrice = StringToInteger(js.m_e[1].m_sv);        // High allowed price of each day
               int belowHighAllowedPrice = StringToInteger(js.m_e[3].m_sv);   // High allowed price mines 1 or 10
               int aboveLowAllowedPrice = StringToInteger(js.m_e[5].m_sv);    // Low allowed price plus 1 or 10
               int lowAllowedPrice = StringToInteger(js.m_e[7].m_sv);         // Low allowed price of each day
               m_tickSize = StringToInteger(js.m_e[9].m_sv);                  // Rial or Toman
               m_yesterdayPrice = StringToInteger(js.m_e[10].m_sv);           // PY(price yesterday)

               /* diff: Number of prices between high and low allowed price */
               int diff = highAllowedPrice-lowAllowedPrice+1;

               /* Clear HashTables */
               cMainTable.Clear();
               mapDomRowIdToPrice.Clear();

               int temp = highAllowedPrice;

               /* Fill CMainTable */
               for(int i=0; i<diff; i++)
                 {
                  CBookCell *cell=new CBookCell();

                  double pricePercentage = ((float)(temp-lowAllowedPrice)/(highAllowedPrice-lowAllowedPrice))*100;
                  CMainTable *cmt = new CMainTable(pricePercentage);
                  cmt.SetPrice(temp);
                  cmt.SetDomRowId(-1);
                  cmt.SetPricePercentage(pricePercentage);

                  cMainTable.Add(temp, GetPointer(cmt));

                  temp = temp - m_tickSize;
                 }


               /* Update mapDomRowIdToPrice */
               CMainTable *value;
               if(cMainTable.TryGetValue(highAllowedPrice,value))
                 {
                  value.SetDomRowId(StringToInteger(js.m_e[2].m_sv));
                  mapDomRowIdToPrice.Add(value.GetDomRowId(), highAllowedPrice);
                 }

               if(cMainTable.TryGetValue(belowHighAllowedPrice,value))
                 {
                  value.SetDomRowId(StringToInteger(js.m_e[4].m_sv));
                  mapDomRowIdToPrice.Add(value.GetDomRowId(), belowHighAllowedPrice);
                 }

               if(cMainTable.TryGetValue(aboveLowAllowedPrice, value))
                 {
                  value.SetDomRowId(StringToInteger(js.m_e[6].m_sv));
                  mapDomRowIdToPrice.Add(value.GetDomRowId(), aboveLowAllowedPrice);
                 }

               if(cMainTable.TryGetValue(lowAllowedPrice, value))
                 {
                  value.SetDomRowId(StringToInteger(js.m_e[8].m_sv));
                  mapDomRowIdToPrice.Add(value.GetDomRowId(), lowAllowedPrice);
                 }

               CEventRefresh *refresh = new CEventRefresh();
               double prices[] = {highAllowedPrice, belowHighAllowedPrice, aboveLowAllowedPrice, lowAllowedPrice};
               int askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
               int bidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);

               /* Show cells for high, below high, low, and above low allowed price */
               for(int j=0; j<4; j++)
                 {
                  if(cMainTable.TryGetValue(prices[j], value) && (askPrice!=prices[j] && (askPrice+m_tickSize)!=prices[j]) && (bidPrice!=prices[j] && (bidPrice-m_tickSize)!=prices[j]))
                    {
                     int type = (value.GetDomRowId()<13)?0:1;
                     int values[] = {value.GetVolume(), 0, 0, (value.GetDomRowId()<13)?-1:value.GetBidVolume(), (value.GetDomRowId()<13)?-1:value.GetSellerVolume(), (value.GetDomRowId()>13)?-1:value.GetBuyerVolume(), (value.GetDomRowId()>13)?-1:value.GetAskVolume()};

                     for(int i=0; i<TOTAL_COLUMN; i++)
                       {
                        if(i==PRICE_COLUMN)
                           ShowCellBook(value, value.GetDomRowId(), PRICE_COLUMN, refresh, (value.GetDomRowId()<13)?0:1, 0, prices[j], 0);
                        else
                           if(i==PRICE_PERCENTAGE_COLUMN)
                              ShowCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, (value.GetDomRowId()<13)?0:1, 0, value.GetPricePercentage(), 2);
                           else
                              ShowCellBook(value, value.GetDomRowId(), i, refresh, (value.GetDomRowId()<13)?0:1, values[i], 0, 1);
                       }
                    }

                 }

               delete refresh;
              }
            else
               if(js.m_e[0].m_sv=="2") /* Code2: Get prices from Nodejs */
                 {
                  CMainTable *value;
                  CEventRefresh *refresh = new CEventRefresh();

                  double price = StringToDouble(js.m_e[1].m_sv);
                  int domRowId = StringToInteger(js.m_e[2].m_sv);

                  /*
                     If the domRowId variable does not exist, add it to mapDomRowIdToPrice, otherwise update its value
                  */
                  if(!mapDomRowIdToPrice.ContainsKey(domRowId))
                     mapDomRowIdToPrice.Add(domRowId, price);
                  else
                     mapDomRowIdToPrice.TrySetValue(domRowId, price);

                  /* Find the input price in CMainTable */
                  if(cMainTable.TryGetValue(price, value)  && value!=NULL)
                    {
                     if(domRowId != -1)
                       {
                        CMainTable *previousValue;
                        double tempPrice;
                        mapDomRowIdToPrice.TryGetValue(domRowId, tempPrice);

                        if(cMainTable.TryGetValue(tempPrice, previousValue))
                          {
                           for(int z=0; z<TOTAL_COLUMN; z++)
                             {
                              HideCellBook(previousValue, z, refresh, tempPrice);
                             }
                           previousValue.SetDomRowId(-1);

                           cMainTable.TrySetValue(tempPrice, previousValue);
                          }

                       }

                     value.SetDomRowId(domRowId);
                     value.SetPrice(price);
                     cMainTable.TrySetValue(price, value);

                     int values[] = {value.GetVolume(), 0, 0, (value.GetDomRowId()<13)?-1:value.GetBidVolume(), (value.GetDomRowId()<13)?-1:value.GetSellerVolume(), (value.GetDomRowId()>13)?-1:value.GetBuyerVolume(), (value.GetDomRowId()>13)?-1:value.GetAskVolume()};

                     for(int j=0, k=0; j<TOTAL_COLUMN; j++)
                       {
                        if(j==PRICE_PERCENTAGE_COLUMN)
                          {
                           ShowCellBook(value, value.GetDomRowId(), j, refresh, (value.GetDomRowId()<13)?0:1, 0, price, 2);
                          }
                        else
                           if(j==PRICE_COLUMN)
                             {
                              ShowCellBook(value, value.GetDomRowId(), j, refresh, (value.GetDomRowId()<13)?0:1, 0, price, 0);
                             }
                           else
                             {
                              ShowCellBook(value, value.GetDomRowId(), j, refresh, (value.GetDomRowId()<13)?0:1, values[j], price, 1);
                             }
                       }
                    }

                  delete refresh;
                 }
               else
                  if(js.m_e[0].m_sv=="3")
                    {
                     int price = StringToInteger(js.m_e[1].m_sv);
                     int orderVolume = StringToInteger(js.m_e[2].m_sv);
                     int orderPlace = StringToInteger(js.m_e[3].m_sv);
                     int domRowId = StringToInteger(js.m_e[4].m_sv);

                     CMainTable *value;
                     if(cMainTable.TryGetValue(price, value))
                       {
                        if(value.GetDomRowId() != -1 && value.GetDomRowId() == domRowId)
                          {
                           CEventRefresh *refresh = new CEventRefresh();

                           int type = (value.GetDomRowId()<13)?0:1;
                           int cellNumber;

                           if(type == 0)
                             {
                              value.SetAskVolume(orderVolume);
                              cellNumber=ASK_COLUMN;
                             }
                           else
                             {
                              value.SetBidVolume(orderVolume);
                              cellNumber=BID_COLUMN;
                             }

                           cMainTable.TrySetValue(price, value);
                           ShowCellBook(value, value.GetDomRowId(), cellNumber, refresh, type, orderVolume, price, 1);

                           delete refresh;
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
void CBookGraphTable::ShowCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type) const
  {
   CMainTable *tempValue=GetPointer(value);

   FindMinMaxInMainTable();

   CBookCell *bookCell = new CBookCell();
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());

   if(type==1)
      bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], volume, buyOrSell);
   else
      if(type==2)
         bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], value.GetPricePercentage(), buyOrSell);
      else
         bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], price, buyOrSell);

   value.SetBookCell(bookCell, cellNumber);
   cMainTable.TrySetValue(price, tempValue);

   bookCell.Hide();
   bookCell.Show();
   bookCell.OnRefresh2(refresh);
  }
//+------------------------------------------------------------------+
void CBookGraphTable::HideCellBook(CMainTable &value, int cellNumber, CEventRefresh *refresh, double price)
  {
   CMainTable *tempValue=GetPointer(value);

   CBookCell *bookCell = new CBookCell();
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());
   value.SetBookCell(bookCell, cellNumber);
   cMainTable.TrySetValue(price, tempValue);

   bookCell.Hide();
   bookCell.OnRefresh2(refresh);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBookGraphTable::ShiftCells(int start, int end) const
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   if(ArraySize(keys)!=0)
     {
      CMainTable *value;
      CEventRefresh *refresh = new CEventRefresh();

      for(int i=start; i<end; i++)
        {
         if(cMainTable.TryGetValue(keys[i], value))
           {
            int type = (value.GetDomRowId()<13)?0:1;
            int values[] = {value.GetVolume(), 0, 0, (value.GetDomRowId()<13)?-1:value.GetBidVolume(), (value.GetDomRowId()<13)?-1:value.GetSellerVolume(), (value.GetDomRowId()>13)?-1:value.GetBuyerVolume(), (value.GetDomRowId()>13)?-1:value.GetAskVolume()};

            for(int i=0; i<TOTAL_COLUMN; i++)
              {
               if(i==PRICE_COLUMN)
                  ShowCellBook(value, value.GetDomRowId(), PRICE_COLUMN, refresh, (value.GetDomRowId()<13)?0:1, 0, keys[i], 0);
               else
                  if(i==PRICE_PERCENTAGE_COLUMN)
                     ShowCellBook(value, value.GetDomRowId(), PRICE_PERCENTAGE_COLUMN, refresh, (value.GetDomRowId()<13)?0:1, 0, value.GetPricePercentage(), 2);
                  else
                     ShowCellBook(value, value.GetDomRowId(), i, refresh, (value.GetDomRowId()<13)?0:1, values[i], 0, 1);
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBookGraphTable::FindMinMaxInMainTable() const
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);
   int minPendingVolume=0, maxPendingVolume=0, minVolume=0, maxVolume=0, minBuyerSellerVolume=0, maxBuyerSellerVolume=0;

   long max_ask = MarketBook.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   long max_bid = MarketBook.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   long max_volume=max_ask>max_bid ? max_ask : max_bid;
   long min_volume = (ArraySize(MarketBook.MarketBook)!=0)?MarketBook.MarketBook[0].volume:0;

   for(int i=1; i<ArraySize(MarketBook.MarketBook); i++)
     {
      if(min_volume > MarketBook.MarketBook[i].volume)
        {
         min_volume = MarketBook.MarketBook[i].volume;
        }
     }

   if(ArraySize(values) != 0 && values[0]!=NULL)
     {
      minMaxStruct.pendingVolume.minB=0;
      minMaxStruct.pendingVolume.minH=0;
      minMaxStruct.pendingVolume.minK=0;
      minMaxStruct.pendingVolume.minM=0;
      minMaxStruct.pendingVolume.maxB=0;
      minMaxStruct.pendingVolume.maxK=0;
      minMaxStruct.pendingVolume.maxM=0;
      minMaxStruct.pendingVolume.maxH=0;

      minMaxStruct.buyerSellerVolume.minB=0;
      minMaxStruct.buyerSellerVolume.minH=0;
      minMaxStruct.buyerSellerVolume.minK=0;
      minMaxStruct.buyerSellerVolume.minM=0;
      minMaxStruct.buyerSellerVolume.maxB=0;
      minMaxStruct.buyerSellerVolume.maxK=0;
      minMaxStruct.buyerSellerVolume.maxM=0;
      minMaxStruct.buyerSellerVolume.maxH=0;

      minMaxStruct.totalVolume.minB=0;
      minMaxStruct.totalVolume.minH=0;
      minMaxStruct.totalVolume.minK=0;
      minMaxStruct.totalVolume.minM=0;
      minMaxStruct.totalVolume.maxB=0;
      minMaxStruct.totalVolume.maxK=0;
      minMaxStruct.totalVolume.maxM=0;
      minMaxStruct.totalVolume.maxH=0;

      for(int i=0, j=1; i<ArraySize(keys); i++, j++)
        {
         if(values[i]!=NULL)
           {
            int legnth = StringLen(values[i].GetBidVolume());
            string result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = values[i].GetBidVolume();
               else
                  if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxK)
                     minMaxStruct.pendingVolume.maxK = values[i].GetBidVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = values[i].GetBidVolume();
                  else
                     if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxM)
                        minMaxStruct.pendingVolume.maxM = values[i].GetBidVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = values[i].GetBidVolume();
                     else
                        if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxB)
                           minMaxStruct.pendingVolume.maxB = values[i].GetBidVolume();
                    }
                  else
                    {
                     if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minH)
                        minMaxStruct.pendingVolume.minH = values[i].GetBidVolume();
                     else
                        if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxH)
                           minMaxStruct.pendingVolume.maxH = values[i].GetBidVolume();
                    }

            legnth = StringLen(values[i].GetAskVolume());
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = values[i].GetAskVolume();
               else
                  if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxK)
                     minMaxStruct.pendingVolume.maxK = values[i].GetAskVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = values[i].GetAskVolume();
                  else
                     if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxM)
                        minMaxStruct.pendingVolume.maxM = values[i].GetAskVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = values[i].GetAskVolume();
                     else
                        if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxB)
                           minMaxStruct.pendingVolume.maxB = values[i].GetAskVolume();
                    }
                  else
                    {
                     if(values[i].GetAskVolume() < minMaxStruct.pendingVolume.minH)
                        minMaxStruct.pendingVolume.minH = values[i].GetAskVolume();
                     else
                        if(values[i].GetAskVolume() > minMaxStruct.pendingVolume.maxH)
                           minMaxStruct.pendingVolume.maxH = values[i].GetAskVolume();
                    }

            legnth = StringLen(values[i].GetBuyerVolume());
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minK)
                  minMaxStruct.buyerSellerVolume.minK = values[i].GetBuyerVolume();
               else
                  if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxK)
                     minMaxStruct.buyerSellerVolume.maxK = values[i].GetBuyerVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minM)
                     minMaxStruct.buyerSellerVolume.minM = values[i].GetBuyerVolume();
                  else
                     if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxM)
                        minMaxStruct.buyerSellerVolume.maxM = values[i].GetBuyerVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minB)
                        minMaxStruct.buyerSellerVolume.minB = values[i].GetBuyerVolume();
                     else
                        if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxB)
                           minMaxStruct.buyerSellerVolume.maxB = values[i].GetBuyerVolume();
                    }
                  else
                    {
                     if(values[i].GetBuyerVolume() < minMaxStruct.buyerSellerVolume.minH)
                        minMaxStruct.buyerSellerVolume.minH = values[i].GetBuyerVolume();
                     else
                        if(values[i].GetBuyerVolume() > minMaxStruct.buyerSellerVolume.maxH)
                           minMaxStruct.buyerSellerVolume.maxH = values[i].GetBuyerVolume();
                    }

            legnth = StringLen(values[i].GetSellerVolume());
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minK)
                  minMaxStruct.buyerSellerVolume.minK = values[i].GetSellerVolume();
               else
                  if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxK)
                     minMaxStruct.buyerSellerVolume.maxK = values[i].GetSellerVolume();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minM)
                     minMaxStruct.buyerSellerVolume.minM = values[i].GetSellerVolume();
                  else
                     if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxM)
                        minMaxStruct.buyerSellerVolume.maxM = values[i].GetSellerVolume();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minB)
                        minMaxStruct.buyerSellerVolume.minB = values[i].GetSellerVolume();
                     else
                        if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxB)
                           minMaxStruct.buyerSellerVolume.maxB = values[i].GetSellerVolume();
                    }
                  else
                    {
                     if(values[i].GetSellerVolume() < minMaxStruct.buyerSellerVolume.minH)
                        minMaxStruct.buyerSellerVolume.minH = values[i].GetSellerVolume();
                     else
                        if(values[i].GetSellerVolume() > minMaxStruct.buyerSellerVolume.maxH)
                           minMaxStruct.buyerSellerVolume.maxH = values[i].GetSellerVolume();
                    }


            legnth = StringLen(max_volume);
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(max_volume > minMaxStruct.pendingVolume.maxK)
                  minMaxStruct.pendingVolume.maxK = max_volume;
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(max_volume > minMaxStruct.pendingVolume.maxM)
                     minMaxStruct.pendingVolume.maxM = max_volume;
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(max_volume > minMaxStruct.pendingVolume.maxB)
                        minMaxStruct.pendingVolume.maxB = max_volume;
                    }
                  else
                    {
                     if(max_volume > minMaxStruct.pendingVolume.maxH)
                        minMaxStruct.pendingVolume.maxH = max_volume;
                    }

            legnth = StringLen(min_volume);
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(min_volume < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = min_volume;
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(min_volume < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = min_volume;
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(min_volume < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = min_volume;
                    }
                  else
                    {
                     if(min_volume < minMaxStruct.pendingVolume.minH)
                        minMaxStruct.pendingVolume.minH = min_volume;
                    }

            if(j<ArraySize(keys) && values[j] != NULL)
              {
               legnth = StringLen(values[j].GetVolume());
               result = TempFunction(legnth);

               if(StringCompare(result, "K")==0)
                 {
                  if(values[j].GetVolume() < minMaxStruct.totalVolume.minK)
                     minMaxStruct.totalVolume.minK = values[j].GetVolume();
                  else
                     if(values[j].GetVolume() > minMaxStruct.totalVolume.maxK)
                        minMaxStruct.totalVolume.maxK = values[j].GetVolume();
                 }
               else
                  if(StringCompare(result, "M")==0)
                    {
                     if(values[j].GetVolume() < minMaxStruct.totalVolume.minM)
                        minMaxStruct.totalVolume.minM = values[j].GetVolume();
                     else
                        if(values[j].GetVolume() > minMaxStruct.totalVolume.maxM)
                           minMaxStruct.totalVolume.maxM = values[j].GetVolume();
                    }
                  else
                     if(StringCompare(result, "B")==0)
                       {
                        if(values[j].GetVolume() < minMaxStruct.totalVolume.minB)
                           minMaxStruct.totalVolume.minB = values[j].GetVolume();
                        else
                           if(values[j].GetVolume() > minMaxStruct.totalVolume.maxB)
                              minMaxStruct.totalVolume.maxB = values[j].GetVolume();
                       }
                     else
                       {
                        if(values[j].GetVolume() < minMaxStruct.totalVolume.minH)
                           minMaxStruct.totalVolume.minH = values[j].GetVolume();
                        else
                           if(values[j].GetVolume() > minMaxStruct.totalVolume.maxH)
                              minMaxStruct.totalVolume.maxH = values[j].GetVolume();
                       }
              }

           }
        }
     }

  }
//+------------------------------------------------------------------+
string CBookGraphTable::TempFunction(int volumeLegnth) const
  {
   string result;

   if(volumeLegnth<=6 && volumeLegnth>3)
     {
      result = "K";
     }
   else
      if(volumeLegnth<=9 && volumeLegnth>6)
        {
         result = "M";
        }
      else
         if(volumeLegnth>9 && volumeLegnth<=12)
           {
            result = "B";
           }
         else
            if(volumeLegnth <=3)
              {
               result = "H";
              }

   return result;
  }
//+------------------------------------------------------------------+
