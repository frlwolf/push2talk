//
//  ViewController.swift
//  Push2Talk
//
//  Created by Felipe Lobo on 23/08/21.
//

import UIKit

final class ViewController: UIViewController {

    let useCase: UseCase

    let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0

        return textField
    }()

    let pushToTalkControl: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Push to talk", for: .normal)
        button.backgroundColor = UIColor.lightGray

        return button
    }()

    required init(useCase: UseCase) {
        self.useCase = useCase
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupSubviews()
        setupLayout()

        useCase.startConnection()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        pushToTalkControl.layoutIfNeeded()
        pushToTalkControl.layer.cornerRadius = pushToTalkControl.frame.width / 2
        pushToTalkControl.addTarget(self, action: #selector(didTapPushToTalk(sender:)), for: .touchUpInside)
    }

    @objc
    private func didTapPushToTalk(sender: UIButton) {
        useCase.startAudioSession(sender: textField.text ?? "Unknown")
    }

    private func setupSubviews() {
        view.addSubview(textField)
        view.addSubview(pushToTalkControl)
    }

    private func setupLayout() {
        view.addConstraints([
            textField.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(greaterThanOrEqualToConstant: 320),
            textField.heightAnchor.constraint(equalToConstant: 44),

            pushToTalkControl.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 44),
            pushToTalkControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pushToTalkControl.widthAnchor.constraint(equalToConstant: 200),
            pushToTalkControl.heightAnchor.constraint(equalTo: pushToTalkControl.widthAnchor)
        ])
    }

}
