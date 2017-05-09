//
//  TableViewController.swift
//  Metro Navigation
//
//  Created by Anastasia on 06.05.17.
//  Copyright © 2017 Anastasia. All rights reserved.
//

import UIKit

protocol MyTableViewDelegate {
    func setData(_ data: String, to tag: Int)
}

class TableViewController: UIViewController {

    fileprivate var allOfStations: [Station] = []
    fileprivate var filteredStations: [Station] = []
    
    var searchText: String?
    var textFieldTag: Int?
    
    var delegate: MyTableViewDelegate?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in DataManager.instance.getWays() {
            allOfStations.append(contentsOf: item.stations)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        textField.delegate = self
        
        resetFilters()
        
    }

    
    //Private methods
    
    fileprivate func resetFilters() {
        filteredStations = allOfStations.sorted(by: { $0.name < $1.name })
    }
    
    fileprivate func pushData(_ data: String, to tag: Int) {
            delegate?.setData(data, to: tag)
    }

}


extension TableViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = filteredStations[indexPath.row].name
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
     
        pushData(filteredStations[indexPath.row].name, to: textFieldTag ?? 0)
        navigationController?.popViewController(animated: true)
        
    }
    
}


extension TableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        let nsString = textField.text as NSString?
        let updatedString = nsString?.replacingCharacters(in: range, with: string) ?? ""
        
        if updatedString == "" {
            resetFilters()
        } else {
            filteredStations = allOfStations.filter({ $0.name.lowercased().range(of: updatedString.lowercased()) != nil })
        }
        tableView.reloadData()
        
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetFilters()
        tableView.reloadData()
        
        return true
    }
    
}
