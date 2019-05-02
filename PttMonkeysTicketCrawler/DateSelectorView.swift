//
//  DateSelectorView.swift
//  PttMonkeysTicketCrawler
//
//  Created by marcus fu on 2019/4/26.
//  Copyright © 2019 marcus fu. All rights reserved.
//

import UIKit
protocol DateSelectorViewDelegate: class {
    func dateSelected(_ date: Date)
    func showDatePickerView()
}

enum WeekDay: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursnday
    case friday
    case saturday
    
    var Word: String {
        switch self {
        case .sunday: return "日"
        case .monday: return "一"
        case .tuesday: return "二"
        case .wednesday: return "三"
        case .thursnday: return "四"
        case .friday: return "五"
        case .saturday: return "六"
        }
    }
}

class DateSelectorView: UIView {
    
    lazy var selectDateButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        button.addTarget(self, action: #selector(touchDateSelectButton(_:)), for: .touchUpInside)
        return button
    }()
    
    var nowSelectedDate: Date!
    
    weak var delegate: DateSelectorViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 73.0 / 255.0, green: 201.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
        nowSelectedDate = Date()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        setSelectedDateText(nowSelectedDate)
    }
    
    func setSelectedDateText(_ date: Date) {
        guard let weekDayWord = WeekDay(rawValue: date.toCalendarComponentsPart().weekday)?.Word else { return }
        let dateString = date.toTimeString(format: "YYYY年MM月dd日") + " 星期" + weekDayWord
        selectDateButton.setTitle(dateString, for: .normal)
    }
    
    func setConstraints() {
        addSubview(selectDateButton)
        NSLayoutConstraint(item: selectDateButton, attribute: .top, relatedBy: .equal,
                           toItem: self, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: selectDateButton, attribute: .centerX, relatedBy: .equal,
                           toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: selectDateButton, attribute: .leading, relatedBy: .equal,
                           toItem: self, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: selectDateButton, attribute: .bottom, relatedBy: .equal,
                           toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    @objc func touchDateSelectButton(_ button: UIButton) {
        delegate?.showDatePickerView()
    }
    
    func showSelectedDate(_ date: Date) {
        nowSelectedDate = date
        setSelectedDateText(date)
        delegate?.dateSelected(date)
    }
}
