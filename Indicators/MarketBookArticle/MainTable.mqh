//+------------------------------------------------------------------+
//|                                                    MainTable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Arrays\ArrayObj.mqh>
#include "MBookCell.mqh"

const int LOSS_PROFIT_COLUMN=0;
const int VOLUME_COLUMN=1;
const int PRICE_COLUMN=2;
const int PRICE_PERCENTAGE_COLUMN=3;
const int SNAPSHOT_BID_COLUMN=4;
const int BID_COLUMN=5;
const int SELLER_COLUMN=6;
const int BUYER_COLUMN=7;
const int ASK_COLUMN=8;
const int SNAPSHOT_ASK_COLUMN=9;

const int TOTAL_COLUMN=10;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMainTable
  {
private:
   CArrayObj         m_bookCell;
   int               m_xCoordinate;
   int               m_yCoordinate;
   int               m_volume;
   double            m_price;
   double            m_pricePercentage;
   int               m_sellerVol;
   int               m_buyerVol;
   int               m_domRowId;
   int               m_type;
   int               m_bidVol;
   int               m_askVol;
   int               m_snapshotBid;
   int               m_snapshotAsk;
   string            m_lossProfit;
public:
                     CMainTable(double pricePercentage);
   void              SetBookCell(CBookCell &bookCell, int index);
   void              GetBookCell(CBookCell &bookCell, int index, double pricePercentage);

   void              SetSnapshotBid(int snapshotBid)
     {
      m_snapshotBid = snapshotBid;
     }

   int               GetSnapshotBid()
     {
      return m_snapshotBid;
     }

   void              SetSnapshotAsk(int snapshotAsk)
     {
      m_snapshotAsk = snapshotAsk;
     }

   void              SetCoordinate(int xCoordinate, int yCoordinate)
     {
      m_xCoordinate = xCoordinate;
      m_yCoordinate = yCoordinate;
     }

   int               GetSnapshotAsk()
     {
      return m_snapshotAsk;
     }

   int               GetXCoordinate()
     {
      return m_xCoordinate;
     }

   int               GetYCoordinate()
     {
      return m_yCoordinate;
     }

   void              SetVolume(int vol)
     {
      m_volume = vol;
     }

   int               GetVolume()
     {
      return m_volume;
     }

   void              SetPrice(double price)
     {
      m_price = price;
     }

   int               GetPrice()
     {
      return m_price;
     }

   void              SetPricePercentage(double pricePercentage)
     {
      m_pricePercentage = pricePercentage;
     }

   double               GetPricePercentage()
     {
      return m_pricePercentage;
     }

   void              SetSellerVolume(int sellerVol)
     {
      m_sellerVol = sellerVol;
     }

   int               GetSellerVolume()
     {
      return m_sellerVol;
     }

   void              SetBuyerVolume(int buyerVol)
     {
      m_buyerVol = buyerVol;
     }

   int               GetBuyerVolume()
     {
      return m_buyerVol;
     }

   void              SetDomRowId(int domRowId)
     {
      m_domRowId = domRowId;
     }

   int               GetDomRowId()
     {
      return m_domRowId;
     }

   void              SetType(int type)
     {
      m_type = type;
     }

   int               GetType()
     {
      return m_type;
     }

   void              SetBidVolume(int bidVolume)
     {
      m_bidVol = bidVolume;
     }

   int               GetBidVolume()
     {
      return m_bidVol;
     }

   void              SetAskVolume(int askVol)
     {
      m_askVol = askVol;
     }

   int               GetAskVolume()
     {
      return m_askVol;
     }

   void              SetLossProfit(string lossProfit)
     {
      m_lossProfit = lossProfit;
     }

   string               GetLossProfit()
     {
      return m_lossProfit;
     }
  };
//+------------------------------------------------------------------+
CMainTable::CMainTable(double pricePercentage)
  {
   string str[] = {"lossProfit", "volume", "price", "pricePercentage", "snapshotBid", "bidVol", "sellerVol", "buyerVol", "askVol", "snapshotAsk"};

   for(int i=0; i<TOTAL_COLUMN; i++)
     {
      CBookCell *bookCell;

      if(i==LOSS_PROFIT_COLUMN)
         bookCell = new CBookCell(3, 0, 0, "", 3, str[i]);
      else
         if(i==PRICE_COLUMN)
            bookCell = new CBookCell(0, 0, 0, 0.0, 0, str[i]);
         else
            if(i==PRICE_PERCENTAGE_COLUMN)
               bookCell = new CBookCell(2, 0, 0, pricePercentage, 0, str[i]);
            else
               bookCell = new CBookCell(1, 0, 0, 0, 0, str[i]);


      m_bookCell.Add(GetPointer(bookCell));

     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CMainTable::SetBookCell(CBookCell &bookCell, int index)
  {
   m_bookCell.Update(index, GetPointer(bookCell));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CMainTable::GetBookCell(CBookCell &bookCell, int index, double pricePercentage)
  {
   if(m_bookCell.Available())
     {
      CBookCell *cell = m_bookCell.At(index);

      if(CheckPointer(cell)!=POINTER_INVALID)
        {
         bookCell = GetPointer(cell);
        }
      else
        {
         string str[] = {"lossProfit", "volume", "price", "pricePercentage", "snapshotBid", "bidVol", "sellerVol", "buyerVol", "askVol", "snapshotAsk"};

         CBookCell *newBookCell;
         if(index==LOSS_PROFIT_COLUMN)
            newBookCell = new CBookCell(3, 0, 0, "0.00", 0, str[index]);
         else
            if(index==PRICE_COLUMN)
               newBookCell = new CBookCell(0, 0, 0, 0.0, 0, str[index]);
            else
               if(index==PRICE_PERCENTAGE_COLUMN)
                  newBookCell = new CBookCell(2, 0, 0, pricePercentage, 0, str[index]);
               else
                  newBookCell = new CBookCell(1, 0, 0, 0, 0, str[index]);

         SetBookCell(newBookCell, index);

         bookCell = GetPointer(newBookCell);
        }
     }

  }
//+------------------------------------------------------------------+
