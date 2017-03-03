//
//  DataCell.swift
//  AlamofireTest
//
//  Created by Fantastic on 03/03/17.
//  Copyright © 2017 Fantastic. All rights reserved.
//

import UIKit
import AlamofireImage

class DataCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(with URLString: String) {
        let size = profileImageView.frame.size
        
        profileImageView.af_setImage(
            withURL: URL(string: URLString)!,
            placeholderImage: nil,
            filter: AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: 0.0),
            imageTransition: .crossDissolve(0.2)
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.af_cancelImageRequest()
        profileImageView.layer.removeAllAnimations()
        profileImageView.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
