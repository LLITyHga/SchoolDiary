//
//  NewsVC.swift
//  SchoolDiary
//
//  Created by Wolf on 25.04.2024.
//

import Foundation
import UIKit

class NewsVC: UIViewController {
    
    private var collectionView: UICollectionView!
    private var indicator = UIActivityIndicatorView(style: .large)
    private var articles: [Article] = []
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
                let layout = UICollectionViewFlowLayout()

                layout.minimumLineSpacing = 8
        

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
                //collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                collectionView.delegate = self
                collectionView.dataSource = self

                collectionView.register(NewsArticleCollectionViewCell.self, forCellWithReuseIdentifier: "NewsArticleCell")

                view.addSubview(collectionView)
        view.addSubview(indicator)
        indicator.startAnimating()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        collectionView.backgroundColor = .clear
                loadNewsData()
    }
    private func loadNewsData() {
        
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=ua&category=science&apiKey=a41d58d563484d238e4c73f8081c8504") else {return}
            URLSession.shared.dataTask(with: url) { [self] data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let data = data else {
                    return
                }
                do{
                    let news = try JSONDecoder().decode(NewsModel.self, from: data)
                    for i in news.articles{
                        self.articles.append(i)
                    }
                    DispatchQueue.main.async { [self] in
                        indicator.stopAnimating()
                        collectionView.reloadData()
                    }
                }catch{
                    print(error)
                }
            }.resume()
        }
        
    }
}

extension NewsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(articles.count)
        return articles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsArticleCell", for: indexPath) as? NewsArticleCollectionViewCell else {
            return UICollectionViewCell() // Повернути порожню комірку в разі помилки
        }

        cell.backgroundColor = .clear
        let article = articles[indexPath.row]
        cell.configure(with: article) 
        cell.readMore = {
            () in
            if let url = URL(string: article.url ?? ""), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }else{
                print("Неможливо відкрити URL")
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let article = articles[indexPath.row]
            
            let collectionViewWidth = collectionView.bounds.width
            let contentWidth = collectionViewWidth - 20 // Відступ з обох сторін
            
        let titleHeight = (article.title?.height(withConstrainedWidth: contentWidth, font: UIFont(name: "Montserrat-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 18)))!
            
        let descriptionHeight = (article.description?.height(withConstrainedWidth: contentWidth, font: UIFont(name: "Montserrat-Regular", size: 14) ?? UIFont.boldSystemFont(ofSize: 18))) ?? 0
        let imageHeight = screenHeight * 0.25
            
        let totalHeight = imageHeight + titleHeight + descriptionHeight 
            
            return CGSize(width: collectionViewWidth, height: totalHeight)
        }
    
    @IBAction func backBTN(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}
