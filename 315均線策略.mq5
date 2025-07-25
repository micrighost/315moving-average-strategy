//+------------------------------------------------------------------+
//|                                                  315均線策略.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include  <classpack.mqh>
ClassPack CPack ;



//策略說明:
//用3日和15日MA的金叉死叉來判斷做多做空。
//如果之前是空頭，金叉就做多，反之亦然。
//停利停損為方向轉換
//
//
//參數:
//MA  3天
//MA  15天


double day3_ma_values[];   //裝3日iMA值的陣列
double day3_ma_handle;     //3日iMA指標的句柄

double day15_ma_values[];  //裝15日iMA值的陣列
double day15_ma_handle;    //15日iMA指標的句柄

int position_type = 0;     //long position(多頭) = 1      short position(空頭) = -1   

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---

   //--- 建立iMA指標
   day3_ma_handle = iMA(NULL,PERIOD_CURRENT,3,0,MODE_EMA,PRICE_OPEN);
   
   
   //--- 建立iMA指標
   day15_ma_handle = iMA(NULL,PERIOD_CURRENT,15,0,MODE_EMA,PRICE_OPEN);

   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   //--- 用目前iMA的值填入day3_ma_values[]數組
   //--- 複製1個元素
   CopyBuffer(day3_ma_handle,0,0,1,day3_ma_values);   //day3_ma_values[0]為目前bar的MA值
   
   //--- 用目前iMA的值填入day15_ma_values[]數組
   //--- 複製1個元素
   CopyBuffer(day15_ma_handle,0,0,1,day15_ma_values); //day15_ma_values[0]為目前bar的MA值
   
   
   if (position_type == 0){                           //沒有空頭或是多頭的狀態，就賦予它現在是空頭還是多頭
      if(day3_ma_values[0] > day15_ma_values[0]){
      position_type = 1;                              //現在是多頭
      }
      if(day3_ma_values[0] < day15_ma_values[0]){
      position_type = -1;                             //現在是空頭
      }
   }




   if(position_type == -1){                        //如果之前是空頭
      if(day3_ma_values[0] > day15_ma_values[0]){  //如果出現金叉，判斷為多頭即將開始
         if(PositionsTotal() > 0){                 //如果有持倉
            trade.PositionClose(_Symbol);          //先關閉之前的倉位
         }
            
         if(PositionsTotal() < 1){                 //如果沒有持倉
            trade.Buy(0.01);                       //就開倉
            position_type = 1;                     //轉換現在狀態為多頭
         }
      }     
   }

   if(position_type == 1){                         //如果之前是多頭
      if(day3_ma_values[0] < day15_ma_values[0]){  //如果出現死叉，判斷為空頭即將開始
         if(PositionsTotal() > 0){                 //如果有持倉
            trade.PositionClose(_Symbol);          //先關閉之前的倉位
         }
            
         if(PositionsTotal() < 1){                 //如果沒有持倉
            trade.Sell(0.01);                      //就開倉
            position_type = -1;                    //轉換現在狀態為空頭
         }
      }     
   }


   
}
//+------------------------------------------------------------------+
