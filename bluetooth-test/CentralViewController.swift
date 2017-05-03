//
//  CentralViewController.swift
//  bluetooth-test
//
//  Created by Wataru Inoue on 2017/05/03.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//


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
        
        var data2 = self.characteristic.value
        let reportData = UnsafePointer<UInt8>(data2.bytes)
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
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        println("state: \(central.state)")
    }
    
    //周辺にあるデバイスを発見すると呼ばれる
    func centralManager(central: CBCentralManager!,
                        didDiscoverPeripheral peripheral: CBPeripheral!,
                        advertisementData: [NSObject : AnyObject]!,
                        RSSI: NSNumber!)
    {
        println("発見したBLEデバイス: \(peripheral)")
        
        self.peripheral = peripheral
        
        
        self.peripheral = peripheral
        
        // 接続開始
        self.centralManager.connectPeripheral(self.peripheral, options: nil)
        
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager!,
                        didConnectPeripheral peripheral: CBPeripheral!)
    {
        println("接続成功！")
        
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
        println("接続失敗・・・")
    }
    
    func centralManager(central: CBCentralManager!,didDisconnectPeripheral peripheral:CBPeripheral!,error: NSError!) {
        println("接続が切断されました。")
        
        if error != nil {
            println("エラー: \(error)")
        }
        
        self.peripheral = nil;
        self.characteristic = nil;
        self.valueLabel.text = nil;
    }
    
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        if error != nil {
            println("エラー: \(error)")
            return
        }
        
        let services: NSArray = peripheral.services
        
        println("\(services.count) 個のサービスを発見！ \(services)")
        
        
        
        
        
        for obj in services {
            
            if let service = obj as? CBService {
                
                // キャラクタリスティック探索開始
                peripheral.discoverCharacteristics(nil, forService: service)
                
            }
        }
        
        
    }
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral!,
                    didDiscoverCharacteristicsForService service: CBService!,
                    error: NSError!)
    {
        if error != nil {
            println("エラー: \(error)")
            return
        }
        
        let characteristics: NSArray = service.characteristics
        println("\(characteristics.count) 個のキャラクタリスティックを発見！ \(characteristics)")
        
        
        // 特定のキャラクタリスティックをプロパティに保持
        let uuid = CBUUID(string:"0001")
        for aCharacteristic in characteristics {
            
            if aCharacteristic.UUID == uuid {
                
                
                
                self.characteristic = aCharacteristic as! CBCharacteristic
                
                
                break;
            }
        }
        
        
        
        
    }
    
    // Notify開始／停止時に呼ばれる
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic:CBCharacteristic!, error: NSError!)
    {
        if error != nil {
            println("Notify状態更新失敗...error:%@", error)
            
        } else {
            
            
            println("Notify状態更新成功！characteristic UUID:\(characteristic.UUID), isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    // データ更新時に呼ばれる
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!)
    {
        
        if error != nil {
            println("データ更新通知エラー:%@", error)
            return
            
        } else {
            
            
            println("データ更新！ characteristic UUID: \(characteristic.UUID), value: \(characteristic.value)")
            
            updateValue()
        }
        
        
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didWriteValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            println("Write失敗...error:%@", error)
            
        } else {
            
            
            println("Write成功！")
            // このキャラクタリスティックの値には実はまだ更新が反映されていない
            updateValue()
        }
        
        
    }
    
    
    
    @IBAction func scanBtn(sender: UIButton) {
        if !isScanning {
            
            isScanning = true
            
            // スキャン開始（特定サービスを持つペリフェラルに限定）
            
            let serviceUUIDs:[AnyObject] = [CBUUID(string:"0000")]
            self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: nil)
            
            
            
            
            sender.setTitle("STOP SCAN", forState: UIControlState.Normal)
        }
        else {
            // スキャン停止
            self.centralManager.stopScan()
            
            sender.setTitle("START SCAN", forState: UIControlState.Normal)
            
            isScanning = false
        }
        
        
    }
    
    @IBAction func writeBtnTapped(sender: UIButton) {
        //13の値を送ったとき
        var valuemoto2 = 13
        var value: UInt8 = UInt8(valuemoto2 & 0xFF)
        var data = NSData(bytes: [value] as [UInt8], length: 1)
        peripheral .writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
        
        
        
        
        
    }
    
    @IBAction func notifyBtn1(sender: UIButton) {
        
        if !self.characteristic.isNotifying {
            
            // Notify開始をリクエスト
            
            self.peripheral .setNotifyValue(true, forCharacteristic: self.characteristic)
            sender.setTitle("STOP NOTIFY",forState:UIControlState.Normal)
        } else {
            
            // Notify停止をリクエスト
            self.peripheral .setNotifyValue(false, forCharacteristic: self.characteristic)
            sender.setTitle("START NOTIFY",forState:UIControlState.Normal)
            
        }
        
    }
    
    
}
