//
//  SongTableViewCell.swift
//  Fusion APP
//
//  Created by Cooper on 2020/11/13.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var songName: UILabel!
    
    //解決圖片過大在load的時候會閃一下的問題
    var task: URLSessionTask?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumImage.image = nil
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
