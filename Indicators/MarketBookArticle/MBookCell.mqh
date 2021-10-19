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
#include "GlobalMinMax.mqh"

#define BOOK_PRICE 0
#define BOOK_VOLUME 1
int previousVolumeMaxK=0;
int previousVolumeMinK=0;
int previousVolumeMaxM=0;
int previousVolumeMinM=0;
int previousVolumeMaxB=0;
int previousVolumeMinB=0;
int previousVolumeMaxH=0;
int previousVolumeMinH=0;
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
   double            m_pricePercentage;
   ulong             m_volume;
   string            m_columnName;
   void              SetBackgroundColor();
   void              SetBackgroundColor2(void);
public:
   void              CBookCell();
                     CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName, double pricePercentage, int min, int max);
                     CBookCell(int type,long x_dist,long y_dist, double price, int buyOrSellType, string columnName);
                     CBookCell(int type,long x_dist,long y_dist, ulong volume, int buyOrSellType, string columnName, int min, int max);
   void              SetVariables(int type, long x_dist,long y_dist,double price, int buyOrSellType);
   void              SetVariables(int type, long x_dist,long y_dist, ulong volume,  int buyOrSellType, int min, int max);
   string            ConvertVolumeToString(string volume);
   string            SetText(string price, string pricePercentage, string volume, int type);
   void              SetWidth(string showingVolume,  string tempVolume, int type);
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
CBookCell::CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName, double pricePercentage, int min, int max) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(18);
   Width(100);
   BorderType(BORDER_FLAT);
   BorderColor(C'17, 18, 51');

   m_index=index_mbook;
   m_book=book;
   m_cell_type=type;

   if(type==2)
      m_pricePercentage = pricePercentage;

   m_buyOrSellType = (book.MarketBook[m_index].type==BOOK_TYPE_SELL)?0:1;

   m_columnName = columnName;

   m_text.XCoord(x_dist);

   m_text.YCoord(y_dist);
   m_text.Height(16);
   m_text.Width(58);

   if(m_columnName=="bidVol" || m_columnName=="askVol")
     {
      m_text.TextColor(clrWhite);
     }
   else
      if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
        {
         if(m_columnName=="buyerVol")
            m_text.TextColor(clrBlue);
         else
            m_text.TextColor(clrRed);
        }
      else
         if(m_columnName=="price" || m_columnName=="pricePercentage")
            m_text.TextColor(C'240, 240, 240');
         else
            if(m_columnName=="volume")
              {
               m_text.TextColor(clrWhite);
              }
            else
               m_text.TextColor(clrBlack);

   m_text.TextSize(9);
   //m_text.BorderType(BORDER_FLAT);
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
   BorderColor(C'17, 18, 51');

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
   //m_text.BorderType(BORDER_FLAT);
   m_text.TextFont("Consolas");
   m_elements.Add(GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
CBookCell::CBookCell(int type,long x_dist,long y_dist, ulong volume, int buyOrSellType, string columnName, int min, int max) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(18);
   Width(100);
   BorderType(BORDER_FLAT);
   BorderColor(C'17, 18, 51');

   m_volume=volume;
   m_cell_type=type;
   m_buyOrSellType = buyOrSellType;

   m_columnName = columnName;

   m_text.XCoord(x_dist);

   m_text.YCoord(y_dist);
   m_text.Height(16);
   m_text.Width(58);
   
   if(m_columnName=="bidVol" || m_columnName=="askVol")
     {
      m_text.TextColor(clrWhite);
     }
   else
      if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
        {
         if(m_columnName=="buyerVol")
            m_text.TextColor(clrBlue);
         else
            m_text.TextColor(clrRed);
        }
      else
         if(m_columnName=="price" || m_columnName=="pricePercentage")
            m_text.TextColor(C'240, 240, 240');
         else
            if(m_columnName=="volume")
              {
               m_text.TextColor(clrWhite);
              }
            else
               m_text.TextColor(clrBlack);

   m_text.TextSize(9);
   m_text.TextFont("Consolas");
   //m_text.BorderType(BORDER_FLAT);
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

   m_buyOrSellType = buyOrSellType;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);

   if(m_columnName=="bidVol" || m_columnName=="askVol")
     {
      m_text.TextColor(clrWhite);
      //m_text.TextColor(clrBlack);
     }
   else
      if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
        {
         if(m_columnName=="buyerVol")
            m_text.TextColor(clrBlue);
         else
            m_text.TextColor(clrRed);
        }
      else
         if(m_columnName=="price" || m_columnName=="pricePercentage")
            m_text.TextColor(C'240, 240, 240');
         else
            if(m_columnName=="volume")
              {
               m_text.TextColor(clrWhite);
              }
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

   long min_volume = (ArraySize(MarketBook.MarketBook)!=0)?MarketBook.MarketBook[0].volume:0;
   for(int i=1; i<ArraySize(MarketBook.MarketBook); i++)
     {
      if(min_volume > MarketBook.MarketBook[i].volume)
        {
         min_volume = MarketBook.MarketBook[i].volume;
        }
     }

   int pendingVolumeMinB=0;
   int pendingVolumeMinH=0;
   int pendingVolumeMinK=0;
   int pendingVolumeMinM=0;
   int pendingVolumeMaxB=0;
   int pendingVolumeMaxK=0;
   int pendingVolumeMaxH=0;
   int pendingVolumeMaxM=0;

   for(int i=0; i<ArraySize(MarketBook.MarketBook); i++)
     {
      int vol = MarketBook.MarketBook[i].volume;
      int legnth = StringLen(vol);

      if(legnth<=6 && legnth>3)
        {
         if(pendingVolumeMaxK < vol)
           {
            pendingVolumeMaxK = vol;
           }
         else
            if(pendingVolumeMinK > vol)
              {
               pendingVolumeMinK = vol;
              }
        }
      else
         if(legnth<=9 && legnth>6)
           {
            if(pendingVolumeMaxM < vol)
              {
               pendingVolumeMaxM = vol;
              }
            else
               if(pendingVolumeMinM > vol)
                 {
                  pendingVolumeMinM = vol;
                 }
           }
         else
            if(legnth>9 && legnth<=12)
              {
               if(pendingVolumeMaxB < vol)
                 {
                  pendingVolumeMaxB = vol;
                 }
               else
                  if(pendingVolumeMinB > vol)
                    {
                     pendingVolumeMinB = vol;
                    }
              }
            else
               if(legnth <=3)
                 {
                  if(pendingVolumeMaxH < vol)
                    {
                     pendingVolumeMaxH = vol;
                    }
                  else
                     if(pendingVolumeMinH > vol)
                       {
                        pendingVolumeMinH = vol;
                       }
                 }
     }


   if(minMaxStruct.pendingVolume.maxK < pendingVolumeMaxK || minMaxStruct.pendingVolume.maxK == previousVolumeMaxK)
     {
      minMaxStruct.pendingVolume.maxK = pendingVolumeMaxK;
      previousVolumeMaxK = pendingVolumeMaxK;
     }

   if(minMaxStruct.pendingVolume.minK > pendingVolumeMinK || minMaxStruct.pendingVolume.minK == previousVolumeMinK)
     {
      minMaxStruct.pendingVolume.minK = pendingVolumeMinK;
      previousVolumeMinK = pendingVolumeMinK;
     }

   if(minMaxStruct.pendingVolume.minM > pendingVolumeMinM || minMaxStruct.pendingVolume.minM == previousVolumeMinM)
     {
      minMaxStruct.pendingVolume.minM = pendingVolumeMinM;
      previousVolumeMinM = pendingVolumeMinM;
     }

   if(minMaxStruct.pendingVolume.maxM < pendingVolumeMaxM || minMaxStruct.pendingVolume.maxM == previousVolumeMaxM)
     {
      minMaxStruct.pendingVolume.maxM = pendingVolumeMaxM;
      previousVolumeMaxM = pendingVolumeMaxM;
     }

   if(minMaxStruct.pendingVolume.maxB < pendingVolumeMaxB || minMaxStruct.pendingVolume.maxB == previousVolumeMaxB)
     {
      minMaxStruct.pendingVolume.maxB = pendingVolumeMaxB;
      previousVolumeMaxB = pendingVolumeMaxB;
     }

   if(minMaxStruct.pendingVolume.minB > pendingVolumeMinB || minMaxStruct.pendingVolume.minB == previousVolumeMinB)
     {
      minMaxStruct.pendingVolume.minB = pendingVolumeMinB;
      previousVolumeMinB = pendingVolumeMinB;
     }

   if(minMaxStruct.pendingVolume.minH > pendingVolumeMinH || minMaxStruct.pendingVolume.minH == previousVolumeMinH)
     {
      minMaxStruct.pendingVolume.minH = pendingVolumeMinH;
      previousVolumeMinH = pendingVolumeMinH;
     }

   if(minMaxStruct.pendingVolume.maxH < pendingVolumeMaxH || minMaxStruct.pendingVolume.maxH == previousVolumeMaxH)
     {
      minMaxStruct.pendingVolume.maxH = pendingVolumeMaxH;
      previousVolumeMaxH = pendingVolumeMaxH;
     }

   string volume = SetText(DoubleToString(info.price,Digits()), DoubleToString(m_pricePercentage,2), (info.volume==ULONG_MAX)?" ":(string)info.volume, info.type);
   SetCellColor(volume, info.type);
   SetWidth(volume, info.volume, info.type);
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


   string volume = SetText(DoubleToString(m_price,Digits()), DoubleToString(m_pricePercentage,2), (m_volume==ULONG_MAX)?" ":(string)m_volume, type);
   SetCellColor(volume, type);
   SetWidth(volume, m_volume, type);

  }
//+------------------------------------------------------------------+
string CBookCell::SetText(string price, string pricePercentage, string volume, int type)
  {
   string showingVolume = ConvertVolumeToString(volume);

   if(m_cell_type==BOOK_PRICE || m_cell_type==2)
     {
      if(m_cell_type==BOOK_PRICE && price!="-1")
         m_text.Text(price);
      else
         if(m_cell_type==2 && pricePercentage!="-1.00")
            m_text.Text(pricePercentage);
         else
            m_text.Text(" ");
     }
   else
      if(m_cell_type==BOOK_VOLUME)
        {
         if((type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET) && (m_columnName=="askVol"))
           {
            //m_text.Text(showingVolume);
            m_text.Text(volume);
           }
         else
            if((type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET) && (m_columnName=="bidVol"))
              {
               //m_text.Text(showingVolume);
               m_text.Text(volume);
              }
            else
               if((m_columnName=="sellerVol" || m_columnName=="buyerVol" || m_columnName == "volume") && m_volume!=-1)
                 {
                  //m_text.Text(ConvertVolumeToString((string)m_volume));
                  showingVolume = ((string)m_volume);
                  m_text.Text((string)m_volume);
                 }
               else
                  m_text.Text(" ");
        }

   return showingVolume;
  }
//+------------------------------------------------------------------+
void CBookCell::SetWidth(string showingVolume, string tempVolume, int type)
  {
   float width;

   string text[2];
   StringSplit(tempVolume, ' ', text);

   double volume = StringToDouble(text[0]);

   if(StringCompare(m_text.Text(), " ")==0 || StringCompare(m_text.Text(), "0")==0)
     {
      width=10;
     }
      else
         if(m_columnName=="price")
           {
            width=100;
           }
         else
            if(m_columnName=="pricePercentage")
              {
               width=50;
              }
            else
               if(m_columnName=="volume")
                 {
                  if((minMaxStruct.totalVolume.minK != 0 || minMaxStruct.totalVolume.maxK != 0) && (minMaxStruct.totalVolume.maxK - minMaxStruct.totalVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                    {
                     width = ((volume - minMaxStruct.totalVolume.minK) / (minMaxStruct.totalVolume.maxK - minMaxStruct.totalVolume.minK)) * 100;
                    }
                  else
                     if((minMaxStruct.totalVolume.minM != 0 || minMaxStruct.totalVolume.maxM != 0) && (minMaxStruct.totalVolume.maxM - minMaxStruct.totalVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                       {
                        width = ((volume - minMaxStruct.totalVolume.minM) / (minMaxStruct.totalVolume.maxM - minMaxStruct.totalVolume.minM)) * 100;
                       }
                     else
                        if((minMaxStruct.totalVolume.minB != 0 || minMaxStruct.totalVolume.maxB != 0) && (minMaxStruct.totalVolume.maxB - minMaxStruct.totalVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                          {
                           width = ((volume - minMaxStruct.totalVolume.minB) / (minMaxStruct.totalVolume.maxB - minMaxStruct.totalVolume.minB)) * 100;
                          }
                        else
                           if((minMaxStruct.totalVolume.minH != 0 || minMaxStruct.totalVolume.maxH != 0) && (minMaxStruct.totalVolume.maxH - minMaxStruct.totalVolume.minH>0))
                             {
                              width = ((volume - minMaxStruct.totalVolume.minH) / (minMaxStruct.totalVolume.maxH - minMaxStruct.totalVolume.minH)) * 100;
                             }
                           else
                              width = 40;

                  //width = (volume / maxVolume) * 100;
                  //width = ((volume - minVolume) / (maxVolume - minVolume)) * 100;
                  //width = ((volume - minVolume) / (maxVolume - minVolume)) * 60 + 40;
                 }
               else
                  if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
                    {

                     if((minMaxStruct.buyerSellerVolume.minK != 0 || minMaxStruct.buyerSellerVolume.maxK != 0) && (minMaxStruct.buyerSellerVolume.maxK - minMaxStruct.buyerSellerVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                       {
                        width = ((volume - minMaxStruct.buyerSellerVolume.minK) / (minMaxStruct.buyerSellerVolume.maxK - minMaxStruct.buyerSellerVolume.minK)) * 100;
                       }
                     else
                        if((minMaxStruct.buyerSellerVolume.minM != 0 || minMaxStruct.buyerSellerVolume.maxM != 0) && (minMaxStruct.buyerSellerVolume.maxM - minMaxStruct.buyerSellerVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                          {
                           width = ((volume - minMaxStruct.buyerSellerVolume.minM) / (minMaxStruct.buyerSellerVolume.maxM - minMaxStruct.buyerSellerVolume.minM)) * 100;
                          }
                        else
                           if((minMaxStruct.buyerSellerVolume.minB != 0 || minMaxStruct.buyerSellerVolume.maxB != 0) && (minMaxStruct.buyerSellerVolume.maxB - minMaxStruct.buyerSellerVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                             {
                              width = ((volume - minMaxStruct.buyerSellerVolume.minB) / (minMaxStruct.buyerSellerVolume.maxB - minMaxStruct.buyerSellerVolume.minB)) * 100;
                             }
                           else
                              if((minMaxStruct.buyerSellerVolume.minH != 0 || minMaxStruct.buyerSellerVolume.maxH != 0) && (minMaxStruct.buyerSellerVolume.maxH - minMaxStruct.buyerSellerVolume.minH>0))
                                {
                                 width = ((volume - minMaxStruct.buyerSellerVolume.minH) / (minMaxStruct.buyerSellerVolume.maxH - minMaxStruct.buyerSellerVolume.minH)) * 100;
                                }
                              else
                                 width = 40;

                     //width = (volume / maxBuyerSellerVolume) * 100;
                     //width = ((volume - minBuyerSellerVolume) / (maxBuyerSellerVolume - minBuyerSellerVolume)) * 100;
                     //width = ((volume - minBuyerSellerVolume) / (maxBuyerSellerVolume - minBuyerSellerVolume)) * 60 + 40;
                    }
                  else
                     if(m_columnName=="bidVol" || m_columnName=="askVol")
                       {
                        if((minMaxStruct.pendingVolume.minK != 0 || minMaxStruct.pendingVolume.maxK != 0) && (minMaxStruct.pendingVolume.maxK - minMaxStruct.pendingVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                          {
                           width = ((volume - minMaxStruct.pendingVolume.minK) / (minMaxStruct.pendingVolume.maxK - minMaxStruct.pendingVolume.minK)) * 100;
                          }
                        else
                           if((minMaxStruct.pendingVolume.maxM != 0 || minMaxStruct.pendingVolume.minM != 0) && (minMaxStruct.pendingVolume.maxM - minMaxStruct.pendingVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                             {
                              width = ((volume - minMaxStruct.pendingVolume.minM) / (minMaxStruct.pendingVolume.maxM - minMaxStruct.pendingVolume.minM)) * 100;
                             }
                           else
                              if((minMaxStruct.pendingVolume.minB != 0 || minMaxStruct.pendingVolume.maxB != 0) && (minMaxStruct.pendingVolume.maxB - minMaxStruct.pendingVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                                {
                                 width = ((volume - minMaxStruct.pendingVolume.minB) / (minMaxStruct.pendingVolume.maxB - minMaxStruct.pendingVolume.minB)) * 100;
                                }
                              else
                                 if((minMaxStruct.pendingVolume.minH != 0 || minMaxStruct.pendingVolume.maxH != 0) && (minMaxStruct.pendingVolume.maxH - minMaxStruct.pendingVolume.minH>0))
                                   {
                                    width = ((volume - minMaxStruct.pendingVolume.minH) / (minMaxStruct.pendingVolume.maxH - minMaxStruct.pendingVolume.minH)) * 100;
                                   }
                                 else
                                    width = 40;

                        //width = (volume / 999) * 100;
                        //width = ((volume - minPendingVolume) / (maxPendingVolume - minPendingVolume)) * 100;
                        //width = ((volume - minPendingVolume) / (maxPendingVolume - minPendingVolume)) * 60 + 40;

                       }
   
   /*
   if(width!=10 && width!=0 && (m_columnName=="bidVol" || m_columnName=="askVol"))
     {
      if(width<30)
        {
            m_text.TextColor(C'150,150,150');
            m_text.BackgroundColor(clrCyan);
        }
      else
         m_text.TextColor(clrWhite);
     }
   */
   
   Width(width);
  }
//+------------------------------------------------------------------+
void CBookCell::SetCellColor(string text, int type)
  {
   if(m_columnName=="price" || m_columnName=="pricePercentage")
     {
      BackgroundColor(C'128,  128, 128');
     }
   else
      if(m_columnName=="sellerVol" || m_columnName=="buyerVol")
        {
         BackgroundColor(C'216,  216, 216');
        }
      else
         if(m_columnName == "volume")
           {
            BackgroundColor(C'212,  104, 29');
           }
         else if(StringCompare(m_text.Text(), " ")==0)
         {
            if(m_columnName=="bidVol")
                 {
                  BackgroundColor("0,0,100");
                  //m_text.TextColor(clrWhite);
                 }
               else
                  if(m_columnName=="askVol")
                    {
                     BackgroundColor("100,0,0");
                     //m_text.TextColor(C'150, 150, 150');
                    }
         }  
         else
            if(StringFind(text, " K") != -1)
              {
               if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                 {
                  BackgroundColor("0,0,120");
                  //m_text.TextColor(clrWhite);
                 }
               else
                  if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                    {
                     BackgroundColor("120,0,0");
                     //m_text.TextColor(C'150, 150, 150');
                    }
              }
            else
               if(StringFind(text, " M") != -1)
                 {
                  if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                    {
                     BackgroundColor("0,0,220");
                     //m_text.TextColor(C'250, 250, 250');
                    }
                  else
                     if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                       {
                        BackgroundColor("220,0,0");
                        //m_text.TextColor(C'250, 250, 250');
                       }
                 }

               else
                  if(StringFind(text, " B") != -1)
                    {
                     if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                        BackgroundColor("0,0,250");
                     else
                        if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                           BackgroundColor("250,0,0");
                    }
                  else
                    {
                     if(type==BOOK_TYPE_BUY || type==BOOK_TYPE_BUY_MARKET)
                       {
                        BackgroundColor(C'0,0,100');
                        //m_text.TextColor(C'50, 50, 50');
                       }
                     else
                        if(type==BOOK_TYPE_SELL || type==BOOK_TYPE_SELL_MARKET)
                          {
                           BackgroundColor(C'100,0,0');
                           //m_text.TextColor(C'50, 50, 50');
                          }
                    }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CBookCell::ConvertVolumeToString(string volume)
  {
   string showingVolume;
//showingVolume=volume;

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
               showingVolume = volume + " ";
              }

   string text[2];
   StringSplit(showingVolume, ' ', text);
   int textLength = StringLen(text[0]);
   string numberOfDigit;

   string firstNumber="";
   string secondNumber="";
   string thirdNumber="";

   firstNumber = StringSubstr(text[0], 0, 1);

   if(textLength>=2)
      secondNumber = StringSubstr(text[0], 1, 1);

   if(textLength==3)
      thirdNumber = StringSubstr(text[0], 2, 1);

   switch(textLength)
     {
      case 3:
         if(StringToInteger(StringSubstr(volume, 3, 1))>=5)
           {
            int temp = StringToInteger(thirdNumber)+1;
            if(temp==10)
              {
               thirdNumber = "0";
               temp = StringToInteger(secondNumber)+1;

               if(temp==10)
                 {
                  secondNumber="0";
                  temp = IntegerToString(StringToInteger(firstNumber)+1);

                  if(temp==10)
                    {
                     text[0]="1";

                     if(StringCompare(text[1]," K")==0)
                       {
                        text[1]=" M";
                       }
                     else
                        if(StringCompare(text[1]," M")==0)
                          {
                           text[1]=" B";
                          }
                        else
                           if(StringCompare(text[1]," ")==0)
                             {
                              text[1]=" K";
                             }
                    }
                 }
               else
                 {
                  secondNumber = IntegerToString(temp);
                 }
              }
            else
              {
               thirdNumber = IntegerToString(temp);
              }
           }

         text[0] = firstNumber+secondNumber+thirdNumber;
         break;
      case 2:
         if(StringToInteger(StringSubstr(volume, 2, 1))>=5)
           {
            int temp = StringToInteger(secondNumber)+1;
            if(temp==10)
              {
               secondNumber = "0";
               temp = IntegerToString(StringToInteger(firstNumber)+1);

               if(temp==10)
                 {
                  text[0]="1";

                  if(StringCompare(text[1]," K")==0)
                    {
                     text[1]=" M";
                    }
                  else
                     if(StringCompare(text[1]," M")==0)
                       {
                        text[1]=" B";
                       }
                     else
                        if(StringCompare(text[1]," ")==0)
                          {
                           text[1]=" K";
                          }

                 }
               else
                 {
                  firstNumber = IntegerToString(temp);
                 }
              }
            else
              {
               secondNumber = IntegerToString(temp);
              }
           }
         text[0] = firstNumber+secondNumber;
         break;
      case 1:
         if(StringToInteger(StringSubstr(volume, 1, 1))>=5)
           {
            int temp = StringToInteger(firstNumber)+1;
            if(temp==10)
              {
               text[0]="1";

               if(StringCompare(text[1]," K")==0)
                 {
                  text[1]=" M";
                 }
               else
                  if(StringCompare(text[1]," M")==0)
                    {
                     text[1]=" B";
                    }
                  else
                     if(StringCompare(text[1]," ")==0)
                       {
                        text[1]=" K";
                       }
              }
            else
              {
               firstNumber = IntegerToString(temp);
              }

            text[0] = firstNumber;
            break;
           }

     }
   showingVolume = text[0] +  " " + text[1];

   return showingVolume;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
