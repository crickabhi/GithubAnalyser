//
//  ProfileInfoTableViewCell.swift
//  GithubAnalyser
//
//  Created by Abhinav Mathur on 12/11/17.
//  Copyright © 2017 crickabhi. All rights reserved.
//

import UIKit

class ProfileInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var location: UILabel?
    @IBOutlet weak var lastUpdated: UILabel?
    @IBOutlet weak var publicRepoCount: UILabel?
    @IBOutlet weak var publicRepoLabel: UILabel?
    @IBOutlet weak var followersCount: UILabel?
    @IBOutlet weak var followersLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
