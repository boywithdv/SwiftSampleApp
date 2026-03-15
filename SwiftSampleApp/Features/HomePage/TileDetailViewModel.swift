//
//  TileDetailViewModel.swift
//  SwiftSampleApp
//
//  Created by 佃 寿希也 on 2026/03/12.
//

import Foundation
import Combine

final class TileDetailViewModel: BaseViewModel, ObservableObject {

    // MARK: - Published
    @Published private(set) var item: HomeTileItem

    // MARK: - Initialization
    init(item: HomeTileItem) {
        self.item = item
        super.init()
    }
}
