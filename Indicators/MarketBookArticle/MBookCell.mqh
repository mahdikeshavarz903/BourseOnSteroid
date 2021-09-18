//+------------------------------------------------------------------+
//|                                                   MBookCell.mqh  |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <../Shared Projects/BourseOnSteroid/Include/Trade/MarketBook.mqh>
#include <../Shared Projects/BourseOnSteroid/Include/Panel/ElChart.mqh>
#include "GlobalMarketBook.mqh"
#include "GlobalMainTable.mqh"

#define BOOK_PRICE 0
#define BOOK_VOLUME 1
//+------------------------------------------------------------------+
//| The class represents a cell of the order book.                   |
//+------------------------------------------------------------------+
class CBookCell : public CElChart
  {
private:
   long              m_ydist;
   long              m_xdist;
   int               m_index;
   int               m_cell_type;
   int               m_buyOrSellType;
   CElChart          m_text;
   CMarketBook       *m_book;
   double            m_price;
   ulong             m_volume;
   string            m_columnName;
   void              SetBackgroundColor();
   void              SetBackgroundColor2(void);
public:
   void              CBookCell();
                     CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName);
                     CBookCell(int type,long x_dist,long y_dist,int index_mbook, double price, int buyOrSellType, string columnName);
                     CBookCell(int type,long x_dist,long y_dist, ulong volume, int buyOrSellType, string columnName);
   void              SetVariables(long x_dist,long y_dist,int index_mbook, double price, int buyOrSellType, int m_text_index);
   void              SetVariables(long x_dist,long y_dist, ulong volume,  int buyOrSellType, int m_text_index);
   string            ConvertVolumeToString(string volume);
   void              InitialMainTable(MainTable &mtlb);
   virtual void      OnRefresh(CEventRefresh *event);
   virtual void      OnRefresh2(CEventRefresh *event);
  };
//+------------------------------------------------------------------+
//| At the moment of order book cell creation we specify:            |
//| type -  what the cell will show, either price (BOOK_PRICE) or    |
//|        volume (BOOK_VOLUME).                                     |
//| x_dist - horizontal shift in pixels relative to the              |
//|         chart window.                                            |
//| y_dist - vertical shift in pixels relative to the                |
//|         chart window                                             |
//| index_mbook - the index of Market Depth order corrsponding       |
//|         to this cell.                                            |
//| book - a pointer to the Market Depth class instance              |
//+------------------------------------------------------------------+
void CBookCell::CBookCell()
{}

CBookCell::CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(18);
   Width(100);
   BorderType(BORDER_FLAT);

   m_index=index_mbook;
   m_book=book;
   m_cell_type=type;

   m_buyOrSellType = (book.MarketBook[m_index].type==BOOK_TYPE_SELL)?0:1;

   m_columnName = columnName;

   m_text.XCoord(x_dist);

   m_text.YCoord(y_dist);
   m_text.Height(16);
   m_text.Width(58);

   if(m_columnName=="bidVol" || m_columnName=="askVol")
      m_text.TextColor(clrWhite);
   else
      if(m_columnName=="buyerVol")
         m_text.TextColor(C'76, 67, 197');
      else
         if(m_columnName=="sellerVol")
            m_text.TextColor(C'117, 36, 35');
         else
            if(m_columnName=="price")
               m_text.TextColor(C'240, 240, 240');
            else
               if(m_columnName=="volume")
                  m_text.TextColor(C'20, 21, 29');
               else
                  m_text.TextColor(clrBlack);

   m_text.TextSize(9);
   m_text.BorderType(BORDER_FLAT);
   m_text.TextFont("Consolas");
   m_elements.Add(GetPointer(m_text));
  }

//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
CBookCell::CBookCell(int type,long x_dist,long y_dist,int index_mbook, double price, int buyOrSellType, string columnName) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(18);
   Width(100);
   BorderType(BORDER_FLAT);

   m_index=index_mbook;
   m_price=price;
   m_cell_type=type;
   m_buyOrSellType = buyOrSellType;

   m_columnName = columnName;

   m_text.XCoord(x_dist);

   m_text.YCoord(y_dist);
   m_text.Height(16);
   m_text.Width(58);

   if(m_columnName=="price")
      m_text.TextColor(C'240, 240, 240');
   else
      m_text.TextColor(clrBlack);

   m_text.TextSize(9);
   m_text.BorderType(BORDER_FLAT);
   m_text.TextFont("Consolas");
   m_elements.Add(GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
CBookCell::CBookCell(int type,long x_dist,long y_dist, ulong volume, int buyOrSellType, string columnName) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(18);
   Width(100);
   BorderType(BORDER_FLAT);

   m_volume=volume;
   m_cell_type=type;
   m_buyOrSellType = buyOrSellType;

   m_columnName = columnName;

   m_text.XCoord(x_dist);

   m_text.YCoord(y_dist);
   m_text.Height(16);
   m_text.Width(58);

   if(m_columnName=="bidVol" || m_columnName=="askVol")
      m_text.TextColor(clrWhite);
   else
      if(m_columnName=="buyerVol")
         m_text.TextColor(C'76, 67, 197');
      else
         if(m_columnName=="sellerVol")
            m_text.TextColor(C'117, 36, 35');
         else
            if(m_columnName=="volume")
               m_text.TextColor(C'20, 21, 29');
            else
               m_text.TextColor(clrBlack);

   m_text.TextSize(9);
   m_text.TextFont("Consolas");
   m_text.BorderType(BORDER_FLAT);
   m_elements.Add(GetPointer(m_text));
  }

//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
void CBookCell::SetVariables(long x_dist,long y_dist,int index_mbook, double price, int buyOrSellType, int m_text_index)
  {
   m_text = m_elements.At(0);
   
   XCoord(x_dist);
   YCoord(y_dist);
   
   m_price=price;
   m_buyOrSellType = buyOrSellType;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   
   if(m_columnName=="price")
      m_text.TextColor(C'240, 240, 240');
   else
      m_text.TextColor(clrBlack);
   
   m_elements.Update(0 , GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
void CBookCell::SetVariables(long x_dist,long y_dist, ulong volume,  int buyOrSellType, int m_text_index)
  {
   
   m_text = m_elements.At(0);
   
   XCoord(x_dist);
   YCoord(y_dist);
   
   m_volume=volume;
   m_buyOrSellType = buyOrSellType;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);

   if(m_columnName=="bidVol" || m_columnName=="askVol")
      m_text.TextColor(clrWhite);
   else
      if(m_columnName=="buyerVol")
         m_text.TextColor(C'76, 67, 197');
      else
         if(m_columnName=="sellerVol")
            m_text.TextColor(C'117, 36, 35');
         else
            if(m_columnName=="volume")
               m_text.TextColor(C'20, 21, 29');
            else
               m_text.TextColor(clrBlack);
               
   m_elements.Update(0 , GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//| Updates the Market Depth values after the update of the          |
//| Market Depth info                                                |
//+------------------------------------------------------------------+
void CBookCell::OnRefresh(CEventRefresh *event)
  {
   if(m_book==NULL)
      return;
   if(m_index>=ArraySize(m_book.MarketBook))
      return;
   ENUM_BOOK_TYPE type=m_book.MarketBook[m_index].type;
   long max_ask = m_book.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   long max_bid = m_book.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   long max_volume=max_ask>max_bid ? max_ask : max_bid;
   MqlBookInfo info=m_book.MarketBook[m_index];
   SetBackgroundColor();
   /*if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
         BackgroundColor(C'205,245,250');
      else if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
         BackgroundColor(C'255,231,239');
      else
         BackgroundColor(clrWhite);*/
   if(m_cell_type==BOOK_PRICE)
      m_text.Text(DoubleToString(info.price,Digits()));
   else
      if(m_cell_type==BOOK_VOLUME)
        {
         string showingVolume = ConvertVolumeToString((string) info.volume);

         if((info.type==BOOK_TYPE_SELL || info.type==BOOK_TYPE_SELL_MARKET) && (m_columnName!="bidVol" && m_columnName!="sellerVol" && m_columnName!="buyerVol" && m_columnName!="volume"))
           {
            m_text.Text(showingVolume);
           }
         else
            if((info.type==BOOK_TYPE_BUY || info.type==BOOK_TYPE_BUY_MARKET) && (m_columnName!="askVol" && m_columnName!="buyerVol" && m_columnName!="sellerVol" && m_columnName!="volume"))
              {
               m_text.Text(showingVolume);
              }
            else
               if(m_columnName=="sellerVol" || m_columnName=="buyerVol" || m_columnName == "volume")
                 {
                  if(ArraySize(mainTable)==0)
                     m_text.Text((string) 0);

                  for(int i=0; i<ArraySize(mainTable); i++)
                    {
                     if(mainTable[i].price == info.price)
                       {
                        if(m_columnName=="sellerVol")
                          {
                           m_text.Text(ConvertVolumeToString((string) mainTable[i].sellerVol));
                          }
                        else
                           if(m_columnName=="buyerVol")
                             {
                              m_text.Text(ConvertVolumeToString((string) mainTable[i].buyerVol));
                             }
                           else
                              m_text.Text(ConvertVolumeToString((string) mainTable[i].volume));
                       }
                    }

                 }
               else
                  m_text.Text(" ");

        }



   if(m_cell_type!=BOOK_VOLUME)
      return;

   double delta=1.0;
   if(max_volume>0)
      delta=(info.volume/(double)max_volume);
   if(delta>1.0)
      delta=1.0;
   long size=(long)(delta*100.0);
   if(size==0)
      size=30;

   string text[2];
   StringSplit(m_text.Text(), ' ', text);
   float width = ((float)text[0] / 999) * 30;

   if(m_text.Text() == " ")
      Width(0);
   else
      if(m_text.Text() == "0")
         Width(10);
      else
        {
         if(StringFind(m_text.Text(), " K") != -1)
            width += 40;
         else
            if(StringFind(m_text.Text(), " M") != -1)
               width += 70;
            else
               if(StringFind(m_text.Text(), " B") != -1)
                  width += 100;
               else
                  width += 10;
         Width(width);
        }
  }
//+------------------------------------------------------------------+
//| Sets the color of cell background depending on its type          |
//+------------------------------------------------------------------+
void CBookCell::SetBackgroundColor(void)
  {
   int type;

   if(m_price!=-1)
      if(m_columnName=="bidVol" || m_columnName=="askVol")
         type=(m_buyOrSellType==0)?BOOK_TYPE_SELL:BOOK_TYPE_BUY;
      else
         if(m_columnName=="sellerVol" || m_columnName=="buyerVol")
            type=-2;
         else
            if(m_columnName=="price")
               type=-3;
            else
               if(m_columnName == "volume")
                  type=-4;
               else
                  type=-1;

//to do: Display last deals in the order book in green
   /*if(ArraySize(m_book.LastTicks)>0)
      {
         int last = ArraySize(m_book.LastTicks)-1;
         MqlTick last_tick = m_book.LastTicks[last];
         bool is_main_level = m_book.MarketBook[m_index].price == last_tick.last;
         bool is_buy = (last_tick.flags & TICK_FLAG_BUY) == TICK_FLAG_BUY;
         bool is_sell = (last_tick.flags & TICK_FLAG_SELL) == TICK_FLAG_SELL;
         bool is_last = true;
         if((is_buy||is_sell) && is_main_level)
         {
            BackgroundColor(clrGreen);
            return;
         }
      }*/
   if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
      BackgroundColor(C'3,0,149');
   else
      if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
         BackgroundColor(C'150,0,1');
      else
         if(type==-1)
            BackgroundColor(clrWhite);
         else
            if(type==-2)
               BackgroundColor(C'216,  216, 216');

            else
               if(type==-3)
                  BackgroundColor(C'139,  139, 139');
               else
                  if(type==-4)
                     BackgroundColor(C'215,  215, 215');
  }
//+------------------------------------------------------------------+
//| Updates the Market Depth values after the update of the          |
//| Market Depth info                                                |
//+------------------------------------------------------------------+
void CBookCell::OnRefresh2(CEventRefresh *event)
  {
   double vol=1000;

   long max_ask = MarketBook.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   long max_bid = MarketBook.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   long max_volume=max_ask>max_bid ? max_ask : max_bid;
   SetBackgroundColor();
   /*if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
         BackgroundColor(C'205,245,250');
      else if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
         BackgroundColor(C'255,231,239');
      else
         BackgroundColor(clrWhite);*/
   if(m_cell_type==BOOK_PRICE)
     {
      if(m_price!=-1)
         m_text.Text(DoubleToString(m_price,Digits()));
      else
         m_text.Text(" ");
     }
   else
      if(m_cell_type==BOOK_VOLUME)
         if(m_volume!=-1)
            m_text.Text(ConvertVolumeToString((string)m_volume));
         else
            m_text.Text(" ");
   if(m_cell_type!=BOOK_VOLUME)
      return;
   double delta=1.0;
   if(max_volume>0)
      delta=(m_volume/(double)max_volume);
   if(delta>1.0)
      delta=1.0;
   long size=(long)(delta*50.0);
   if(size==0)
      size=1;

   string text[2];
   StringSplit(m_text.Text(), ' ', text);
   float width = ((float)text[0] / 999) * 30;

   if(m_price==-1 || m_volume==-1)
      Width(0);
   else
      if(m_text.Text() == "0")
         Width(10);
      else
        {
         if(StringFind(m_text.Text(), " K") != -1)
            width += 40;
         else
            if(StringFind(m_text.Text(), " M") != -1)
               width += 70;
            else
               if(StringFind(m_text.Text(), " B") != -1)
                  width += 100;
               else
                  width += 10;
         Width(width);
        }

  }
//+------------------------------------------------------------------+
string CBookCell::ConvertVolumeToString(string volume)
  {
   string showingVolume;

   int len = StringLen(volume);

   if(len<=6 && len>3)
     {
      showingVolume = StringSubstr(volume, 0, len-3) + " K";
     }
   else
      if(len<=9 && len>6)
        {
         showingVolume = StringSubstr(volume, 0, len-6) + " M";
        }
      else
         if(len>9 && len<=12)
           {
            showingVolume = StringSubstr(volume, 0, len-9) + " B";
           }
         else
            if(len <=3)
              {
               showingVolume = volume;
              }

   return showingVolume;
  }
//+------------------------------------------------------------------+
