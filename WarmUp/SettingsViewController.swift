//
//  SettingsViewController.swift
//  WarmUp
//
//  Created by Ангелина Плужникова on 18.09.2022.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var worksTime: UITextField!
    @IBOutlet weak var warmUpTime: UITextField!
    
    private let keyWorksTime = "keyWorksTime"
    private let keyWarmUpTime = "keyWarmUpTime"
    private let timePicker = UIPickerView()
    private let secondTimePicker = UIPickerView()
    private let pickerStrings = ["1 мин", "2 мин", "3 мин", "4 мин", "5 мин", "6 мин", "7 мин", "8 мин", "9 мин", "10 мин", "11 мин", "12 мин", "13 мин", "14 мин", "15 мин", "16 мин", "17 мин", "18 мин", "19 мин", "20 мин", "21 мин", "22 мин", "23 мин", "24 мин", "25 мин", "26 мин", "27 мин", "28 мин", "29 мин", "30 мин", "31 мин", "32 мин", "33 мин", "34 мин", "35 мин", "36 мин", "37 мин", "38 мин", "39 мин", "40 мин", "41 мин", "42 мин", "43 мин", "44 мин", "45 мин", "46 мин", "47 мин", "48 мин", "49 мин", "50 мин", "51 мин", "52 мин", "53 мин", "54 мин", "55 мин", "56 мин", "57 мин", "58 мин", "59 мин", "60 мин"]
    
    @IBAction func darcThemeSwich(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTimePicker(timePicker, worksTime)
        settingsTimePicker(secondTimePicker, warmUpTime)
        if UserDefaults.standard.integer(forKey: keyWorksTime) == 0 { UserDefaults.standard.set(25, forKey: keyWorksTime)
        }
        worksTime.text =  "\(String(describing: UserDefaults.standard.integer(forKey: keyWorksTime))) мин"
        if UserDefaults.standard.integer(forKey: keyWarmUpTime) == 0 { UserDefaults.standard.set(2, forKey: keyWarmUpTime)
        }
        warmUpTime.text =  "\(String(describing: UserDefaults.standard.integer(forKey: keyWarmUpTime))) мин"
    }
    
    private func settingsTimePicker(_ timePicker: UIPickerView, _ textFiled: UITextField) {
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.frame.size = CGSize(width: 0, height: 300)
        textFiled.inputView = timePicker
    }
}


extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerStrings.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerStrings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == secondTimePicker {
            warmUpTime.text = pickerStrings[row]
            warmUpTime.resignFirstResponder()
            UserDefaults.standard.set(pickerStrings.firstIndex(of: warmUpTime.text!)! + 1, forKey: keyWarmUpTime)
        } else {
            worksTime.text = pickerStrings[row]
            worksTime.resignFirstResponder()
            UserDefaults.standard.set(pickerStrings.firstIndex(of: worksTime.text!)! + 1, forKey: keyWorksTime)
        }
    }
}
