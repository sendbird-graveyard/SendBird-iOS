//
//  OpenChannelListTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/13/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelListTableViewCell: UITableViewCell {
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var participantCountLabel: UILabel!
    
    private var channel: SBDOpenChannel!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    func setRow(row: NSInteger) {
        switch (row % 5) {
        case 0:
            self.leftLineView.backgroundColor = Constants.openChannelLineColorNo0()
            break;
            
        case 1:
            self.leftLineView.backgroundColor = Constants.openChannelLineColorNo1()
            break;
            
        case 2:
            self.leftLineView.backgroundColor = Constants.openChannelLineColorNo2()
            break;
            
        case 3:
            self.leftLineView.backgroundColor = Constants.openChannelLineColorNo3()
            break;
            
        case 4:
            self.leftLineView.backgroundColor = Constants.openChannelLineColorNo4()
            break;
        
        default:
            self.leftLineView.backgroundColor = Constants.openChannelLineColorNo0()
            break;
        }
    }

    func setModel(aChannel: SBDOpenChannel) {
        self.channel = aChannel
        
        self.channelName.text = self.channel.name
        
        if self.channel.participantCount <= 1 {
            self.participantCountLabel.text = String(format: Bundle.sbLocalizedStringForKey(key: "ParticipantSingular"), aChannel.participantCount)
        }
        else {
            self.participantCountLabel.text = String(format: Bundle.sbLocalizedStringForKey(key: "ParticipantPlural"), aChannel.participantCount)
        }
    }
}
