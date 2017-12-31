//
//  RecurringTaskTableViewCell.swift
//  Schedule Maker Prototype
//
//  Created by Albert Wu on 12/31/17.
//  Copyright © 2017 Old Friend. All rights reserved.
//

import UIKit

class RecurringTaskTableViewCell: UITableViewCell {

    var scheduleItem: ScheduleItem! {
        //Have cell display proper TextField content based on ScheduleItem data
        didSet {
            taskNameTF.text = scheduleItem.taskName
            durationTF.text = durationDescription(duration: scheduleItem.duration)
            if let startTime = scheduleItem.startTime {
                startTimeTF.text = timeDescription(durationSinceMidnight: startTime)
                let endTime = startTime + scheduleItem.duration
                endTimeTF.text = timeDescription(durationSinceMidnight: endTime)
            }
            else {
                startTimeTF.text = "XX:XX"
                endTimeTF.text = "XX:XX"
            }
            //lockButton.setTitle(scheduleItem.locked ? "🔒" : "🌀", for: .normal)
        }
    }
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var weekdaySelection: WeekdaySelection!
    @IBOutlet weak var startTimeTF: UITextField!
    @IBOutlet weak var durationTF: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func durationDescription(duration: Int) -> String {
        let hour:Int = duration / 3600
        let minute:Int = (duration % 3600) / 60
        var hourString = "\(hour)"
        var minuteString = "\(minute)"
        if(hour < 10) {
            hourString = "0" + hourString
        }
        if(minute < 10) {
            minuteString = "0" + minuteString
        }
        
        return "\(hourString):\(minuteString)"
        
    }
    func timeDescription(durationSinceMidnight: Int) -> String {
        /*
         if(durationSinceMidnight / 3600 < 13) {
         return "\(Int(durationSinceMidnight) / 3600):\((Int(durationSinceMidnight) % 3600) / 60) AM"
         }
         else if(durationSinceMidnight / 3600 < 24){
         return "\(Int(durationSinceMidnight) / 3600 - 12):\((Int(durationSinceMidnight) % 3600) / 60) PM"
         }
         else {
         return "ERROR: durationSinceMidnight greater than a day"
         }
         */
        let is24Mode = appDelegate.userSettings.is24Mode
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let date = startOfToday.addingTimeInterval(Double(durationSinceMidnight))
        var text = formatter.string(from: date)
        if durationSinceMidnight >= 13 * 3600 {
            text = text + " "
        }
        if(is24Mode) {
            let hour = String(durationSinceMidnight / 3600)
            var minute = String((durationSinceMidnight % 3600) / 60)
            if (durationSinceMidnight % 3600) / 60 < 10 {
                minute = "0" + minute
            }
            text = hour + ":" + minute
        }
        if durationSinceMidnight < 10 * 3600 {
            text = text + " "
        }
        /*
         let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font : UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .regular)])
         if durationSinceMidnight < 10 * 3600 || (!is24Mode && durationSinceMidnight >= 13 * 3600) {
         attributedString.setAttributes([NSAttributedStringKey.foregroundColor : UIColor(white: 0.0, alpha: 0.0)], range: NSRange(text.count - 1..<text.count))
         }
         return attributedString
         */
        return text
        //return "ERROR: durationSinceMidnight greater than a day"
    }
}
