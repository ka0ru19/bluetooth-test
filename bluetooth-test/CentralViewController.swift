//
//  CentralViewController.swift
//  bluetooth-test
//
//  Created by Wataru Inoue on 2017/05/03.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import CoreBluetooth

//プロパティ定義
class CentralViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var pictNumLabel: UILabel!
    @IBOutlet weak var myimageView: UIImageView!
    
    var isScanning = false
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic:CBCharacteristic!
    
    var aCharacteristic: CBCharacteristic!
    var outputString:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //セントラルマネージャ初期化
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.valueLabel.text = nil;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //データを表示
    func updateValue() {
        
        var data2: NSData = self.characteristic.value as! NSData
        let reportData = data2.bytes.assumingMemoryBound(to: UInt8.self)
        
        var bpm : UInt16
        bpm = UInt16(reportData[0])
        bpm = CFSwapInt16LittleToHost(bpm)
        let outputString = String(bpm)
        
        self.valueLabel.text = "文字変換: \(outputString)"
        
        switch outputString {
        case "1":
            pictNumLabel.text = "いちです"
            myimageView.image = UIImage(named: "testPic1.png")
        case "2":
            pictNumLabel.text = "にです"
            myimageView.image = UIImage(named: "testPic2.png")
        case "3":
            pictNumLabel.text = "さんです"
            myimageView.image = UIImage(named: "testPic3.png")
        case "4":
            pictNumLabel.text = "ランダム"
            myimageView.image = UIImage(named: "testPic4.png")
        default:
            pictNumLabel.text = "その他"
            myimageView.image = UIImage(named: "testPic1.png")
            
        }
        
    }
    
    //セントラルマネージャの状態が変化すると呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager!) {
        
        print("state: \(central.state)")
    }
    
    //周辺にあるデバイスを発見すると呼ばれる
    func centralManager(central: CBCentralManager!,
                        didDiscoverPeripheral peripheral: CBPeripheral!,
                        advertisementData: [NSObject : AnyObject]!,
                        RSSI: NSNumber!)
    {
        print("発見したBLEデバイス: \(peripheral)")
        
        self.peripheral = peripheral
        
        
        self.peripheral = peripheral
        
        // 接続開始
        self.centralManager.connect(self.peripheral, options: nil)
        
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager!,
                        didConnectPeripheral peripheral: CBPeripheral!)
    {
        print("接続成功！")
        
        // サービス探索結果を受け取るためにデリゲートをセット
        peripheral.delegate = self
        
        // サービス探索開始
        peripheral.discoverServices(nil)
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager!,
                        didFailToConnectPeripheral peripheral: CBPeripheral!,
                        error: NSError!)
    {
        print("接続失敗・・・")
    }
    
    func centralManager(central: CBCentralManager!,didDisconnectPeripheral peripheral:CBPeripheral!,error: NSError!) {
        print("接続が切断されました。")
        
        if error != nil {
            print("エラー: \(error)")
        }
        
        self.peripheral = nil;
        self.characteristic = nil;
        self.valueLabel.text = nil;
    }
    
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        if error != nil {
            print("エラー: \(error)")
            return
        }
        
        let services = peripheral.services
        
        print("\(services?.count) 個のサービスを発見！ \(services)")
        
        
        
        
        
        for obj in services! {
            
            if let service = obj as? CBService {
                
                // キャラクタリスティック探索開始
                peripheral.discoverCharacteristics(nil, for: service)
                
            }
        }
        
        
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral!,
                    didDiscoverCharacteristicsForService service: CBService!,
                    error: NSError!)
    {
        if error != nil {
            print("エラー: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("\(characteristics?.count) 個のキャラクタリスティックを発見！ \(characteristics)")
        
        
        // 特定のキャラクタリスティックをプロパティに保持
        let uuid = CBUUID(string:"0001")
        for aCharacteristic in characteristics! {
            
            if (aCharacteristic as AnyObject).uuid == uuid {
                
                
                
                self.characteristic = aCharacteristic as! CBCharacteristic
                
                
                break;
            }
        }
        
        
        
        
    }
    
    // Notify開始／停止時に呼ばれる
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic!, error: NSError!)
    {
        if error != nil {
            print("Notify状態更新失敗...error:%@", error)
            
        } else {
            
            
            print("Notify状態更新成功！characteristic UUID:\(characteristic.uuid), isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    // データ更新時に呼ばれる
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!)
    {
        
        if error != nil {
            print("データ更新通知エラー:%@", error)
            return
            
        } else {
            
            
            print("データ更新！ characteristic UUID: \(characteristic.uuid), value: \(characteristic.value)")
            
            updateValue()
        }
        
        
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            print("Write失敗...error:%@", error)
            
        } else {
            
            
            print("Write成功！")
            // このキャラクタリスティックの値には実はまだ更新が反映されていない
            updateValue()
        }
        
        
    }
    
    
    
    @IBAction func scanBtn(sender: UIButton) {
        if !isScanning {
            
            isScanning = true
            
            // スキャン開始（特定サービスを持つペリフェラルに限定）
            
            let serviceUUIDs:[AnyObject] = [CBUUID(string:"0000")]
            self.centralManager.scanForPeripherals(withServices: serviceUUIDs as! [CBUUID], options: nil)
            
            
            
            
            sender.setTitle("STOP SCAN", for: UIControlState.normal)
        }
        else {
            // スキャン停止
            self.centralManager.stopScan()
            
            sender.setTitle("START SCAN", for: UIControlState.normal)
            
            isScanning = false
        }
        
        
    }
    
    @IBAction func writeBtnTapped(sender: UIButton) {
        //13の値を送ったとき
        var valuemoto2 = 13
        var value: UInt8 = UInt8(valuemoto2 & 0xFF)
        var data = NSData(bytes: [value] as [UInt8], length: 1)
        peripheral.writeValue(data as Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        
        
        
        
        
    }
    
    @IBAction func notifyBtn1(sender: UIButton) {
        
        if !self.characteristic.isNotifying {
            
            // Notify開始をリクエスト
            
            self.peripheral .setNotifyValue(true, for: self.characteristic)
            sender.setTitle("STOP NOTIFY",for:UIControlState.normal)
        } else {
            
            // Notify停止をリクエスト
            self.peripheral .setNotifyValue(false, for: self.characteristic)
            sender.setTitle("START NOTIFY",for:UIControlState.normal)
            
        }
        
    }
    
    
}
