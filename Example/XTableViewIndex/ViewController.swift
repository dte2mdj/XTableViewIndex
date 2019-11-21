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
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    
    }

}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitles.count - section + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath)"
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
        tableView.indexPathsForVisibleRows?
            .map { $0.section }
            .removeDuplicates()
            .forEach {
                tableView.headerView(forSection: $0)?.textLabel?.textColor = getSectionTextColor($0)
        }
        
        tableViewIndex.updateSelectItemWhenTableViewDidScroll(tableView)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader")
        header?.textLabel?.text = sectionTitles[section]
        header?.textLabel?.textColor = getSectionTextColor(section)
        return header
    }
    
    func isTopSection(_ section: Int) -> Bool {
        return (tableView.indexPathForRow(at: tableView.contentOffset)?.section ?? 0) == section
    }
    func getSectionTextColor(_ section: Int) -> UIColor {
        return isTopSection(section) ? .red : .blue
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScroll(scrollView)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate else { return }
        scrollViewDidEndScroll(scrollView)
    }
    func scrollViewDidEndScroll(_ scrollView: UIScrollView) {
        print("停止了。。。")
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

// MARK: - Methods
public extension Array where Element: Equatable {
    /// 去重：Return array with all duplicate elements removed.
    ///
    ///     [1, 1, 2, 2, 3, 3, 3, 4, 5].removeDuplicates() -> [1, 2, 3, 4, 5])
    ///     ["h", "e", "l", "l", "o"].removeDuplicates() -> ["h", "e", "l", "o"])
    ///
    /// - Returns: an array of unique elements.
    func removeDuplicates() -> [Element] {
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }
}
