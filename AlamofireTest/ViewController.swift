//
//  ViewController.swift
//  AlamofireTest
//
//  Created by Fantastic on 03/03/17.
//  Copyright © 2017 Fantastic. All rights reserved.
//

import UIKit
import Alamofire
import EGOTableViewPullRefreshAndLoadMore

struct Const {
    static let pageNum = 5
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataArray = [DataModel]()
    
    var egoRefreshTableHeaderView: EGORefreshTableHeaderView? = nil
    var isRefreshing: Bool?
    var loadMoreTableFooterView: LoadMoreTableFooterView? = nil
    var isLoadMoreing: Bool?
    var loadMoreCount: Int!
    var totalCount: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.layoutIfNeeded()
        
        isRefreshing = false
        isLoadMoreing = false
        loadMoreCount = 0
        totalCount = 0
        
        if (egoRefreshTableHeaderView == nil)
        {
            egoRefreshTableHeaderView = EGORefreshTableHeaderView(frame: CGRect(x: 0, y: 0 - self.tableView.bounds.size.height, width: self.view.frame.size.width, height: self.view.frame.size.height))
            egoRefreshTableHeaderView?.delegate = self
            
            self.tableView.addSubview(egoRefreshTableHeaderView!)
        }
        egoRefreshTableHeaderView?.refreshLastUpdatedDate()
        
        refreshControlStart()
    }
    
    func refreshControlStart() {
        loadMoreCount = 0
        
        ApiService.sharedInstance.getData(start: 0, count: Const.pageNum, onSuccess: { (response) in
            debugPrint(response)
            
            self.isRefreshing = false
            
            if let result = response.result.value as? NSDictionary{
                if let count = result["total_count"] as? Int {
                    
                    if count <= 0 {
                        self.showAlert(message: "Item not found")
                    } else {
                        self.totalCount = count
                        if let items = result["results"] as? [NSDictionary] {
                            self.dataArray.removeAll(keepingCapacity: false)
                            for item in items {
                                self.dataArray.append(self.getDataModel(dataModel: item))
                            }
                            
                            if (self.loadMoreTableFooterView == nil)
                            {
                                self.loadMoreTableFooterView = LoadMoreTableFooterView(frame: CGRect(x: 0, y: self.tableView.contentSize.height, width: self.view.frame.size.width, height: self.tableView.bounds.size.height))
                                self.loadMoreTableFooterView?.delegate = self
                                self.tableView.addSubview(self.loadMoreTableFooterView!)
                            }
                            
                            self.tableView.reloadData()
                            
                            self.loadMoreTableFooterView?.frame = CGRect(x: 0, y: self.tableView.contentSize.height, width: self.view.frame.size.width, height: self.tableView.bounds.size.height)
                            
                            self.egoRefreshTableHeaderView?.egoRefreshScrollDataSourceDidFinishedLoading(self.tableView)
                        }
                    }
                    
                }
                else {
                    if let message = result["message"] as? String {
                        self.showAlert(message: message)
                        return
                    }
                }
            }
        }, onFailure: { (error) in
            debugPrint(error)
            self.showAlert(message: error.localizedDescription)
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        egoRefreshTableHeaderView?.egoRefreshScrollDidScroll(scrollView)
        if self.dataArray.count < self.totalCount {
            loadMoreTableFooterView?.loadMoreScrollDidScroll(scrollView)
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        egoRefreshTableHeaderView?.egoRefreshScrollDidEndDragging(scrollView)
        if self.dataArray.count < self.totalCount {
            loadMoreTableFooterView?.loadMoreScrollDidEndDragging(scrollView)
        }
        
    }
    
    func getDataModel(dataModel: NSDictionary) -> DataModel {
        let tmpDataModel = DataModel()
        
        if let id = dataModel["id"] as? String {
            tmpDataModel.id = id
        }
        if let type = dataModel["type"] as? String {
            tmpDataModel.type = type
        }
        if let picUrl = dataModel["picUrl"] as? String {
            tmpDataModel.picUrl = picUrl
        }
        if let like_count = dataModel["like_count"] as? Int {
            tmpDataModel.like_count = like_count
        }
        return tmpDataModel
    }
    
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadData(start: Int) {
        ApiService.sharedInstance.getData(start: start, count: Const.pageNum, onSuccess: { (response) in
            debugPrint(response)
            self.isLoadMoreing = false            
            
            if let result = response.result.value as? NSDictionary{
                if let count = result["total_count"] as? Int {
                    
                    if count <= 0 {
                        self.showAlert(message: "Item not found")
                    } else {
                        self.totalCount = count
                        if let items = result["results"] as? [NSDictionary] {
                            for item in items {
                                self.dataArray.append(self.getDataModel(dataModel: item))
                            }
                            
                            if (self.loadMoreTableFooterView == nil)
                            {
                                self.loadMoreTableFooterView = LoadMoreTableFooterView(frame: CGRect(x: 0, y: self.tableView.contentSize.height, width: self.view.frame.size.width, height: self.tableView.bounds.size.height))
                                self.loadMoreTableFooterView?.delegate = self
                                self.tableView.addSubview(self.loadMoreTableFooterView!)
                            }
                            
                            self.tableView.reloadData()
                            
                            self.loadMoreTableFooterView?.frame = CGRect(x: 0, y: self.tableView.contentSize.height, width: self.view.frame.size.width, height: self.tableView.bounds.size.height)
                            
                            self.loadMoreTableFooterView?.loadMoreScrollDataSourceDidFinishedLoading(self.tableView)
                        }
                    }
                    
                }
                else {
                    if let message = result["message"] as? String {
                        self.showAlert(message: message)
                        return
                    }
                }
            }
        }, onFailure: { (error) in
            debugPrint(error)
            self.showAlert(message: error.localizedDescription)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate {
    func egoRefreshTableHeaderDidTriggerRefresh(_ view: EGORefreshTableHeaderView!) {
        isRefreshing = true
        self.refreshControlStart()
    }
    func egoRefreshTableHeaderDataSourceIsLoading(_ view: EGORefreshTableHeaderView!) -> Bool {
        return isRefreshing!
    }
    
    func loadMoreTableFooterDidTriggerLoadMore(_ view: LoadMoreTableFooterView!) {
        
        isLoadMoreing = true
        loadMoreCount = loadMoreCount + 1
        loadData(start: loadMoreCount * Const.pageNum)
    }
    
    func loadMoreTableFooterDataSourceIsLoading(_ view: LoadMoreTableFooterView!) -> Bool {
        return isLoadMoreing!
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let _cell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! DataCell
        
        let item = self.dataArray[indexPath.row]
        var str: String = ""
        if item.type == "cat" {
            if item.like_count! > 0 {
                str = "meows"
            } else {
                str = "meow"
            }
            
        } else if item.type == "dog" {
            if item.like_count! > 0 {
                str = "woofs"
            } else {
                str = "woof"
            }
            
        }
        _cell.lblCount.text = "\(item.like_count!) \(str)"
        _cell.lblID.text = item.id!
        
        if (item.picUrl != nil && item.picUrl != "") {
            _cell.configureCell(with: item.picUrl!)
        }
        
        cell = _cell
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
}

