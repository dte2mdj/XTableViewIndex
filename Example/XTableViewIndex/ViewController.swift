//
//  ViewController.swift
//  XTableViewIndex
//
//  Created by Xwg on 11/18/2019.
//  Copyright (c) 2019 Xwg. All rights reserved.
//

import UIKit
import XTableViewIndex

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewIndex: XTableViewIndex!
    
    var sectionTitles: [String] {
        let A = Character("A").asciiValue!
        let Z = Character("Z").asciiValue!
        
        return (A...Z).map { String(format: "%c", $0) }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section + 1) * 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = indexPath.row == 0 ? sectionTitles[indexPath.section] : nil
        cell.detailTextLabel?.text = "\(indexPath)"
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableViewIndex.updateSelectItemWhenTableViewDidScroll(tableView)
    }
}

extension ViewController: XTableViewIndexDataSource {
    func indexTitles(for tableViewIndex: XTableViewIndex) -> [String] {
        return sectionTitles
    }
}

extension ViewController: XTableViewIndexDelegate {
    func tableViewIndex(_ tableViewIndex: XTableViewIndex, didSelectItemAt index: Int) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top, animated: false)
    }
}
