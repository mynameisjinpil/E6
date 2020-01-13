//
//  QuestionAnswerViewController.swift
//  E6-0920
//
//  Created by yujinpil on 10/07/2019.
//  Copyright © 2019 jinpil. All rights reserved.
//

import UIKit

class QuestionAnswerViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  
  @IBOutlet var myCollectionView: UICollectionView!
  
  var alert: UIAlertController!
  
  var images:[UIImage]!
  
  var numberOfImages: Int!
  
  var language: String = ""
  
  var sizeOfImages: CGSize!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    images = [UIImage]()
    
    numberOfImages = 5
    
    self.navigationItem.title = "How to use"
    
    let myBackImage = UIImage(named: "album_x")
       let newBackButton = UIBarButtonItem(image: myBackImage,
                                           style: .plain,
                                           target: self,
                                           action: #selector(goBack))
    
    self.navigationItem.leftBarButtonItem = newBackButton
    self.navigationItem.leftBarButtonItem?.tintColor = .black
    
    alert = UIAlertController(title: "언어 선택", message: "언어를 선택하세요", preferredStyle: .alert)
    let hanguel = UIAlertAction(title: "한글", style: .default) { _ in
      self.language = "hanguel"
      for n in 1..<(self.numberOfImages + 1) {
        let image = UIImage(named: "qa_\(n)")
        self.images.append(image!)
      }
      
      self.sizeOfImages = self.images.first?.size
          
      OperationQueue.main.addOperation {
        self.myCollectionView.reloadData()
      }
    }
    let english = UIAlertAction(title: "English", style: .default) { _ in
      self.language = "english"
      
      for n in 1..<(self.numberOfImages + 1) {
             let image = UIImage(named: "qa_\(n)_en")
             self.images.append(image!)
      }
      
      self.sizeOfImages = self.images.first?.size
          
      OperationQueue.main.addOperation {
        self.myCollectionView.reloadData()
      }
    }
    
    alert.addAction(hanguel)
    alert.addAction(english)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.present(alert, animated: false) { () in
    }
  }
  
  @objc func goBack() {
    navigationController?.popViewController(animated: true)
  }
  
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QA Cell",
                                                  for: indexPath) as! QACell

    cell.image.image = images[indexPath.row]
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let comparisonRatio = images.first!.size.width / view.frame.width
    let padding:CGFloat = 10.0
    let navigationHeight: CGFloat! = self.navigationController?.navigationBar.frame.size.height
    let actualHeight = (images.first!.size.height / comparisonRatio) + padding - navigationHeight
    
    return CGSize(width: view.frame.width, height: actualHeight)
  }
}
