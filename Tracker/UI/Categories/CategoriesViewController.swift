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
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.dataSource = self
        tableView.delegate = self
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
        if viewModel.categories.isEmpty {
            tableView.backgroundView = categoryNotFoundedView
        }
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.categories.count
        tableView.isHidden = count == .zero

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


        if indexPath.row == 0 {
            cell.configureCell(
                with: category,
                isSelected: isSelected,
                isFirstCell: true
            )
        } else {
            cell.configureCell(
                with: category,
                isSelected: isSelected,
                isFirstCell: false
            )
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryCell else { return }
        let selectedCategoryTitle = cell.getSelectedCategoryTitle()
        viewModel.selectCategory(with: selectedCategoryTitle)
        dismiss(animated: true)
    }
}
