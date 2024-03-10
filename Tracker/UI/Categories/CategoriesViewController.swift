//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Dinara on 04.03.2024.
//

import UIKit
import SnapKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func categoryConfirmed(_ category: TrackerCategory)
}

final class CategoriesViewController: UIViewController {
    private var viewModel: CategoriesViewModel

    // MARK: - Lifecycle
    init(
        delegate: CategoriesViewModelDelegate?,
        selectedCategory: TrackerCategory?
    ) {
        viewModel = CategoriesViewModel(
            selectedCategory: selectedCategory,
            delegate: delegate
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            CategoryCell.self,
            forCellReuseIdentifier: CategoryCell.cellID
        )
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var categoryNotFoundedView: CategoryNotFoundedView = {
        let view = CategoryNotFoundedView()
        return view
    }()

    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Black")
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        updateNotFoundedCategories()
    }
}

private extension CategoriesViewController {
    // MARK: - Setup Views
    func setupViews() {
        navigationItem.title = "Категория"
        view.backgroundColor = UIColor.white

        [tableView,
         categoryNotFoundedView,
         addCategoryButton,
        ].forEach {
            view.addSubview($0)
        }

        viewModel.updateClosure = { [weak self] in
            print("Update closure called")
            guard let self else { return }
            self.tableView.reloadData()
            self.updateNotFoundedCategories()
        }
    }

    // MARK: - Setup Constraints
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(addCategoryButton.snp.top).offset(-16)
        }

        categoryNotFoundedView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(addCategoryButton.snp.top)
        }

        addCategoryButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true, completion: nil)
    }

    func updateNotFoundedCategories()  {
        let isEmpty = viewModel.categories.isEmpty
        tableView.isHidden = isEmpty
        categoryNotFoundedView.isHidden = !isEmpty
    }
}

extension CategoriesViewController: AddCategoryViewControllerDelegate {
    func addedCategory(_ category: TrackerCategory) {
        viewModel.selectCategory(with: category.title)
        viewModel.selectedCategory(category)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.categories.count
        updateNotFoundedCategories()
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.cellID,
            for: indexPath
        ) as? CategoryCell else {
            fatalError("Could not cast to CategoryCell")
        }
        let category = viewModel.categories[indexPath.row].title
        let isSelected = viewModel.selectedCategory?.title != category

        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.cornerRadius = 0

        if indexPath.row == viewModel.categories.count - 1 {
            cell.configureCell(
                with: category
            )
            cell.setRoundedCornersForContentView(top: false,
                                                 bottom: true)
        } else if indexPath.row == 0 {
            cell.configureCell(
                with: category
            )
            cell.setRoundedCornersForContentView(top: true,
                                                 bottom: false)
        } else {
            cell.configureCell(
                with: category
            )
            cell.contentView.layer.maskedCorners = []
            cell.contentView.layer.cornerRadius = 0
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell  {
            cell.checkMarkIconSetup(with: UIImage(named: "checkmark_icon") ?? UIImage())
            let selectedCategoryTitle = cell.getSelectedCategoryTitle()
            viewModel.selectCategory(with: selectedCategoryTitle)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let separatorInset: CGFloat = 16
        let separatorWidth = tableView.bounds.width - separatorInset * 2
        let separatorHeight: CGFloat = 1.0
        let separatorX = separatorInset
        let separatorY = cell.frame.height - separatorHeight

        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1

        if !isLastCell {
            let separatorView = UIView(frame: CGRect(x: separatorX, y: separatorY, width: separatorWidth, height: separatorHeight))
            separatorView.backgroundColor = UIColor(named: "YP Dark Gray")
            cell.addSubview(separatorView)
        }
    }
}
