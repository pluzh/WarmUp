//
//  CircularProgressBar.swift
//  WarmUp
//
//  Created by Ангелина Плужникова on 02.09.2022.
//

import UIKit


class CircularProgressBar: UIView {
    
    
    //MARK: Public
    
    public var lineWidth:CGFloat = 50 {
        didSet{
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth - (0.20 * lineWidth)
        }
    }
    
    private var timerR: Timer?
    
    public var TimeInterval:TimeInterval = 0
    
    public var labelSize: CGFloat = 20 {
        didSet {
            label.font = UIFont(name: "Avenir", size: labelSize)
            label.sizeToFit()
            configLabel()
        }
    }
    
    public func stopTimer() {
        timerR?.invalidate()
    }
    
    public func setProgress(to progressConstant: Double, withAnimation: Bool, _ timer: TimeInterval) {
        
        var gameTimeLeft: TimeInterval = timer * 60
        
        var progress: Double {
            get {
                if progressConstant > 1 { return 1 }
                else if progressConstant < 0 { return 0 }
                else { return progressConstant }
            }
        }
        
        foregroundLayer.strokeEnd = CGFloat(progress)
        
        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.duration = CFTimeInterval(timer * 60)
            foregroundLayer.add(animation, forKey: "foregroundAnimation")
        }

        timerR = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if gameTimeLeft < 0 {
                timer.invalidate()
            } else {
                let minutes = String(Int(gameTimeLeft) / 60)
                let seconds = String(Int(gameTimeLeft) % 60)
                self.label.text = minutes + ":" + seconds
                self.foregroundLayer.strokeColor = UIColor.blue.cgColor
                self.configLabel()
                gameTimeLeft -= 1
            }
        }
        timerR?.fire()
    }
    
    
    //MARK: Private
    private var label = UILabel()
    private let foregroundLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()
    private var radius: CGFloat {
        get{
            if self.frame.width < self.frame.height { return (self.frame.width - lineWidth)/2 }
            else { return (self.frame.height - lineWidth)/2 }
        }
    }
    
    private var pathCenter: CGPoint{ get{ return self.convert(self.center, from:self.superview) } }
    
    private func makeBar(){
        self.layer.sublayers = nil
        drawBackgroundLayer()
        drawForegroundLayer()
    }
    
    private func drawBackgroundLayer(){
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        self.backgroundLayer.path = path.cgPath
        self.backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        self.backgroundLayer.lineWidth = lineWidth - (lineWidth * 20/100)
        self.backgroundLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(backgroundLayer)
        
    }
    
    private func drawForegroundLayer(){
        
        let startAngle = (-CGFloat.pi/2)
        let endAngle = 2 * CGFloat.pi + startAngle
        
        let path = UIBezierPath(arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        foregroundLayer.lineCap = CAShapeLayerLineCap.round
        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = UIColor.red.cgColor
        foregroundLayer.strokeEnd = 0
        
        self.layer.addSublayer(foregroundLayer)
        
    }
    
    private func makeLabel(withText text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = text
        label.font = UIFont.systemFont(ofSize: labelSize)
        label.sizeToFit()
        label.center = pathCenter
        return label
    }
    
    private func configLabel(){
        label.sizeToFit()
        label.center = pathCenter
    }
    
    private func setupView() {
        makeBar()
        self.addSubview(label)
    }
    
    //MARK: Layout Sublayers

    private var layoutDone = false
    override func layoutSublayers(of layer: CALayer) {
        if !layoutDone {
            let tempText = label.text
            setupView()
            label.text = tempText
            layoutDone = true
        }
    }
    
}
