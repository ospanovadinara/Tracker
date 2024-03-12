//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Dinara on 11.03.2024.
//

import UIKit
import SnapKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filterSelected(filter: Filters)
}

final class FiltersViewController: UIViewController {

    // MARK: - Properties
    var selectedFilter: Filters?
    private lazy var filters: [Filters] = Filters.allCases
    weak var delegate: FiltersViewControllerDelegate?

    // MARK: - UI
    private lazy var navBarLabel: UILabel = {
        let label = UILabel()
        label.text = "Фильтры"
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            FiltersCell.self,
            forCellReuseIdentifier: FiltersCell.cellID
        )
        tableView.isScrollEnabled = false
        tableView.allowsMultipleSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
    }
}

private extension FiltersViewController {
    // MARK: Setup Views
    func setupViews() {
        view.backgroundColor = UIColor.white

        [navBarLabel,
         tableView
        ].forEach {
            view.addSubview($0)
        }
    }

    // MARK: Setup Constraints
    func setupConstraints() {
        navBarLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navBarLabel.snp.bottom).offset(34)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(300)
        }
    }
}

extension FiltersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersCell.cellID,
            for: indexPath
        ) as? FiltersCell else {
            fatalError("Could not cast to FiltersCell")
        }

        let filter = filters[indexPath.row]
        let isHidden = filter != selectedFilter
        cell.configureCell(
            with: filter.rawValue,
            isHidden: isHidden
        )
        
        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.cornerRadius = 0

        if indexPath.row == filters.count - 1 {
            cell.setRoundedCornersForContentView(top: false,
                                                 bottom: true)
        } else if indexPath.row == 0 {
            cell.setRoundedCornersForContentView(top: true,
                                                 bottom: false)
        } else {
            cell.contentView.layer.maskedCorners = []
            cell.contentView.layer.cornerRadius = 0
        }
        cell.selectionStyle = .none

        return cell
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

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FiltersCell else {
            fatalError("Could not cast to FiltersCell")
        }

        let isHidden = false
        cell.checkMarkImageSetup(isHidden: isHidden)

        let filter = filters[indexPath.row]
        delegate?.filterSelected(filter: filter)
        dismiss(animated: true)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FiltersCell else {
            fatalError("Could not cast to FiltersCell")
        }

        let isHidden = false
        cell.checkMarkImageSetup(isHidden: isHidden)
    }
}
