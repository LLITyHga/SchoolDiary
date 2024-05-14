import UIKit

class NewsArticleCollectionViewCell: UICollectionViewCell {
    
    var readMore : (()->())?
    private var indicator = UIActivityIndicatorView(style: .large)
    var url : URL?
    override func prepareForReuse() {
        imageView.image = nil
        descriptionLabel.isHidden = false
        indicator.startAnimating()
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Bold", size: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Montserrat-Regular", size: 14)
        label.numberOfLines = 0
        return label
    }()
    
     let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Читати більше", for: .normal)
        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Додаємо елементи в комірку
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(expandButton)
        contentView.addSubview(indicator)
        
        // Обмеження для розташування елементів
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.4),
            
            expandButton.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            expandButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            expandButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        // Додаємо дію для кнопки
        expandButton.addTarget(self, action: #selector(toggleDescription), for: .touchUpInside)
    }
    
    @objc private func toggleDescription() {
        readMore?()
    }
    
    func configure(with article: Article) {
        titleLabel.text = article.title
        if article.description == nil {
            descriptionLabel.isHidden = true
        }else{
            descriptionLabel.text = article.description ?? "Опис відсутній"
        }
        if let imageUrlString = article.urlToImage, let imageUrl = URL(string: imageUrlString) {
            // Завантажуємо зображення асинхронно
            downloadImage(from: imageUrl)
        } else {
            imageView.image = nil
        }
        
        // Зброс статусу при конфігурації комірки
        expandButton.setTitle("Читати більше", for: .normal)
    }
    
    private func downloadImage(from url: URL) {
        // Завантаження зображення асинхронно
        self.url = url
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               url == self.url {
                DispatchQueue.main.async { [self] in
                    self.imageView.image = UIImage(data: data)
                    indicator.stopAnimating()
                }
            }
        }
    }
}
