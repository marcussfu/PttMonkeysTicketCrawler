//
//  MainViewController.swift
//  PttMonkeysTicketCrawler
//
//  Created by marcus fu on 2019/4/19.
//  Copyright © 2019 marcus fu. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class MainViewController: UIViewController {
    
    enum state: String {
        case sell = "售"
        case ask = "徵"
    }
    
    enum direction: String {
        case east = "東"
        case west = "西"
        case both
    }
    
    lazy var dateSelectorView: DateSelectorView = {
        let dateSelectorView = DateSelectorView()
        dateSelectorView.translatesAutoresizingMaskIntoConstraints = false
        dateSelectorView.delegate = self
        dateSelectorView.configure()
        return dateSelectorView
    }()

    lazy var datePickerViewController: DatePickerViewController = {
        let datePickerVC = DatePickerViewController()
        datePickerVC.modalPresentationStyle = .overCurrentContext
        datePickerVC.delegate = self
        return datePickerVC
    }()
    
    lazy var tableview: UITableView = {
        let tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.dataSource = self
        tableview.delegate = self
        tableview.backgroundColor = .black
        view.addSubview(tableview)
        return tableview
    }()
    
    lazy var pttAsyncSocket: PTTAsyncSocket = {
        let pttAsyncsocket = PTTAsyncSocket()
        pttAsyncsocket.delegate = self
        return pttAsyncsocket
    }()
    
    var askDate = Date()
    var askState = state.sell.rawValue
    var askDirection = direction.west.rawValue
    
    var filterOutIdList = [String]()
    var filterOutContentList = [String]()
    var filterOutPushTimeList = [String]()
    let targetUrl = "https://www.ptt.cc/bbs/Monkeys/M.1534603045.A.FFC.html"
    
    var spinnerController: SpinnerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        scrawlHtmlData()
        
        pttAsyncSocket.setAccountData(id: "Q305011", password: "Q74012011")
//        pptAsyncSocket = PPTAsyncSocket(id: "Q305011", password: "Q74012011")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension MainViewController {
    func initView() {
        title = "尋票平台"
        view.backgroundColor = .black
        view.addSubview(self.dateSelectorView)
        setConstraint()
        tableview.tableFooterView = UIView()
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    func setConstraint() {
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint(item: dateSelectorView, attribute: .top, relatedBy: .equal,
                               toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 0).isActive = true
        }
        else {
            NSLayoutConstraint(item: dateSelectorView, attribute: .top, relatedBy: .equal,
                               toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        }
        
        NSLayoutConstraint(item: dateSelectorView, attribute: .height, relatedBy: .equal,
                           toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: UIScreen.main.bounds.size.height * 0.08).isActive = true
        NSLayoutConstraint(item: dateSelectorView, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: dateSelectorView, attribute: .trailing, relatedBy: .equal,
                           toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: tableview, attribute: .top, relatedBy: .equal,
                           toItem: dateSelectorView, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableview, attribute: .bottom, relatedBy: .equal,
                           toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableview, attribute: .centerX, relatedBy: .equal,
                           toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableview, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
    }
    
    func scrawlHtmlData() {
        guard let url: URL = URL(string: targetUrl) else { return }
        Alamofire.request(url).responseString { response in
            if let responseValue = response.result.value {
                self.parseHTML(responseValue)
            }
        }
    }
    
    func parseHTML(_ htmlData: String){
        var idList = [String]()
        var contentList = [String]()
        var pushTimeList = [String]()
        do {
            for link in try Kanna.HTML(html: htmlData, encoding: String.Encoding.utf8).xpath("//div[@class='push']") {
                guard let idSpanText = link.at_xpath("span[@class='f3 hl push-userid']")?.text else {return}
                guard let contentSpanText = link.at_xpath("span[@class='f3 push-content']")?.text else {return}
                guard let timeSpanText = link.at_xpath("span[@class='push-ipdatetime']")?.text else {return}
                
                idList.append(idSpanText)
                contentList.append(contentSpanText)
                pushTimeList.append(timeSpanText)
            }
        } catch{}
        
        filterData(idList, contentList, pushTimeList)
        
        DispatchQueue.main.async {
            self.tableview.reloadData()
            //self.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func filterData(_ idList: [String], _ contentList: [String], _ pushTimeList: [String]) {
        filterOutIdList.removeAll()
        filterOutContentList.removeAll()
        filterOutPushTimeList.removeAll()
        
        for content in contentList {
            if checkDate(askDate, content: content) {
                if content.contains(askState) {
                    guard let index = contentList.firstIndex(of: content) else { return }
                    filterOutIdList.append(idList[index])
                    filterOutContentList.append(content)
                    filterOutPushTimeList.append(pushTimeList[index])
                }
            }
        }
    }
    
    func checkDate(_ askDate: Date, content: String) -> Bool {
        let askDateTimeString = askDate.toTimeString(format: "M/d")
        if content.contains(askDateTimeString) {
            let splitContent = content.components(separatedBy: askDateTimeString)
            guard let splitFirstCharacter = splitContent[1].first else {return false}
            let numbersRange = String(splitFirstCharacter).rangeOfCharacter(from: .decimalDigits)
            
            if numbersRange != nil {
                return false
            }
            return true
        }
        return false
    }
    
    func presentTicketInfoAlert(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        let sendAction = UIAlertAction(title: "站內信", style: .destructive) { _ in
            self.pttAsyncSocket.connect()
        }
        alertController.addAction(sendAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        alertController.setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.heavy), NSAttributedString.Key.foregroundColor : UIColor.blue]), forKey: "attributedTitle")
        
        alertController.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor : UIColor.black]), forKey: "attributedMessage")
        
        present(alertController, animated: true)
    }
    
    func presentSendMailOKAlert(_ title: String = "", message: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}

extension MainViewController: PTTAsyncSocketDelegate {
    func createActivityIndicatorView() {
        if spinnerController == nil {
            spinnerController = SpinnerViewController()
        }
        addChild(spinnerController)
        spinnerController.view.frame = view.frame
        view.addSubview(spinnerController.view)
        spinnerController.didMove(toParent: self)
    }
    
    func removeActivityIndicatorView() {
        spinnerController.willMove(toParent: nil)
        spinnerController.view.removeFromSuperview()
        spinnerController.removeFromParent()
        presentSendMailOKAlert(message: "已寄送站內信")
    }
}

extension MainViewController: DatePickerViewControllerDelegate {
    func sendDatePickerSelectedDate(_ date: Date) {
        dateSelectorView.showSelectedDate(date)
    }
    
}

extension MainViewController: DateSelectorViewDelegate {
    func showDatePickerView() {
        present(datePickerViewController, animated: false, completion: nil)
    }
    
    func dateSelected(_ date: Date) {
        datePickerViewController.datePickerView.date = date
        askDate = date
        scrawlHtmlData()
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = String((filterOutContentList[indexPath.row]).dropFirst()) + "\n" + filterOutPushTimeList[indexPath.row]
        presentTicketInfoAlert(filterOutIdList[indexPath.row], message: message)
    }

}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterOutContentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = filterOutIdList[indexPath.row] + filterOutContentList[indexPath.row]
        cell.textLabel?.textColor = .lightGray
        cell.backgroundColor = .black
        return cell
    }
}
