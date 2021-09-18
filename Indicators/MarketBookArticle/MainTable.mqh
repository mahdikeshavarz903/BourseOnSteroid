//+------------------------------------------------------------------+
//|                                                    MainTable.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

#include <Arrays\ArrayObj.mqh>
#include "MBookCell.mqh"
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
   int               m_sellerVol;
   int               m_buyerVol;
   int               m_domRowId;
   int               m_type;
   int               m_bidVol;
   int               m_askVol;
public:
                     CMainTable();
   void              SetBookCell(CBookCell &bookCell, int index);
   void              GetBookCell(CBookCell &bookCell, int index);

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
CMainTable::CMainTable(void)
  {
      string str[] = {"volume", "price", "bidVol", "sellerVol", "buyerVol", "askVol"};
      
      for(int i=0;i<6;i++)
      {
         CBookCell *bookCell;
         
         if(i==1)
            bookCell = new CBookCell(0, 0,0,0,0, 0, str[i]);
         else
            bookCell = new CBookCell(1, 0,0,0,0, 0,str[i]);    
            
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
void  CMainTable::GetBookCell(CBookCell &bookCell, int index)
  {
   if(m_bookCell.Available())
     {
      CBookCell *cell = m_bookCell.At(index);
      bookCell = GetPointer(cell);
     }

  }
//+------------------------------------------------------------------+
