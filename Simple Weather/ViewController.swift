//
//  ViewController.swift
//  Simple Weather
//
//  Created by Oremade, Oluwatobi Oluwatomisin on 3/14/16.
//  Copyright © 2016 Oremade, Oluwatobi Oluwatomisin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var validCity = false
    
    var baseURl: String = ""
    
    var cityImages = [UIImage?](repeating: nil, count: 5)
    
    var imageIndex = 0

    @IBAction func submitButton(_ sender: AnyObject) {
        if (cityField.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty){
            weatherLabel.text = "Please enter a valid city."
        }
        else {
            let urlString = URL(string: "http://www.weather-forecast.com/locations/"+cityField.text!.replacingOccurrences(of: " ", with: "-") + "/forecasts/latest")
            baseURl = "https://api.flickr.com/services/rest/?format=json&sort=random&method=flickr.photos.search&tags=" + cityField.text!.replacingOccurrences(of: " ", with: ",") + ",skyline&tag_mode=all&api_key=0e2b6aaf8a6901c264acb91f151a3350&nojsoncallback=1"
            if let url = urlString
            {
            

            
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                if let urlContent = data
                {
                    let htmlContent = NSString(data: urlContent, encoding: String.Encoding.utf8.rawValue)
                    print(htmlContent!)
                    
                    //this splits the string into an array separated by the specified string
                    let htmlArray = htmlContent?.components(separatedBy: "3 Day Weather Forecast Summary:</b><span class=\"read-more-small\"><span class=\"read-more-content\"> <span class=\"phrase\">")
                    if htmlArray!.count>1
                    {
                        let summaryArray = htmlArray![1].components(separatedBy: "</span>")
                        print(summaryArray[0])
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.weatherLabel.text = summaryArray[0].replacingOccurrences(of: "&deg", with: "º")
                        })
                        self.fetchImage()
                    }
                    else{
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.weatherLabel.text = "You may have misspelled the city."
                        })

                    }
                }
                else
                {
                    print("unable to retrieve data. Please check connection")
                }
            }) 
            
            task.resume()
            }
            
            
        }
        
    }
    
    func fetchImage() -> Void {
        self.getInfoFromURLViaRequest(self.baseURl) { (sucess, result: [String: Any]?) -> Void in
            if sucess{
                let nestedDictionary = result?["photos"] as! [String:Any]
                let photoArray = nestedDictionary["photo"] as! [Dictionary<String, Any>]
                
                //populate the local cityImages array
                var i = 0
                while (i < photoArray.count && i < 5)
                {
                    let farmValue = photoArray[i]["farm"]  as! Int
                    let serverValue = photoArray[i]["server"] as! String
                    let photoIDValue = photoArray[i]["id"] as! String
                    let photoSecretValue = photoArray[i]["secret"] as! String
                    
                    //build the url string
                    if let correctUrl = URL(string: "http://farm\(farmValue).static.flickr.com/\(serverValue)/\(photoIDValue)_\(photoSecretValue)_b.jpg")
                    {
                        let newImage = UIImage(data: try! Data(contentsOf: correctUrl))!
                        self.cityImages[i] = newImage
                    }
                    else
                    {
                        print("check url")
                    }
                    i = i + 1
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    UIView.animate(withDuration: 1, animations: { 
                        self.backgroundImage.alpha = 0
                    })
                    self.backgroundImage.image = self.cityImages[self.imageIndex % 5]
                    UIView.animate(withDuration: 3, animations: {
                        self.backgroundImage.alpha = 1
                    })
                })
                self.imageIndex = self.imageIndex + 1
            }
            else
            {
                print("Boo, we failed")
            }
        }
    }
    
    func getInfoFromURLViaRequest(_ url : String, completion: @escaping (_ sucess: Bool, _ result : [String:Any]?)->Void)
    {
        
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if data != nil
            {
                do
                {
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    completion(true, parsedData)
                }
                catch
                {
                    completion(false, nil)
                }
            }
            else
            {
                print("error")
                completion(false, nil)
            }
        })
        task.resume()
        
    }

    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

