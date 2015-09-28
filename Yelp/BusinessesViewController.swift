//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let searchBar = UISearchBar()
    
    var businesses: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up search bar in navigation
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.placeholder = "e.g. asian fusion"
        searchBar.sizeToFit()
        
        //set up tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        //begin with a general restaurant search
        Business.searchWithTerm("Restaurants", sort: .BestMatched, categories: nil, radius: 32000, deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCellTableViewCell
        cell.business = businesses[indexPath.row]
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        // set filter pararmeters for categories
        let categories = filters["categories"] as? [String]

        // set filter parameters for sort type
        var sort: YelpSortMode = .BestMatched

        switch filters["sort"] as! Int{
        case 0:
            sort = .BestMatched
        case 1:
            sort = .Distance
        case 2:
            sort = .HighestRated
        default:
            sort = .BestMatched
        }
        
        // set filter parameters for distance (radius in Yelp API)
        var radius = filters["distance"] as? Int
        
        switch filters["distance"] as! Int{
        case 0:
            radius = 500
        case 1:
            radius = 1600
        case 2:
            radius = 8000
        case 3:
            radius = 32000
        default:
            radius = 40000
        }
        
        // set filter parameters for deals on/off
        let deals = filters["deals"] as? Bool
        
        // perform search with filters applied
        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, radius: radius, deals: deals) {(businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    // function to perform search using the Search Bar
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Business.searchWithTerm(searchText) {(businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    // remove keyboard from view when search is cancelled
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

    // remove keyboard from view when search button is tapped
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }

}
