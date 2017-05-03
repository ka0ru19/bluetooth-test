////
////  ViewController.swift
////  bluetooth-test
////
////  Created by Wataru Inoue on 2017/05/03.
////  Copyright © 2017年 Wataru Inoue. All rights reserved.
////
//
//import UIKit
//import CoreBluetooth
//
//class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
//    
//    var centralManager: CBCentralManager!
//    var peripheral: CBPeripheral!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
//        
//        // CBCentralManagerを初期化する
//        centralManager = CBCentralManager(delegate: self, queue: nil)
//        
//        // スキャンを開始する
//        centralManager.scanForPeripherals(withServices: nil, options: nil)
//        
//        // スキャンを停止する
//        // centralManager.stopScan()
//        
//        // ペリフェラルへの接続を開始する
//        centralManager.connect(peripheral, options: nil)
//
//        // サービス探索を開始する
//        peripheral.delegate = self
//        peripheral.discoverServices(nil)
//        
//        // キャラクタリスティック探索を開始する
//        peripheral.discoverCharacteristics(nil, for: service)
//
//        // Readを開始する
//        peripheral.readValueForCharacteristic(characteristic)
//
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // セントラルマネージャの状態変化を取得する
//    func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        
//        print("state: \(central.state)")
//    }
//    
//    // スキャン結果を受け取る
//    func centralManager(central: CBCentralManager,
//                        didDiscoverPeripheral peripheral: CBPeripheral,
//                        advertisementData: [String : AnyObject],
//                        RSSI: NSNumber!)
//    {
//        print("peripheral: \(peripheral)")
//    }
//    
//    // 接続結果を取得する: ペリフェラルへの接続が成功すると呼ばれる
//    func centralManager(central: CBCentralManager,
//                        didConnectPeripheral peripheral: CBPeripheral)
//    {
//        print("connected!")
//    }
//    
//    // 接続結果を取得する: ペリフェラルへの接続が失敗すると呼ばれる
//    func centralManager(central: CBCentralManager,
//                        didFailToConnectPeripheral peripheral: CBPeripheral,
//                        error: NSError?)
//    {
//        print("failed...")
//    }
//
//    // サービス探索結果を受け取る
//    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
//        
//        if let error = error {
//            print("error: \(error)")
//            return
//        }
//        
//        let services = peripheral.services
//        print("Found \(services?.count) services! :\(services)")
//    }
//    
//    // キャラクタリスティック探索結果を取得する
//    func peripheral(peripheral: CBPeripheral,
//                    didDiscoverCharacteristicsForService service: CBService,
//                    error: NSError?)
//    {
//        if let error = error {
//            print("error: \(error)")
//            return
//        }
//        
//        let characteristics = service.characteristics
//        print("Found \(characteristics?.count) characteristics! : \(characteristics)")
//    }
//   
//}
//
