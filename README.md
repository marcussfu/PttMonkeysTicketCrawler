# Buy Baseball Ticket Helper
## Why
因為想要買票，還需要爬文找到想要的時間和坐位，就算找到了，也可能太晚回被買走了

## What
決定做一個App查詢球賽的時間和坐位，並寄信站內信給賣家

## How
* 爬蟲的方式去爬ptt.cc的Monkeys版的賣票文，再針對推文以設定的條件去爬出想要的球賽時間與坐位
  warning (改版中，因為賣票已經集中至 專版CPBL_ticket)
* 第三方套件
    - [Alamofire](https://github.com/Alamofire/Alamofire)
    - [Kanna](https://github.com/tid-kijyun/Kanna)
    - [CocoaAsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket)
    
記得先 pod install 安裝第三方套件
