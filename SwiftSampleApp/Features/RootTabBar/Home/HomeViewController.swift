import UIKit
import RxFlow
import RxSwift
import RxCocoa

class HomeViewController: UIViewController, Stepper {
    // MARK: - Properties
    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "ようこそ"
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Card Views
    private lazy var reservationCard = CardView(
        title: "予約管理",
        description: "予約の確認・変更ができます",
        iconName: "calendar"
    )

    private lazy var favoriteCard = CardView(
        title: "お気に入り",
        description: "お気に入りのサロンを確認",
        iconName: "heart.fill"
    )

    private lazy var historyCard = CardView(
        title: "閲覧履歴",
        description: "最近見たサロンをチェック",
        iconName: "clock.fill"
    )

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "ホーム"

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(welcomeLabel)
        contentStackView.addArrangedSubview(reservationCard)
        contentStackView.addArrangedSubview(favoriteCard)
        contentStackView.addArrangedSubview(historyCard)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Set card heights
        reservationCard.heightAnchor.constraint(equalToConstant: 80).isActive = true
        favoriteCard.heightAnchor.constraint(equalToConstant: 80).isActive = true
        historyCard.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }

    // MARK: - Bindings
    private func setupBindings() {
        reservationCard.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.steps.accept(AppStep.tileDetail(.reservation))
            })
            .disposed(by: disposeBag)

        favoriteCard.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.steps.accept(AppStep.tileDetail(.favorite))
            })
            .disposed(by: disposeBag)

        historyCard.tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.steps.accept(AppStep.tileDetail(.browsing))
            })
            .disposed(by: disposeBag)
    }
}