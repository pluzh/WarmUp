//
//  ViewController.swift
//  WarmUp
//
//  Created by Ангелина Плужникова on 27.08.2022.
//

import UIKit
import UserNotifications
import AVFoundation
import AudioToolbox
import SwiftEntryKit


class ViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var lableInformation: UILabel!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: CircularProgressBar!
    
    private var timeWork: TimeInterval = 0 // нужно взять из настроек
    private var timeBreak: TimeInterval = 0
    private var status = 0 // если 1 - идет время работы 2 - время перерыва
    private var gameTimeLeft: TimeInterval = 0
    private var timer: Timer?
    private let daisplayDuration: TimeInterval = 1
    private var pause = false
    private let shapeLayer = CAShapeLayer()
    private var popUpClosed = 0
    private var player = AVAudioPlayer()
    private let keyWorksTime = "keyWorksTime"
    private let keyWarmUpTime = "keyWarmUpTime"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.integer(forKey: keyWorksTime) == 0 { UserDefaults.standard.set(25, forKey: keyWorksTime)
        }
        timeWork = TimeInterval(UserDefaults.standard.integer(forKey: keyWorksTime))
        if UserDefaults.standard.integer(forKey: keyWarmUpTime) == 0 { UserDefaults.standard.set(2, forKey: keyWarmUpTime)
        }
        timeBreak = TimeInterval(UserDefaults.standard.integer(forKey: keyWarmUpTime))
    }
    
    @IBAction func startButtonTapped(_ sender: Any) {
        timer?.invalidate()
        status = 1
        progressBar.isHidden = false
        startButton.isHidden = true
        settingsButton.isEnabled = false
        stopButton.isHidden = false
        lableInformation.isHidden = false
        startWork()
    }
    
    @IBAction func stopButtonTapped(_ sender: Any) {
        startButton.isHidden = false
        stopButton.isHidden = true
        settingsButton.isEnabled = true
        lableInformation.isHidden = true
        progressBar.isHidden = true
        status = 0
        pause = false
        timer?.invalidate()
        progressBar.stopTimer()
    }

    private func startWork() {
        timer?.invalidate()
        gameTimeLeft = timeWork * 60
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerTick),
            userInfo: nil,
            repeats: true)
        progressBar.TimeInterval = timeWork
        progressBar.labelSize = 50
        progressBar.lineWidth = 10
        progressBar.setProgress(to: 2, withAnimation: true, timeWork)
    }

    private func startBreak() {
        timer?.invalidate()
        gameTimeLeft = timeBreak * 60
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(timerTick),
            userInfo: nil,
            repeats: true)
        progressBar.TimeInterval = timeBreak
        progressBar.labelSize = 50
        progressBar.lineWidth = 10
        progressBar.setProgress(to: 2, withAnimation: true, timeBreak)
    }
    
    @objc private func timerTick (){
        var backgroundTask = UIApplication.shared.beginBackgroundTask()
        
        if backgroundTask != UIBackgroundTaskIdentifier.invalid {
            if UIApplication.shared.applicationState == .active {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
        }
        
        gameTimeLeft -= 1
        if gameTimeLeft < 0 && status == 1 {
            lableInformation.text = "До работы осталось:"
            timer?.invalidate()
//            AudioServicesPlaySystemSound(1000)
            playSound()
            showPopUp()
        } else if gameTimeLeft < 0 && status == 2{
            lableInformation.text = "До перерыва осталось:"
            timer?.invalidate()
//            AudioServicesPlaySystemSound(1000)
            playSound()
            showPopUp()
        }
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "melody1", withExtension: "mp3") else {return}
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
        } catch {
            fatalError("unable to find file with given url")
        }
        player.play()
    }
    
    //MARK: PopUp_Settings
    
    private func setupAttributes() -> EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: .init(light: UIColor(white: 100.0/255.0, alpha: 0.3), dark: UIColor(white: 50.0/255.0, alpha: 0.3)))
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 8
            )
        )
        attributes.entryBackground = .color(color: .standardBackground)
        attributes.roundCorners = .all(radius: 25)
        
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .jolt
        )
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.7,
                spring: .init(damping: 1, initialVelocity: 0)
            ),
            scale: .init(
                from: 1.05,
                to: 1,
                duration: 0.4,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.2)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.2)
            )
        )
        attributes.positionConstraints.verticalOffset = 10
        attributes.statusBar = .dark
        return attributes
    }
    
    private func setupMessage() -> EKPopUpMessage {
        
        let image = UIImage(named: "Image_done")!.withRenderingMode(.alwaysTemplate)
        var title = ""
        var description = ""
        if status == 1 {
             title = "Разомнись!"
             description =
            """
            Нажмите "ОК" для \
            начала перерыва
            """
        } else {
             title = "Пора за работу!"
             description =
            """
            Нажмите "ОК" для \
            начала работы
            """
        }

        let themeImage = EKPopUpMessage.ThemeImage(image: EKProperty.ImageContent(image: image, size: CGSize(width: 60, height: 60), tint: .black, contentMode: .scaleAspectFit))

        let titleLabel = EKProperty.LabelContent(text: title, style: .init(font: UIFont.systemFont(ofSize: 24),
                                                                      color: .black,
                                                                      alignment: .center))

        let descriptionLabel = EKProperty.LabelContent(
            text: description,
            style: .init(
                font: UIFont.systemFont(ofSize: 16),
                color: .init(UIColor.systemGray),
                alignment: .center
            )
        )

        let button = EKProperty.ButtonContent(
            label: .init(
                text: "ОК",
                style: .init(
                    font: UIFont.systemFont(ofSize: 16),
                    color: .white
                )
            ),
            backgroundColor: .init(UIColor.systemPurple),
            highlightedBackgroundColor: .clear
        )

        let message = EKPopUpMessage(themeImage: themeImage, title: titleLabel, description: descriptionLabel, button: button) {
            SwiftEntryKit.dismiss()
            if self.status == 1 {
                self.startBreak()
                self.player.stop()
                self.status = 2
            } else {
                self.startWork()
                self.player.stop()
                self.status = 1
            }
        }
        return message
        
    }
    
    private func showPopUp() {
        sheduleNotification(1) {(success) in }
        SwiftEntryKit.display(entry: PopUpView(with: setupMessage()), using: setupAttributes())
    }
    
    
    //MARK: Notifications
    
    private func sheduleNotification(_ seconds: TimeInterval, completion: (Bool) -> ()){
        
        removeNotifications(["MyUniqueIdentifier"])
        
        let date = Date(timeIntervalSinceNow: seconds)
        let content = UNMutableNotificationContent()
        
        content.title = "Уведомление"
        if status == 2 {
            content.body = "Пора сделать перерыв!"
        } else {
            content.body = "Пора за работу!"
        }
        content.sound = nil
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "MyUniqueIdentifier", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request, withCompletionHandler: nil)
    }

    private func removeNotifications(_ identifiers: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
