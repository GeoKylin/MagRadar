//
//  ViewController.swift
//  MagRadar
//
//  Created by Mac-wk on 2019/1/21.
//  Copyright © 2019 Mac-wk. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    // 参数
    let magDecimal:Int = 4 //磁场强度小数位数
    let timeInterval: TimeInterval = 0.2 //刷新时间间隔

    // 变量
    var magVals:[Double] = [0,1,2,3] //磁强计的值
    var magBase:[Double] = [0,0,0,0] //背景磁场
    var origin:[CGFloat] = [0,0] //原点坐标
    var didCali:Bool = false //是否校正

    // 控件
    @IBOutlet weak var magXView: UILabel! //X分量
    @IBOutlet weak var magYView: UILabel! //Y分量
    @IBOutlet weak var magZView: UILabel! //Z分量
    @IBOutlet weak var magFView: UILabel! //总磁场
    @IBOutlet weak var targetView: UIButton! //目标
    
    // 传感器管理器
    let motionManager = CMMotionManager()

    // 主函数
    override func viewDidLoad() {
        super.viewDidLoad()
        /**** 视图加载完毕 ****/
        // 获取原点坐标
        origin[0] = targetView.frame.origin.x
        origin[1] = targetView.frame.origin.y
        // 开始磁力计更新
        startMagnetometerUpdates()

    }

    // 内存不足处理方法
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // 开始获取磁力计数据
    func startMagnetometerUpdates() {
        //判断设备支持情况
        guard motionManager.isMagnetometerAvailable else {
            warningAlert(warningText: "当前设备不支持磁力计！")
            return
        }
        
        //设置刷新时间间隔
        self.motionManager.magnetometerUpdateInterval = self.timeInterval
        
        //开始实时获取数据
        let queue = OperationQueue.current
        self.motionManager.startMagnetometerUpdates(to: queue!, withHandler: {
            (magnetometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            // 有更新
            if self.motionManager.isMagnetometerActive {
                if let magneticField = magnetometerData?.magneticField {
                    // 获取磁场数据
                    let magX = magneticField.x
                    let magY = magneticField.y
                    let magZ = magneticField.z
                    let magF = sqrt(pow(magX, 2)+pow(magY, 2)+pow(magZ, 2))
                    // 传入参数
                    self.magVals[0] = magX
                    self.magVals[1] = magY
                    self.magVals[2] = magZ
                    self.magVals[3] = magF
                    // 显示数据
                    self.magXView.text = String(format: "X:%0."+String(self.magDecimal)+"f uT", magX - self.magBase[0])
                    self.magYView.text = String(format: "Y:%0."+String(self.magDecimal)+"f uT", magY - self.magBase[1])
                    self.magZView.text = String(format: "Z:%0."+String(self.magDecimal)+"f uT", magZ - self.magBase[2])
                    self.magFView.text = String(format: "F:%0."+String(self.magDecimal)+"f uT", magF - self.magBase[3])
                    // 目标位置
                    if self.didCali {
                        self.targetView.frame.origin.x = self.origin[0] + (CGFloat)(magX - self.magBase[0])
                        self.targetView.frame.origin.y = self.origin[1] + (CGFloat)(magY - self.magBase[1])
                    }
                }
            }
        })
    }

    // 提示框函数
    func warningAlert(warningText: String) {
        // 提示框
        let alertController = UIAlertController(title: warningText, message: nil, preferredStyle: .alert)
        // 显示提示框
        self.present(alertController, animated: true, completion: nil)
        // 两秒钟后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }

    // 背景场校正
    @IBAction func calibrateButton(_ sender: Any) {
        magBase = magVals
        didCali = true
    }

}

