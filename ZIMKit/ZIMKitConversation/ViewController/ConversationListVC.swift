//
//  ConversationListVC.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit

open class ConversationListVC: _ViewController {

    lazy var viewModel: ConversationViewModel = ConversationViewModel()

    lazy var noDataView: ConversationNoDataView = {
        let noDataView = ConversationNoDataView(frame: view.bounds).withoutAutoresizingMaskConstraints
        noDataView.delegate = self
        return noDataView
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain).withoutAutoresizingMaskConstraints
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = view.backgroundColor
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        tableView.rowHeight = 74
        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        return tableView
    }()

    open override func setUp() {
        super.setUp()
        view.backgroundColor = .white
        self.navigationItem.title = "In-app Chat"
    }

    open override func setUpLayout() {
        super.setUpLayout()

        view.embed(tableView)
        view.embed(noDataView)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        configViewModel()
        loadData()
        LocalAPNS.shared.setupLocalAPNS()
    }

    deinit {
        ZIMKitManager.shared.disconnectUser()
    }

    func configViewModel() {
        // listen the conversations change and reload.
        viewModel.$conversations.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
    }

    func loadData() {
        viewModel.loadConversations { [weak self] error in
            if error.code != .success {
                guard let self = self else { return }
                if self.viewModel.isFirstLoadFail {
                    self.noDataView.setButtonTitle(L10n("conversation_reload"))
                    self.noDataView.isHidden = false
                }
                HUDHelper.showMessage(error.message)
            }
        }
    }
}

extension ConversationListVC: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.noDataView.isHidden = viewModel.conversations.count > 0
        return viewModel.conversations.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationCell.reuseIdentifier, for: indexPath)
                as? ConversationCell else {
            return ConversationCell()
        }

        if indexPath.row >= viewModel.conversations.count {
            return ConversationCell()
        }

        cell.model = viewModel.conversations[indexPath.row]

        return cell
    }
}

extension ConversationListVC: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= viewModel.conversations.count { return }
        let model = viewModel.conversations[indexPath.row]

        Dispatcher.open(MessagesDispatcher.messagesList(model.conversationID, model.type, model.conversationName))

        // clear unread messages
        viewModel.clearConversationUnreadMessageCount(model.conversationID, type: model.type)
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.row >= viewModel.conversations.count { return nil }

        let action = UITableViewRowAction(style: .normal, title: L10n("conversation_delete")) { _, index in
            tableView.performBatchUpdates {
                self.viewModel.deleteConversation(at: index.row) { error in
                    if error.code != .success {
                        HUDHelper.showMessage(error.message)
                    }
                }
                tableView.deleteRows(at: [index], with: .none)
            }
        }
        action.backgroundColor = .zim_backgroundRed

        return [action]
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.row >= viewModel.conversations.count { return nil }

        let action = UIContextualAction(style: .normal, title: L10n("conversation_delete")) { _, _, _ in
            tableView.performBatchUpdates {
                self.viewModel.deleteConversation(at: indexPath.row) { error in
                    if error.code != .success {
                        HUDHelper.showMessage(error.message)
                    }
                }
                tableView.deleteRows(at: [indexPath], with: .none)
            }
        }
        action.backgroundColor = .zim_backgroundRed

        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }

    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let distance = viewModel.conversations.count - 5
        if row == distance {
            loadData()
        }
    }
}

extension ConversationListVC: ConversationNoDataViewDelegate {
    func onCreateButtonClick() {
        if viewModel.isFirstLoadFail {
            loadData()
        } else {
            //            showStartChattingAlert()
        }
    }
}
