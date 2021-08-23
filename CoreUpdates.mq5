//+------------------------------------------------------------------+
//|                                                       client.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
/* ###################################################################

Example socket server.
Code can be used as both MQ4 and MQ5 (on both 32-bit and 64-bit MT5)

Receives messages from the example client and simply writes them
to the Experts log.

Also contains functionality for handling files sent by the example
file-sender script.

In addition, you can telnet into the server's port. Any CRLF-terminated
message you type is similarly printed to the Experts log. You
can also type in the commands "quote", to which the server reponds
with the current price of its chart, or "close", which causes the
server to shut down the connection.

As well as demonstrating server functionality, the use of Receive()
and the event-driven handling are also applicable to a client
which needs to receive data from the server as well as just sending it.

################################################################### */


#property strict

// --------------------------------------------------------------------
// Include socket library, asking for event handling
// --------------------------------------------------------------------

#define SOCKET_LIBRARY_USE_EVENTS
#include <socket-library-mt4-mt5.mqh>
#include <JAson.mqh>
// --------------------------------------------------------------------
// EA user inputs
// --------------------------------------------------------------------

input ushort   ServerPort = 63146;  // Server port


// --------------------------------------------------------------------
// Global variables and constants
// --------------------------------------------------------------------

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

// --------------------------------------------------------------------
// Initialisation - set up server socket
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
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


// --------------------------------------------------------------------
// Termination - free server socket and any clients
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   switch(reason)
     {
      case REASON_CHARTCHANGE:
         // Keep the server socket and all its clients if
         // the EA is going to be reloaded because of a
         // change to chart symbol or timeframe
         break;

      default:
         // For any other unload of the EA, delete the
         // server socket and all the clients
         glbCreatedTimer = false;

         // Delete all clients currently connected
         for(int i = 0; i < ArraySize(glbClients); i++)
           {
            delete glbClients[i];
           }
         ArrayResize(glbClients, 0);

         // Free the server socket. *VERY* important, or else
         // the port number remains in use and un-reusable until
         // MT4/5 is shut down
         delete glbServerSocket;
         glbServerSocket = NULL;
         Print("Server socket terminated");
         break;
     }
  }


// --------------------------------------------------------------------
// Timer - accept new connections, and handle incoming data from clients.
// Secondary to the event-driven handling via OnChartEvent(). Most
// socket events should be picked up faster through OnChartEvent()
// rather than being first detected in OnTimer()
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
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


// --------------------------------------------------------------------
// Accepts new connections on the server socket, creating new
// entries in the glbClients[] array
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AcceptNewConnections()
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

         // pNewClient.Send("Hello\r\n");
        }

     }
   while(pNewClient != NULL);
  }


// --------------------------------------------------------------------
// Handles any new incoming data on a client socket, identified
// by its index within the glbClients[] array. This function
// deletes the ClientSocket object, and restructures the array,
// if the socket has been closed by the client
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HandleSocketIncomingData(int idxClient)
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
            string temp="";
            
            for(int i=0;i<ArraySize(js.m_e);i++)
            {
               temp += js.m_e[i].m_sv;
               temp += "_";
               
            }
            
            Print(temp);
            
            /*
            Print("Symbol: ", js.m_e[0].m_sv, " InsCode: ", js.m_e[1].m_sv, " LastTradedPrice: ", js.m_e[2].m_sv, "  TradeDate: ", js.m_e[3].m_sv,
            "  ClosingPrice: ", js.m_e[4].m_sv,"  LowPrice: ", js.m_e[5].m_sv,"  TotalNumberOfTrades: ", js.m_e[6].m_sv,"  HighPrice: ", js.m_e[7].m_sv,
            "  TotalNumberOfSharesTraded: ", js.m_e[8].m_sv,"  YesterdayPrice: ", js.m_e[9].m_sv);
            */
         }
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


// --------------------------------------------------------------------
// Use OnTick() to watch for failure to create the timer in OnInit()
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!glbCreatedTimer)
      glbCreatedTimer = EventSetMillisecondTimer(TIMER_FREQUENCY_MS);
  }

// --------------------------------------------------------------------
// Event-driven functionality, turned on by #defining SOCKET_LIBRARY_USE_EVENTS
// before including the socket library. This generates dummy key-down
// messages when socket activity occurs, with lparam being the
// .GetSocketHandle()
// --------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   if(id == CHARTEVENT_KEYDOWN)
     {
      // If the lparam matches a .GetSocketHandle(), then it's a dummy
      // key press indicating that there's socket activity. Otherwise,
      // it's a real key press

      if(lparam == glbServerSocket.GetSocketHandle())
        {
         // Activity on server socket. Accept new connections
         Print("New server socket event - incoming connection");
         AcceptNewConnections();

        }
      else
        {
         // Compare lparam to each client socket handle
         for(int i = 0; i < ArraySize(glbClients); i++)
           {
            if(lparam == glbClients[i].GetSocketHandle())
              {
               HandleSocketIncomingData(i);
               return; // Early exit
              }
           }

         // If we get here, then the key press does not seem
         // to match any socket, and appears to be a real
         // key press event...
        }
     }
  }
//+------------------------------------------------------------------+
