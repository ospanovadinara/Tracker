//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Dinara on 16.03.2024.
//

import UIKit
import SnapKit

final class EditCategoryViewController: UIViewController {
    var categoryToEdit: TrackerCategory?
    private let trackerCategoryStore = TrackerCategoryStore()

    // MARK: - UI
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor(named: "YP Black")
        textField.backgroundColor = UIColor(named: "YP TextField Gray")
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.setupLeftView(size: 10)
        textField.text = categoryToEdit?.title
        textField.clearButtonMode = .whileEditing
        textField.addTarget(self, action: #selector(textFieldTapped), for: .editingChanged)
        return textField
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.isEnabled = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }
}

private extension EditCategoryViewController {
    // MARK: - SetupViews
    func setupViews() {
        navigationItem.title = "Редактирование категории"
        view.backgroundColor = UIColor.systemBackground
        textField.becomeFirstResponder()

        [textField,
         doneButton
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: - SetupConstraints
    func setupConstraints() {
        textField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(84)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(75)
        }

        doneButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc func textFieldTapped() {
        if textField.text != "" {
            doneButton.backgroundColor = UIColor(named: "YP Black")
            doneButton.isEnabled = true
        } else {
            doneButton.backgroundColor = UIColor(named: "YP Dark Gray")
            doneButton.isEnabled = false
        }
    }

    @objc func doneButtonTapped() {
        guard let categoryToEdit = categoryToEdit else { return }
        if let newTitle = textField.text {
            try? trackerCategoryStore.updateCategoryTitle(
                newTitle,
                categoryToEdit
            )
            dismiss(animated: true)
        }
    }
}
