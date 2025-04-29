//
//  MyPenDataManager.swift
//  BPenDemoSwift
//
//  Created by HFY on 2020/7/18.
//  Copyright © 2020 bbb. All rights reserved.
//

import UIKit
import BPenPlusSDK

/// 此类为sdk的对接实现的数据管理类，可用于：1.管理sdk的相关配置 2. 笔的发现连接流程 3.发送给笔的数据 4.笔返回的数据 ； 此类会随着sdk的迭代而扩展迭代，且在demo中开源，客户可以直接使用，但不建议大幅度修改（可向提供方提出修改意见）；  OC的客户可以混编此类或者参照此类的实现来对接sdk

enum PenManager {
    
    // MARK: - 0. 笔管理相关的错误类型
    enum  PenDataError: LocalizedError{
        case unknow
        case unconnectPen
        case firewareTooLow
        case otherError(Error)
        case erroWithMessage(String)
        
        var errorDescription: String? {
            switch self {
            case .unconnectPen:
                return "未连接智慧笔"
            case .firewareTooLow:
                return "固件版本过低"
            case .otherError(let error):
                return error.localizedDescription
            case .erroWithMessage(let msg):
                return msg
            case .unknow:
                return "未知错误"
            }
        }
    }
    
    typealias PenResult = Result<BPenModel,PenManager.PenDataError>
    
    // MARK: - 1. SDK的相关设置 ,不设置将采用SDK默认值
    enum PenManagerConfig {
        case shouldAutoRecoveryConnect(_ auto: Bool)
        case shouldAutoReplyWhenSynchronizeData(_ auto: Bool)
        case shouldFilterPointsNearStrokeEnd(_ auto: Bool)
        case shouldFilterLessAndFastPageChangedPoints(_ auto: Bool)
    }
    
    // MARK: - 2.  笔的发现连接操作等
    enum PenConnectAction {
        case startScan
        case stopScan
        case penConnect(_ pen:BPenModel)
        case penDisconnect
        case beginSaveToFile(_ file:String, handel: ((Bool,Error?) -> Void))
        case endSave(_ handel: ((Bool,Error?) -> Void))
        case readDataFromRawfile(_ filePath: String,delegate:BPenRawDataDelegate,handel: ((Bool,Error?) -> Void))
    }
    
    // MARK: - 3.  笔的连接状态等
    enum PenConnectState {
        case bluetoothUnsupported     //手机端设备不支持蓝牙 如某些老款ipad可能无蓝牙模块，或者设备蓝牙损坏
        case bluetoothPoweredOff      //手机端设备未开启蓝牙
        case bluetoothUnauthorized     //手机端设备系统未授权app使用蓝牙
        
        case scanStarted  //开始扫描
        case scanStoped   // 停止扫描
        
        case penDiscoveryed(_ pen: BPenModel)  //发现智慧笔
        case penConnected(_ result: PenResult)  //连接上笔
        case penDisConnected(_ result: PenResult) // 笔断开连接
        case penReadyToUseState(_ result: PenResult) //笔准备好可以工作
    }
    
    // MARK: - 4. 发送给笔的指令
    enum OderSendToPen {
        case setSleepTime(_ sleepAfterSeconds:Int)    // 设置笔休眠时间为sleepAfterSeconds
        case setSyncDataMode(_ mode:SynchronizationMode) // 设置笔的数据同步模式为mode
        case setShouldReportCameraCoveredState(_ shouldReport:Bool) // 设置笔是否报告笔尖附件的摄像头被不当握笔姿势遮挡
        case askPenFlashlight                        // 命令笔上的灯闪一闪
        case askPenToUpdateDiskUsedPercent           // 命令笔更新闪存使用情况
        case ackWhenBatchDataPackageFinished          //批量数据不由SDK自动应答时，每收到一包应手动应答一次
        case checkFireworkForPenWithHandel(_ hande: ((String?, Error?) -> Void)) //检查笔是否有新固件版本
        case otaForPen(loadFireworkProgress: ((Int32) -> Void)?,prepareHandel:((Bool,Bool) -> Void)?,otaProgress:((Int32) -> Void)?,completedHandel:((Bool,Error?) -> Void)?)
        case otaForPenFromFile(firmwareFile:String,prepareHandel:((Bool,Bool) -> Void)?,otaProgress:((Int32) -> Void)?,completedHandel:((Bool,Error?) -> Void)?)
        case startSynchronizationBatchDatas         //发送给笔，可以开始同步数据了
        case clearFlashDataInPen            //直接清除笔内的数据
        case setEnableWritingLight(_ enable:Bool) // 设置笔是否开启书写时状态指示灯
        case setMaxPointCountInRealtimeFrame(_ maxCount:Int) // 设置笔是否开启书写时状态指示灯
        case setExposureTime(_ exposureTime:Int) // 设置笔的曝光时间，详见sdk说明
    }
    
    // MARK: - 5. 从笔接收的数据或状态
    enum DataReceivedFromPen {
        case receivedFirewareVersion           // 笔报告且已更新currentConnectPen的固件版本
        case receivedSyncDataModeState         // 笔报告且已更新currentConnectPen的数据同步模式
        case receivedBatteryPercent(_ percent:Int)                 // 笔报告电池电量剩余百分比
        case receivedDiskUsedPercent(_ percent:Int)                // 笔报告自身闪存已用百分比
        case receivedPreciousBindPhone(_ last4NumberOfPhone:String) // 笔报告之前绑定的手机号 （如已绑定过连接后会返回此数据，绑定功能已废弃，故通常不会有此回调）
        case haveCompletedSyncData                       // 笔报告批量数据传输完
        case receivedRealtimePoints(_ points:[BPPoint])            // 笔返回实时数据点
        case receivedBatchPoints(_ points:[BPPoint])               // 笔返回批量数据点
    }
}

class MyPenDataManager {
    static let shared = MyPenDataManager()
    
    private let manager = BPenManager.init()
    
    //连接笔之后的同步方式，修改后会在下次连接笔时生效
    var connectType: BPenConnectType = BPenConnectTypeDefault
    
    var shouldAutoRecoveryConnect: Bool {
        return manager.shouldAutoRecoveryConnect
    }

    var shouldAutoReplyWhenSynchronizeData: Bool {
        return manager.shouldAutoReplyWhenSynchronizeData
    }
    
    var shouldFilterLessAndFastPageChangedPoints: Bool {
        return manager.shouldFilterLessAndFastPageChangedPoints
    }
    
    var shouldFilterPointsNearStrokeEnd:Bool {
        return manager.shouldFilterPointsNearStrokeEnd
    }
    
    func configSDKWith(_ config:PenManager.PenManagerConfig) {
        switch config {
        case .shouldAutoRecoveryConnect(let auto):
            manager.shouldAutoRecoveryConnect = auto
        case .shouldAutoReplyWhenSynchronizeData(let auto):
            manager.shouldAutoReplyWhenSynchronizeData = auto
        case .shouldFilterPointsNearStrokeEnd(let should):
            manager.shouldFilterPointsNearStrokeEnd = should
        case .shouldFilterLessAndFastPageChangedPoints(let should):
            manager.shouldFilterLessAndFastPageChangedPoints = should
        }
    }
    
    fileprivate lazy var proxy: PenManagerProxy = {
         let item = PenManagerProxy.init(manager: self)
         return item
     }()
    
    init() {
        manager.delegate = proxy
        manager.drawDelegate = proxy
        //manager.smoothLevel = BPenSmoothLevelNone
    }
    
    var isScanning: Bool {
        return manager.isScanning
    }
    
    var currentConnectPen: BPenModel? {
        return manager.currentConnectPen
    }

   // 笔的扫描发现连接等状态回调
    var penConnectStateHandel:((PenManager.PenConnectState) -> Void)?
    
    // 笔的扫描发现连接等操作
    func makePenConnectAction(_ action: PenManager.PenConnectAction) {
        switch action {
        case .startScan:
            manager.startScan()
        case .stopScan:
            manager.stopScan()
        case .penConnect(let pen):
            manager.connect(pen,connectType: connectType)
        case .penDisconnect:
            manager.disconnect()
        case .beginSaveToFile(let paht, handel: let handel):
            manager.beginSaveRawData(toFile: paht, completedHandel: handel)
        case .endSave(let handel):
            manager.endSaveRawData(completedHandel: handel)
        case .readDataFromRawfile(let path, delegate: let delegate, handel: let handel):
            manager.readRawData(fromFile: path, dataDelegate: delegate, completedHandel: handel)
        }
        
       // manager.checkNewFirmwareVersion(handel: T##((String?, Error?) -> Void)?##((String?, Error?) -> Void)?##(String?, Error?) -> Void)
    }
    
    // 笔的数据指令通讯回调
    var dataFromPenHandel: ((BPenModel,PenManager.DataReceivedFromPen) -> Void)?
    
    // 向笔发送相关指令
    @discardableResult
    func orderSendToPen(_ pen: BPenModel,order: PenManager.OderSendToPen) -> Result<PenManager.OderSendToPen,PenManager.PenDataError> {
        guard  (pen.isConnect && pen == currentConnectPen) || (pen.isInDFU) else {
            return .failure(.unconnectPen)
        }
    
        switch order {
        case .setSleepTime(let time):
            if pen.shortFirmwareVersionNumber < 512 {
                return .failure(.firewareTooLow)
            } else {
                manager.setPenSleepTime(Int32(time))
            }
        case .setSyncDataMode(let mode):
            manager.switchSynchronizationModel(mode)
        case .askPenFlashlight:
            manager.notifyFlashLight()
        case .ackWhenBatchDataPackageFinished:
            manager.replyForBatchDataReceived()
        case .askPenToUpdateDiskUsedPercent:
            manager.askPenToUpdateUnSynchronizationDataPercentToPenDisk()
        case .checkFireworkForPenWithHandel(let handel):
            //#if USEBPenPlusSDK
            manager.checkNewFirmwareVersion(handel: handel)
//            #else
//            handel(nil,PenManager.PenDataError.erroWithMessage("BPenSDK不提供固件版本检测和升级的功能，请使用带OTA升级能力的加强版SDK BPenPlusSDK"))
//            #endif
        case .otaForPen(loadFireworkProgress: let loadFireworkProgress, prepareHandel: let prepareHandel, otaProgress: let otaProgress, completedHandel: let completedHandel):
          //  #if USEBPenPlusSDK
            manager.ota(withPen: pen, loadFirmwareProgress: loadFireworkProgress, prepareHandel: prepareHandel, otaProgressHandel: otaProgress, completedHandel: completedHandel)
//            #else
//            completedHandel?(false,PenManager.PenDataError.erroWithMessage("BPenSDK不提供固件版本检测和升级的功能，请使用带OTA升级能力的加强版SDK BPenPlusSDK"))
//            #endif
        case .setShouldReportCameraCoveredState(let report):
            manager.setShouldReportCameraCoveredState(report)
        case .otaForPenFromFile(firmwareFile: let firmwareFile, prepareHandel: let prepareHandel, otaProgress: let otaProgress, completedHandel: let completedHandel):
//            #if USEBPenPlusSDK
            manager.ota(withPen: pen, loadFirmwareFromFile: firmwareFile, prepareHandel: prepareHandel, otaProgressHandel: otaProgress, completedHandel: completedHandel)
//            #else
//            completedHandel?(false,PenManager.PenDataError.erroWithMessage("BPenSDK不提供固件版本检测和升级的功能，请使用带OTA升级能力的加强版SDK BPenPlusSDK"))
//            #endif
        case .clearFlashDataInPen:
            manager.cleanBatchDataInPen()
        case .startSynchronizationBatchDatas:
            manager.startSynchronizationBatchDatas()
        case .setEnableWritingLight(let enable):
            manager.setEnableWritingLight(enable)
        case .setMaxPointCountInRealtimeFrame(let maxCount):
            manager.setRealtimeMaxOutPointsCountEachFrame(Int32(maxCount))
        case .setExposureTime(let exposureTime):
            manager.setExposureTime(Int32(exposureTime))
        }
        
        return .success(order)
    }
}

/// 此类的目的仅仅是用于隐藏对BPenManagerDelegate和BPenManagerDrawDelegate的实现，避免MyPenDataManager直接遵循这两个公开协议而在外边可见这些协议定义的方法,同时避免MyPenDataManager对象必须遵循NSObject类(因为BPenManagerDelegate和BPenManagerDrawDelegate继承自NSObjectProtocol)
fileprivate class PenManagerProxy: NSObject {
    unowned let manager: MyPenDataManager
    
    required init(manager: MyPenDataManager) {
        self.manager = manager
        super.init()
    }
}

extension PenManagerProxy: BPenManagerDelegate {
    /**=================可选实现的方法开始===================**/
    //此处要有回调需要在连接后调用 shouldReportCameraCoveredState
    func notifyCameraHasBeenCovered() {
        print("笔的摄像头被遮挡");
    }

    func accelerometerDataSendFromPen(onXYZ ax: Float, ay: Float, az: Float, rotation: Int16) {
        print("握笔姿势,加速度向量ax:\(ax),ay:\(ay),az:\(az), 纸笔相对角rotation:\(rotation)");
    }
    
    func notifyPenChargeState(_ chargeState: BPChargeState) {
       // print(isCharging ?  "笔当前在充电中" : "笔当前没有在充电");
        switch chargeState {
         
        case .ChargeStateNoCharge:
            print("笔当前没有在充电");
        case .ChargeStateInCharging:
            print("笔当前在充电中");
        case .ChargeStateFullPower:
            print("笔当前已充满电");
        @unknown default:
            break;
        }
    }
    
    /**=================可选实现的方法结束===================**/
    
    /**=================必须实现的方法开始===================**/
    func didStartScan() {
        manager.penConnectStateHandel?(.scanStarted)
    }
    
    func didStopScan() {
        manager.penConnectStateHandel?(.scanStoped)
    }
    
    func didDiscover(withPen model: BPenModel) {
        manager.penConnectStateHandel?(.penDiscoveryed(model))
    }
    
    func didConnectSuccess() {
        if let pen = manager.currentConnectPen {
            manager.penConnectStateHandel?(.penConnected(.success(pen)))
            
            //开启笔报告鼻尖摄像头是否被遮挡 需要笔的固件支持，若不支持则无效果，详见此命令的说明
        //    manager.orderSendToPen(pen, order: .setShouldReportCameraCoveredState(true))
        }
    }
    
    func didConnectFail(_ error: Error?) {
        let aError = (error == nil) ? PenManager.PenDataError.unknow : PenManager.PenDataError.otherError(error!)
        manager.penConnectStateHandel?(.penConnected(.failure(aError)))
    }
    
    func didDisconnect(_ model: BPenModel, error: Error?) {
        if let error = error {
            manager.penConnectStateHandel?(.penDisConnected(.failure(.otherError(error))))
        } else {
            manager.penConnectStateHandel?(.penDisConnected(.success(model)))
        }
    }
    
    func notifyBattery(_ battery: Int) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        manager.dataFromPenHandel?(pen,.receivedBatteryPercent(battery))
    }
    
    func unSynchronizationDataPercent(toPenDisk percent: Float) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        manager.dataFromPenHandel?(pen,.receivedFirewareVersion)
    }
    
    func synchronizationDataDidCompleted() {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        manager.dataFromPenHandel?(pen,.haveCompletedSyncData)
    }
    
    func notifyFirmwareVersion(_ currentVersion: String) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        assert(pen.firmwareVersion == currentVersion, "sdk对currentConnectPen的版本信息未正确更新")
        manager.dataFromPenHandel?(pen,.receivedFirewareVersion)
    }
    
    func notifyDataSynchronizationMode(_ mode: SynchronizationMode) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        assert(pen.dataSyncMode  == mode, "sdk对currentConnectPen的数据同步模式未正确更新")
        manager.dataFromPenHandel?(pen,.receivedSyncDataModeState)
    }
    
    func notifyBluetoothPoweredOff() {
        manager.penConnectStateHandel?(.bluetoothPoweredOff)
    }
    
    func notifyBluetoothUnsupported() {
        manager.penConnectStateHandel?(.bluetoothUnsupported)
    }
    
    func notifyBluetoothUnauthorized() {
        manager.penConnectStateHandel?(.bluetoothUnauthorized)
    }
    
    func notifyContinueToUseSuccess() {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            manager.penConnectStateHandel?(.penReadyToUseState(.failure(PenManager.PenDataError.unconnectPen)))
            return
        }
        manager.penConnectStateHandel?(.penReadyToUseState(.success(pen)))
    }
    
    func notifyContinueToUseFail() {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            manager.penConnectStateHandel?(.penReadyToUseState(.failure(PenManager.PenDataError.unconnectPen)))
            return
        }
        manager.penConnectStateHandel?(.penReadyToUseState(.failure(.unconnectPen)))
    }
    
    func notifyVerifyPhoneNumber(_ endOfTheNumber: String) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        
        manager.dataFromPenHandel?(pen,.receivedPreciousBindPhone(endOfTheNumber))
    }
    /**=================必须实现的方法结束===================**/
}

extension PenManagerProxy: BPenManagerDrawDelegate {
    func notifyWrittingBatchPointData(_ pointDrawArray: [BPPoint]) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        // TODO: 可以在此处保存批量模式或者离线书写时的数据到本地文件或者数据库中，也可以整理好数据后发往服务器后台
           // 保存数据 发往后台等
        
        manager.dataFromPenHandel?(pen,.receivedBatchPoints(pointDrawArray))
    }
    
    func notifyOfflineBatchPointData(_ pointDrawArray: [BPPoint], remainPackages: Int) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        // TODO: 可以在此处保存批量模式或者离线书写时的数据到本地文件或者数据库中，也可以整理好数据后发往服务器后台
           // 保存数据 发往后台等
        
        manager.dataFromPenHandel?(pen,.receivedBatchPoints(pointDrawArray))
    }
    
    func notifyRealTimePointData(_ pointDrawArray: [BPPoint]) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        // TODO: 可以在此处保存实时数据到本地文件或者数据库中，也可以整理好数据后发往服务器后台
           // 保存数据 发往后台等
        
        // 下面的回调中可以实现绘制等界面操作
        manager.dataFromPenHandel?(pen,.receivedRealtimePoints(pointDrawArray ))
    }
    
    func notifyBatchPointData(_ pointDrawArray: [BPPoint]) {
        guard let pen = manager.currentConnectPen else {
            print("\(PenManager.PenDataError.unconnectPen)",#function)
            return
        }
        // TODO: 可以在此处保存批量模式或者离线书写时的数据到本地文件或者数据库中，也可以整理好数据后发往服务器后台
           // 保存数据 发往后台等
        
        manager.dataFromPenHandel?(pen,.receivedBatchPoints(pointDrawArray))
    }
}
