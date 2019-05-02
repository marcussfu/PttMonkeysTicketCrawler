//
//  DatePickerViewController.swift
//  PttMonkeysTicketCrawler
//
//  Created by marcus fu on 2019/4/26.
//  Copyright © 2019 marcus fu. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {
    func sendDatePickerSelectedDate(_ date: Date)
}

class DatePickerViewController: UIViewController {
    
    lazy var datePickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        datePicker.minimumDate = format.date(from: Date().toTimeString(format: "YYYY-MM-dd"))
        datePicker.backgroundColor = .white
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    lazy var datePickerToolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneDatePicker))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        toolbar.setItems([spaceButton,doneButton], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .white
        return toolbar
    }()
    
    var datePickerViewHeight: NSLayoutConstraint!
    var isShowDatePicker = false
    
    weak var delegate: DatePickerViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        view.isOpaque = false
        
        setDatePickerViewConstraint()
        setDatePickerToolBarConstraint()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showDatePicker(true)
    }
    
    func setDatePickerViewConstraint() {
        view.addSubview(datePickerView)
        NSLayoutConstraint(item: datePickerView, attribute: .trailing, relatedBy: .equal,
                           toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: datePickerView, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: datePickerView, attribute: .bottom, relatedBy: .equal,
                           toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        datePickerViewHeight = NSLayoutConstraint(item: datePickerView, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        datePickerViewHeight.isActive = true
    }
    
    func setDatePickerToolBarConstraint() {
        view.addSubview(datePickerToolBar)
        NSLayoutConstraint(item: datePickerToolBar, attribute: .trailing, relatedBy: .equal,
                           toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: datePickerToolBar, attribute: .leading, relatedBy: .equal,
                           toItem: view, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: datePickerToolBar, attribute: .bottom, relatedBy: .equal,
                           toItem: datePickerView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        datePickerToolBar.isHidden = true
    }
    
    func showDatePicker(_ isShow: Bool) {
        UIView.animate(withDuration: 0.3) {
            if isShow {
                self.datePickerViewHeight.constant = 200
                self.datePickerToolBar.isHidden = false
            } else {
                self.datePickerViewHeight.constant = 0
                self.datePickerToolBar.isHidden = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func doneDatePicker() {
        showDatePicker(false)
        dismiss(animated: false, completion: nil)
        delegate?.sendDatePickerSelectedDate(self.datePickerView.date)
    }
    
}
