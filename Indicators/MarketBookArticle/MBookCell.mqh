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
//#include "GlobalMainTable.mqh"

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
   int               m_minVolume;
   int               m_maxVolume;
   int               m_buyOrSellType;
   CElChart          m_text;
   CMarketBook       *m_book;
   double            m_price;
   double            m_pricePercentage;
   ulong             m_volume;
   string            m_columnName;
   void              SetBackgroundColor();
   void              SetBackgroundColor2(void);
public:
   void              CBookCell();
                     CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName, int min, int max, double pricePercentage);
                     CBookCell(int type,long x_dist,long y_dist, double price, int buyOrSellType, string columnName);
                     CBookCell(int type,long x_dist,long y_dist, ulong volume, int buyOrSellType, string columnName);
   void              SetVariables(int type, long x_dist,long y_dist,double price, int buyOrSellType);
   void              SetVariables(int type, long x_dist,long y_dist, ulong volume,  int buyOrSellType, int min, int max);
   string            ConvertVolumeToString(string volume);
   void              SetText(string price, string pricePercentage, string volume, int type);
   void              SetWidth(float tempVolume, int type);
   void              SetCellColor(string text, int type);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBookCell::CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName, int min, int max, double pricePercentage) : CElChart(OBJ_RECTANGLE_LABEL),
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

   if(type==2)
      m_pricePercentage = pricePercentage;

   m_buyOrSellType = (book.MarketBook[m_index].type==BOOK_TYPE_SELL)?0:1;

   m_columnName = columnName;
   m_minVolume = min;
   m_maxVolume = max;

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
            if(m_columnName=="price" || m_columnName=="pricePercentage")
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
CBookCell::CBookCell(int type,long x_dist,long y_dist, double price, int buyOrSellType, string columnName) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(18);
   Width(100);
   BorderType(BORDER_FLAT);

   if(type==2)
      m_pricePercentage=price;
   else
      m_price=price;

   m_cell_type=type;
   m_buyOrSellType = buyOrSellType;

   m_columnName = columnName;

   m_text.XCoord(x_dist);

   m_text.YCoord(y_dist);
   m_text.Height(16);
   m_text.Width(58);

   if(m_columnName=="price" || m_columnName=="pricePercentage")
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
void CBookCell::SetVariables(int type, long x_dist,long y_dist, double price, int buyOrSellType)
  {
   CElChart *obj= m_elements.At(0);
   if(CheckPointer(obj)==POINTER_INVALID)
     {
      m_elements.Clear();
      m_elements.Add(GetPointer(m_text));
     }
   else
      m_text = obj;

   XCoord(x_dist);
   YCoord(y_dist);

   if(type==2)
      m_pricePercentage=price;
   else
      m_price=price;

   m_cell_type = type;

   m_buyOrSellType = buyOrSellType;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);

   if(m_columnName=="price" || m_columnName=="pricePercentage")
      m_text.TextColor(C'240, 240, 240');
   else
      m_text.TextColor(clrBlack);

   m_elements.Update(0, GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
void CBookCell::SetVariables(int type, long x_dist,long y_dist, ulong volume,  int buyOrSellType, int min, int max)
  {

   CElChart *obj= m_elements.At(0);
   if(CheckPointer(obj)==POINTER_INVALID)
     {
      m_elements.Clear();
      m_elements.Add(GetPointer(m_text));
     }
   else
      m_text = obj;

   XCoord(x_dist);
   YCoord(y_dist);

   m_volume=volume;
   m_minVolume = min;
   m_maxVolume = max;

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

   m_elements.Update(0, GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//| Updates the Market Depth values after the update of the          |
//| Market Depth info                                                |
//+------------------------------------------------------------------+
void CBookCell::OnRefresh(CEventRefresh *event)
  {
   float tempVolume;

   if(m_book==NULL)
      return;
   if(m_index>=ArraySize(m_book.MarketBook))
      return;
   ENUM_BOOK_TYPE type=m_book.MarketBook[m_index].type;
   long max_ask = m_book.InfoGetInteger(MBOOK_MAX_ASK_VOLUME);
   long max_bid = m_book.InfoGetInteger(MBOOK_MAX_BID_VOLUME);
   long max_volume=max_ask>max_bid ? max_ask : max_bid;
   MqlBookInfo info=m_book.MarketBook[m_index];

   SetText(DoubleToString(info.price,Digits()), "-1", (string) info.volume, info.type);
   SetCellColor(m_text.Text(), info.type);
   SetWidth(info.volume, info.type);
//SetBackgroundColor();
  }

//+------------------------------------------------------------------+
//| Updates the Market Depth values after the update of the          |
//| Market Depth info                                                |
//+------------------------------------------------------------------+
void CBookCell::OnRefresh2(CEventRefresh *event)
  {
   int type;

   if(m_columnName=="bidVol" || m_columnName=="askVol")
      type=(m_buyOrSellType==0)?BOOK_TYPE_SELL:BOOK_TYPE_BUY;
   else
      if(m_columnName=="sellerVol" || m_columnName=="buyerVol")
         type=-2;
      else
         if(m_columnName=="price")
            type=-3;
         else
            if(m_columnName=="pricePercentage")
               type=-1;
            else
               if(m_columnName == "volume")
                  type=-4;

//SetBackgroundColor();

   SetText(DoubleToString(m_price,Digits()), DoubleToString(m_pricePercentage,Digits()), (string)m_volume, type);
   SetCellColor(m_text.Text(), type);
   SetWidth(m_volume, type);

  }
//+------------------------------------------------------------------+
//| Sets the color of cell background depending on its type          |
//+------------------------------------------------------------------+
void CBookCell::SetBackgroundColor(void)
  {
   int type;

   if(m_price!=-1)
     {
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
     }

   if(m_cell_type==2)
     {
      if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
         BackgroundColor(C'3,0,149');
      else
         if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
            BackgroundColor(C'150,0,1');
     }
   else
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
string CBookCell::ConvertVolumeToString(string volume)
  {
   string showingVolume;

   int len = StringLen(volume);

   if(len<=6 && len>3)
     {
      int tempVol = StringToInteger(StringSubstr(volume, 0, len-3));
      tempVol = (tempVol >= 500)? MathCeil(tempVol):MathFloor(tempVol);
      showingVolume = IntegerToString(tempVol) + " K";
     }
   else
      if(len<=9 && len>6)
        {
         int tempVol = StringToInteger(StringSubstr(volume, 0, len-6));
         tempVol = (tempVol >= 500)? MathCeil(tempVol):MathFloor(tempVol);
         showingVolume = IntegerToString(tempVol) + " M";
        }
      else
         if(len>9 && len<=12)
           {
            int tempVol = StringToInteger(StringSubstr(volume, 0, len-9));
            tempVol = (tempVol >= 500)? MathCeil(tempVol):MathFloor(tempVol);
            showingVolume = IntegerToString(tempVol) + " B";
           }
         else
            if(len <=3)
              {
               showingVolume = volume;
              }

   string text[2];
   StringSplit(showingVolume, ' ', text);
   int textLength = StringLen(text[0]);
   string numberOfZero;

   switch(textLength)
     {
      case 3:
         numberOfZero = "00";
         break;
      case 2:
         numberOfZero = "0";
         break;
      case 1:
         numberOfZero = "";
         break;
     }

   string firstNumber = StringSubstr(text[0], 0, 1);
   string secondNumber = StringSubstr(text[0], 1, 1);

   if(StringLen(numberOfZero) == 2 || StringLen(numberOfZero) == 1)
      text[0] = (StringToInteger(secondNumber)>=5)?IntegerToString(StringToInteger(firstNumber)+1)+ numberOfZero:firstNumber+ numberOfZero;

   showingVolume = text[0] +  " " + text[1];

   return showingVolume;
  }
//+------------------------------------------------------------------+
void CBookCell::SetText(string price, string pricePercentage, string volume, int type)
  {
   if(m_cell_type==BOOK_PRICE || m_cell_type==2)
     {
      if(m_cell_type==BOOK_PRICE && price!="-1")
         m_text.Text(price);
      else
         if(m_cell_type==2 && pricePercentage!="-1")
            m_text.Text(pricePercentage);
         else
            m_text.Text(" ");
     }
   else
      if(m_cell_type==BOOK_VOLUME)
        {
         string showingVolume = ConvertVolumeToString(volume);

         if((type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET) && (m_columnName=="askVol"))
           {
            m_text.Text(showingVolume);
           }
         else
            if((type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET) && (m_columnName=="bidVol"))
              {
               m_text.Text(showingVolume);
              }
            else
               if((m_columnName=="sellerVol" || m_columnName=="buyerVol" || m_columnName == "volume") && m_volume!=-1)
                 {
                  m_text.Text(ConvertVolumeToString((string)m_volume));
                 }
               else
                  m_text.Text(" ");
        }
  }
//+------------------------------------------------------------------+
void CBookCell::SetWidth(float tempVolume, int type)
  {
   float width;
   if(m_minVolume != 0 || m_maxVolume != 0)
      width = ((tempVolume - m_minVolume) / (m_maxVolume - m_minVolume)) * 60 + 40;
   else
      width = 40;

   if(StringCompare(m_text.Text(), " ")==0)
      Width(0);
   else
      if(StringCompare(m_text.Text(), "0 ")==0)
        {
         Width(10);
        }
      else
         if(m_columnName=="pricePercentage")
           {
            Width(40);
           }
         else
            if(m_columnName=="bidVol" || m_columnName=="askVol")
              {
               Width(width);
              }
  }
//+------------------------------------------------------------------+
void CBookCell::SetCellColor(string text, int type)
  {
   if(m_columnName=="price" || m_columnName=="pricePercentage")
     {
      BackgroundColor(C'139,  139, 139');
     }
   else
      if(m_columnName=="sellerVol" || m_columnName=="buyerVol")
        {
         BackgroundColor(C'216,  216, 216');
        }
      else
         if(m_columnName == "volume")
           {
            BackgroundColor(C'215,  215, 215');
           }
         else
            if(StringFind(text, " K") != -1)
              {
               if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                  BackgroundColor("0,0,200");
               else
                  if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                     BackgroundColor("200,0,0");
              }
            else
               if(StringFind(text, " M") != -1)
                 {
                  if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                     BackgroundColor("0,0,100");
                  else
                     if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                        BackgroundColor("100,0,0");
                 }

               else
                  if(StringFind(text, " B") != -1)
                    {
                     if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                        BackgroundColor("0,0,50");
                     else
                        if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                           BackgroundColor("50,0,0");
                    }
                  else
                    {
                     if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                        BackgroundColor("0,0,250");
                     else
                        if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                           BackgroundColor("250,0,0");
                    }
  }
//+------------------------------------------------------------------+
