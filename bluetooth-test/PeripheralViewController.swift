//
//  PeripheralViewController.swift
//  bluetooth-test
//
//  Created by Wataru Inoue on 2017/05/03.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import CoreBluetooth

class PreipheralViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet var advertiseBtn: UIButton!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var strLabel: UILabel!
    
    var peripheralManager: CBPeripheralManager!
    var serviceUUID: CBUUID!
    var characteristic: CBMutableCharacteristic!
    
    var data:NSData!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        self.valueLabel.text = nil;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func publishservice () {
        
        // サービスを作成
        self.serviceUUID = CBUUID(string: "0000")
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // キャラクタリスティックを作成
        let characteristicUUID = CBUUID(string: "0001")
        
        let properties = (
            CBCharacteristicProperties.Notify |
                CBCharacteristicProperties.Read |
                CBCharacteristicProperties.Write)
        
        let permissions = (
            CBAttributePermissions.Readable |
                CBAttributePermissions.Writeable)
        
        self.characteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: properties,
            value: nil,
            permissions: permissions)
        
        // キャラクタリスティックをサービスにセット
        service.characteristics = [self.characteristic]
        
        // サービスを Peripheral Manager にセット
        self.peripheralManager.addService(service)
        
        var msg: String = "0"
        
        let data: NSData! = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion:true)
        println("data: \(data)")
        
        self.characteristic.value = data;
        
    }
    
    func startAdvertise() {
        
        // アドバタイズメントデータを作成する
        let advertisementData: Dictionary = [
            CBAdvertisementDataLocalNameKey: "Test Device",
            CBAdvertisementDataServiceUUIDsKey: [self.serviceUUID]
        ]
        
        // アドバタイズ開始
        self.peripheralManager.startAdvertising(advertisementData)
        
        self.advertiseBtn.setTitle("STOP ADVERTISING", forState: UIControlState.Normal)
    }
    
    func stopAdvertise () {
        
        // アドバタイズ停止
        self.peripheralManager.stopAdvertising()
        
        self.advertiseBtn.setTitle("START ADVERTISING", forState: UIControlState.Normal)
    }
    
    //データ送信
    func updateValueLabel () {
        
        let reportData = UnsafePointer<UInt8>(data.bytes)
        var bpm : UInt16
        bpm = UInt16(reportData[0])
        bpm = CFSwapInt16LittleToHost(bpm)
        let outputString = String(bpm)
        
        
        self.valueLabel.text = "分類用文字: \(outputString)"
        
        switch outputString {
        case "1":
            self.strLabel.text = "いちです"
        case "2":
            self.strLabel.text = "にです"
        case "3":
            self.strLabel.text = "さんです"
        default:
            self.strLabel.text = "その他"
            
            //ランダムな数値を出力する場合
            //self.valueLabel.text = NSString(format: "Characteristic value: %@", self.characteristic.value) as String
            
        }
    }
    
    // ペリフェラルマネージャの状態が変化すると呼ばれる
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        
        println("state: \(peripheral.state)")
        
        switch peripheral.state {
            
        case CBPeripheralManagerState.PoweredOn:
            // サービス登録開始
            self.publishservice()
            break
            
        default:
            break
        }
    }
    
    
    // サービス追加処理が完了すると呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager!, didAddService service: CBService!, error: NSError!) {
        
        if (error != nil) {
            println("サービス追加失敗！ error: \(error)")
            return
        }
        
        println("サービス追加成功！")
        
        // アドバタイズ開始
        self.startAdvertise()
    }
    
    // アドバタイズ開始処理が完了すると呼ばれる
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
        
        if (error != nil) {
            println("アドバタイズ開始失敗！ error: \(error)")
            return
        }
        
        println("アドバタイズ開始成功！")
    }
    
    // Readリクエスト受信時に呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveReadRequest request: CBATTRequest!) {
        
        println("Readリクエスト受信！ requested service uuid:\(request.characteristic.service.UUID) characteristic uuid:\(request.characteristic.UUID) value:\(request.characteristic.value)")
        
        // プロパティで保持しているキャラクタリスティックへのReadリクエストかどうかを判定
        if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
            
            // CBMutableCharacteristicのvalueをCBATTRequestのvalueにセット
            request.value = self.characteristic.value;
            
            // リクエストに応答
            self.peripheralManager.respondToRequest(request, withResult: CBATTError.Success)
        }
    }
    
    // Writeリクエスト受信時に呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager!, didReceiveWriteRequests requests: [AnyObject]!) {
        
        println("\(requests.count) 件のWriteリクエストを受信！")
        
        for obj in requests {
            
            if let request = obj as? CBATTRequest {
                
                println("Requested value:\(request.value) service uuid:\(request.characteristic.service.UUID) characteristic uuid:\(request.characteristic.UUID)")
                
                if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
                    
                    // CBCharacteristicのvalueに、CBATTRequestのvalueをセット
                    self.characteristic.value = request.value;
                }
            }
        }
        
        // リクエストに応答
        self.peripheralManager.respondToRequest(requests[0] as! CBATTRequest, withResult: CBATTError.Success)
    }
    
    
    // Notify開始リクエスト受信時に呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!)
    {
        println("Notify開始リクエストを受信")
        println("Notify中のセントラル: \(self.characteristic.subscribedCentrals)")
    }
    
    // Notify停止リクエスト受信時に呼ばれる
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!)
    {
        println("Notify停止リクエストを受信")
        println("Notify中のセントラル: \(self.characteristic.subscribedCentrals)")
    }
    
    
    
    
    
    @IBAction func advertiseBtnTap(sender: UIButton) {
        if (!self.peripheralManager.isAdvertising) {
            
            self.startAdvertise()
        }
        else {
            self.stopAdvertise()
        }
        
    }
    
    @IBAction func updateBtn1(sender: UIButton) {
        
        // 新しい値となるNSDataオブジェクトを生成
        //1の値を送ったとき
        let valuemoto = 1
        let value = UInt8(valuemoto & 0xFF)
        data = NSData(bytes: [value] as [UInt8], length: 1)
        
        // 値を更新
        self.characteristic.value = data;
        
        let result =  self.peripheralManager.updateValue(
            data,
            forCharacteristic: self.characteristic,
            onSubscribedCentrals: nil)
        
        println("resultだよ: \(result)")
        
        
        
        self.updateValueLabel()
        
    }
    
    @IBAction func updateBtn2(sender: UIButton) {
        // 新しい値となるNSDataオブジェクトを生成
        //2の値を送ったとき
        let valuemoto = 2
        let value = UInt8(valuemoto & 0xFF)
        data = NSData(bytes: [value] as [UInt8], length: 1)
        
        // 値を更新
        self.characteristic.value = data;
        
        let result =  self.peripheralManager.updateValue(
            data,
            forCharacteristic: self.characteristic,
            onSubscribedCentrals: nil)
        
        println("resultだよ: \(result)")
        
        
        
        self.updateValueLabel()
        
    }
    
    @IBAction func updateBtn3(sender: UIButton) {
        // 新しい値となるNSDataオブジェクトを生成
        //3の値を送ったとき
        let valuemoto = 3
        let value = UInt8(valuemoto & 0xFF)
        data = NSData(bytes: [value] as [UInt8], length: 1)
        
        // 値を更新
        self.characteristic.value = data;
        
        let result =  self.peripheralManager.updateValue(
            data,
            forCharacteristic: self.characteristic,
            onSubscribedCentrals: nil)
        
        println("resultだよ: \(result)")
        
        
        
        self.updateValueLabel()
        
    }
    
    @IBAction func updateBtnRan(sender: UIButton) {
        //ランダムな値を送ったとき
        
        let value = UInt8(arc4random() & 0xFF)
        let data = NSData(bytes: [value] as [UInt8], length: 1)
        self.characteristic.value = data;
        
        let result =  self.peripheralManager.updateValue(
            data,
            forCharacteristic: self.characteristic,
            onSubscribedCentrals: nil)
        
        println("resultだよ: \(result)")
        
        
        
        self.updateValueLabel()
        
        
    }
    
    
    
}
