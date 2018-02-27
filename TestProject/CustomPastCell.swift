//
//  CustomPastCell.swift
//  TestProject
//
//  Created by Admin on 2/27/18.
//  Copyright © 2018 Patel, Sanjay. All rights reserved.
//

import UIKit

class CustomPastCell: UITableViewCell{
    
    @IBOutlet weak var timeNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    func loadObjectImage(name:String){
        NetworkService.downloadImage(from: name) {
            [weak self](image, error) in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let image = image else{ return }
            
            DispatchQueue.main.async {
                self?.imgView.layer.cornerRadius = (self?.imgView.frame.size.height)!/2
                self?.imgView.clipsToBounds = true
                self?.imgView.image = image
            }
        }
    }
}
