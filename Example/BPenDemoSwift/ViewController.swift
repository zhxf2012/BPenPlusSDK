//
//  ViewController.swift
//  BPenDemoSwift
//
//  Created by HFY on 2020/7/18.
//  Copyright © 2020 bbb. All rights reserved.
//

import UIKit
import BPenPlusSDK
import MBProgressHUD


/*
 本类主要展示如下功能的可能交互方式： 1.SDK相关配置 2.与笔的通讯 3.常规内容笔迹点数据的获取 4.功能卡（id卡等）的实现。如果项目中未用到id功能卡，可以无视功能卡的相关实现；上述这些功能的数据模型和业务逻辑以及与sdk的具体交互已经封装到本demo的MyPenDataManager类中； 绘制部分详见DrawViewController
 */

final class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var autoReplayReceivedDataSwtich: UISwitch!
    @IBOutlet weak var batchDataReceivedUserReplayButton: UIButton!
    @IBOutlet weak var autoReconnectSwtich: UISwitch!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var scanIndicator: UIActivityIndicatorView!

    @IBOutlet weak var rawDataActionButton: UIButton!
    @IBOutlet weak var readRawDataButton: UIButton!
    
    @IBOutlet weak var strokeEndPointsFilterSwitch: UISwitch!
    @IBOutlet weak var wrongPageFilterSwtich: UISwitch!
    
    @IBOutlet weak var batchDataPackageConfirmStack: UIStackView!
    
    @IBOutlet weak var batchDataAutoSyncLabel: UILabel!
    
    @IBOutlet weak var batchDataAutoSyncSwtich: UISwitch!
    
    @IBOutlet weak var enableWritinglightSwitch: UISwitch!
    
    @IBOutlet weak var realtimeFramePointCountMaxSegements: UISegmentedControl!
    
    @IBOutlet weak var realtimeFramePointCountMaxStack: UIStackView!
    
    private lazy var drawViewController: DrawViewController = {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DrawViewController") as? DrawViewController else {
            return DrawViewController.init()
        }
        _ = vc.view
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    private var penArray = [BPenModel]()
    var currentConnectPenIndex:Int?
    
    var isSavingRawData = false {
        didSet {
            let title = isSavingRawData ? "结束存储" : "开始存储"
            DispatchQueue.main.async {
                self.rawDataActionButton.setTitle(title, for: .normal)
            }
        }
    }
    
    var currentIdItem: IdCardGridItem?
    var cardAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "BPPenCell", bundle: nil), forCellReuseIdentifier: BPPenCell.reuseIdentifier)
        tableView.tableFooterView = .init()
        
        batchDataPackageConfirmStack.isHidden = true
        
        //MARK: 1.初始化BPenSDK设置
        let penDataManager = MyPenDataManager.shared
        
        /*
         //如需改变sdk的默认行为，可以去掉此处的注释 打开下面的代码以改变SDK的初始配置 如需修改最好在app启动的时候初始化BPenSDK的时候修改初始配置，不建议像本demo这样在运行中动态修改sdk的如下配置
         
         //MARK: 1.1 关闭BPenSDK默认的自动重连智慧笔，行为参照该属性的说明
         penDataManager.configSDKWith(.shouldAutoRecoveryConnect(false))
        
         //MARK: 1.2  关闭BPenSDK默认的SDK自动应答已收到的离线数据包，行为参照该属性的说明
         penDataManager.configSDKWith(.shouldAutoReplyWhenSynchronizeData(false))
         
        */
        
        // 开启减弱勾笔
        //penDataManager.configSDKWith(.shouldFilterPointsNearStrokeEnd(true))
        penDataManager.configSDKWith(.shouldFilterPointsNearStrokeEnd(true))
        strokeEndPointsFilterSwitch.isOn = penDataManager.shouldFilterPointsNearStrokeEnd
        
        
        wrongPageFilterSwtich.isOn = penDataManager.shouldFilterLessAndFastPageChangedPoints
         
        penDataManager.penConnectStateHandel = {[weak self] state in
            switch state {
            
            case .bluetoothUnsupported:
                // 系统会弹框
                break
            case .bluetoothPoweredOff:
                // 系统会弹框
                break
            case .bluetoothUnauthorized:
                self?.showAlert(title: "蓝牙未授权", message: "智能笔需要使用蓝牙，请前往设置-隐私-蓝牙并允许当前app使用蓝牙", confirm: .init(title: "OK", style: .cancel), cancel: nil)
            case .penDiscoveryed(let pen):
                self?.haveFoundNewPen(pen)
            case .penConnected(let result):
                self?.connectPenStateWithResult(result)
            case .penDisConnected(let result):
                self?.disConnectPenStateWithResult(result)
            case .penReadyToUseState(let result):
                if let pen = try? result.get() {
                    self?.sendConfigToPen(pen)
                    self?.canBeUse()
                }
            case .scanStarted:
                self?.adjustScanButton()
            case .scanStoped:
                self?.adjustScanButton()
            }
        }
        
        penDataManager.dataFromPenHandel = {[weak self] (pen,data) in
            switch data {
            case .receivedFirewareVersion:
                    self?.updateCellUIForConnectPen()
            case .receivedSyncDataModeState:
                self?.updateCellUIForConnectPen()
            case .receivedBatteryPercent(_):
                self?.updateCellUIForConnectPen()
            case .receivedDiskUsedPercent(_):
                self?.updateCellUIForConnectPen()
            case .receivedPreciousBindPhone(_):
                break
            case .haveCompletedSyncData:
                print("now data in pen has completed sync to sdk and app")
                self?.requestFlashSpacePercentUpdateForPen(pen)
            case .receivedRealtimePoints(let points):
                self?.haveReceiedRealtimePoints(points)
            case .receivedBatchPoints(let points):
                self?.haveReceiedBatchPoints(points)
            }
        }
        
        
        //
        self.autoReplayReceivedDataSwtich.isOn = MyPenDataManager.shared.shouldAutoReplyWhenSynchronizeData
        
        batchDataAutoSyncSwtich.isOn = true
        adjustConnectType(batchDataAutoSyncSwtich.isOn)
        
        enableWritinglightSwitch.isOn = false
        
        scanButton.layer.borderWidth = 1.0
        scanButton.layer.borderColor = view.tintColor.cgColor
        scanButton.layer.cornerRadius = 3
        
        adjustScanButton()
    }
    
    func adjustConnectType(_ isOn: Bool) {
        MyPenDataManager.shared.connectType = isOn ? BPenConnectTypeDefault : BPenConnectTypeBatchDataAutoSyncClose ;
    }
    
    func haveFoundNewPen(_ pen: BPenModel) {
        if let index = penArray.firstIndex(where: {$0.mac == pen.mac}) {
            debugPrint("has found and replaced the same pen:\(pen.mac) who’s perial may changed")
            penArray.remove(at: index)
            penArray.insert(pen, at: index)
        } else {
            penArray.insert(pen, at: 0)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func connectPenStateWithResult(_ result: PenManager.PenResult) {
        do {
            let pen =  try result.get()
            
            let preciousIndex = currentConnectPenIndex
            currentConnectPenIndex = penArray.firstIndex(where: {$0.mac == pen.mac})
            DispatchQueue.main.async {
                
                var reloadIndexs:[IndexPath] = [];
                if let preciousIndex = preciousIndex {
                    reloadIndexs.append(.init(row: preciousIndex, section: 0))
                }
                
                if let currentConnectPenIndex = self.currentConnectPenIndex {
                    reloadIndexs.append(.init(row: currentConnectPenIndex, section: 0))
                }
                self.tableView.reloadRows(at: reloadIndexs, with: .automatic)
//                self.adjustScanButton()
                self.canBeUse()
            }
            
        } catch  {
            showMessageWithTitle(msg: error.localizedDescription)
        }
    }
    
    func disConnectPenStateWithResult(_ result: PenManager.PenResult) {
        DispatchQueue.main.async {
            do {
                _ = try result.get()
                
                var reloadIndexs:[IndexPath] = [];
                if let currentConnectPenIndex = self.currentConnectPenIndex {
                    reloadIndexs.append(.init(row: currentConnectPenIndex, section: 0))
                }
                self.tableView.reloadRows(at: reloadIndexs, with: .automatic)
                self.currentConnectPenIndex = nil
                
            } catch  {
                self.tableView.reloadData()
                self.showMessageWithTitle(msg: error.localizedDescription)
            }
        }
    }
    
    func sendConfigToPen(_ pen: BPenModel) {
        DispatchQueue.main.async {
            let maxCount = self.realtimeFramePointCountMaxSegements.selectedSegmentIndex + 1;
            var time = DispatchTime.now()
            if(self.enableWritinglightSwitch.isOn) {
                time = time + .microseconds(200)
                DispatchQueue.main.asyncAfter(deadline: time) {
                    MyPenDataManager.shared.orderSendToPen(pen, order: .setEnableWritingLight(true))
                }
            }
            
            //延时100毫秒后设置另外一项
            DispatchQueue.main.asyncAfter(deadline: time + .microseconds(200)) {
                MyPenDataManager.shared.orderSendToPen(pen, order: .setMaxPointCountInRealtimeFrame(maxCount))
            }
        }
    }
    
    func updateCellUIForConnectPen() {
        guard let currentConnectPenIndex = currentConnectPenIndex else {
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [.init(row: currentConnectPenIndex, section: 0)], with: .automatic)
        }
    }
    
    func adjustScanButton()  {
        let isScanning = MyPenDataManager.shared.isScanning
        let title =  isScanning ? "结束扫描" : "扫描棒棒笔"
        
        DispatchQueue.main.async(execute: {
            self.scanButton.setTitle(title, for: .normal)
            if isScanning {
                self.scanIndicator.isHidden = false
                self.scanIndicator.startAnimating()
            } else {
                self.scanIndicator.stopAnimating()
                self.scanIndicator.isHidden = true
            }
        })
    }
    
    func otaWithPenNow(_ pen: BPenModel,fromLocal:Bool){
        if fromLocal {
            let path = Bundle.main.path(forResource: "Ubtech_V24.0.0.zip", ofType: "")!
            let otaOrder: PenManager.OderSendToPen = .otaForPenFromFile(firmwareFile: path,  prepareHandel: {[weak self] (start, end) in
                //固件升级准备中
                if start  {
                    let title = "正在准备升级"
                    let progress = "固件升级准备中"
                    self?.showProgressWith(title, progressMsg: progress)
                } else if end  {
                    self?.hideAllHud()
                }
            }, otaProgress: { [weak self] (percent) in
                //固件升级进度
                let title = "固件升级进度:\(percent)%"
                let progress = "正在升级固件，请勿关闭笔电源，也不要退出App;若升级失败，请重新连接笔并检查更新"
                self?.showProgressWith(title, progressMsg: progress)
            }, completedHandel: { [weak self] (finished, error) in
                //固件升级结果回调
                self?.hideAllHud()
                //升级完成
                if finished {
                    let title = "固件升级完成"
                    let progress = "稍后笔会重启，并自动连接"
                    self?.showMessageWithTitle(title, msg: progress,disapperAfterDelay: 5)
                } else {
                    self?.showMessageWithTitle("固件失败",msg: error?.localizedDescription ?? "未知错误")
                }
            })
            
            MyPenDataManager.shared.orderSendToPen(pen, order: otaOrder)
        } else {
            //MARK: 13.2  固件更新
            let otaOrder: PenManager.OderSendToPen = .otaForPen(loadFireworkProgress: {[weak self] (percent) in
                // 固件下载进度
                let title = "正在加载固件"
                let progress = "固件加载进度:\(percent)%"
                self?.showProgressWith(title, progressMsg: progress)
            }, prepareHandel: {[weak self] (start, end) in
                //固件升级准备中
                if start  {
                    let title = "正在准备升级"
                    let progress = "固件升级准备中"
                    self?.showProgressWith(title, progressMsg: progress)
                } else if end  {
                    self?.hideAllHud()
                }
            }, otaProgress: { [weak self] (percent) in
                //固件升级进度
                let title = "固件升级进度:\(percent)%"
                let progress = "正在升级固件，请勿关闭笔电源，也不要退出App;若升级失败，请重新连接笔并检查更新"
                self?.showProgressWith(title, progressMsg: progress)
            }, completedHandel: { [weak self] (finished, error) in
                //固件升级结果回调
                self?.hideAllHud()
                //升级完成
                if finished {
                    let title = "固件升级完成"
                    let progress = "稍后笔会重启，并自动连接"
                    self?.showMessageWithTitle(title, msg: progress,disapperAfterDelay: 5)
                } else {
                    self?.showMessageWithTitle("固件失败",msg: error?.localizedDescription ?? "未知错误")
                }
            })
            
            MyPenDataManager.shared.orderSendToPen(pen, order: otaOrder)
        }
    }
    
    //MARK: 13  检测固件版本并更新
    func checkFirmworkVersion(_ sender: BPenModel) {
        //MARK: 13.1  检测固件版本更新
        self.showProgressWith("检查新固件", progressMsg: "正在检测是否有新固件版本")
         MyPenDataManager.shared.orderSendToPen(sender, order: .checkFireworkForPenWithHandel({[weak self] (version, error) in
            self?.hideAllHud()
            if let error = error {
                self?.showAlert(title: "Failed", message: error.localizedDescription, confirm: nil, cancel:.init(title: "OK", style: .cancel, handler: { _ in
                }))
            } else {
                if let version = version {
                    let confirm = UIAlertAction.init(title: "升级在线固件", style: .default) { [weak self] _ in
                        self?.otaWithPenNow(sender, fromLocal: false)
                    }
                    let cancel = UIAlertAction.init(title: "升级到本地固件", style: .cancel) { _ in
                        self?.otaWithPenNow(sender, fromLocal: true)
                    }
                    self?.showAlert(title: "检测到新的固件版本", message: "当前连接的笔可以升级到新固件：\(version)", confirm: confirm, cancel: cancel)
                } else {
                    self?.showAlert(title: nil, message: "当前连接的笔已经是最新固件,需要升级到本地固件?", confirm: nil, cancel: UIAlertAction.init(title: "升级到本地固件", style: .default) { _ in
                        self?.otaWithPenNow(sender, fromLocal: true)
                    })
                }
            }
        }))
    }
    
    //MARK: 10 设置笔休眠时间
    func setSleepTimeForPen(_ pen: BPenModel) {
        DispatchQueue.main.async {
            let alert = UIAlertController.init(title: "设置笔休眠时间", message: "笔休眠时间可以设置为1 - 255分钟，超出范围将分别取上下限", preferredStyle: .alert)
            alert.addTextField { (text) in
                text.keyboardType = .decimalPad
                text.placeholder = "请输入1至255之间的数字作"
            }
            
            alert.addAction(.init(title: "OK", style: .default, handler: { (_) in
                if let minutesString = alert.textFields?.first?.text,let minutes = Int.init(minutesString) {
                     MyPenDataManager.shared.orderSendToPen(pen, order: .setSleepTime(minutes))
                }
            }))
            self.present(alert, animated: true) {
                
            }
        }
    }
    
    func requestFlashSpacePercentUpdateForPen(_ pen:BPenModel) {
        MyPenDataManager.shared.orderSendToPen(pen, order: .askPenToUpdateDiskUsedPercent)
    }
    
    @IBAction func strokeEndPointsFilterSwitchOn(_ sender: Any) {
        MyPenDataManager.shared.configSDKWith(.shouldFilterPointsNearStrokeEnd(self.strokeEndPointsFilterSwitch.isOn))
    }
    
    @IBAction func wrongPageFilterSwtichOn(_ sender: Any) {
        MyPenDataManager.shared.configSDKWith(.shouldFilterLessAndFastPageChangedPoints(self.wrongPageFilterSwtich.isOn))
    }
    
    @IBAction func autoReconnectPenBySDK(_ sender: Any) {
        MyPenDataManager.shared.configSDKWith(.shouldAutoRecoveryConnect(self.autoReconnectSwtich.isOn))
    }
    
    //MARK: 9 .关闭sdk自动应答批量数据接收 ，若关闭则需应用层应答
    //应用层开启自动应答或关闭自动应答示例
    @IBAction func batchDataRecivedReplaySwtichChanged(_ sender: Any) {
        //开启SDK自动应答，则无需客服端应答
        MyPenDataManager.shared.configSDKWith(.shouldAutoReplyWhenSynchronizeData(self.autoReplayReceivedDataSwtich.isOn))
    }
    
    //MARK: 9.1  应用层自行应答示例
    //仅当关闭SDK的批量数据接收自动应答时（即MyPenManager的shouldAutoReplyWhenSynchronizeData为false），客户端可以调用应答操作，否则不执行任何操作（即MyPenManager的shouldAutoReplyWhenSynchronizeData为true）。
   //收到离线数据包时可以应答 ，不一定由用户的操作触发应答，客服端可以在收到离线数据回调中notifyBatchPointData处理好收到的数据，应答一次，然后后会收到下一个批量数据包
   // 如果SDK的shouldAutoReplyWhenSynchronizeData配置为false又不在适当的时候调用应答方法replyForBatchDataReceived，笔和sdk将不发送一下一个批量数据包，直到应答为止
    @IBAction func receivedDataReplayForPen(_ sender: Any) {
        guard let pen = MyPenDataManager.shared.currentConnectPen else {
            return
        }
        
        MyPenDataManager.shared.orderSendToPen(pen, order: .ackWhenBatchDataPackageFinished)
    }
    
    //MARK: 2.扫描笔或结束扫描
    @IBAction func scanButtonTouched(_ sender: Any) {
        if MyPenDataManager.shared.isScanning {
            //结束扫描
            MyPenDataManager.shared.makePenConnectAction(.stopScan)
        } else {
            self.penArray.removeAll { pen in
                return !pen.isConnect
            }
            tableView.reloadData()
            //启动扫描
            MyPenDataManager.shared.makePenConnectAction(.startScan)
        }
//        adjustScanButton()
    }
    
    @IBAction func drawButtonTouched(_ sender: Any) {
        canBeUse(true)
    }
    
    @IBAction func batchDataAutoSyncSwitchValueChanged(_ sender: Any) {
        var msg = ""
        if batchDataAutoSyncSwtich.isOn {
            MyPenDataManager.shared.connectType = BPenConnectTypeDefault
            msg = "已切换连接方式为：连接后自动同步笔内flash上的数据."
        } else {
            MyPenDataManager.shared.connectType = BPenConnectTypeBatchDataAutoSyncClose
            msg = "已切换连接方式为：连接后不自动同步，需要应用层手动同步笔内flash上的数据.目前B8系列固件版本20及以上支持此行为"
        }
        showMessageWithTitle(msg: msg + "\n下次连接笔时生效",disapperAfterDelay: 3)
    }
    //MARK: 8 .笔上的灯闪一闪
    func flashButtonTouched(_ pen: BPenModel) {
         MyPenDataManager.shared.orderSendToPen(pen, order: .askPenFlashlight)
    }
    
    func canBeUse(_ force:Bool = false) {
        guard (MyPenDataManager.shared.currentConnectPen != nil) || force else {
            return
        }
    
        DispatchQueue.main.async(execute: {
            guard self.drawViewController.presentingViewController == nil else {
                return
            }
            
            self.present(self.drawViewController, animated: true)
        })
    }
    
    func haveReceiedRealtimePoints(_ points:[BPPoint],force:Bool = false) {
        
        debugPrint("realtimeData pointsCount:\(points.count)")
       // debugPrint(points,#function,#line)
        
        // 功能卡相关代码------开始
             //如未用到功能卡请忽略这部分
        var idItem: IdCardGridItem?
        points.forEach { point in
            if let value = IdItemListManager.shared.chectIdCartWithPoint(point) {
                idItem = value
            }
        }
        
        if let resultId = idItem {
             // 已识别到id编号
            debugPrint("已识别到功能卡上的id编码：\(resultId.id),请自行对应你们模型的唯一标识符")
            
             showAlertForItem(resultId)
            
        } else {
            debugPrint("普通的内容笔迹点，可以绘制")
        }
        // 功能卡相关代码------结束
        canBeUse(force)
        
        DispatchQueue.main.async(execute: {
            self.drawViewController.realTimeDrawing(points)
        })
    }
    
    func haveReceiedBatchPoints(_ points:[BPPoint],force:Bool = false) {
       canBeUse(force)
        
        //debugPrint(points,#function,#line)
        debugPrint("haveReceiedBatchPoints pointsCount:\(points.count)")
        DispatchQueue.main.async(execute: {
            self.drawViewController.realTimeDrawing(points)

//            //收到一个批次的批量数据时可以更新离线数据量
            if !MyPenDataManager.shared.shouldAutoReplyWhenSynchronizeData {
                self.batchDataReceivedUserReplayButton.isEnabled = true
            }
        })
    }
    
    func rawDataToTestFile() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/test"
    }
    
    @IBAction func beginToSaveRawDataToFile(_ sender: Any) {
        if !isSavingRawData {
            let path = self.rawDataToTestFile()
            MyPenDataManager.shared.makePenConnectAction( .beginSaveToFile(path, handel: {[weak self] finished, error in
                if let error = error {
                    self?.showMessageWithTitle(msg: error.localizedDescription)
                } else {
                    self?.isSavingRawData = true;
                }
            }))
        } else {
            MyPenDataManager.shared.makePenConnectAction( .endSave({[weak self] finished, error in
                if let error = error {
                    self?.showMessageWithTitle(msg: error.localizedDescription)
                } else {
                    self?.isSavingRawData = false
                }
            }))
        }
    }
    
    var RawdataFromBundleTryTimes = 0
    @IBAction func readRawDataFromFile(_ sender: Any) {
        var path =  self.rawDataToTestFile()
        if !FileManager.default.fileExists(atPath: path) {
            //let defaultTestFileName = (RawdataFromBundleTryTimes % 2 == 0 ) ? "rawData_saved_by_ios_bpensdk" : "rawData_saved_by_android_bpensdk"
            let defaultTestFileName =  "dots7"
            path = Bundle.main.path(forResource: defaultTestFileName, ofType: nil)!
            RawdataFromBundleTryTimes += 1
        }
        
        MyPenDataManager.shared.makePenConnectAction(.readDataFromRawfile(path, delegate: self, handel:({[weak self] finished, error in
            if let error = error {
                self?.showMessageWithTitle(msg: error.localizedDescription)
            }
        })))
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return penArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let pen = penArray[indexPath.row]
        return pen.isConnect ? 180 : 54
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BPPenCell.reuseIdentifier, for: indexPath) as? BPPenCell else {
            fatalError("should check tableView have register for identifier:\(BPPenCell.reuseIdentifier)")
        }
        
        let thePen = penArray[indexPath.row]

        cell.configWithPen(thePen)
        
        cell.connectOrDisConnectHandel = {[weak self] pen in
            if(pen.isInDFU) {
                self?.showAlert(title: "笔处于恢复模式", message: "笔处于恢复模式，需要升级到最新版", confirm: .init(title: "更新固件", style: .default, handler: { _ in
                    self?.otaWithPenNow(pen,fromLocal: true)
                }), cancel: .init(title: "取消", style: .cancel, handler: nil))
            } else {
                if pen.isConnect {
                    MyPenDataManager.shared.makePenConnectAction(.penDisconnect)
                } else {
                    MyPenDataManager.shared.makePenConnectAction(.penConnect(pen))
                }
            }
        }
        
        cell.penSyncDataModeChangeHandel = {pen in
            if pen.dataSyncMode == .BatchPointData {
                MyPenDataManager.shared.orderSendToPen(pen, order: .setSyncDataMode(.RealTime))
            } else {
                MyPenDataManager.shared.orderSendToPen(pen, order: .setSyncDataMode(.BatchPointData))
            }
        }
        
        cell.penFlashHandel = { pen in
             MyPenDataManager.shared.orderSendToPen(pen, order: .askPenFlashlight)
        }
        
        cell.fireworkCheckHandel = {[weak self] pen in
            self?.checkFirmworkVersion(pen)
        }
        
        cell.fireworkOTAHandel = {[weak self] pen in
            self?.otaWithPenNow(pen,fromLocal: false)
        }
        
        cell.updateUnSyncDataPercentHandel = { [weak self]  pen in
            self?.requestFlashSpacePercentUpdateForPen(pen)
        }
        
        cell.sleepTimeSetHandel = {[weak self] pen in
            self?.setSleepTimeForPen(pen)
        }
        
        cell.startSyncHandel = {pen in
            MyPenDataManager.shared.orderSendToPen(pen, order: .startSynchronizationBatchDatas)
        }
        
        cell.clearFlashDataniuHandel = {pen in
            MyPenDataManager.shared.orderSendToPen(pen, order: .clearFlashDataInPen)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK: id功能卡相关的实现
extension ViewController {
    func showAlertForItem(_ resultId: IdCardGridItem) {
        if resultId.id != currentIdItem?.id {
             //更换id 去掉之前的提示
            DispatchQueue.main.async(execute: {
                self.cardAlert?.dismiss(animated: true, completion: {
                     
                })
                self.cardAlert = nil
            })
             
        } else {
            //已经显示过提示
            if self.cardAlert != nil {
                return
            }
        }
        
        let itemNo = (resultId.row-1) * resultId.colCount + resultId.col
        var itemInfor = "编号是：\(itemNo)"
        if let idItemList = IdItemListManager.shared.getIdItemListFrom(type: resultId.type, pageid: resultId.pageId),((itemNo - 1) < idItemList.items.count) {
            let item = idItemList.items[itemNo - 1]
            itemInfor = "已选择学生:\(item.name)\n学号是：\(item.id)"
        }
        let message = "当前点击的是id卡\(resultId.type.rawValue)-\(resultId.pageId)的第\(resultId.row)行第\(resultId.col),\(resultId.id)"
        let alert = showAlert(title: itemInfor, message: message, confirm: .init(title: "OK", style:.cancel, handler: { _ in
        }), cancel: nil)
        
        currentIdItem = resultId
        cardAlert = alert
    }
}

extension ViewController:BPenRawDataDelegate {
    func realtimeData(fromPen penMac: String, points: [BPPoint]) {
         haveReceiedRealtimePoints(points,force: true)
    }
    
    func batchData(fromPen penMac: String, points: [BPPoint]) {
         haveReceiedBatchPoints(points,force: true)
    }
}
