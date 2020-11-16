//
//  InstagramSecondPageTableViewCell.swift
//  Fusion APP
//
//  Created by Cooper on 2020/11/16.
//

import UIKit

class InstagramSecondPageTableViewCell: UITableViewCell {
    
    var IGData : InstagramInfo!
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var profileNameLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
