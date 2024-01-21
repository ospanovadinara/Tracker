//
//  CreateHabitViewController.swift
//  Tracker
//
//  Created by Dinara on 02.12.2023.
//

import UIKit
import SnapKit

protocol CreateHabitViewControllerDelegate: AnyObject {
    func createButtonidTap(tracker: Tracker, category: String)
    func reloadData()
    func cancelButtonDidTap()
}

final class CreateHabitViewController: UIViewController {

    // MARK: - ScheduleViewControllerDelegate
    weak var scheduleViewControllerdelegate: ScheduleViewControllerDelegate?
    weak var createHabitViewControllerDelegate: TrackersViewController?

    // MARK: - Private properties
    private var selectedWeekDays: [WeekDay] = []
    private var trackers: [Tracker] = []
    private let emojis: [String] = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    private let colors: [UIColor] = [
        AppColor.color1.uiColor, AppColor.color2.uiColor, AppColor.color3.uiColor,
        AppColor.color4.uiColor, AppColor.color5.uiColor, AppColor.color6.uiColor,
        AppColor.color7.uiColor, AppColor.color8.uiColor, AppColor.color9.uiColor,
        AppColor.color10.uiColor, AppColor.color11.uiColor, AppColor.color12.uiColor,
        AppColor.color13.uiColor, AppColor.color14.uiColor, AppColor.color15.uiColor,
        AppColor.color16.uiColor, AppColor.color17.uiColor, AppColor.color18.uiColor
    ]

    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    // MARK: -  UI
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var textFieldContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var trackersNameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textAlignment = .left
        textField.placeholder = "Введите название трекера"
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.rightView = clearTextFieldButton
        textField.rightViewMode = .whileEditing
        return textField
    }()


    private lazy var clearTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "clear_icon"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clearTextFieldButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CreateHabitCell.self,
                           forCellReuseIdentifier: CreateHabitCell.cellID)
        tableView.backgroundColor = UIColor(named: "YP Gray")?.withAlphaComponent(0.3)
        tableView.layer.cornerRadius = 16
        return tableView
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(EmojiCell.self,
                                forCellWithReuseIdentifier: EmojiCell.cellID)
        collectionView.register(EmojiHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: EmojiHeader.cellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false

        return collectionView
    }()

    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(ColorCell.self,
                                forCellWithReuseIdentifier: ColorCell.cellID)
        collectionView.register(ColorHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ColorHeader.cellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "YP Red"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor(named: "YP Red")?.cgColor
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16,
                                                    weight: .medium)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(named: "YP Dark Gray")
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleViewControllerdelegate = self
        setupViews()
        setupConstraints()
        checkCorrectness()
    }

    // MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = UIColor.white

        scrollView.addSubview(contentView)
        view.addSubview(scrollView)

        [navBarLabel,
         textFieldContainerView,
         tableView,
         emojiCollectionView,
         colorCollectionView,
         buttonStackView
        ].forEach  {
            contentView.addSubview($0)
        }

        textFieldContainerView.addSubview(trackersNameTextField)
        trackersNameTextField.addSubview(clearTextFieldButton)

        [cancelButton,
         createButton
        ].forEach {
            buttonStackView.addArrangedSubview($0)
        }
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)

        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            make.height.greaterThanOrEqualTo(view.bounds.height)
        }

        navBarLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(15)
            make.centerX.equalTo(scrollView.snp.centerX)
            make.height.equalTo(22)
        }

        textFieldContainerView.snp.makeConstraints { make in
            make.top.equalTo(navBarLabel.snp.top).offset(58)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.height.equalTo(75)
        }

        trackersNameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(75)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainerView.snp.bottom).offset(24)
            make.leading.equalTo(contentView.snp.leading).offset(16)
            make.trailing.equalTo(contentView.snp.trailing).offset(-16)
            make.height.equalTo(150)
        }

        emojiCollectionView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(32)
            make.leading.equalTo(contentView.snp.leading).offset(18)
            make.trailing.equalTo(contentView.snp.trailing).offset(-18)
            make.height.equalTo(222)
        }

        colorCollectionView.snp.makeConstraints { make in
            make.top.equalTo(emojiCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(contentView.snp.leading).offset(18)
            make.trailing.equalTo(contentView.snp.trailing).offset(-18)
            make.height.equalTo(222)
        }

        buttonStackView.snp.makeConstraints { make in
//            make.top.equalTo(colorCollectionView.snp.bottom).offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.height.equalTo(60)
        }
    }

    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
        createHabitViewControllerDelegate?.cancelButtonDidTap()
    }

    @objc private func createButtonTapped() {
        guard let text = trackersNameTextField.text, !text.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor else {
            return
        }

        let newTracker = Tracker(
            id: UUID(),
            title: text,
            color: color,
            emoji: emoji,
            scedule: self.selectedWeekDays,
            completedDays: [])

        createHabitViewControllerDelegate?.createButtonidTap(
            tracker: newTracker,
            category: "Category"
        )
        createHabitViewControllerDelegate?.reloadData()
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    @objc private func clearTextFieldButtonTapped() {
        trackersNameTextField.text = ""
        clearTextFieldButton.isHidden = true
    }

    private func checkCorrectness() {
        if let text = trackersNameTextField.text, !text.isEmpty || !selectedWeekDays.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = UIColor(named: "YP Black")
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(named: "YP Dark Gray")
        }
    }
}

// MARK: - UITextFieldDelegate
extension CreateHabitViewController: UITextFieldDelegate {
    // MARK: - Text Field Change Handler
    @objc private func textFieldDidChange() {
        if let text = trackersNameTextField.text, !text.isEmpty {
            clearTextFieldButton.isHidden = false
        } else {
            clearTextFieldButton.isHidden = true
        }
        checkCorrectness()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true 
    }
}

// MARK: - UITableViewDataSource
extension CreateHabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CreateHabitCell.cellID,
            for: indexPath) as? CreateHabitCell else {
            assertionFailure("Could not cast to CreateHabitCell")
            return UITableViewCell()
        }

        if indexPath.row == 0 {
            cell.configureCell(with: "Категория", subtitle: "Category", isFirstCell: true)
        }  else if indexPath.row == 1 {
            let schedule = selectedWeekDays.isEmpty ? "" : selectedWeekDays.map { $0.shortTitle }.joined(separator: ", ")
            cell.configureCell(with: "Расписание", subtitle: schedule, isFirstCell: false)
        }

        let imageView = UIImageView(image: UIImage(named: "right_array_icon"))
        cell.accessoryView = imageView
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateHabitViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            print("Category Selected")
        } else if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            self.scheduleViewControllerdelegate?.didSelectDays(self.selectedWeekDays)
            present(viewController, animated: true, completion: nil)
        }
        checkCorrectness()
    }
}

// MARK: - ScheduleViewControllerDelegate
extension CreateHabitViewController: ScheduleViewControllerDelegate {
    func didSelectDays(_ days: [WeekDay]) {
        selectedWeekDays = days
        tableView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension CreateHabitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        18
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.cellID,
                                                                for: indexPath) as? EmojiCell else {
                assertionFailure("Could not cast to EmojiCell")
                return UICollectionViewCell()
            }

            let emoji = emojis[indexPath.item]
            cell.label.text = emoji
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.cellID,
                                                                for: indexPath) as? ColorCell else {
                assertionFailure("Could not cast to ColorCell")
                return UICollectionViewCell()
            }

            let color = colors[indexPath.item]
            cell.colorView.backgroundColor = color
            return cell
        }

        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojiCollectionView {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: EmojiHeader.cellID,
                                                                                   for: indexPath) as? EmojiHeader else {
                assertionFailure("Could not cast to EmojiHeader")
                return UICollectionReusableView()
            }
            return headerView
        } else if collectionView == colorCollectionView {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: ColorHeader.cellID,
                                                                                   for: indexPath) as? ColorHeader else {
                assertionFailure("Could not cast to ColorHeader")
                return UICollectionReusableView()
            }
            return headerView
        }
        return UICollectionReusableView()
    }
}

extension CreateHabitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width - 36) / 6
        let cellHeight = 52.0
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
    }
}

extension CreateHabitViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let selectedCell = collectionView.cellForItem(at: indexPath) as? EmojiCell
            selectedEmoji = emojis[indexPath.item]

            selectedCell?.highlightEmoji()
        } else if collectionView == colorCollectionView {
            let selectedCell = collectionView.cellForItem(at: indexPath) as? ColorCell
            selectedColor = colors[indexPath.item]

            selectedCell?.highlightColor()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            let deselectedCell = collectionView.cellForItem(at: indexPath) as? EmojiCell
            deselectedCell?.unhighlightEmoji()

        } else if collectionView == colorCollectionView {
            let deselectedCell = collectionView.cellForItem(at: indexPath) as? ColorCell
            deselectedCell?.unhighlightColor()
        }
    }
}
