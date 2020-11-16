//
//  InstagramHomeViewController.swift
//  Fusion APP
//
//  Created by Cooper on 2020/11/15.
//

import UIKit

//漸變色網址："https://www.schemecolor.com/in-vogue.php"
//漸變色排序方式："https://www.appcoda.com.tw/cagradientlayer/"

class InstagramHomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var IGData: InstagramInfo!
    var IGPost = [InstagramInfo.Graphql.User.Edge_owner_to_timeline_media.Edges]()
    
    
    //MARK: Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return IGPost.count
    }
    
    //collection view cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InstagramHomePicCollectionViewCell", for: indexPath) as! InstagramHomePicCollectionViewCell
        
        URLSession.shared.dataTask(with: IGPost[indexPath.row].node.thumbnail_src!) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    cell.IGImageView.image = UIImage(data: data)
                }
            }
        }.resume()
       
        return cell
    }
    
    //Reusable View
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let reusableView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "InstagramHeaderCollectionReusableView", for: indexPath) as! InstagramHeaderCollectionReusableView
        
        
        if IGData != nil {
            reusableView.numberOfFansLabel.text = followerNumConverter(IGData.graphql.user.edge_followed_by.count)
            reusableView.profileNameLabel.text = " \(IGData.graphql.user.full_name)"
            reusableView.profileTextView.text = IGData.graphql.user.biography
            reusableView.numberOfPostLabel.text = String(IGData.graphql.user.edge_owner_to_timeline_media.count)
            
            URLSession.shared.dataTask(with: IGData.graphql.user.profile_pic_url_hd) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        reusableView.profilePicImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        return reusableView
    }
    
    //segue to next page
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PostSegue", sender: indexPath)
    }
    
    
    
    //MARK: Fetch IG DATA
    func fetchIGData () {
        InstagramController.shared.fetchInstagramData { result in
            switch result {
            case .success(let igData):
                self.IGData = igData
                self.IGPost = igData.graphql.user.edge_owner_to_timeline_media.edges
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let networkError):
                switch networkError {
                case .requestFailed(let error):
                    print(networkError, error)
                case .invalidUrl, .invalidData, .invalidResponse, .decodingError:
                    print(networkError)
                }
            }
        }
    }
    
    
    //Transfer number to display on IG
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
    
    
    //Modify Collection view square‘s size
    func setCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()
        
        // Header
        flowLayout.headerReferenceSize = CGSize(width: view.frame.width, height: 250)

    
        // Cell
        let cellPerRow: CGFloat = 3
        let cellSpacing: CGFloat = 0
        let lineSpacing: CGFloat = 0
        let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        let widthPerItem = floor((view.frame.width - (sectionInsets.left + sectionInsets.right) - cellSpacing * (cellPerRow - 1) ) / cellPerRow)
        flowLayout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
        
        flowLayout.estimatedItemSize = .zero
        flowLayout.minimumInteritemSpacing = cellSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.sectionInset = sectionInsets
        
        collectionView.collectionViewLayout = flowLayout
    
    }
    
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let sender = sender as! IndexPath
        let controller = segue.destination as! InstagramSecondPageViewController
        controller.indexPath = sender
        controller.secondPageIGData = IGData
        controller.secondPageIGPosts = IGPost
    }
    
    
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackground()
        
        setCollectionViewLayout()
        
        fetchIGData()
    }
    

    

}
