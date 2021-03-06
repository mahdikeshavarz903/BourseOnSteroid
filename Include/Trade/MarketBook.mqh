//+------------------------------------------------------------------+
//|                                                   MarketBook.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#define LAST_ASK_INDEX 0
#define LAST_BID_INDEX m_depth_total-1
//+------------------------------------------------------------------+
//| Side of MarketBook.                                              |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_SIDE
{
   MBOOK_ASK,                    // Ask side
   MBOOK_BID                     // Bid (offer) side
};
//+------------------------------------------------------------------+
//| Market Book info integer properties.                             |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_INFO_INTEGER
{
   MBOOK_BEST_ASK_INDEX,         // Best ask index
   MBOOK_BEST_BID_INDEX,         // Best bid index
   MBOOK_LAST_ASK_INDEX,         // Last (worst) ask index
   MBOOK_LAST_BID_INDEX,         // Last (worst) bid index
   MBOOK_DEPTH_ASK,              // Depth of ask side
   MBOOK_DEPTH_BID,              // Depth of bid side
   MBOOK_DEPTH_TOTAL,            // Total depth
   MBOOK_MAX_ASK_VOLUME,         // Max ask volume
   MBOOK_MAX_ASK_VOLUME_INDEX,   // Max ask volume index
   MBOOK_MAX_BID_VOLUME,         // Max bid volume
   MBOOK_MAX_BID_VOLUME_INDEX,   // Max bid volume index
   MBOOK_ASK_VOLUME_TOTAL,       // Total volume on Ask side of MarketBook
   MBOOK_BID_VOLUME_TOTAL,       // Total volume on Bid side of MarketBook
   MBOOK_BUY_ORDERS,             // Total orders on sell
   MBOOK_SELL_ORDERS,            // Total orders on buy
   
};
//+------------------------------------------------------------------+
//| Market Book info double properties.                              |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_INFO_DOUBLE
{
   MBOOK_BEST_ASK_PRICE,         // Best ask price,
   MBOOK_BEST_BID_PRICE,         // Best bid price,
   MBOOK_LAST_ASK_PRICE,         // Last (worst) ask price, 
   MBOOK_LAST_BID_PRICE,         // Last (worst) bid price,
   MBOOK_AVERAGE_SPREAD,         // Average spread for work time
   MBOOK_OPEN_INTEREST,          // Current Open Interest of Market
   MBOOK_BUY_ORDERS_VOLUME,      // Total volume of sell orders
   MBOOK_SELL_ORDERS_VOLUME,     // Total volume of buy orders
}; 

class CMarketBook;

class CBookCalculation
{
private:
   int m_max_ask_index;         // Index of maximum Bid volume
   long m_max_ask_volume;       // Maximum Bid volume
   
   int m_max_bid_index;         // Index of maximum Ask volume
   long m_max_bid_volume;       // Maximum Ask volume 
   
   long m_sum_ask_volume;       // Total ask volume in the Market Depth
   long m_sum_bid_volume;       // Total bid volume in the Market Depth
   
   bool m_calculation;          // Flag indicating that all necessary calculations are made
   CMarketBook* m_book;         // Depth of Market indicator
   
   void Calculation(void)
   {
      // FOR ASK SIDE
      int begin = (int)m_book.InfoGetInteger(MBOOK_LAST_ASK_INDEX);
      int end = (int)m_book.InfoGetInteger(MBOOK_BEST_ASK_INDEX);
      //m_ask_best_index
      for(int i = begin; i <= end && begin !=-1; i++)
      {
         if(m_book.MarketBook[i].volume > m_max_ask_volume)
         {
            m_max_ask_index = i;
            m_max_ask_volume = m_book.MarketBook[i].volume;
         }
         m_sum_ask_volume += m_book.MarketBook[i].volume;
      }
      // FOR BID SIDE
      begin = (int)m_book.InfoGetInteger(MBOOK_BEST_BID_INDEX);
      end = (int)m_book.InfoGetInteger(MBOOK_LAST_BID_INDEX);
      for(int i = begin; i <= end && begin != -1; i++)
      {
         if(m_book.MarketBook[i].volume > m_max_bid_volume)
         {
            m_max_bid_index = i;
            m_max_bid_volume = m_book.MarketBook[i].volume;
         }
         m_sum_bid_volume += m_book.MarketBook[i].volume;
      }
      m_calculation = true;
   }
   
public:
   CBookCalculation(CMarketBook* book)
   {
      Reset();
      m_book = book;
   }
   
   void Reset()
   {
      m_max_ask_volume = 0.0;
      m_max_bid_volume = 0.0;
      m_max_ask_index = -1;
      m_max_bid_index = -1;
      m_sum_ask_volume = 0;
      m_sum_bid_volume = 0;
      m_calculation = false;
   }
   int GetMaxVolAskIndex()
   {
      if(!m_calculation)
         Calculation();
      return m_max_ask_index;
   }
   
   long GetMaxVolAsk()
   {
      if(!m_calculation)
         Calculation();
      return m_max_ask_volume;
   }
   int GetMaxVolBidIndex()
   {
      if(!m_calculation)
         Calculation();
      return m_max_bid_index;
   }
   
   long GetMaxVolBid()
   {
      if(!m_calculation)
         Calculation();
      return m_max_bid_volume;
   }
   long GetAskVolTotal()
   {
      if(!m_calculation)
         Calculation();
      return m_sum_ask_volume;
   }
   long GetBidVolTotal()
   {
      if(!m_calculation)
         Calculation();
      return m_sum_bid_volume;
   }
};

class CMarketBook
{
private:
   string      m_symbol;                 // Market Book symbol
   int         m_depth_total;            // Market depth total
   bool        m_available;              // True if market book available, otherwise false
   double      m_spread_sum;             // Accumulation spread;
   int         m_count_refresh;          // Count call CMarketBook::Refresh()
                  /* Indexes fields*/
   int         m_best_ask_index;         // Best ask index
   int         m_best_bid_index;         // Best bid index
   void        SetBestAskAndBidIndex(void);
   bool        FindBestBid(void);
   CBookCalculation Calculation;
   ulong       m_tiks_count;
   //void        CreateSyntetickTick(void);
   long        m_sell_deals;
   long        m_buy_deals;
   int         m_n_ticks;      //Количество новых торговых тиков с предыдущего обновления стакана цен
   MqlTick     m_ticks[];
   bool        CompareTiks(MqlTick& tick1, MqlTick& tick2);
public:
   void        CompareTiks(void);
   
   MqlBookInfo MarketBook[];             // Array of market book
   MqlTick     LastTicks[];              // Array of last tiks beetwen prev. and current slide
               CMarketBook();
               CMarketBook(string symbol);
   long        InfoGetInteger(ENUM_MBOOK_INFO_INTEGER property);
   double      InfoGetDouble(ENUM_MBOOK_INFO_DOUBLE property);
   void        Refresh(void);
   void        Refresh(int num);
   bool        IsAvailable(void);
   bool        SetMarketBookSymbol(string symbol);
   string      GetMarketBookSymbol(void);
   double      GetDeviationByVol(long vol, ENUM_MBOOK_SIDE side);
   long        GetVolByDeviation(double deviation, ENUM_MBOOK_SIDE side);
   void        OnTick(void);
   ulong       TiksCount();
};

//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
CMarketBook::CMarketBook(void) : Calculation(GetPointer(this))
{
   SetMarketBookSymbol(Symbol());
}
//+------------------------------------------------------------------+
//| Create Market Book and set symbol for it.                        |
//+------------------------------------------------------------------+
CMarketBook::CMarketBook(string symbol) : Calculation(GetPointer(this))
{
   SetMarketBookSymbol(symbol);
}

//+------------------------------------------------------------------+
//| Get symbol for market book.                                      |
//+------------------------------------------------------------------+
string CMarketBook::GetMarketBookSymbol(void)
{
   return m_symbol;
}
//+------------------------------------------------------------------+
//| Set symbol for market book.                                      |
//+------------------------------------------------------------------+
bool CMarketBook::SetMarketBookSymbol(string symbol)
{
   m_sell_deals = 0;
   m_buy_deals = 0;
   ArrayResize(MarketBook, 0);
   m_available = false;
   m_best_ask_index = -1;
   m_best_bid_index = -1;
   m_depth_total = 0;
   bool isSelect = SymbolSelect(symbol, true);
   if(isSelect)
      m_symbol = symbol;
   else
   {
      if(!SymbolSelect(m_symbol, true) && SymbolSelect(Symbol(), true))
         m_symbol = Symbol();
   }
   if(isSelect)
      MarketBookAdd(m_symbol);
   Refresh();
   return isSelect;
}
//+------------------------------------------------------------------+
//| Refresh Market Book.                                             |
//+------------------------------------------------------------------+
void CMarketBook::Refresh(void)
{
   m_available = MarketBookGet(m_symbol, MarketBook);
   m_depth_total = ArraySize(MarketBook);
   SetBestAskAndBidIndex();
   if(m_depth_total == 0)
      return;
   m_count_refresh++;
   CompareTiks();
   if(m_best_ask_index != -1 && m_best_bid_index != -1)
      m_spread_sum += MarketBook[m_best_ask_index].price-MarketBook[m_best_bid_index].price;
   Calculation.Reset();
}

void CMarketBook::Refresh(int num)
{
   m_available = MarketBookGet(m_symbol, MarketBook);
   m_depth_total = ArraySize(MarketBook);
   SetBestAskAndBidIndex();
   if(m_depth_total == 0)
      return;
   m_count_refresh++;
   if(m_best_ask_index != -1 && m_best_bid_index != -1)
      m_spread_sum += MarketBook[m_best_ask_index].price-MarketBook[m_best_bid_index].price;
   Calculation.Reset();
}
//+------------------------------------------------------------------+
//| Compare two tiks collections and find new tiks                   |
//+------------------------------------------------------------------+
void CMarketBook::CompareTiks(void)
{
   MqlTick n_tiks[];
   ulong t_begin = (TimeCurrent()-(1*20))*1000; // from 20 sec ago
   int total = CopyTicks(m_symbol, n_tiks, COPY_TICKS_ALL, t_begin, 1000);
   if(total<1)
      return;
   if(ArraySize(m_ticks) == 0)
   {
      ArrayCopy(m_ticks, n_tiks, 0, 0, WHOLE_ARRAY);
      return;
   }
   int k = ArraySize(m_ticks)-1;
   int n_t = 0;
   int limit_comp = 20;
   int comp_sucess = 0;
   
   //Перебираем новые полученые торговые сделки начиная с самой последней
   for(int i = ArraySize(n_tiks)-1; i >= 0 && k >= 0; i--)
   {
      if(!CompareTiks(n_tiks[i], m_ticks[k]))
      {
         n_t = ArraySize(n_tiks) - i;
         k = ArraySize(m_ticks)-1;
         comp_sucess = 0;
      }
      else
      {
         comp_sucess += 1;
         if(comp_sucess >= limit_comp)
            break;
         k--;
      }
   }
   //Remember the received ticks
   ArrayResize(m_ticks, total);
   ArrayCopy(m_ticks, n_tiks, 0, 0, WHOLE_ARRAY);
   //Calculate the index of the beginning of new ticks and copy them to buffer for access
   ArrayResize(LastTicks, n_t);
   if(n_t > 0)
   {
      int index = ArraySize(n_tiks)-n_t;
      ArrayCopy(LastTicks, m_ticks, 0, index, n_t);
   }
}
//+------------------------------------------------------------------+
//| Compare two tiks                                                 |
//+------------------------------------------------------------------+
bool CMarketBook::CompareTiks(MqlTick& tick1, MqlTick& tick2)
{
   MqlTick at1[1], at2[1];
   at1[0] = tick1;
   at2[0] = tick2;
   if(ArrayCompare(at1, at2) == 0)
      return true;
   return false;
}
//+------------------------------------------------------------------+
//| Return tiks count.                                               |
//+------------------------------------------------------------------+
ulong CMarketBook::TiksCount(void)
{
   return m_tiks_count;
}
//+------------------------------------------------------------------+
//| Return true if market book is available, otherwise return false  |
//+------------------------------------------------------------------+
bool CMarketBook::IsAvailable(void)
{
   return m_available;
}
//+------------------------------------------------------------------+
//| Find best ask and bid indexes and set this indexes for           |
//| m_best_ask_index and m_best_bid field                            |
//+------------------------------------------------------------------+
void CMarketBook::SetBestAskAndBidIndex(void)
{
   if(!FindBestBid())
   {
      //Find best ask by slow full search
      m_best_ask_index = -1;
      int bookSize = ArraySize(MarketBook);   
      for(int i = 0; i < bookSize; i++)
      {
         if((MarketBook[i].type == BOOK_TYPE_BUY) || (MarketBook[i].type == BOOK_TYPE_BUY_MARKET))
         {
            m_best_ask_index = i-1;
            FindBestBid();
            break;
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Fast find best bid by best ask                                   |
//+------------------------------------------------------------------+
bool CMarketBook::FindBestBid(void)
{
   m_best_bid_index = -1;
   bool isBestAsk = m_best_ask_index >= 0 && m_best_ask_index < m_depth_total &&
                    (MarketBook[m_best_ask_index].type == BOOK_TYPE_SELL ||
                    MarketBook[m_best_ask_index].type == BOOK_TYPE_SELL_MARKET);
   if(!isBestAsk && m_best_ask_index != -1)return false;
   int bestBid = m_best_ask_index+1;
   bool isBestBid = bestBid >= 0 && bestBid < m_depth_total &&
                    (MarketBook[bestBid].type == BOOK_TYPE_BUY ||
                    MarketBook[bestBid].type == BOOK_TYPE_BUY_MARKET);
   if(isBestBid)
   {
      m_best_bid_index = bestBid;
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//| Get integer property by ENUM_MBOOK_INFO_INTEGER modifier         |
//+------------------------------------------------------------------+
long CMarketBook::InfoGetInteger(ENUM_MBOOK_INFO_INTEGER property)
{
   switch(property)
   {
      case MBOOK_BEST_ASK_INDEX:
         return m_best_ask_index;
      case MBOOK_BEST_BID_INDEX:
         return m_best_bid_index;
      case MBOOK_LAST_ASK_INDEX:
         if(m_best_ask_index == -1)
            return -1;
         else
            return LAST_ASK_INDEX;
      case MBOOK_LAST_BID_INDEX:
         if(m_best_bid_index == -1)
            return -1;
         else
            return LAST_BID_INDEX;
      case MBOOK_DEPTH_TOTAL:
         return m_depth_total;
      case MBOOK_DEPTH_BID:
         return (m_depth_total - m_best_bid_index);
      case MBOOK_DEPTH_ASK:
         return m_best_bid_index;
      case MBOOK_MAX_ASK_VOLUME:
         return Calculation.GetMaxVolAsk();
      case MBOOK_MAX_ASK_VOLUME_INDEX:
         return Calculation.GetMaxVolAskIndex();
      case MBOOK_MAX_BID_VOLUME:
         return Calculation.GetMaxVolBid();
      case MBOOK_MAX_BID_VOLUME_INDEX:
         return Calculation.GetMaxVolBidIndex();
      case MBOOK_BUY_ORDERS:
         return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_BUY_ORDERS);
      case MBOOK_SELL_ORDERS:
         return SymbolInfoInteger(m_symbol, SYMBOL_SESSION_SELL_ORDERS);
      case MBOOK_ASK_VOLUME_TOTAL:
         return Calculation.GetAskVolTotal();
      case MBOOK_BID_VOLUME_TOTAL:
         return Calculation.GetBidVolTotal();
   }
   return 0;
}
//+------------------------------------------------------------------+
//| Get double property by ENUM_MBOOK_INFO_DOUBLE modifier           |
//+------------------------------------------------------------------+
double CMarketBook::InfoGetDouble(ENUM_MBOOK_INFO_DOUBLE property)
{
   switch(property)
   {
      case MBOOK_BEST_ASK_PRICE:
         if(m_best_ask_index == -1)
            return EMPTY_VALUE;
         return MarketBook[m_best_ask_index].price;
      case MBOOK_BEST_BID_PRICE:
         if(m_best_bid_index == -1)
            return EMPTY_VALUE;
         return MarketBook[m_best_bid_index].price;
      case MBOOK_LAST_ASK_PRICE:
         if(ArraySize(MarketBook)==0)
            return EMPTY_VALUE;
         return MarketBook[LAST_ASK_INDEX].price;
      case MBOOK_LAST_BID_PRICE:
         if(ArraySize(MarketBook)==0)
            return EMPTY_VALUE;
         return MarketBook[LAST_BID_INDEX].price;
      case MBOOK_AVERAGE_SPREAD:
         if(m_count_refresh==0)
            return EMPTY_VALUE;
         return (m_spread_sum/m_count_refresh);
      case MBOOK_BUY_ORDERS_VOLUME:
         return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_BUY_ORDERS_VOLUME);
      case MBOOK_SELL_ORDERS_VOLUME:
         return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_SELL_ORDERS_VOLUME);
      case MBOOK_OPEN_INTEREST:
         return SymbolInfoDouble(m_symbol, SYMBOL_SESSION_INTEREST);
   }
   return 0.0;  
}

//+------------------------------------------------------------------+
//| Get deviation value by volume. Return 0.0 if deviation is        |
//| infinity (insufficient liquidity)                                |
//+------------------------------------------------------------------+
double CMarketBook::GetDeviationByVol(long vol, ENUM_MBOOK_SIDE side)
{
   if(ArraySize(MarketBook) == 0)return 0.0;
   int best_ask = (int)InfoGetInteger(MBOOK_BEST_ASK_INDEX);
   int last_ask = (int)InfoGetInteger(MBOOK_LAST_ASK_INDEX); 
   int best_bid = (int)InfoGetInteger(MBOOK_BEST_BID_INDEX);
   int last_bid = (int)InfoGetInteger(MBOOK_LAST_BID_INDEX);
   double avrg_price = 0.0;
   long volume_exe = vol;
   if(side == MBOOK_ASK)
   {
      for(int i = best_ask; i >= last_ask; i--)
      {
         long currVol = MarketBook[i].volume < volume_exe ?
                        MarketBook[i].volume : volume_exe ;   
         avrg_price += currVol * MarketBook[i].price;
         volume_exe -= MarketBook[i].volume;
         if(volume_exe <= 0)break;
      }
   }
   else
   {
      for(int i = best_bid; i <= last_bid; i++)
      {
         long currVol = MarketBook[i].volume < volume_exe ?
                        MarketBook[i].volume : volume_exe ;   
         avrg_price += currVol * MarketBook[i].price;
         volume_exe -= MarketBook[i].volume;
         if(volume_exe <= 0)break;
      }
   }
   if(volume_exe > 0)
      return 0.0;
   avrg_price/= (double)vol;
   double deviation = 0.0;
   if(side == MBOOK_ASK)
      deviation = avrg_price - MarketBook[best_ask].price;
   else
      deviation = MarketBook[best_bid].price - avrg_price;
   return deviation;
}
