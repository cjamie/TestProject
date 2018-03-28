//
//  ViewController.swift
//  TestProject
//
//  Created by Patel, Sanjay on 3/31/17.
//  Copyright © 2017 Patel, Sanjay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var appointments: AppointmentService = AppointmentService.getInstance()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var past:[Appointment] = []
    var future:[Appointment] = []
    var asthmaPast:[Appointment] = []
    var isAsthma:Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appointments.delegate = self
        //will set up all of the uiElements

        // Find Appointments using AppointmentService
        appointments.getAppointments()
        setUpNavBar()
        setUpSegmented()

    }
    @IBAction func toggleOutlet(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:  //all types
            if isAsthma == true{
                isAsthma = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        case 1: //asthma only
            if isAsthma == false{
                isAsthma = true
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        default:
            print("error: default case")
        }
    }
}

extension ViewController: AppointmentServiceDelegate{
    func appointmentsRetrieved(pastAppointmentArray: [Appointment], futureAppointmentArray: [Appointment]) {
        self.past = pastAppointmentArray
        self.future = futureAppointmentArray
        self.asthmaPast = futureAppointmentArray.filter{$0.isAsthmaAppointment!}
    }
}


typealias ViewFunctions = ViewController
typealias CollectionViewFunctions = ViewController
typealias TableViewFunctions = ViewController


extension ViewFunctions{
    func setUpNavBar(){
        navigationController?.navigationBar.barTintColor = UIColor.blue
        
        //white text for title
        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "AvenirNext-DemiBold", size: 22)!
        ]
        navigationController?.navigationBar.titleTextAttributes = attrs
    }
    
    func setUpSegmented(){
        segmentedControl.setTitle("All Types", forSegmentAt: 0)
        segmentedControl.setTitle("Asthma Only", forSegmentAt: 1)
    }
}

extension CollectionViewFunctions: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return future.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath) as? CustomCollectionCell else{
            fatalError("no cell")
        }
        
        //add the shadow (could be an cell extension)
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.55
        cell.layer.shadowRadius = 5.0
        cell.layer.shadowOffset = CGSize(width: 4, height: 4)
        cell.layer.shadowColor = UIColor.gray.cgColor
        
        let element = future[indexPath.row]
        
        guard let specialty = element.providerSpecialty else {fatalError()}
        guard let last = element.providerLastName else {fatalError()}
        guard let date = element.dateAndTime else {fatalError()}
        guard let providerId = element.providerId else {fatalError()}
        
        //using attributed text for timeLabel
        let attributes:[NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 26, weight: UIFont.Weight.medium),
            NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 0.116, green: 0.297, blue: 0.726, alpha: 1)
        ]

        //for message attribute
        let attributes2:[NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium),
            NSAttributedStringKey.foregroundColor : UIColor(displayP3Red: 0.116, green: 0.297, blue: 0.726, alpha: 1)
        ]
        
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MMM d, yyyy"
        let day = dayFormatter.string(from: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let hourMinString = formatter.string(from: date)
        
        let attributedText = NSMutableAttributedString(string: "\t\(day)", attributes: attributes)
        attributedText.append(NSAttributedString(string: "\n\t\(hourMinString)", attributes: attributes2))
        
        //centering my attributed text (using the .addAttribute method)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let length = attributedText.length
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range:
            NSRange(location: 0, length: length))
        
        cell.nameLabel.text =  "Dr. \(last)\n\(specialty)"
        cell.addressLabel.text = element.address
//        cell.timeLabel.text = timestamp //lets make this attributed text
        cell.timeLabel.attributedText = attributedText
        cell.loadObjectImage(name: providerId)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //each side is 16 pixels and the shadow length is 5px
        return CGSize(width: view.frame.width-32-5, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
}

extension TableViewFunctions: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tvCell") as? CustomPastCell
            else{fatalError("no cell")}
        
        //alternating background colors
        cell.backgroundColor = indexPath.row%2 == 0 ? UIColor.lightGray: UIColor.gray
        
        //get rid of highlighting
        cell.selectionStyle = .none
        
        //set up labels
        let element = self.isAsthma ? asthmaPast[indexPath.row] : past[indexPath.row]
        
        
        guard let date = element.dateAndTime else {fatalError()}
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "MMM d, yyyy"
        let day = dayFormatter.string(from: date)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let hourMinString = formatter.string(from: date)
        
        guard let lastName = element.providerLastName else { fatalError()}

        cell.dateLabel.text = day
        cell.descLabel.text = element.providerSpecialty
        cell.timeNameLabel.text = hourMinString + " - Dr. " + lastName
        cell.loadObjectImage(name: element.providerId!)
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isAsthma ?  asthmaPast.count : past.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
}


