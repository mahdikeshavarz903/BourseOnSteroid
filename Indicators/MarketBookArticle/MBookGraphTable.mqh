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
#include "ResultOrder.mqh"
#include "RequestOrder.mqh"


bool      enterOnShowFunction = false;   // This flag is used to control access to part of the OnShow function
int       domMapCoordinates[][10][2];     // The variable that holds all coordinates of cells
bool      updateTableFlag=false;         // This flag is used to control enterOnShowFunction flag
const int PRIMARY_DEPTH_LENGTH=36;
int       m_items_total_size=2;
double    previousStartPrice=0, previousEndPrice=0;
int       startIndex=0, endIndex=0;
int       highAllowedPrice, lowAllowedPrice;
int       closingPrice=0;
int       yesterdayPrice=0;    // PY(price yesterday), The value of this variable comes from Nodejs
int       tomorrowHigh=0;
int       tomorrowLow=0;
int       ninetyAverageVolume=0;
   
static CElChart          book_line;
static CElChart          book_line_before_asks;
static CElChart          book_line_after_bids;

double totalLossProfit=0;

CRequestOrder orders[];

struct Portfolio
  {
   double            totalPrices;
   double            price;
   int               numberOfshares;
   string            time;
  };
Portfolio  m_portfolio;

const int buyPriceIncludingFeesFactor = 1.003712;
const int minimumPriceToBuySymbol = 5000000;
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
   CElChart          m_book_line_before_asks;         // The separation line of the Market Depth
   CElChart          m_book_line_after_bids;         // The separation line of the Market Depth
   long              m_prev_ask_total;    // The previous Ask depth
   long              m_prev_bid_total;    // The previous Bid depth
   long              m_limit_y;
   bool              m_pos_by_central;    // Positioning in the center
   double            m_prev_last;
   bool              IsLastTick(MqlTick& tick);
   static int        m_tickSize;          // Rial or Toman , The value of this variable comes from Nodejs
public:
                     CBookGraphTable(void);
   virtual void      OnShow();
   virtual void      OnRefresh(CEventRefresh* refresh);
   int               GetTickSize() {return CBookGraphTable::m_tickSize;};
   void              LimitHeight(int y_pips);
   int               LimitHeight(void);
   long              YCenterDelta(void);
   void              AcceptNewConnections();
   void              HandleSocketIncomingData(int idxClient);
   static void       FindMinMaxInMainTable();
   static string     TempFunction(int volumeLegnth);
   static void       ShowCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type, string lossProfit, bool isPriceInDepth);
   static void       HideCellBook(CMainTable &value, int cellNumber, CEventRefresh *refresh, double price);
   static void       ShiftCells(int start, int end, bool showWholeTable);
   static void       ResetMinMaxStruct();
   void              CenterOfCustomDepth(int i, double temp, int diff);
   static bool       CheckClickedPoint(int x, int y, int shareCount);
   static double     CalculateProfit(double currentPrice, double previousPrice, int shareCount);
   static bool       NewOrder(double price, double bidPrice, double askPrice, int columnNumber, int shareCount);
   static void       SetBookLines(double askPrice, double bidPrice);
  };

int CBookGraphTable::m_tickSize=1;
//+------------------------------------------------------------------+
//| Creates an instance of the order book                            |
//+------------------------------------------------------------------+
CBookGraphTable::CBookGraphTable(void) : CElChart(OBJ_LABEL),
   m_book_line(OBJ_RECTANGLE_LABEL), m_book_line_before_asks(OBJ_RECTANGLE_LABEL), m_book_line_after_bids(OBJ_RECTANGLE_LABEL),
   m_limit_y(0)
  {
   Text(" ");
   m_prev_ask_total = -1;
   m_prev_bid_total = -1;
   m_pos_by_central = true;

   m_portfolio.numberOfshares=0;
   m_portfolio.totalPrices=0;

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
      long lossProfitXCoordinate = 100 + 20 + XCoord()-880;
      long volumeXCoordinate = 100 + 20 + XCoord()-760;
      long priceXCoordinate = 100 + 20 + XCoord()-640;
      long pricePercentageXCoordinate = 100 + 20 + XCoord()-520;
      long snapshotBidVolXCoordinate = 100 + 20 + XCoord()-400;
      long bidXCoordinate = 100 + 20 + XCoord()-280;
      long sellerVolXCoordinate = 100 + 20 + XCoord()-160;
      long buyerVolXCoordinate = 100 + 20 + XCoord()-40;
      long askVolXCoordinate = 100 + 20 + XCoord()+80;
      long snapshotAskVolXCoordinate = 100 + 20 + XCoord()+200;

      int xCoordinates[] = {lossProfitXCoordinate, volumeXCoordinate, priceXCoordinate, pricePercentageXCoordinate, snapshotBidVolXCoordinate, bidXCoordinate,
                            sellerVolXCoordinate, buyerVolXCoordinate, askVolXCoordinate, snapshotAskVolXCoordinate
                           };

      /* 0: price, 1: volume , 2: pricePercentage */
      int type[] = {3, 1, 0, 2, 1, 1, 1, 1, 1, 1};
      string column[] = {"lossProfit", "volume", "price", "pricePercentage", "snapshotBid", "bidVol", "sellerVol", "buyerVol", "askVol", "snapshotAsk"};

      /* Find min and max for hundred and below hundred, thousands, Millions, Billions */
      FindMinMaxInMainTable();

      CMainTable *value;
      int index=0;

      for(int i=0; i< PRIMARY_DEPTH_LENGTH; i++)
        {
         CBookCell *cell;
         YCoordinate = i * 20 + 20+YCoord();

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
      m_book_line.XCoord(XCoord()-580);
      m_book_line.Width(920);
      m_book_line.Height(1);
      m_book_line.BackgroundColor(clrBlack);
      m_book_line.BorderColor(clrBlack);
      m_book_line.BorderType(BORDER_RAISED);
      m_book_line.Show();
      m_elements.Add(GetPointer(m_book_line));
      book_line = GetPointer(m_book_line);

      m_book_line_before_asks.YCoord(y);
      m_book_line_before_asks.XCoord(XCoord()-580);
      m_book_line_before_asks.Width(920);
      m_book_line_before_asks.Height(1);
      m_book_line_before_asks.BackgroundColor(clrRed);
      m_book_line_before_asks.BorderColor(clrBlack);
      m_book_line_before_asks.BorderType(BORDER_RAISED);
      m_book_line_after_bids.Hide();
      m_elements.Add(GetPointer(m_book_line_before_asks));
      book_line_before_asks = GetPointer(m_book_line_before_asks);

      m_book_line_after_bids.YCoord(y);
      m_book_line_after_bids.XCoord(XCoord()-580);
      m_book_line_after_bids.Width(920);
      m_book_line_after_bids.Height(1);
      m_book_line_after_bids.BackgroundColor(clrBlue);
      m_book_line_after_bids.BorderColor(clrBlack);
      m_book_line_after_bids.BorderType(BORDER_RAISED);
      m_book_line_after_bids.Hide();
      m_elements.Add(GetPointer(m_book_line_after_bids));
      book_line_after_bids = GetPointer(m_book_line_after_bids);
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
               highAllowedPrice = StringToInteger(js.m_e[1].m_sv);        // High allowed price of each day
               int belowHighAllowedPrice = StringToInteger(js.m_e[3].m_sv);   // High allowed price mines 1 or 10
               int aboveLowAllowedPrice = StringToInteger(js.m_e[5].m_sv);    // Low allowed price plus 1 or 10
               lowAllowedPrice = StringToInteger(js.m_e[7].m_sv);         // Low allowed price of each day
               m_tickSize = StringToInteger(js.m_e[9].m_sv);                  // Rial or Toman
               yesterdayPrice = StringToInteger(js.m_e[10].m_sv);           // PY(price yesterday)
               ninetyAverageVolume = StringToInteger(js.m_e[11].m_sv);

               int diff;
               if(m_tickSize==1)
                 {
                  /* diff: Number of prices between high and low allowed price */
                  diff = highAllowedPrice-lowAllowedPrice;
                 }
               else
                 {
                  diff = (highAllowedPrice-lowAllowedPrice)/m_tickSize;
                 }

               m_items_total_size = diff;

               /* Clear HashTables */
               cMainTable.Clear();
               mapDomRowIdToPrice.Clear();

               int temp = highAllowedPrice;

               /* Fill CMainTable */
               for(int i=0; i<=diff; i++)
                 {
                  CenterOfCustomDepth(i, temp, diff);

                  CBookCell *cell=new CBookCell();

                  double pricePercentage = ((float)(temp-lowAllowedPrice)/(highAllowedPrice-lowAllowedPrice))*100;
                  CMainTable *cmt = new CMainTable(pricePercentage);
                  cmt.SetPrice(temp);
                  cmt.SetDomRowId(i);
                  cmt.SetPricePercentage(pricePercentage);

                  cMainTable.Add(temp, GetPointer(cmt));

                  temp = temp - m_tickSize;
                 }

               CMainTable *value;
               for(int i=0; i<ArraySize(MarketBook.MarketBook); i++)
                 {
                  if(cMainTable.TryGetValue(MarketBook.MarketBook[i].price, value) &&  value !=NULL)
                    {
                     if(MarketBook.MarketBook[i].type == BOOK_TYPE_SELL)
                        value.SetAskVolume(MarketBook.MarketBook[i].volume);
                     else
                        value.SetBidVolume(MarketBook.MarketBook[i].volume);

                     cMainTable.TrySetValue(MarketBook.MarketBook[i].price, value);
                    }
                 }

               cMainTable.TryGetValue((double)highAllowedPrice, value);
               value.SetAskVolume(-1);
               cMainTable.TrySetValue((double)highAllowedPrice, value);

               cMainTable.TryGetValue((double)lowAllowedPrice, value);
               value.SetBidVolume(-1);
               cMainTable.TrySetValue((double)lowAllowedPrice, value);

               if(startIndex==0 && endIndex==0)
                 {
                  startIndex=0;
                  endIndex=36;
                 }

               MqlTick tick_array[];   // Tick receiving array
               MqlTick lasttick;       // To receive last tick data
               SymbolInfoTick(_Symbol,lasttick);

               int ticks=ArraySize(tick_array);

               MqlDateTime today;
               datetime current_time=TimeCurrent();
               TimeToStruct(current_time,today);
               PrintFormat("current_time=%s",TimeToString(current_time));
               today.hour=0;
               today.min=0;
               today.sec=0;
               datetime startday=StructToTime(today);
               datetime endday=startday+24*60*60;
               if((ticks=CopyTicksRange(_Symbol,tick_array,COPY_TICKS_TRADE,startday*1000,endday*1000))==-1)
                 {
                  PrintFormat("CopyTicksRange(%s,tick_array,COPY_TICKS_ALL,%s,%s) failed, error %d",
                              _Symbol,TimeToString(startday),TimeToString(endday),GetLastError());
                 }

               for(int i=0; i<ticks; i++)
                 {
                  if(cMainTable.TryGetValue(tick_array[i].last, value))
                    {
                     value.SetVolume(value.GetVolume() + tick_array[i].volume);
                    }
                  cMainTable.TrySetValue(tick_array[i].last, value);
                 }

               ShiftCells(startIndex, endIndex, true);
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
                     if(value.GetDomRowId() != -1)
                       {
                        CEventRefresh *refresh = new CEventRefresh();

                        double askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
                        int type = (price>=askPrice)?0:1;
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
                        //ShowCellBook(value, value.GetDomRowId(), cellNumber, refresh, type, orderVolume, price, 1);

                        delete refresh;
                       }
                    }
                 }
               else
                  if(js.m_e[0].m_sv=="4")
                    {
                     closingPrice = StringToInteger(js.m_e[1].m_sv);
                     tomorrowHigh = StringToInteger(js.m_e[2].m_sv);
                     tomorrowLow = StringToInteger(js.m_e[3].m_sv);
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
void CBookGraphTable::ShowCellBook(CMainTable &value, int domRowIndex, int cellNumber, CEventRefresh *refresh, int buyOrSell, int volume, double price, int type, string lossProfit, bool isPriceInDepth)
  {
   CMainTable *tempValue=GetPointer(value);

   FindMinMaxInMainTable();

   CBookCell *bookCell = new CBookCell();
   value.GetBookCell(bookCell, cellNumber, value.GetPricePercentage());

   if(!isPriceInDepth && price <= MarketBook.MarketBook[0].price && price >= MarketBook.MarketBook[ArraySize(MarketBook.MarketBook)-1].price)
      volume=0;

   if(type==3)
      bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], lossProfit, buyOrSell);
   else
      if(type==1)
         bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], volume, buyOrSell);
      else
         if(type==2)
            bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], value.GetPricePercentage(), buyOrSell);
         else
            bookCell.SetVariables(type, domMapCoordinates[domRowIndex][cellNumber][0], domMapCoordinates[domRowIndex][cellNumber][1], price, buyOrSell);

   value.SetBookCell(bookCell, cellNumber);
   cMainTable.TrySetValue(price, tempValue);

//uint s=GetMicrosecondCount();
//Print("Time: ", GetMicrosecondCount()-s);

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
void CBookGraphTable::ShiftCells(int start, int end, bool showWholeTable=false)
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   double askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
   double bidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);

   SetBookLines(askPrice, bidPrice);

   int keySize = ArraySize(keys)-1;
   if(keySize!=0 && end <= keySize && start <= keySize && ArraySize(MarketBook.MarketBook)-1>0)
     {
      CMainTable *value;
      CEventRefresh *refresh = new CEventRefresh();

      for(double price=previousEndPrice; price<=previousStartPrice && previousStartPrice!=0 && previousEndPrice!=0; price+=m_tickSize)
        {
         if((cMainTable.TryGetValue(price, value) && price <= MarketBook.MarketBook[0].price && price >= MarketBook.MarketBook[ArraySize(MarketBook.MarketBook)-1].price) || showWholeTable)
           {
            for(int i=0; i< TOTAL_COLUMN; i++)
               HideCellBook(value, i, refresh, price);
           }
        }
      previousStartPrice = keys[start];
      previousEndPrice = keys[end];

      /* Find min and max for hundred and below hundred, thousands, Millions, Billions */
      FindMinMaxInMainTable();

      if(end==ArraySize(keys)-1)
        {
         start += 1;
         end+=1;
        }

      for(int i=start, k=0; i<end; i++, k++)
        {
         if(cMainTable.TryGetValue(keys[i], value))
           {
            int negOrPos;
            double lossProfit;

            if(m_portfolio.numberOfshares!=0)
              {
               lossProfit = value.GetLossProfit();
               negOrPos = ((lossProfit)>0)?1:(lossProfit<0)?2:3;
              }
            else
              {
               lossProfit = 0;
               negOrPos = 0;
              }

            bool findPriceInDom=false;
            for(int j=0; j<ArraySize(MarketBook.MarketBook) && keys[i] <= MarketBook.MarketBook[0].price && keys[i] >= MarketBook.MarketBook[ArraySize(MarketBook.MarketBook)-1].price; j++)
              {
               if(keys[i]==MarketBook.MarketBook[j].price)
                 {
                  findPriceInDom=true;
                 }
              }

            ShowCellBook(value, k, LOSS_PROFIT_COLUMN, refresh, negOrPos, 0, keys[i], 3, value.GetLossProfit(), findPriceInDom);

            if((keys[i] <= MarketBook.MarketBook[0].price && keys[i] >= MarketBook.MarketBook[ArraySize(MarketBook.MarketBook)-1].price) || showWholeTable)
              {
               int type = (keys[i]>=askPrice)?0:(keys[i]<=bidPrice)?1:-5;
               int volumeValues[] = {0, value.GetVolume(), 0, 0, (type==0)?-1:(type==1)?value.GetSnapshotBid():0,(type==0)?-1:(type==1)?value.GetBidVolume():0, (type==0)?-1:(type==1)?value.GetSellerVolume():0, (type==1)?-1:(type==0)?value.GetBuyerVolume():0, (type==1)?-1:(type==0)?value.GetAskVolume():0, (type==1)?-1:(type==0)?value.GetSnapshotAsk():0};

               /* Show a row of cells  */
               for(int j=1; j<TOTAL_COLUMN; j++)
                 {
                  value.SetCoordinate(domMapCoordinates[k][j][0], domMapCoordinates[k][j][1]);

                  if(j==PRICE_COLUMN)
                     ShowCellBook(value, k, PRICE_COLUMN, refresh, type, 0, keys[i], 0, "0.00", findPriceInDom);
                  else
                     if(j==PRICE_PERCENTAGE_COLUMN)
                        ShowCellBook(value, k, PRICE_PERCENTAGE_COLUMN, refresh, type, 0, keys[i], 2, "0.00", findPriceInDom);
                     else
                        ShowCellBook(value, k, j, refresh, type, volumeValues[j], keys[i], 1, "0.00", findPriceInDom);
                 }
              }
           }

        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBookGraphTable::SetBookLines(double askPrice, double bidPrice)
  {
   CMainTable *value;

   double lastAskPrice = MarketBook.InfoGetDouble(MBOOK_LAST_ASK_PRICE);
   double lastBidPrice = MarketBook.InfoGetDouble(MBOOK_LAST_BID_PRICE);

   if(cMainTable.TryGetValue(askPrice, value))
     {
      if((askPrice<=previousStartPrice && askPrice >= previousEndPrice) || bidPrice == askPrice)
        {
         book_line.YCoord(value.GetYCoordinate()+20);

         if(askPrice==lowAllowedPrice)
            book_line.Hide();
         else
            if(!book_line.IsShowed())
               book_line.Show();
        }
      else
         book_line.Hide();
     }
   else
      if(cMainTable.TryGetValue(bidPrice, value))
        {
         if(bidPrice<=previousStartPrice && bidPrice >= previousEndPrice)
           {
            book_line.YCoord(value.GetYCoordinate()-20);

            if(bidPrice==highAllowedPrice)
               book_line.Hide();
            else
               if(!book_line.IsShowed())
                  book_line.Show();
           }
         else
            book_line.Hide();
        }

   if(cMainTable.TryGetValue(lastAskPrice, value))
     {
      if((lastAskPrice<=previousStartPrice && lastAskPrice >= previousEndPrice) || bidPrice == askPrice)
        {
         book_line_before_asks.YCoord(value.GetYCoordinate());

         if(lastAskPrice==lowAllowedPrice || lastAskPrice==highAllowedPrice)
            book_line_before_asks.Hide();
         else
            if(!book_line_before_asks.IsShowed())
               book_line_before_asks.Show();
        }
      else
         book_line_before_asks.Hide();
     }

   if(cMainTable.TryGetValue(lastBidPrice, value))
     {
      if((lastBidPrice<=previousStartPrice && lastBidPrice >= previousEndPrice) || bidPrice == askPrice)
        {
         book_line_after_bids.YCoord(value.GetYCoordinate()+20);

         if(lastBidPrice==highAllowedPrice || lastBidPrice==lowAllowedPrice)
            book_line_after_bids.Hide();
         else
            if(!book_line_after_bids.IsShowed())
               book_line_after_bids.Show();
        }
      else
         book_line_after_bids.Hide();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBookGraphTable::CheckClickedPoint(int x, int y, int shareCount)
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   CMainTable *value;
   CBookCell *bookCell;

   for(int i=startIndex; i<=endIndex && ArraySize(keys)-1>0; i++)
     {
      for(int j=0; j<TOTAL_COLUMN; j++)
        {
         if(j==BID_COLUMN || j==ASK_COLUMN)
           {
            double askPrice = MarketBook.InfoGetDouble(MBOOK_BEST_ASK_PRICE);
            double bidPrice = MarketBook.InfoGetDouble(MBOOK_BEST_BID_PRICE);

            bookCell = new CBookCell();
            values[i].GetBookCell(bookCell, j, values[i].GetPricePercentage());

            int bookCellX = bookCell.XCoord();
            int bookCellY = bookCell.YCoord();
            int bookCellHeight = bookCell.Height();
            int bookCellWidth = MathAbs(bookCell.Width());

            if(bookCellX>=x && (bookCellX-bookCellWidth)<=x &&
               bookCellY<=y && (bookCellY+bookCellHeight)>=y)
              {
               return NewOrder(keys[i], bidPrice, askPrice, j, shareCount);
              }
           }
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBookGraphTable::NewOrder(double price, double bidPrice, double askPrice, int columnNumber, int shareCount)
  {
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   string buyOrSell;
   OrderType orderType;

   int max=200;
   int min=100;
//int shareCount = MathCeil((minimumPriceToBuySymbol * buyPriceIncludingFeesFactor) / price);

   if(price<=bidPrice)
     {
      if(columnNumber==BID_COLUMN)
        {
         buyOrSell="buy";
         orderType = (price==bidPrice)?MARKET:LIMIT;
        }
      else
         if(columnNumber==ASK_COLUMN)
           {
            buyOrSell="sell";
            orderType = (price==bidPrice)?MARKET:STOP_LIMIT;

            if(m_portfolio.numberOfshares!=0)
               shareCount = m_portfolio.numberOfshares;
           }
     }
   else
      if(price>=askPrice)
        {
         if(columnNumber==BID_COLUMN)
           {
            buyOrSell="buy";
            orderType = (price==askPrice)?MARKET:STOP_LIMIT;
           }
         else
            if(columnNumber==ASK_COLUMN)
              {
               buyOrSell="sell";
               orderType = (price==askPrice)?MARKET:LIMIT;

               if(m_portfolio.numberOfshares!=0)
                  shareCount = m_portfolio.numberOfshares;
              }
        }

   CRequestOrder *cro = new CRequestOrder();
   cro.SetPrice(price);
   cro.SetCautionAgreementSelected(false);
   cro.SetIsSymbolCautionAgreement(false);
   cro.SetSepahAgreementSelected(false);
   cro.SetIsSymbolSepahAgreement(false);
   cro.SetIsin(SymbolInfoString(Symbol(), SYMBOL_ISIN));
   cro.SetMaxShow(0);
   cro.SetMinimumQuantity(0);
   cro.SetOrderCount(shareCount);
   cro.SetOrderId(0);
   cro.SetOrderSide(StringCompare(buyOrSell, "sell")==0 ? "86" : "65");
   cro.SetOrderValidity(74);
   cro.SetOrderValidityDate(NULL);
   cro.SetShortSellIncentivePercent(0);
   cro.SetShortSellIsEnabled(false);
   cro.SetOrderType(orderType);

   ArrayResize(orders, ArraySize(orders)+1);
   orders[ArraySize(orders)-1] = cro;

   double tempPrice;
   int    tempShares;
   bool   condition=false;

   if(StringCompare(buyOrSell, "buy")==0)
     {
      if(m_portfolio.numberOfshares>0)
        {
         tempShares = shareCount + m_portfolio.numberOfshares;
         m_portfolio.totalPrices += price*shareCount;
         tempPrice = m_portfolio.totalPrices / tempShares;
        }
      else
        {
         m_portfolio.totalPrices=0;
         m_portfolio.totalPrices += price*shareCount;
         tempPrice = price;
         tempShares = shareCount;
        }

      condition=true;
     }
   else
     {
      if(m_portfolio.numberOfshares>0)
        {
         int shares=m_portfolio.numberOfshares-shareCount;

         if(shares>=0)
           {
            m_portfolio.numberOfshares=shares;
            tempShares = shares;
            m_portfolio.totalPrices = m_portfolio.price*shareCount;
            tempPrice = m_portfolio.price;

            condition=true;
           }
        }
     }

   if(orderType==MARKET && condition)
     {
      for(int k=0; k<ArraySize(keys); k++)
        {
         double lossProfit = CalculateProfit(keys[k], tempPrice, tempShares);
         values[k].SetLossProfit(DoubleToString(lossProfit, Digits()));
        }

      m_portfolio.numberOfshares = tempShares;
      m_portfolio.price = tempPrice;
      m_portfolio.time = TimeToString(TimeCurrent());

      if(StringCompare(buyOrSell, "sell")==0)
        {
         totalLossProfit+= CalculateProfit(price, tempPrice, shareCount);
        }

      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CBookGraphTable::CalculateProfit(double currentPrice, double previousPrice, int shareCount)
  {
   int primaryBuyPrice = previousPrice*shareCount*1.0037;
   int sellPrice = currentPrice*shareCount*0.9912;
   double lossProfit = sellPrice-primaryBuyPrice;

   return lossProfit;
  }
//+-------------------------------------------------------------------------------+
//| Find min and max for hundred and below hundred, thousands, Millions, Billions |
//+-------------------------------------------------------------------------------+
void CBookGraphTable::FindMinMaxInMainTable()
  {
   /* Convert cMainTable from HashTable to ArrayList */
   double keys[];
   CMainTable *values[];
   cMainTable.CopyTo(keys, values, 0);

   long max_ask = MarketBook.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);   // Find maximum volume from asks
   long max_bid = MarketBook.InfoGetInteger(MBOOK_MAX_BID_VOLUME);   // Find maximum volume from bids
   long max_volume = max_ask>max_bid ? max_ask : max_bid;            // Find maximum volume between bids and asks
   long min_volume = (ArraySize(MarketBook.MarketBook)!=0)?MarketBook.MarketBook[0].volume:0;

   /* Find min_volume in DOM */
   for(int i=1; i<ArraySize(MarketBook.MarketBook); i++)
     {
      if(min_volume > MarketBook.MarketBook[i].volume)
        {
         min_volume = MarketBook.MarketBook[i].volume;
        }
     }

   if(ArraySize(values) != 0 && values[0]!=NULL)
     {
      /* ‌Before finding new min and max we should reset previous min and maxes */
      ResetMinMaxStruct();

      /*
         This loop try to find min and max volumes in the CMainTable between bids and asks, buyers and sellers, total volumes
         To achieve this goal, we select the volume of each column and compare it with the corresponding minimum or maximum in minMaxStruct
      */
      for(int i=0, j=1; i<ArraySize(keys); i++, j++)
        {
         if(values[i]!=NULL)
           {
            /* Get length of bid volume */
            int legnth = StringLen(values[i].GetBidVolume());
            string result = TempFunction(legnth);

            /* Condition is true when there is a K letter in string volume */
            if(StringCompare(result, "K")==0)
              {
               /* If the bid volume is less than minK, we have to update minK in minMaxStruct, otherwise,
               we have to compare the bid volume with maxK, and if it is more than maxK we have to update maxK. */
               if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minK)
                  minMaxStruct.pendingVolume.minK = values[i].GetBidVolume();
               else
                  if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxK)
                     minMaxStruct.pendingVolume.maxK = values[i].GetBidVolume();
              }
            else
               if(StringCompare(result, "M")==0)   /* Condition is true when there is a M letter in string volume */
                 {
                  /* If the bid volume is less than minM, we have to update minM in minMaxStruct, otherwise,
                     we have to compare the bid volume with maxM, and if it is more than maxM we have to update maxM. */
                  if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minM)
                     minMaxStruct.pendingVolume.minM = values[i].GetBidVolume();
                  else
                     if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxM)
                        minMaxStruct.pendingVolume.maxM = values[i].GetBidVolume();
                 }
               else
                  if(StringCompare(result, "B")==0) /* Condition is true when there is a B letter in string volume */
                    {
                     /* If the bid volume is less than minB, we have to update minB in minMaxStruct, otherwise,
                      we have to compare the bid volume with maxB, and if it is more than maxB we have to update maxB. */
                     if(values[i].GetBidVolume() < minMaxStruct.pendingVolume.minB)
                        minMaxStruct.pendingVolume.minB = values[i].GetBidVolume();
                     else
                        if(values[i].GetBidVolume() > minMaxStruct.pendingVolume.maxB)
                           minMaxStruct.pendingVolume.maxB = values[i].GetBidVolume();
                    }
                  else
                    {
                     /* If the bid volume is less than minH, we have to update minH in minMaxStruct, otherwise,
                      we have to compare the bid volume with maxH, and if it is more than maxH we have to update maxH. */
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

            legnth = StringLen(IntegerToString(values[i].GetSnapshotAsk()));
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetSnapshotAsk() < minMaxStruct.snapshotsVolume.minK)
                  minMaxStruct.snapshotsVolume.minK = (values[i].GetSnapshotAsk()>=0)?values[i].GetSnapshotAsk():0;
               else
                  if(values[i].GetSnapshotAsk() > minMaxStruct.snapshotsVolume.maxK)
                     minMaxStruct.snapshotsVolume.maxK = values[i].GetSnapshotAsk();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetSnapshotAsk() < minMaxStruct.snapshotsVolume.minM)
                     minMaxStruct.snapshotsVolume.minM = (values[i].GetSnapshotAsk()>=0)?values[i].GetSnapshotAsk():0;
                  else
                     if(values[i].GetSnapshotAsk() > minMaxStruct.snapshotsVolume.maxM)
                        minMaxStruct.snapshotsVolume.maxM = values[i].GetSnapshotAsk();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetSnapshotAsk() < minMaxStruct.snapshotsVolume.minB)
                        minMaxStruct.snapshotsVolume.minB = (values[i].GetSnapshotAsk()>=0)?values[i].GetSnapshotAsk():0;
                     else
                        if(values[i].GetSnapshotAsk() > minMaxStruct.buyerSellerVolume.maxB)
                           minMaxStruct.buyerSellerVolume.maxB = values[i].GetBuyerVolume();
                    }
                  else
                    {
                     if(values[i].GetSnapshotAsk() < minMaxStruct.snapshotsVolume.minH)
                        minMaxStruct.snapshotsVolume.minH = (values[i].GetSnapshotAsk()>=0)?values[i].GetSnapshotAsk():0;
                     else
                        if(values[i].GetSnapshotAsk() > minMaxStruct.snapshotsVolume.maxH)
                           minMaxStruct.snapshotsVolume.maxH = values[i].GetSnapshotAsk();
                    }

            legnth = StringLen(IntegerToString(values[i].GetSnapshotBid()));
            result = TempFunction(legnth);

            if(StringCompare(result, "K")==0)
              {
               if(values[i].GetSnapshotBid() < minMaxStruct.snapshotsVolume.minK)
                  minMaxStruct.snapshotsVolume.minK = (values[i].GetSnapshotBid()>=0)?values[i].GetSnapshotBid():0;
               else
                  if(values[i].GetSnapshotBid() > minMaxStruct.snapshotsVolume.maxK)
                     minMaxStruct.snapshotsVolume.maxK = values[i].GetSnapshotBid();
              }
            else
               if(StringCompare(result, "M")==0)
                 {
                  if(values[i].GetSnapshotBid() < minMaxStruct.snapshotsVolume.minM)
                     minMaxStruct.snapshotsVolume.minM = (values[i].GetSnapshotBid()>=0)?values[i].GetSnapshotBid():0;
                  else
                     if(values[i].GetSnapshotBid() > minMaxStruct.snapshotsVolume.maxM)
                        minMaxStruct.snapshotsVolume.maxM = values[i].GetSnapshotBid();
                 }
               else
                  if(StringCompare(result, "B")==0)
                    {
                     if(values[i].GetSnapshotBid() < minMaxStruct.snapshotsVolume.minB)
                        minMaxStruct.snapshotsVolume.minB = (values[i].GetSnapshotBid()>=0)?values[i].GetSnapshotBid():0;
                     else
                        if(values[i].GetSnapshotBid() > minMaxStruct.snapshotsVolume.maxB)
                           minMaxStruct.snapshotsVolume.maxB = values[i].GetSnapshotBid();
                    }
                  else
                    {
                     if(values[i].GetSnapshotBid() < minMaxStruct.snapshotsVolume.minH)
                        minMaxStruct.snapshotsVolume.minH = (values[i].GetSnapshotBid()>=0)?values[i].GetSnapshotBid():0;
                     else
                        if(values[i].GetSnapshotBid() > minMaxStruct.snapshotsVolume.maxH)
                           minMaxStruct.snapshotsVolume.maxH = values[i].GetSnapshotBid();
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
//+-------------------------------------------------------------------------------+
//| Reset all min and max                                                         |
//+-------------------------------------------------------------------------------+
void CBookGraphTable::ResetMinMaxStruct()
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

   minMaxStruct.snapshotsVolume.minB=0;
   minMaxStruct.snapshotsVolume.minH=0;
   minMaxStruct.snapshotsVolume.minK=0;
   minMaxStruct.snapshotsVolume.minM=0;
   minMaxStruct.snapshotsVolume.maxB=0;
   minMaxStruct.snapshotsVolume.maxK=0;
   minMaxStruct.snapshotsVolume.maxM=0;
   minMaxStruct.snapshotsVolume.maxH=0;
  }
//+-------------------------------------------------------------------------------+
//| A function that determines the size of the volume                             |
//+-------------------------------------------------------------------------------+
string CBookGraphTable::TempFunction(int volumeLegnth)
  {
   string result;

   if(volumeLegnth<=6 && volumeLegnth>3)
     {
      result = "K";  // Thousand
     }
   else
      if(volumeLegnth<=9 && volumeLegnth>6)
        {
         result = "M";  // Million
        }
      else
         if(volumeLegnth>9 && volumeLegnth<=12)
           {
            result = "B";  // Billion
           }
         else
            if(volumeLegnth <=3)
              {
               result = "H";  // Hundred and below hundred
              }

   return result;
  }
//+------------------------------------------------------------------+
void CBookGraphTable::CenterOfCustomDepth(int i, double temp, int diff)
  {
   if(ArraySize(MarketBook.MarketBook)>0 && temp == MarketBook.MarketBook[0].price)
     {
      bool flag=true;

      for(int j=13; j>=0 && flag; j++)
        {
         if(i-j>=0)
           {
            startIndex = i-j;

            int listLength = i-j+PRIMARY_DEPTH_LENGTH;
            if(listLength<diff)
              {
               endIndex = listLength;
              }
            else
              {
               startIndex -= (listLength-diff);
               endIndex = diff;
              }

            flag=false;
           }
        }
     }
  }
//+------------------------------------------------------------------+
