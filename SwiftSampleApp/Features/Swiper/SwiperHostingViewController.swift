//
//  SwiperHostingViewController.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI
import RxFlow
import RxCocoa

final class SwiperHostingViewController: UIViewController, RxFlow.Stepper {

    // MARK: - Properties

    let steps = PublishRelay<Step>()
    private let viewModel: SwiperViewModel

    // MARK: - Init

    init(viewModel: SwiperViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUI()
    }

    // MARK: - Setup

    private func setupSwiftUI() {
        let swiftUIView = SwiperView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
