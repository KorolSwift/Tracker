//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Ди Di on 04/07/25.
//

import UIKit


enum PageModel: CaseIterable {
    case first
    case second
    
    var image: UIImage? {
        switch self {
        case .first:
            return UIImage(resource: .bluePage)
        case .second:
            return UIImage(resource: .redPage)
        }
    }
    
    var text: String {
        switch self {
        case .first:
            return NSLocalizedString("blue_onboarding", comment: "")
        case .second:
            return NSLocalizedString("red_onboarding", comment: "")
        }
    }
}

final class OnboardingPageViewController: UIViewController {
    private let model: PageModel
    
    init(model: PageModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: model.image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = model.text
        label.textColor = .ypBlack
        label.font = .sfProDisplayBold32
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
    }
}
