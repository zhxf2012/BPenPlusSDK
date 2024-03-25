//
//  BPPenCell.swift
//  BPenPLusDemoSwift
//
//  Created by xingfa on 2021/12/28.
//  Copyright © 2021 bbb. All rights reserved.
//

import UIKit
import BPenPlusSDK

class BPPenCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var powerInforLabel: UILabel!
    @IBOutlet weak var penSyncDataModeSegement: UISegmentedControl!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var fireworkLabel: UILabel!
    @IBOutlet weak var fireworkCheckButton: UIButton!
    @IBOutlet weak var fireworkOTAButton: UIButton!
    @IBOutlet weak var unSyncDataPercentInforLabel: UILabel!
    @IBOutlet weak var updateUNSyncDataPercentButton: UIButton!
    @IBOutlet weak var sleepTimeSetButton: UIButton!
    
    @IBOutlet weak var backBgView: UIView!
    @IBOutlet weak var stateStack1: UIStackView!
    @IBOutlet weak var stateStack2: UIStackView!
    @IBOutlet weak var stateStack3: UIStackView!
    @IBOutlet weak var stateStack4: UIStackView!
    
    @IBOutlet weak var startSyncButton: UIButton!
    @IBOutlet weak var clearFlashDataButton: UIButton!
    
    
    static let reuseIdentifier = "kBPPenCellReuseIdentifier"
    
    var pen: BPenModel?
    var connectOrDisConnectHandel: ((BPenModel) -> Void)?
    var penSyncDataModeChangeHandel: ((BPenModel) -> Void)?
    var penFlashHandel: ((BPenModel) -> Void)?
    var fireworkCheckHandel: ((BPenModel) -> Void)?
    var fireworkOTAHandel: ((BPenModel) -> Void)?
    var updateUnSyncDataPercentHandel: ((BPenModel) -> Void)?
    var sleepTimeSetHandel: ((BPenModel) -> Void)?
    var startSyncHandel: ((BPenModel) -> Void)?
    var clearFlashDataniuHandel: ((BPenModel) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backBgView.layer.borderWidth = 0.5
        backBgView.layer.borderColor = UIColor.gray.cgColor
        backBgView.layer.cornerRadius = 3
        
    }
    
    func configWithPen(_ pen:BPenModel) {
        self.pen = pen
        adjustUIForPen(pen)
    }
    
    func adjustUIForPen(_ pen:BPenModel) {
        nameLabel.text = "name:\(pen.name)"
        macLabel.text = "mac:\(pen.mac)"
        if pen.isConnect {
            connectButton.setTitle("断开连接", for: .normal)
            stateStack1.isHidden = false
            stateStack2.isHidden = false
            stateStack3.isHidden = false
            stateStack4.isHidden = false
            penSyncDataModeSegement.selectedSegmentIndex = pen.dataSyncMode.rawValue
            fireworkOTAButton.isEnabled = pen.canUpdateFirmware
            fireworkLabel.text = "固件版本:\(pen.firmwareVersion ?? "-")"
            fireworkCheckButton.isEnabled = !(pen.firmwareVersion?.isEmpty ?? true)
            powerInforLabel.text = "电量:\(pen.powerPercent)%"
            unSyncDataPercentInforLabel.text = "未同步数据占比:\(pen.diskUsedPercent)%"
        } else {
           
            connectButton.setTitle( pen.isInDFU ? "更新固件": "连接设备", for: .normal)
            stateStack1.isHidden = true
            stateStack2.isHidden = true
            stateStack3.isHidden = true
            stateStack4.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func connectButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let connectOrDisConnectHandel = connectOrDisConnectHandel else {
            return
        }
        
        connectOrDisConnectHandel(pen);
    }
    
    @IBAction func swithSyncDataModeSegementValueChanged(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let penSyncDataModeChangeHandel = penSyncDataModeChangeHandel else {
            return
        }
        
        penSyncDataModeChangeHandel(pen);
      //  adjustUIForPen(pen)
    }
    
    @IBAction func flashButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let penFlashHandel = penFlashHandel else {
            return
        }
        
        penFlashHandel(pen);
    }
    
    @IBAction func firewareVersionCheckButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let fireworkCheckHandel = fireworkCheckHandel else {
            return
        }
        
        fireworkCheckHandel(pen);
    }
    
    
    @IBAction func otaButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let fireworkOTAHandel = fireworkOTAHandel else {
            return
        }
        
        fireworkOTAHandel(pen);
    }
    
    @IBAction func updateUnSyncDataPercentButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let updateUNSyncDataPercentHandel = updateUnSyncDataPercentHandel else {
            return
        }
        
        updateUNSyncDataPercentHandel(pen);
    }
    
    @IBAction func sleeptimeSetButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let sleepTimeSetHandel = sleepTimeSetHandel else {
            return
        }
        
        sleepTimeSetHandel(pen);
    }
    
    @IBAction func startSyncButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let startSyncHandel = startSyncHandel else {
            return
        }
        
        startSyncHandel(pen);
    }
    
    @IBAction func clearFlashDataButtonTouched(_ sender: Any) {
        guard let pen = pen else {
            return
        }
        
        guard let clearFlashDataniuHandel = clearFlashDataniuHandel else {
            return
        }
        
        clearFlashDataniuHandel(pen);
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .microseconds(100)) {
            self.updateUnSyncDataPercentButtonTouched(self.updateUNSyncDataPercentButton as Any)
        }
    }
}
