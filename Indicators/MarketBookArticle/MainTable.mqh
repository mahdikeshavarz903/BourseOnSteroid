//+------------------------------------------------------------------+
//|                                                    MainTable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Arrays\ArrayObj.mqh>
#include "MBookCell.mqh"

const int VOLUME_COLUMN=0;
const int PRICE_COLUMN=1;
const int PRICE_PERCENTAGE_COLUMN=2;
const int BID_COLUMN=3;
const int SELLER_COLUMN=4;
const int BUYER_COLUMN=5;
const int ASK_COLUMN=6;
const int TOTAL_COLUMN=7;
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
public:
                     CMainTable(double pricePercentage);
   void              SetBookCell(CBookCell &bookCell, int index);
   void              GetBookCell(CBookCell &bookCell, int index, double pricePercentage);

   void              SetCoordinate(int xCoordinate, int yCoordinate)
     {
      m_xCoordinate = xCoordinate;
      m_yCoordinate = yCoordinate;
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
  };
//+------------------------------------------------------------------+
CMainTable::CMainTable(double pricePercentage)
  {
   string str[] = {"volume", "price", "pricePercentage", "bidVol", "sellerVol", "buyerVol", "askVol"};

   for(int i=0; i<TOTAL_COLUMN; i++)
     {
      CBookCell *bookCell;

      if(i==1)
            bookCell = new CBookCell(0, 0, 0, 0.0, 0, str[i]);
         else
            if(i==2)
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
         string str[] = {"volume", "price", "pricePercentage", "bidVol", "sellerVol", "buyerVol", "askVol"};

         CBookCell *newBookCell;
         if(index==1)
            newBookCell = new CBookCell(0, 0, 0, 0.0, 0, str[index]);
         else
            if(index==2)
               newBookCell = new CBookCell(2, 0, 0, pricePercentage, 0, str[index]);
            else
               newBookCell = new CBookCell(1, 0, 0, 0, 0, str[index]);

         SetBookCell(newBookCell, index);

         bookCell = GetPointer(newBookCell);
        }
     }

  }
//+------------------------------------------------------------------+
