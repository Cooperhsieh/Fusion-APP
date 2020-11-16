//
//  InstagramSecondPageViewController.swift
//  Fusion APP
//
//  Created by Cooper on 2020/11/16.
//

import UIKit

class InstagramSecondPageViewController: UIViewController {
    
    
    @IBOutlet weak var IGProfilePic: UIImageView!
    @IBOutlet weak var IGPostNumbersLabel: UILabel!
    @IBOutlet weak var IGFansNUmbersLabel: UILabel!
    @IBOutlet weak var IGProfileNameLabel: UILabel!
    @IBOutlet weak var IGProfileInfoLabel: UITextView!
    @IBOutlet weak var IGTableView: UITableView!
    
    var secondPageIGData: InstagramInfo!
    var indexPath: IndexPath!
    var secondPageIGPosts = [InstagramInfo.Graphql.User.Edge_owner_to_timeline_media.Edges]()
    
    
    func updateIGInfo () {
        
        IGPostNumbersLabel.text = String(secondPageIGData.graphql.user.edge_owner_to_timeline_media.count)
        IGFansNUmbersLabel.text = followerNumConverter(secondPageIGData.graphql.user.edge_followed_by.count)
        IGProfileNameLabel.text = " \(secondPageIGData.graphql.user.full_name)"
        IGProfileInfoLabel.text = secondPageIGData.graphql.user.biography
        
        //PICS
        URLSession.shared.dataTask(with: secondPageIGData.graphql.user.profile_pic_url_hd) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self.IGProfilePic.image = UIImage(data: data)
                }
            }
            
        }.resume()
        
    }
    
    func followerNumConverter(_ num: Int) -> String{
        if num > 1000000 {
            return "\(num / 1000000) M"
        } else if num > 1000 {
            return "\(num / 1000) K"
        } else {
            return String(num)
        }
    }
    
    func setBackground () {
        let colour1 = #colorLiteral(red: 1, green: 0.5254901961, blue: 0.1882352941, alpha: 1).cgColor
        let colour2 = #colorLiteral(red: 1, green: 0.2549019608, blue: 0.3019607843, alpha: 1).cgColor
        let colour3 = #colorLiteral(red: 0.8901960784, green: 0.07450980392, blue: 0.4, alpha: 1).cgColor
        let colour4 = #colorLiteral(red: 0.6078431373, green: 0.06666666667, blue: 0.4352941176, alpha: 1).cgColor
        let colour5 = #colorLiteral(red: 0.2862745098, green: 0.06274509804, blue: 0.4745098039, alpha: 1).cgColor
        
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [colour1, colour2, colour3, colour4, colour5]
        gradient.startPoint = CGPoint(x:0.3, y:1.0)
        gradient.endPoint = CGPoint(x:1.0, y:0.0)
        
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    

    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        updateIGInfo()
        setBackground()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        IGTableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
}



// MARK: TABLE VIEW
extension InstagramSecondPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        secondPageIGPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = IGTableView.dequeueReusableCell(withIdentifier: "\(InstagramSecondPageTableViewCell.self)", for: indexPath) as! InstagramSecondPageTableViewCell
        
        let post = secondPageIGPosts[indexPath.row]
        
        //FUll name
        cell.profileNameLabel.text = secondPageIGData.graphql.user.username
        
        //Likes
        let likes = post.node.edge_liked_by?.count
        cell.likeLabel.text = " \(likes!) 個讚"
        
        //Post text，初始可能會是0，因此要做判斷
        cell.postTextView.text = post.node.edge_media_to_caption?.edges.count != 0 ? post.node.edge_media_to_caption?.edges[0].node.text : ""
        
        //post timestamp
        let timeStamp = post.node.taken_at_timestamp
        let postTime = Date(timeIntervalSince1970: timeStamp!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        
        let dateStr = dateFormatter.string(from: postTime)
        cell.postTimeLabel.text = " \(dateStr)"
        
        //Image - ProfilePic
        URLSession.shared.dataTask(with: secondPageIGData.graphql.user.profile_pic_url_hd) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    cell.profilePicImageView.image = UIImage(data: data)
                }
            }
        }.resume()
        
        //Image - PostImage
        let postImageURL = post.node.thumbnail_src
        URLSession.shared.dataTask(with: postImageURL!) { (data, respinse, error) in
            if let data = data {
                DispatchQueue.main.async {
                    cell.postImageView.image = UIImage(data: data)
                }
            }
        }.resume()

        
        
        
        return cell
    }
    
}
