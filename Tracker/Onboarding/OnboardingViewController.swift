//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Ди Di on 24/06/25.
//

import UIKit


final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var onboardingButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.tintColor = .ypWhite
        button.titleLabel?.font = .sfProDisplayMedium16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(didTapOnboardingButton), for: .touchUpInside)
        return button
    }()
    
    lazy var pages: [UIViewController] = {
        let bluePage = UIViewController()
        let bluePageLabel: UILabel = {
            let label = UILabel()
            label.text = "Отслеживайте только\n то, что хотите"
            label.textColor = .ypBlack
            label.font = .sfProDisplayBold32
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let bluePageImage = UIImageView(image: UIImage(named: "bluePage"))
        bluePageImage.contentMode = .scaleAspectFit
        bluePageImage.translatesAutoresizingMaskIntoConstraints = false
        
        bluePage.view.addSubview(bluePageImage)
        bluePage.view.addSubview(bluePageLabel)
        bluePage.view.addSubview(onboardingButton)
        
        NSLayoutConstraint.activate([
            bluePageImage.topAnchor.constraint(equalTo: bluePage.view.topAnchor),
            bluePageImage.bottomAnchor.constraint(equalTo: bluePage.view.bottomAnchor),
            bluePageImage.leadingAnchor.constraint(equalTo: bluePage.view.leadingAnchor),
            bluePageImage.trailingAnchor.constraint(equalTo: bluePage.view.trailingAnchor),
            
            bluePageLabel.leadingAnchor.constraint(equalTo: bluePage.view.leadingAnchor, constant: 16),
            bluePageLabel.trailingAnchor.constraint(equalTo: bluePage.view.trailingAnchor, constant: -16),
            bluePageLabel.bottomAnchor.constraint(equalTo: bluePage.view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
        
        let redPage = UIViewController()
        let redPageLabel: UILabel = {
            let label = UILabel()
            label.text = "Даже если это\n не литры воды и йога"
            label.textColor = .ypBlack
            label.font = .sfProDisplayBold32
            label.textAlignment = .center
            label.numberOfLines = 2
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let redPageImage = UIImageView(image: UIImage(named: "redPage"))
        redPageImage.contentMode = .scaleAspectFit
        redPageImage.translatesAutoresizingMaskIntoConstraints = false
        
        redPage.view.addSubview(redPageImage)
        redPage.view.addSubview(redPageLabel)
        redPage.view.addSubview(onboardingButton)
        
        NSLayoutConstraint.activate([
            redPageImage.topAnchor.constraint(equalTo: redPage.view.topAnchor),
            redPageImage.bottomAnchor.constraint(equalTo: redPage.view.bottomAnchor),
            redPageImage.leadingAnchor.constraint(equalTo: redPage.view.leadingAnchor),
            redPageImage.trailingAnchor.constraint(equalTo: redPage.view.trailingAnchor),
            
            redPageLabel.leadingAnchor.constraint(equalTo: redPage.view.leadingAnchor, constant: 16),
            redPageLabel.trailingAnchor.constraint(equalTo: redPage.view.trailingAnchor, constant: -16),
            redPageLabel.bottomAnchor.constraint(equalTo: redPage.view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
        ])
        
        return [bluePage, redPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        view.addSubview(onboardingButton)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -24),
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func didTapOnboardingButton() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        let trackerViewController = TrackerViewController()
        let navigation = UINavigationController(rootViewController: trackerViewController)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
