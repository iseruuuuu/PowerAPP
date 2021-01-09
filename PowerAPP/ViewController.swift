//
//  ViewController.swift
//  PowerAPP
//
//  Created by 井関竜太郎 on 2021/01/07.
//

import UIKit

import CoreMotion

class ViewController: UIViewController {
    
    private let motionManager = CMMotionManager()
    private weak var circleView: UIView?
    private weak var targetView: UIView?
    private var goalCount = 1
    
    
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var reset: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargetView()
        addCircleView()
        
        count.text = "1"
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1 / 100
        
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.current!, withHandler: { [weak self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            guard let strongSelf = self else { return }
            
            let xAngle = motion.attitude.roll * 180 / Double.pi
            let yAngle = motion.attitude.pitch * 180 / Double.pi
            
            let coefficient: CGFloat = 0.1
            
            
            //      print("attitude pitch: \(motion.attitude.pitch * 180 / Double.pi)")
            //    print("attitude roll : \(motion.attitude.roll * 180 / Double.pi)")
            //  print("attitude yaw  : \(motion.attitude.yaw * 180 / Double.pi)")
            
            strongSelf.circleView?.addX(CGFloat(xAngle) * coefficient)
            strongSelf.circleView?.addY(CGFloat(yAngle) * coefficient)
            
            strongSelf.judgeGoal()
        })
    }
    
    @IBAction func reset(_ sender: Any) {
        goalCount = 1
        reset.isHidden = true
      
        count.text = "1"
        
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1 / 100
        
        
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: OperationQueue.current!, withHandler: { [weak self] (motion, error) in
            guard let motion = motion, error == nil else { return }
            guard let strongSelf = self else { return }
            
            let xAngle = motion.attitude.roll * 180 / Double.pi
            let yAngle = motion.attitude.pitch * 180 / Double.pi
            let coefficient: CGFloat = 0.1
            
            strongSelf.circleView?.addX(CGFloat(xAngle) * coefficient)
            strongSelf.circleView?.addY(CGFloat(yAngle) * coefficient)
            
            strongSelf.judgeGoal()
            
            
        })
    }
}

private extension ViewController {
    /// 動かす青いViewを追加する
    func addCircleView() {
        let size: CGFloat = 32.0
        let circleView = UIView()
        circleView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        circleView.backgroundColor = UIColor.blue
        circleView.layer.cornerRadius = size / 2
        self.view.addSubview(circleView)
        self.circleView = circleView
    }
    
    func addTargetView() {
        /// 目標となるグレーのViewを追加する
        let size: CGFloat = 50.0
        let targetView = UIView()
        targetView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        targetView.backgroundColor = UIColor.gray
        targetView.layer.cornerRadius = size / 2
        var frame = targetView.frame
        frame.origin.x = CGFloat.random(in: view.frame.minX..<view.frame.maxX - frame.width)
        frame.origin.y = CGFloat.random(in: view.frame.minY..<view.frame.maxY - frame.height)
        targetView.frame = frame
        view.addSubview(targetView)
        self.targetView = targetView
        view.sendSubviewToBack(targetView)
    }
    
    /// 目標のViewに含まれているか判定する
    /// 5回繰り返したら終了ということで、DeviceMotionUpdateをstopする
    func judgeGoal() {
        if let targetView = targetView, let circleView = circleView,
           targetView.frame.contains(circleView.frame) {
            goalCount += 1
            count.text = "1"
            if goalCount <= 5 {
                count.text = (String(goalCount))
                targetView.removeFromSuperview()
                addTargetView()
                
                
            }else {
                count.text = "クリア！"
                reset.isHidden = false
                
                //  motionManager.stopDeviceMotionUpdates()
            }
        }
    }
}

extension UIView {
    /// X方向にViewを動かす
    func addX(_ x: CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x += x
        if let superViewFrame = superview?.frame {
            if superViewFrame.minX > frame.origin.x {
                frame.origin.x = superViewFrame.minX
            } else if superViewFrame.maxX - frame.width < frame.origin.x {
                frame.origin.x = superViewFrame.maxX - frame.width
            }
        }
        self.frame = frame
    }
    
    /// Y方向にViewを動かす
    func addY(_ y: CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y += y
        if let superViewFrame = superview?.frame {
            if superViewFrame.minY > frame.origin.y {
                frame.origin.y = superViewFrame.minY
            }else if superViewFrame.maxY - frame.height < frame.origin.y {
                frame.origin.y = superViewFrame.maxY - frame.height
            }
        }
        self.frame = frame
    }
}











