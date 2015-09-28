//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 9/23/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filter: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate, SegmentedControlCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    var dealState = false
    var categories: [[String:String]]!
    var categoriesExpanded = false
    var switchStates = [Int:Bool]()
    var sortState: Int = 0
    var distanceState: Int = 3
    var filters = [String : AnyObject]()
    
    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
        
        var selectedCategories = [String]()
        
        for(row, isSelected) in switchStates{
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        filters["deals"] = dealState
        filters["sort"] = sortState
        filters["distance"] = distanceState
        
        // pass data back to the BusinessViewController inside filters
        delegate?.filtersViewController?(self, didUpdateFilters: filters)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = yelpCategories()
        tableView.dataSource = self
        tableView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // set up sections
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Deals"
        case 1:
            return "Distance"
        case 2:
            return "Sort By"
        case 3:
            return "Categories"
        default:
            return "Other"
        }
    }
    
    // configure individual sections
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 1
        case 3:
            // includes a "See All" button initially
            if categoriesExpanded == false {
                return 3
            } else {
            return categories.count
            }
        default:
            return 1
        }
    }
    
    // set up section cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        
        // deal section - single switch cell
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = "Offering a Deal"
            cell.onSwitch.on = dealState
            cell.delegate = self
            return cell
            
        // distance section - segmented control options
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("SegmentedControlCell", forIndexPath: indexPath) as! SegmentedControlCell
            cell.segmentedControl.removeAllSegments()
            cell.segmentedControl.insertSegmentWithTitle("0.3 miles", atIndex: 0, animated: false)
            cell.segmentedControl.insertSegmentWithTitle("1 miles", atIndex: 1, animated: false)
            cell.segmentedControl.insertSegmentWithTitle("5 miles", atIndex: 2, animated: false)
            cell.segmentedControl.insertSegmentWithTitle("20 miles", atIndex: 3, animated: false)
            cell.segmentedControl.selectedSegmentIndex = distanceState
            cell.delegate = self
            return cell
            
        // sort type section - segmented control options
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("SegmentedControlCell", forIndexPath: indexPath) as! SegmentedControlCell
            cell.segmentedControl.removeAllSegments()
            cell.segmentedControl.insertSegmentWithTitle("Best match", atIndex: 0, animated: false)
            cell.segmentedControl.insertSegmentWithTitle("Distance", atIndex: 1, animated: false)
            cell.segmentedControl.insertSegmentWithTitle("Highest rated", atIndex: 2, animated: false)
            cell.segmentedControl.selectedSegmentIndex = sortState
            cell.delegate = self
            return cell
            
        // categories section - expanding table of multiple switch cells
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = switchStates[indexPath.row] ?? false
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.switchLabel.text = categories[indexPath.row]["name"]
            cell.delegate = self
            cell.onSwitch.on = switchStates[indexPath.row] ?? false
            return cell
        }
    }
    
    // footer in section 3 for categories "See All" expansion
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section{
        case 3:
            if categoriesExpanded == false {
                let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
                footerView.backgroundColor = UIColor.whiteColor()
                let expandButton = UIButton(frame: CGRectMake(0, 0, tableView.frame.size.width, 40))
                expandButton.setTitle("See All", forState: UIControlState.Normal)
                expandButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                expandButton.addTarget(self, action: "expandButton:", forControlEvents: UIControlEvents.TouchUpInside)
                footerView.addSubview(expandButton)
                return footerView
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    func expandButton(sender:UIButton){
        self.categoriesExpanded = true
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section{
        case 3:
            if categoriesExpanded == false {
                return 40.0
            } else {
                return 0.0
            }
        default:
            return 0.0
        }
    }
    
    // extracting user input from switch cells
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        
        let indexPath = tableView.indexPathForCell(switchCell)!
        switch indexPath.section {
        case 0:
            dealState = value
        case 3:
            switchStates[indexPath.row] = value
        default: break
        }

    }
    
    // extracting user input from segmented control cells
    func segmentedControlCell(segmentedControlCell: SegmentedControlCell, didChangeValue value: Int) {
        let indexPath = tableView.indexPathForCell(segmentedControlCell)!
        switch indexPath.section {
        case 1:
            distanceState = value
        case 2:
            sortState = value
        default: break
        }
    }
    
    // yelp categories
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
            ["name" : "African", "code": "african"],
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "American, Traditional", "code": "tradamerican"],
            ["name" : "Arabian", "code": "arabian"],
            ["name" : "Argentine", "code": "argentine"],
            ["name" : "Armenian", "code": "armenian"],
            ["name" : "Asian Fusion", "code": "asianfusion"],
            ["name" : "Asturian", "code": "asturian"],
            ["name" : "Australian", "code": "australian"],
            ["name" : "Austrian", "code": "austrian"],
            ["name" : "Baguettes", "code": "baguettes"],
            ["name" : "Bangladeshi", "code": "bangladeshi"],
            ["name" : "Barbeque", "code": "bbq"],
            ["name" : "Basque", "code": "basque"],
            ["name" : "Bavarian", "code": "bavarian"],
            ["name" : "Beer Garden", "code": "beergarden"],
            ["name" : "Beer Hall", "code": "beerhall"],
            ["name" : "Beisl", "code": "beisl"],
            ["name" : "Belgian", "code": "belgian"],
            ["name" : "Bistros", "code": "bistros"],
            ["name" : "Black Sea", "code": "blacksea"],
            ["name" : "Brasseries", "code": "brasseries"],
            ["name" : "Brazilian", "code": "brazilian"],
            ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
            ["name" : "British", "code": "british"],
            ["name" : "Buffets", "code": "buffets"],
            ["name" : "Bulgarian", "code": "bulgarian"],
            ["name" : "Burgers", "code": "burgers"],
            ["name" : "Burmese", "code": "burmese"],
            ["name" : "Cafes", "code": "cafes"],
            ["name" : "Cafeteria", "code": "cafeteria"],
            ["name" : "Cajun/Creole", "code": "cajun"],
            ["name" : "Cambodian", "code": "cambodian"],
            ["name" : "Canadian", "code": "New)"],
            ["name" : "Canteen", "code": "canteen"],
            ["name" : "Caribbean", "code": "caribbean"],
            ["name" : "Catalan", "code": "catalan"],
            ["name" : "Chech", "code": "chech"],
            ["name" : "Cheesesteaks", "code": "cheesesteaks"],
            ["name" : "Chicken Shop", "code": "chickenshop"],
            ["name" : "Chicken Wings", "code": "chicken_wings"],
            ["name" : "Chilean", "code": "chilean"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Comfort Food", "code": "comfortfood"],
            ["name" : "Corsican", "code": "corsican"],
            ["name" : "Creperies", "code": "creperies"],
            ["name" : "Cuban", "code": "cuban"],
            ["name" : "Curry Sausage", "code": "currysausage"],
            ["name" : "Cypriot", "code": "cypriot"],
            ["name" : "Czech", "code": "czech"],
            ["name" : "Czech/Slovakian", "code": "czechslovakian"],
            ["name" : "Danish", "code": "danish"],
            ["name" : "Delis", "code": "delis"],
            ["name" : "Diners", "code": "diners"],
            ["name" : "Dumplings", "code": "dumplings"],
            ["name" : "Eastern European", "code": "eastern_european"],
            ["name" : "Ethiopian", "code": "ethiopian"],
            ["name" : "Fast Food", "code": "hotdogs"],
            ["name" : "Filipino", "code": "filipino"],
            ["name" : "Fish & Chips", "code": "fishnchips"],
            ["name" : "Fondue", "code": "fondue"],
            ["name" : "Food Court", "code": "food_court"],
            ["name" : "Food Stands", "code": "foodstands"],
            ["name" : "French", "code": "french"],
            ["name" : "French Southwest", "code": "sud_ouest"],
            ["name" : "Galician", "code": "galician"],
            ["name" : "Gastropubs", "code": "gastropubs"],
            ["name" : "Georgian", "code": "georgian"],
            ["name" : "German", "code": "german"],
            ["name" : "Giblets", "code": "giblets"],
            ["name" : "Gluten-Free", "code": "gluten_free"],
            ["name" : "Greek", "code": "greek"],
            ["name" : "Halal", "code": "halal"],
            ["name" : "Hawaiian", "code": "hawaiian"],
            ["name" : "Heuriger", "code": "heuriger"],
            ["name" : "Himalayan/Nepalese", "code": "himalayan"],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
            ["name" : "Hot Dogs", "code": "hotdog"],
            ["name" : "Hot Pot", "code": "hotpot"],
            ["name" : "Hungarian", "code": "hungarian"],
            ["name" : "Iberian", "code": "iberian"],
            ["name" : "Indian", "code": "indpak"],
            ["name" : "Indonesian", "code": "indonesian"],
            ["name" : "International", "code": "international"],
            ["name" : "Irish", "code": "irish"],
            ["name" : "Island Pub", "code": "island_pub"],
            ["name" : "Israeli", "code": "israeli"],
            ["name" : "Italian", "code": "italian"],
            ["name" : "Japanese", "code": "japanese"],
            ["name" : "Jewish", "code": "jewish"],
            ["name" : "Kebab", "code": "kebab"],
            ["name" : "Korean", "code": "korean"],
            ["name" : "Kosher", "code": "kosher"],
            ["name" : "Kurdish", "code": "kurdish"],
            ["name" : "Laos", "code": "laos"],
            ["name" : "Laotian", "code": "laotian"],
            ["name" : "Latin American", "code": "latin"],
            ["name" : "Live/Raw Food", "code": "raw_food"],
            ["name" : "Lyonnais", "code": "lyonnais"],
            ["name" : "Malaysian", "code": "malaysian"],
            ["name" : "Meatballs", "code": "meatballs"],
            ["name" : "Mediterranean", "code": "mediterranean"],
            ["name" : "Mexican", "code": "mexican"],
            ["name" : "Middle Eastern", "code": "mideastern"],
            ["name" : "Milk Bars", "code": "milkbars"],
            ["name" : "Modern Australian", "code": "modern_australian"],
            ["name" : "Modern European", "code": "modern_european"],
            ["name" : "Mongolian", "code": "mongolian"],
            ["name" : "Moroccan", "code": "moroccan"],
            ["name" : "New Zealand", "code": "newzealand"],
            ["name" : "Night Food", "code": "nightfood"],
            ["name" : "Norcinerie", "code": "norcinerie"],
            ["name" : "Open Sandwiches", "code": "opensandwiches"],
            ["name" : "Oriental", "code": "oriental"],
            ["name" : "Pakistani", "code": "pakistani"],
            ["name" : "Parent Cafes", "code": "eltern_cafes"],
            ["name" : "Parma", "code": "parma"],
            ["name" : "Persian/Iranian", "code": "persian"],
            ["name" : "Peruvian", "code": "peruvian"],
            ["name" : "Pita", "code": "pita"],
            ["name" : "Pizza", "code": "pizza"],
            ["name" : "Polish", "code": "polish"],
            ["name" : "Portuguese", "code": "portuguese"],
            ["name" : "Potatoes", "code": "potatoes"],
            ["name" : "Poutineries", "code": "poutineries"],
            ["name" : "Pub Food", "code": "pubfood"],
            ["name" : "Rice", "code": "riceshop"],
            ["name" : "Romanian", "code": "romanian"],
            ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
            ["name" : "Rumanian", "code": "rumanian"],
            ["name" : "Russian", "code": "russian"],
            ["name" : "Salad", "code": "salad"],
            ["name" : "Sandwiches", "code": "sandwiches"],
            ["name" : "Scandinavian", "code": "scandinavian"],
            ["name" : "Scottish", "code": "scottish"],
            ["name" : "Seafood", "code": "seafood"],
            ["name" : "Serbo Croatian", "code": "serbocroatian"],
            ["name" : "Signature Cuisine", "code": "signature_cuisine"],
            ["name" : "Singaporean", "code": "singaporean"],
            ["name" : "Slovakian", "code": "slovakian"],
            ["name" : "Soul Food", "code": "soulfood"],
            ["name" : "Soup", "code": "soup"],
            ["name" : "Southern", "code": "southern"],
            ["name" : "Spanish", "code": "spanish"],
            ["name" : "Steakhouses", "code": "steak"],
            ["name" : "Sushi Bars", "code": "sushi"],
            ["name" : "Swabian", "code": "swabian"],
            ["name" : "Swedish", "code": "swedish"],
            ["name" : "Swiss Food", "code": "swissfood"],
            ["name" : "Tabernas", "code": "tabernas"],
            ["name" : "Taiwanese", "code": "taiwanese"],
            ["name" : "Tapas Bars", "code": "tapas"],
            ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
            ["name" : "Tex-Mex", "code": "tex-mex"],
            ["name" : "Thai", "code": "thai"],
            ["name" : "Traditional Norwegian", "code": "norwegian"],
            ["name" : "Traditional Swedish", "code": "traditional_swedish"],
            ["name" : "Trattorie", "code": "trattorie"],
            ["name" : "Turkish", "code": "turkish"],
            ["name" : "Ukrainian", "code": "ukrainian"],
            ["name" : "Uzbek", "code": "uzbek"],
            ["name" : "Vegan", "code": "vegan"],
            ["name" : "Vegetarian", "code": "vegetarian"],
            ["name" : "Venison", "code": "venison"],
            ["name" : "Vietnamese", "code": "vietnamese"],
            ["name" : "Wok", "code": "wok"],
            ["name" : "Wraps", "code": "wraps"],
            ["name" : "Yugoslav", "code": "yugoslav"]]
    }

}
