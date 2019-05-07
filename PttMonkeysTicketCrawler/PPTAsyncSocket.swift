//
//  PPTAsyncSocket.swift
//  PttMonkeysTicketCrawler
//
//  Created by marcus fu on 2019/5/7.
//  Copyright © 2019 marcus fu. All rights reserved.
//

import CocoaAsyncSocket

class PPTAsyncSocket: NSObject {
    var socket: GCDAsyncSocket?
    var id: String?
    var password: String?
    
    let host: String! = "ptt.cc"
    let port: UInt16 = 23
    let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))
    
    init(id: String = "", password: String = "") {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        self.id = id
        self.password = password
    }
    
    func connect() {
        do {
            try self.socket?.connect(toHost: host, onPort: port, withTimeout: -1)
            guard let id = self.id else {return}
            guard let password = self.password else {return}
            pttCommand(id)
            pttCommand(password)
        }
        catch {
            print("oops, connect to socket fail.")
        }
    }
    
    func pttCommand(_ command:String = "") {
        let sendString = command + "\r\n"
        guard let commandData = sendString.data(using: String.Encoding(rawValue: big5)) else {return}
        socketSendCommandData(commandData)
    }
    
    func pttCommandHex(_ command:String = "") {
        let commandData = Data([ 0x18 ])
        socketSendCommandData(commandData)
    }
    
    func socketSendCommandData(_ commandData: Data) {
        let delayTime = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.socket?.write(commandData, withTimeout: -1.0, tag: 0)
            self.socket?.readData(withTimeout: -1.0, tag: 0)
        }
    }
}

extension PPTAsyncSocket: GCDAsyncSocketDelegate {
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("connected")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 0)
        let response = String(data: data, encoding: String.Encoding(rawValue: big5))
//        print("response:\(String(describing: response))")
        
        if response?.range(of: "密碼不對") != nil {
            print("密碼不對或無此帳號。程式結束")
        }
        else if response?.range(of: "您想刪除其他重複登入的連線嗎") != nil {
            pttCommand("y")
        }
        else if response?.range(of: "請按任意鍵繼續") != nil {
            pttCommand()
            guard let id = self.id else {return}
            sendMail(id, title: "你好，我想買票", content: "如果你還沒售出的話，請賣給我\n這是我的lineID")
        }
        else if response?.range(of: "您有一篇文章尚未完成") != nil {
            pttCommand("q")
        }
        else if response?.range(of: "您要刪除以上錯誤嘗試的記錄嗎") != nil {
            pttCommand("y")
        }
        else if response?.range(of: "您確定要離開") != nil {
            pttCommand("y")
        }
        else if response?.range(of: "請勿頻繁登入") != nil {
            pttCommand()
        }
    }
    
    func sendMail(_ id: String, title: String, content: String) {
        print("發信中...")
        // entry to mail manager page
        pttCommand("m")
        // send
        pttCommand("s")
        // input receiver id
        pttCommand(id)
        // input mail title
        pttCommand(title)
        // input mail content
        pttCommand(content)
        // input ctrl+X on hex
        pttCommandHex("0x18")
        // input save
        pttCommand("s")
        // no backup
        pttCommand("n")
        
        logout()
    }
    
    func logout() {
        let delayTime = DispatchTime.now() + 10
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            print("logout")
            self.socket?.disconnect()
        }
        
        //        pttCommand("e")
        //        pttCommand("g")
        //        pttCommand("y")
    }
}

