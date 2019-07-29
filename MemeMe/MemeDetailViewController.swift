//
//  MemeDetailViewController.swift
//  MemeMeV1
//
//  Created by Mohamed Metwaly on 2019-03-09.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var meme:Meme!
    var memePosition:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let meme = meme {
            imageView.image = meme.memedImage
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        meme = appDelegate.memes[memePosition]
        imageView.image = meme.memedImage
    }
    
    func editMeme() {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        detailController.meme = self.meme
        detailController.memeIndex = self.memePosition
        self.navigationController?.present(detailController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMeme" {
            let vc = segue.destination as! MemeEditorViewController
            vc.meme = self.meme
            vc.memeIndex = self.memePosition
        }
    }
}
