//
//  ViewController.swift
//  imagesearch
//
//  Created by ishwaryaraja on 06/08/17.
//  Copyright © 2017 ishwaryaraja. All rights reserved.
//



import UIKit

class ViewController: UIViewController,UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource
{
    
    
    
    let reachability = Reachability()! // to check internet connection
    var exist:Bool = true  // this is used for new search
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var SearchBar: UISearchBar!
    typealias jsonObject = [String:AnyObject]
    var array:[UIImage] = []
        
   
   
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) //searchbar delegate method
    {
        if self.exist == true{ //if the bool is true which is always true
        let imageurl: String = "https://www.googleapis.com/customsearch/v1?q=\(SearchBar.text!)&key=AIzaSyDRW39yCLBNmfDJlTx-J_QXi_ojRfR0l5I&cx=014675809316551014350:ae6qcqdj35i&safe=high&searchType=image"
        
        
        guard let url = URL(string: imageurl)
            else {
                print("error")
                return
        }
        
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if error == nil{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! jsonObject
                    print(json)
                    if let items = json["items"] as? [jsonObject]
                    {
                        for i in 0..<items.count {
                            let item = items[i]
                            
                            if let image = item["image"] as? jsonObject
                            {
                                let thumbnailLink = image["thumbnailLink"]
                                let imageData = thumbnailLink
                                let mainImageURL = URL(string: imageData as! String)
                                let mainImageData = NSData(contentsOf: mainImageURL!)
                                let mainImage = UIImage(data: (mainImageData as Data?)!)
                                self.array.append(mainImage!)
                                print(self.array)
                                if self.array == [] && (self.reachability.whenUnreachable != nil)//if the array is empty then no images found is printed
                                {
                                    let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
                                    label2.center = CGPoint(x: 160, y: 285)
                                    label2.textAlignment = .center
                                    self.view.addSubview(label2)
                                    label2.text = "Images not found"
                                    print("Images not found")
                                }
                                DispatchQueue.main.async {
                                    self.CollectionView?.reloadData()
                                    
                                    
                                }
                            }
                        }
                    }
                }
                catch{
                    print("error")
                }
            }})
        task.resume()
        self.exist = !exist
            array.removeAll()
        }
        else{
            array.removeAll()
            self.exist = !exist
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SearchBar.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)// for the keyboard to resign on a tap
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: 160, y: 285)
        label.textAlignment = .center

        
        reachability.whenReachable = { _ in
            DispatchQueue.main.async {
              print("internet connection available")
                label.isHidden = true
            } }
        reachability.whenUnreachable = { _ in
            DispatchQueue.main.async {
              label.isHidden = false
                self.view.addSubview(label)
                label.text = "Internet connection not available"
                self.view.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) // if there is no internet connection the coloe change occurs
            }}
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return self.array.count
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        cell.ImageView.image = self.array[indexPath.row]
        return cell
    }
    
    
}
