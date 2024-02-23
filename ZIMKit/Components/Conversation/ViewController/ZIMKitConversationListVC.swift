//
//  ZIMKitConversationListVC.swift
//  ZIMKitConversation
//
//  Created by Kael Ding on 2022/7/29.
//

import UIKit

open class ZIMKitConversationListVC: _ViewController {
    
    @objc public weak var delegate: ZIMKitConversationListVCDelegate?
    @objc public weak var messageDelegate: ZIMKitMessagesListVCDelegate?

    lazy var viewModel = ConversationListViewModel()

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
        getConversationList()
        LocalAPNS.shared.setupLocalAPNS()
    }

    deinit {
//        ZIMKit.disconnectUser()
    }

    func configViewModel() {
        // listen the conversations change and reload.
        viewModel.$conversations.bind { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    func getConversationList() {
        viewModel.getConversationList { [weak self] conversations, error in
            if error.code == .success { return }
            guard let self = self else { return }
            self.noDataView.setButtonTitle(L10n("conversation_reload"))
            self.noDataView.isHidden = false
            HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                               defaultMessage: error.message)
        }
    }

    func loadMoreConversations() {
        viewModel.loadMoreConversations()
    }
}

extension ZIMKitConversationListVC: UITableViewDataSource {
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

extension ZIMKitConversationListVC: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= viewModel.conversations.count { return }
        let model = viewModel.conversations[indexPath.row]

        let defaultAction = {
            let messageListVC = ZIMKitMessagesListVC(conversationID: model.id, type: model.type, conversationName: model.name)
            messageListVC.delegate = self.messageDelegate
            self.navigationController?.pushViewController(messageListVC, animated: true)
            // clear unread messages
            self.viewModel.clearConversationUnreadMessageCount(model.id, type: model.type)
        }
        if delegate?.conversationList(_:didSelectWith:defaultAction:) == nil {
            defaultAction()
        } else {
            delegate?.conversationList?(self, didSelectWith: model, defaultAction: defaultAction)
        }
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.row >= viewModel.conversations.count { return nil }

        let conversation = viewModel.conversations[indexPath.row]
        let action = UITableViewRowAction(style: .normal, title: L10n("conversation_delete")) { _, index in
            tableView.performBatchUpdates {
                self.viewModel.deleteConversation(conversation) { error in
                    if error.code != .success {
                        HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                                           defaultMessage: error.message)
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

        let conversation = viewModel.conversations[indexPath.row]
        let action = UIContextualAction(style: .normal, title: L10n("conversation_delete")) { _, _, _ in
            tableView.performBatchUpdates {
                self.viewModel.deleteConversation(conversation) { error in
                    if error.code != .success {
                        HUDHelper.showErrorMessageIfNeeded(error.code.rawValue,
                                                           defaultMessage: error.message)
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
            loadMoreConversations()
        }
    }
}

extension ZIMKitConversationListVC: ConversationNoDataViewDelegate {
    func onNoDataViewButtonClick() {
        getConversationList()
    }
}
