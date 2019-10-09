//
//  CommunityViewController.swift
//  hpa_lunch
//
//  Created by Morgan Dean on 11/30/18.
//  Copyright © 2018 Morgan Dean. All rights reserved.
//

import UIKit
import Alamofire

class CommunityHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variables
    struct Forum {
        var name: String
        var desc: String
        var id: Int
    }
    var forums = [Forum]()
    
    // Outlets
    @IBOutlet weak var forumTable: UITableView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        forumTable.delegate = self
        forumTable.dataSource = self
        // Get category information
        /*let url = "https://lunch.mogdan.xyz/api/forum/categories"
        Alamofire.request(url).responseJSON {response in
            let json = (response.result.value as? NSDictionary) ?? ["err": "error: \(response.result.value ?? "Unknown Error")"]
            if (json.value(forKey: "err") as? String)?.hasPrefix("error:") ?? false {
                // Error!
            } else {
                // no error
                // todo: load cateogry info
                self.forumTable.reloadData()
            }
        }*/
        forums += [Forum(name: "Announcements", desc: "Annoucements forum", id: 23)]
        print(forums)
        self.forumTable.reloadData()

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ForumTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ForumTableCell
        let forum = forums[indexPath.row]
        cell?.forumName.text = forum.name
        cell?.forumDesc.text = forum.desc
        return (cell ?? nil)!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    
            //todo: open forum view thingr
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "CommunityHome")
        viewController.title = "Forum Name"
        self.navigationController!.pushViewController(viewController as UIViewController, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
