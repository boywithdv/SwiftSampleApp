//
//  TileDetailHostingViewController.swift
//  SwiftSampleApp
//
//  Created by 佃 寿希也 on 2026/03/12.
//

import UIKit
import SwiftUI

/// SwiftUI の TileDetailView を UIKit 世界で扱うためのラッパー
final class TileDetailHostingViewController: UIHostingController<TileDetailView> {

    private let viewModel: TileDetailViewModel

    init(viewModel: TileDetailViewModel) {
        self.viewModel = viewModel
        super.init(rootView: TileDetailView(viewModel: viewModel))
    }

    ///
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
