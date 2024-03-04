//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Dinara on 01.03.2024.
//

import UIKit
import SnapKit

final class OnboardingViewController: UIPageViewController {

    // MARK: - Private properties
    private var pages: [UIViewController] = [
        OnboardingPageViewController(
            title: "Отслеживайте только то, что хотите",
            backgroundImage: UIImage(named: "onboarding_background_one")!
        ),
        OnboardingPageViewController(
            title: "Даже если это не литры воды и йога",
            backgroundImage: UIImage(named: "onboarding_background_two")!
        )
    ]

    // MARK: - UI
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(named: "YP Onboarding Gray")
        pageControl.currentPageIndicatorTintColor = UIColor(named: "YP Black")
        return pageControl
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Black")
        return button
    }()

    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: navigationOrientation
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        dataSource = self
        delegate = self

        if let firstPage = pages.first {
            setViewControllers(
                [firstPage],
                direction: .forward,
                animated: true
            )
        }
    }

    override func viewDidLayoutSubviews() {
        continueButton.layer.cornerRadius = 16
    }
}

extension OnboardingViewController {
    @objc func continueButtonTapped() {
        print("onContinueButtonDidTap")
        let viewController = MainTabBarViewController()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = viewController
    }
}

private extension OnboardingViewController {
    // MARK: - Setup Views
    func setupViews() {
        [continueButton,
         pageControl
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-24)
        }

        continueButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-84)
            make.height.equalTo(60)
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }

        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return nil
        }

        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
