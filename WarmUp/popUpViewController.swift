//
//  popUpViewController.swift
//  WarmUp
//
//  Created by Ангелина Плужникова on 08.09.2022.
//

import UIKit

class popUpViewController: UIViewController {
    
    public var lableText = ""
    
    @IBOutlet weak var text: UILabel!
    
    @IBAction func okTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.text = lableText
    }

}
