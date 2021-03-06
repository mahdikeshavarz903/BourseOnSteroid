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

/*
int WITDTH=100;
int HEIGHT=22;
int FONT_SIZE=10;
int WIDTH_MARGIN=12;
int WIDTH_PERCENTAGE_MARGIN=10;
*/

int WITDTH=70;
int HEIGHT=14;
int FONT_SIZE=8;
int WIDTH_MARGIN=8;
int WIDTH_PERCENTAGE_MARGIN=6;
//+------------------------------------------------------------------+
//| The class represents a cell of the order book.                   |
//+------------------------------------------------------------------+
class CBookCell : public CElChart
  {
private:
   long              m_ydist;
   long              m_ydistTemp;
   long              m_xdist;
   long              m_xdistTemp;
   int               m_index;
   int               m_cell_type;
   int               m_buyOrSellType;
   string            m_lossProfit;
   int               m_positiveOrNegative;
   CElChart          m_text;
   CMarketBook       *m_book;
   double            m_price;
   double            m_pricePercentage;
   int               m_volume;
   string            m_columnName;
   void              SetBackgroundColor();
   void              SetBackgroundColor2(void);
public:
   void              CBookCell();
                     CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName, double pricePercentage);
                     CBookCell(int type,long x_dist,long y_dist, double price, int buyOrSellType, string columnName);
                     CBookCell(int type,long x_dist,long y_dist, int volume, int buyOrSellType, string columnName);
                     CBookCell(int type,long x_dist,long y_dist, string lossProfit, int positiveOrNegative, string columnName);
   void              SetVariables(int type, long x_dist,long y_dist,double price, int buyOrSellType);
   void              SetVariables(int type, long x_dist,long y_dist, int volume,  int buyOrSellType);
   void              SetVariables(int type, long x_dist,long y_dist, string lossProfit,  int positiveOrNegative);
   string            ConvertVolumeToString(string volume);
   string            SetText(string price, string pricePercentage, string volume, int type);
   void              SetWidth(string showingVolume,  string tempVolume, int type);
   void              SetCellColor(string text, int type);
   string            CommaSeparator(string value);
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
CBookCell::CBookCell(int type,long x_dist,long y_dist,int index_mbook,CMarketBook *book, string columnName, double pricePercentage) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(HEIGHT);
   Width(WITDTH);
   BorderType(BORDER_RAISED);
   BorderColor(clrRed);

   m_index=index_mbook;
   m_book=book;
   m_cell_type=type;

   if(type==2)
      m_pricePercentage = pricePercentage;

   m_buyOrSellType = (book.MarketBook[m_index].type==BOOK_TYPE_SELL)?0:1;

   m_columnName = columnName;

   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;

   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_text.Height(HEIGHT);
   m_text.Width(WITDTH);
   m_text.Align(ALIGN_RIGHT);

   if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
     {
      m_text.TextColor(clrWhite);
     }
   else
      if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
        {
         if(m_columnName=="buyerVol")
            m_text.TextColor(C'83, 91, 237');
         else
            m_text.TextColor(C'237, 83, 82');
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

   m_text.TextSize(FONT_SIZE);
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
   Height(HEIGHT);
   Width(WITDTH);
   BorderType(BORDER_RAISED);
   BorderColor(clrRed);
   Align(ALIGN_RIGHT);

   if(type==2)
      m_pricePercentage=price;
   else
      m_price=price;

   m_cell_type=type;
   m_buyOrSellType = buyOrSellType;

   m_columnName = columnName;
   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;

   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_text.Height(HEIGHT);
   m_text.Width(WITDTH);
   m_text.Align(ALIGN_RIGHT);

   if(m_columnName=="price" || m_columnName=="pricePercentage")
      m_text.TextColor(C'240, 240, 240');
   else
      m_text.TextColor(clrBlack);

   m_text.TextSize(FONT_SIZE);
//m_text.BorderType(BORDER_FLAT);
   m_text.TextFont("Consolas");
   m_elements.Add(GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
CBookCell::CBookCell(int type,long x_dist,long y_dist, int volume, int buyOrSellType, string columnName) : CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(HEIGHT);
   Width(WITDTH);
   BorderType(BORDER_RAISED);
   BorderColor(clrRed);
   Align(ALIGN_RIGHT);

   m_volume=volume;
   m_cell_type=type;
   m_buyOrSellType = buyOrSellType;
   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;
   m_columnName = columnName;

   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_text.Height(HEIGHT);
   m_text.Width(WITDTH);
   m_text.Align(ALIGN_RIGHT);

   if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
     {
      m_text.TextColor(clrWhite);
     }
   else
      if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
        {
         if(m_columnName=="buyerVol")
            m_text.TextColor(C'83, 91, 237');
         else
            m_text.TextColor(C'237, 83, 82');
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

   m_text.TextSize(FONT_SIZE);
   m_text.TextFont("Consolas");
//m_text.BorderType(BORDER_FLAT);
   m_elements.Add(GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
CBookCell::CBookCell(int type,long x_dist,long y_dist, string lossProfit, int positiveOrNegative, string columnName) :
   CElChart(OBJ_RECTANGLE_LABEL),
   m_text(OBJ_LABEL)
  {
   XCoord(x_dist);
   YCoord(y_dist);
   Height(HEIGHT);
   Width(WITDTH);
   BorderType(BORDER_RAISED);
   BorderColor(clrRed);
   Align(ALIGN_CENTER);
   BackgroundColor(C'1, 43, 55');

   m_lossProfit = lossProfit;

   m_cell_type=type;
   m_positiveOrNegative = positiveOrNegative;

   m_columnName = columnName;
   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;

   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_text.Height(HEIGHT);
   m_text.Width(WITDTH);

   if(m_columnName=="lossProfit")
     {
      if(m_positiveOrNegative==1)
         m_text.TextColor(C'80, 113, 239');
      else
         if(m_positiveOrNegative==2)
            m_text.TextColor(C'239, 80, 95');
         else
            if(m_positiveOrNegative==3)
               m_text.TextColor(C'200, 200, 200');
            else
               m_text.TextColor(C'1, 43, 55');

      m_text.TextSize(FONT_SIZE);
     }
   else
     {
      m_text.TextColor(clrWhite);
      m_text.TextSize(14);
     }

   m_text.TextFont("Consolas");
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
   Align(ALIGN_RIGHT);

   if(type==2)
      m_pricePercentage=price;
   else
      m_price=price;

   m_cell_type = type;

   m_buyOrSellType = buyOrSellType;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;
   m_text.Align(ALIGN_RIGHT);

   if(m_columnName=="price" || m_columnName=="pricePercentage")
      m_text.TextColor(C'240, 240, 240');
   else
      m_text.TextColor(clrBlack);

   m_elements.Update(0, GetPointer(m_text));
  }
//+------------------------------------------------------------------+
//  This is an overload function                                     |
//+------------------------------------------------------------------+
void CBookCell::SetVariables(int type, long x_dist,long y_dist, int volume,  int buyOrSellType)
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
   Align(ALIGN_RIGHT);

   m_volume=volume;
   m_cell_type = type;

   m_buyOrSellType = buyOrSellType;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_text.Align(ALIGN_RIGHT);
   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;

   if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
     {
      m_text.TextColor(clrWhite);
     }
   else
      if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
        {
         if(m_columnName=="buyerVol")
            m_text.TextColor(C'83, 91, 237');
         else
            m_text.TextColor(C'237, 83, 82');
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
//  This is an overload function                                     |
//+------------------------------------------------------------------+
void CBookCell::SetVariables(int type, long x_dist,long y_dist, string lossProfit, int positiveOrNegative)
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
//Align(ALIGN_CENTER);

   m_lossProfit=lossProfit;

   m_cell_type = type;

   m_positiveOrNegative = positiveOrNegative;
   m_text.XCoord(x_dist);
   m_text.YCoord(y_dist);
   m_xdistTemp = x_dist;
   m_ydistTemp = y_dist;
   m_text.Align(ALIGN_CENTER);

   if(m_columnName=="lossProfit")
     {
      if(m_positiveOrNegative==1)
         m_text.TextColor(C'80, 113, 239');
      else
         if(m_positiveOrNegative==2)
            m_text.TextColor(C'239, 80, 95');
         else
            if(m_positiveOrNegative==3)
               m_text.TextColor(C'200, 200, 200');
            else
               m_text.TextColor(C'1, 43, 55');
     }
   else
      m_text.TextColor(clrWhite);

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

   if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="pricePercentage" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
      type=(m_buyOrSellType==0)?0:(m_buyOrSellType==1)?1:-5;
   else
      if(m_columnName=="sellerVol" || m_columnName=="buyerVol")
         type=-2;
      else
         if(m_columnName=="price")
            type=-3;
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
   int priceLength = StringLen(price);

   int volLength = StringLen(volume);
   int pricePercentageLength = StringLen(pricePercentage);
   int lossProfitLength = StringLen(m_lossProfit);

   string showingVolume = ConvertVolumeToString(volume);


   string temp = "";
   uchar str[];
   StringToCharArray(m_lossProfit, str);

   for(int i=lossProfitLength; i>0; i-=3)
     {
      temp = StringSubstr(m_lossProfit, (i-3>=0)?i-3:0, (i-3>=0)?3:i) + ((temp!="" && str[i-1]!= '-')?",":"") + temp;
     }
   m_lossProfit = temp;

   temp = "";
   StringToCharArray(IntegerToString(volume), str);
   for(int i=volLength; i>0; i-=3)
     {
      temp = StringSubstr(volume, (i-3>=0)?i-3:0, (i-3>=0)?3:i) + ((temp!="" && str[i-1]!= '-')?",":"") + temp;
     }
   volume = temp;

   temp = "";
   StringToCharArray(price, str);
   for(int i=priceLength; i>0; i-=3)
     {
      temp = StringSubstr(price, (i-3>=0)?i-3:0, (i-3>=0)?3:i) + ((temp!="" && str[i-1]!= '-')?",":"") + temp;
     }
   price = temp;

   if(m_cell_type==4)
     {
      if(m_columnName=="bidsPower" || m_columnName=="buyerPower" ||
         m_columnName=="snapshotBidsPower" || m_columnName=="lowestPricePower")
        {
         m_text.YCoord(YCoord()- 18 * lossProfitLength);
        }

      m_text.XCoord(m_text.XCoord()+28);
      m_text.BorderType(BORDER_RAISED);
      m_text.BorderColor(clrRed);
      m_text.SetAngle(-90);
      m_text.Text((m_lossProfit!=NULL && m_lossProfit!="")?m_lossProfit:" ");
     }
   else
      if(m_cell_type==3)
        {
         m_text.Text((m_lossProfit!=NULL && m_lossProfit!="")?m_lossProfit:" ");
         m_text.XCoord(m_xdistTemp - WIDTH_MARGIN * lossProfitLength);
        }
      else
         if(m_cell_type==BOOK_PRICE || m_cell_type==2)
           {
            if(m_cell_type==BOOK_PRICE && price!="-1")
              {
               m_text.Text(price);
               m_text.XCoord(m_xdistTemp - WIDTH_MARGIN * priceLength);
              }
            else
               if(m_cell_type==2)
                 {
                  double priceP = StringToDouble(pricePercentage);

                  if(priceP<0)
                     priceP=-priceP;

                  if(priceP==0)
                     BackgroundColor("200,  200, 200");
                  else
                    {
                     int colorValue = ((double) priceP/ 5) * (255 - 50) + 50;

                     if(type==0)
                        BackgroundColor(colorValue + ",  0, 0");
                     else
                        if(type==1)
                           BackgroundColor("0,  0, " + colorValue);
                        else
                           if(type==-5)
                              BackgroundColor("200,  200, 200");
                    }


                  m_text.Text(pricePercentage);
                  m_text.XCoord(m_xdistTemp - WIDTH_PERCENTAGE_MARGIN * pricePercentageLength);
                 }
           }
         else
            if(m_cell_type==BOOK_VOLUME)
              {
               if(type==0 && m_columnName=="askVol")
                 {
                  m_text.Text((volume=="0")?" ": volume);
                  m_text.XCoord(m_xdistTemp - WIDTH_MARGIN * volLength);
                 }
               else
                  if(type==1 && m_columnName=="bidVol")
                    {
                     m_text.Text((volume=="0")?" ": volume);
                     m_text.XCoord(m_xdistTemp - WIDTH_MARGIN * volLength);
                    }
                  else
                     if(m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
                       {
                        m_text.Text((volume=="0")?" ": volume);
                        m_text.XCoord(m_xdistTemp - WIDTH_MARGIN * volLength);
                       }
                     else
                        if((m_columnName=="sellerVol" || m_columnName=="buyerVol" || m_columnName == "volume") && m_volume!=-1)
                          {
                           volLength = StringLen((string)m_volume);

                           temp = "";
                           for(int i=volLength; i>0; i-=3)
                             {
                              temp = StringSubstr((string)m_volume, (i-3>=0)?i-3:0, (i-3>=0)?3:i) + ((temp!="")?",":"") + temp;
                             }

                           showingVolume = (ConvertVolumeToString((string)m_volume));
                           m_text.Text((temp=="0")?" ": temp);

                           m_text.XCoord(m_xdistTemp - WIDTH_MARGIN * volLength);
                          }
                        else
                          {
                           m_text.Text(" ");
                           m_text.XCoord(m_xdistTemp - WIDTH_MARGIN);
                          }
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


   if(m_columnName=="bidsPower" || m_columnName=="asksPower" ||
      m_columnName=="buyerPower" || m_columnName=="sellerPower" ||
      m_columnName=="snapshotAsksPower" || m_columnName=="snapshotBidsPower" ||
      m_columnName=="highestPricePower" || m_columnName=="lowestPricePower")
     {
      return;
     }
   else
      if(StringCompare(m_text.Text(), " ")==0)
        {
         width=10;
        }
      else
         if(StringCompare(m_text.Text(), "0")==0)
           {
            width=0;
           }
         else
            if(m_columnName=="lossProfit")
              {
               width=WITDTH+20;
              }
            else
               if(m_columnName=="price")
                 {
                  width=WITDTH;
                 }
               else
                  if(m_columnName=="pricePercentage")
                    {
                     width=WITDTH/2;
                    }
                  else
                     if(m_columnName=="volume")
                       {
                        if((minMaxStruct.totalVolume.maxK != 0) && (minMaxStruct.totalVolume.maxK - minMaxStruct.totalVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                          {
                           width = ((volume - minMaxStruct.totalVolume.minK) / (minMaxStruct.totalVolume.maxK - minMaxStruct.totalVolume.minK)) * WITDTH;
                          }
                        else
                           if((minMaxStruct.totalVolume.maxM != 0) && (minMaxStruct.totalVolume.maxM - minMaxStruct.totalVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                             {
                              width = ((volume - minMaxStruct.totalVolume.minM) / (minMaxStruct.totalVolume.maxM - minMaxStruct.totalVolume.minM)) * WITDTH;
                             }
                           else
                              if((minMaxStruct.totalVolume.maxB != 0) && (minMaxStruct.totalVolume.maxB - minMaxStruct.totalVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                                {
                                 width = ((volume - minMaxStruct.totalVolume.minB) / (minMaxStruct.totalVolume.maxB - minMaxStruct.totalVolume.minB)) * WITDTH;
                                }
                              else
                                 if((minMaxStruct.totalVolume.maxH != 0) && (minMaxStruct.totalVolume.maxH - minMaxStruct.totalVolume.minH>0))
                                   {
                                    width = ((volume - minMaxStruct.totalVolume.minH) / (minMaxStruct.totalVolume.maxH - minMaxStruct.totalVolume.minH)) * WITDTH;
                                   }
                                 else
                                    width = 40;
                       }
                     else
                        if(m_columnName=="buyerVol" || m_columnName=="sellerVol")
                          {

                           if((minMaxStruct.buyerSellerVolume.maxK != 0) && (minMaxStruct.buyerSellerVolume.maxK - minMaxStruct.buyerSellerVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                             {
                              width = ((volume - minMaxStruct.buyerSellerVolume.minK) / (minMaxStruct.buyerSellerVolume.maxK - minMaxStruct.buyerSellerVolume.minK)) * WITDTH;
                             }
                           else
                              if((minMaxStruct.buyerSellerVolume.maxM != 0) && (minMaxStruct.buyerSellerVolume.maxM - minMaxStruct.buyerSellerVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                                {
                                 width = ((volume - minMaxStruct.buyerSellerVolume.minM) / (minMaxStruct.buyerSellerVolume.maxM - minMaxStruct.buyerSellerVolume.minM)) * WITDTH;
                                }
                              else
                                 if((minMaxStruct.buyerSellerVolume.maxB != 0) && (minMaxStruct.buyerSellerVolume.maxB - minMaxStruct.buyerSellerVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                                   {
                                    width = ((volume - minMaxStruct.buyerSellerVolume.minB) / (minMaxStruct.buyerSellerVolume.maxB - minMaxStruct.buyerSellerVolume.minB)) * WITDTH;
                                   }
                                 else
                                    if((minMaxStruct.buyerSellerVolume.maxH != 0) && (minMaxStruct.buyerSellerVolume.maxH - minMaxStruct.buyerSellerVolume.minH>0))
                                      {
                                       width = ((volume - minMaxStruct.buyerSellerVolume.minH) / (minMaxStruct.buyerSellerVolume.maxH - minMaxStruct.buyerSellerVolume.minH)) * WITDTH;
                                      }
                                    else
                                       width = 40;
                          }
                        else
                           if(m_columnName=="bidVol" || m_columnName=="askVol")
                             {
                              if((minMaxStruct.pendingVolume.maxK != 0) && (minMaxStruct.pendingVolume.maxK - minMaxStruct.pendingVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                                {
                                 width = ((volume - minMaxStruct.pendingVolume.minK) / (minMaxStruct.pendingVolume.maxK - minMaxStruct.pendingVolume.minK)) * WITDTH;
                                }
                              else
                                 if((minMaxStruct.pendingVolume.maxM != 0) && (minMaxStruct.pendingVolume.maxM - minMaxStruct.pendingVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                                   {
                                    width = ((volume - minMaxStruct.pendingVolume.minM) / (minMaxStruct.pendingVolume.maxM - minMaxStruct.pendingVolume.minM)) * WITDTH;
                                   }
                                 else
                                    if((minMaxStruct.pendingVolume.maxB != 0) && (minMaxStruct.pendingVolume.maxB - minMaxStruct.pendingVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                                      {
                                       width = ((volume - minMaxStruct.pendingVolume.minB) / (minMaxStruct.pendingVolume.maxB - minMaxStruct.pendingVolume.minB)) * WITDTH;
                                      }
                                    else
                                       if((minMaxStruct.pendingVolume.maxH != 0) && (minMaxStruct.pendingVolume.maxH - minMaxStruct.pendingVolume.minH>0))
                                         {
                                          width = ((volume - minMaxStruct.pendingVolume.minH) / (minMaxStruct.pendingVolume.maxH - minMaxStruct.pendingVolume.minH)) * WITDTH;
                                         }
                                       else
                                          width = 40;

                             }
                           else
                              if(m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
                                {
                                 if(volume<0)
                                    width=10;
                                 else
                                    if((minMaxStruct.snapshotsVolume.maxK != 0) && (minMaxStruct.snapshotsVolume.maxK - minMaxStruct.snapshotsVolume.minK>0) && StringFind(showingVolume, " K") != -1)
                                      {
                                       width = ((volume - minMaxStruct.snapshotsVolume.minK) / (minMaxStruct.snapshotsVolume.maxK - minMaxStruct.snapshotsVolume.minK)) * WITDTH;
                                      }
                                    else
                                       if((minMaxStruct.snapshotsVolume.maxM != 0) && (minMaxStruct.snapshotsVolume.maxM - minMaxStruct.snapshotsVolume.minM>0) && StringFind(showingVolume, " M") != -1)
                                         {
                                          width = ((volume - minMaxStruct.snapshotsVolume.minM) / (minMaxStruct.snapshotsVolume.maxM - minMaxStruct.snapshotsVolume.minM)) * WITDTH;
                                         }
                                       else
                                          if((minMaxStruct.snapshotsVolume.maxB != 0) && (minMaxStruct.snapshotsVolume.maxB - minMaxStruct.snapshotsVolume.minB>0) && StringFind(showingVolume, " B") != -1)
                                            {
                                             width = ((volume - minMaxStruct.snapshotsVolume.minB) / (minMaxStruct.snapshotsVolume.maxB - minMaxStruct.snapshotsVolume.minB)) * WITDTH;
                                            }
                                          else
                                             if((minMaxStruct.snapshotsVolume.maxH != 0) && (minMaxStruct.snapshotsVolume.maxH - minMaxStruct.snapshotsVolume.minH>0))
                                               {
                                                width = ((volume - minMaxStruct.snapshotsVolume.minH) / (minMaxStruct.snapshotsVolume.maxH - minMaxStruct.snapshotsVolume.minH)) * WITDTH;
                                               }
                                             else
                                                width = 40;
                                }
   Width(-width);
  }
//+------------------------------------------------------------------+
void CBookCell::SetCellColor(string text, int type)
  {
   if(m_columnName=="pricePercentage")
     {
      return;
     }
   if(m_columnName=="price")
     {
      if(m_buyOrSellType==1)
         BackgroundColor("0,  0, " + 150);
      else
         if(m_buyOrSellType==0)
            BackgroundColor(150 + ",  0, 0");
         else
            if(m_buyOrSellType==-5)
               BackgroundColor("200,  200, 200");
     }
   else
      if(m_columnName=="sellerVol" || m_columnName=="buyerVol")
        {
         BackgroundColor(C'255,  255, 255');
         BorderColor(C'255,  255, 255');
         BorderType(BORDER_FLAT);
        }
      else
         if(StringCompare(m_text.Text(), " ")==0)
           {
            if(m_columnName=="bidVol" || m_columnName=="snapshotBid")
              {
               BackgroundColor("37,139,211");
              }
            else
               if(m_columnName=="askVol" || m_columnName=="snapshotAsk")
                 {
                  BackgroundColor("220,49,47");
                 }
               else
                  if(m_columnName=="volume")
                    {
                     BackgroundColor(C'220,  96, 11');
                    }
           }
         else
            if(StringFind(text, " K") != -1)
              {
               if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
                 {
                  if(type==1)
                    {
                     BackgroundColor("0,0,120");
                    }
                  else
                     if(type==0)
                       {
                        BackgroundColor("120,0,0");
                       }
                 }
               else
                  if(m_columnName=="volume")
                    {
                     BackgroundColor(C'212,  104, 29');
                    }
              }
            else
               if(StringFind(text, " M") != -1)
                 {
                  if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
                    {
                     if(type==1)
                       {
                        BackgroundColor("0,0,220");
                       }
                     else
                        if(type==0)
                          {
                           BackgroundColor("220,0,0");
                          }
                    }
                  else
                     if(m_columnName=="volume")
                       {
                        BackgroundColor(C'218,  147, 97');
                       }
                 }
               else
                  if(StringFind(text, " B") != -1)
                    {
                     if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
                       {
                        if(type==1)
                           BackgroundColor("0,0,250");
                        else
                           if(type==0)
                              BackgroundColor("250,0,0");
                       }
                     else
                        if(m_columnName=="volume")
                          {
                           BackgroundColor(C'216,  185, 163');
                          }
                    }
                  else
                    {
                     if(m_columnName=="bidVol" || m_columnName=="askVol" || m_columnName=="snapshotBid" || m_columnName=="snapshotAsk")
                       {
                        if(type==1)
                          {
                           BackgroundColor(C'0,0,100');
                          }
                        else
                           if(type==0)
                             {
                              BackgroundColor(C'100,0,0');
                             }
                       }
                     else
                        if(m_columnName=="volume")
                          {
                           BackgroundColor(C'220,  96, 11');
                          }
                    }
  }
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
//|                                                                  |
//+------------------------------------------------------------------+
string CBookCell::CommaSeparator(string value)
  {
   uchar str[];
   string temp = "";
   int valLength;

   valLength = StringLen(value);
   StringToCharArray(IntegerToString(value), str);

   for(int i=valLength; i>0; i-=3)
     {
      temp = StringSubstr(value, (i-3>=0)?i-3:0, (i-3>=0)?3:i) + ((temp!="" && str[i-1]!= '-')?",":"") + temp;
     }

   return temp;
  }
//+------------------------------------------------------------------+
