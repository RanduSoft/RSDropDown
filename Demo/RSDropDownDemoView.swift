//
//  RSDropDownDemoView.swift
//  RSDropDown
//
//  Interactive demo showcasing different RSDropDown configurations.
//  Open this file in Xcode and use the Canvas (⌥⌘↩) to see previews.
//

import SwiftUI
import UIKit
import RSDropDown

// MARK: - Demo View Controller

/// A full-screen demo hosting multiple RSDropDown instances with different configurations.
final class RSDropDownDemoViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()

    private let items = (1...50).map { "Option \($0)" }
    private let shortItems = ["London", "Paris", "Tokyo", "New York", "Sydney"]
    private let countryItems = ["Romania", "Japan", "Brazil", "Germany", "Canada", "Australia", "India"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        title = "RSDropDown Demo"

        setupScrollView()

        // MARK: - Liquid Glass (Default)

        addSection("Default (Liquid Glass)")
        addDropDown { dd in
            dd.placeholder = "Pick an option"
            dd.optionArray = self.shortItems
        }

        addSection("Search / Autocomplete")
        addDropDown { dd in
            dd.placeholder = "Type to search..."
            dd.optionArray = self.countryItems
            dd.configuration.search.isEnabled = true
        }

        // MARK: - Classic Apple Style

        addStyleSectionHeader(
            title: "CLASSIC APPLE STYLE",
            subtitle: "Opaque backgrounds, borders, shadows, separators"
        )

        addSection("Classic Default")
        addDropDown { dd in
            dd.placeholder = "Classic dropdown"
            dd.optionArray = self.shortItems
            dd.configuration = .classic()
        }

        addSection("Classic Search")
        addDropDown { dd in
            dd.placeholder = "Type to search..."
            dd.optionArray = self.countryItems
            dd.configuration = .classic()
            dd.configuration.search.isEnabled = true
        }

        // MARK: - Customizations

        addStyleSectionHeader(
            title: "CUSTOMIZATIONS",
            subtitle: "Different visual configurations built on top of the classic style"
        )

        addSection("Custom Colors")
        addDropDown { dd in
            dd.placeholder = "Indigo theme"
            dd.optionArray = self.shortItems
            dd.configuration = .classic()
            dd.backgroundColor = .systemIndigo.withAlphaComponent(0.08)
            dd.textColor = .systemIndigo
            dd.configuration.style.rowBackgroundColor = .systemIndigo.withAlphaComponent(0.06)
            dd.configuration.style.rowTextColor = .systemIndigo
            dd.configuration.style.selectedRowColor = .systemIndigo.withAlphaComponent(0.15)
            dd.configuration.chevron.color = .systemIndigo
        }

        addSection("Large Rows")
        addDropDown(height: 52) { dd in
            dd.placeholder = "Tall rows"
            dd.optionArray = self.shortItems
            dd.configuration = .classic()
            dd.configuration.style.rowHeight = 56
            dd.configuration.style.cellFont = .preferredFont(forTextStyle: .title3)
            dd.configuration.list.maxHeight = 56 * 4
            dd.configuration.chevron.size = 16
            dd.font = .preferredFont(forTextStyle: .title3)
        }

        addSection("Compact Rows")
        addDropDown(height: 36) { dd in
            dd.placeholder = "Small rows"
            dd.optionArray = self.shortItems
            dd.configuration = .classic()
            dd.configuration.style.rowHeight = 32
            dd.configuration.style.cellFont = .preferredFont(forTextStyle: .footnote)
            dd.configuration.list.maxHeight = 32 * 6
            dd.configuration.chevron.size = 10
            dd.configuration.style.cornerRadius = 6
            dd.font = .preferredFont(forTextStyle: .footnote)
        }

        addSection("Dark Card")
        addDropDown { dd in
            dd.optionArray = self.shortItems
            dd.configuration = .classic()
            dd.backgroundColor = UIColor(white: 0.15, alpha: 1)
            dd.textColor = .white
            dd.configuration.style.rowBackgroundColor = UIColor(white: 0.18, alpha: 1)
            dd.configuration.style.rowTextColor = .white
            dd.configuration.style.selectedRowColor = UIColor(white: 0.25, alpha: 1)
            dd.configuration.chevron.color = .lightGray
            dd.configuration.style.cornerRadius = 12
            dd.layer.cornerRadius = 12
            dd.attributedPlaceholder = NSAttributedString(
                string: "Dark theme",
                attributes: [.foregroundColor: UIColor.lightGray]
            )
        }

        addSection("Long List (50 items)")
        addDropDown { dd in
            dd.placeholder = "Scroll through many items"
            dd.optionArray = self.items
            dd.configuration.list.maxHeight = 44 * 6
        }

        // Bottom spacing
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 200).isActive = true
        stackView.addArrangedSubview(spacer)
    }

    // MARK: - Layout Helpers

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40)
        ])
    }

    private func addSection(_ title: String) {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel

        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            label.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20)
        ])

        stackView.addArrangedSubview(wrapper)
    }

    private func addStyleSectionHeader(title: String, subtitle: String) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = subtitle
        sub.font = .preferredFont(forTextStyle: .caption2)
        sub.textColor = .secondaryLabel
        sub.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(separator)
        container.addSubview(label)
        container.addSubview(sub)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            sub.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            sub.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            sub.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            sub.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        stackView.addArrangedSubview(container)
    }

    private func addDropDown(height: CGFloat = 44, configure: @escaping (RSDropDown) -> Void) {
        let dropdown = RSDropDown(frame: .zero)
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        dropdown.heightAnchor.constraint(equalToConstant: height).isActive = true
        dropdown.padding = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        dropdown.font = .preferredFont(forTextStyle: .body)

        configure(dropdown)

        dropdown.onSelection = { selection in
            print("[\(dropdown.placeholder ?? "dropdown")] Selected: \(selection.item.dropDownTitle) (index \(selection.index))")
        }

        stackView.addArrangedSubview(dropdown)
    }
}

// MARK: - SwiftUI Wrappers

/// Wraps the full demo view controller for SwiftUI previews.
struct RSDropDownDemoRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: RSDropDownDemoViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

/// A standalone SwiftUI demo using RSDropDownPicker directly.
struct RSDropDownSwiftUIDemo: View {
    @State private var selection1: String?
    @State private var selection2: String?
    @State private var classicSelection1: String?
    @State private var classicSelection2: String?

    private let cities = ["London", "Paris", "Tokyo", "New York", "Sydney"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("SwiftUI RSDropDownPicker")
                    .font(.title2.bold())
                    .padding(.top)

                // MARK: Default (Liquid Glass)

                Group {
                    sectionLabel("Default (Liquid Glass)")
                    RSDropDownPicker(
                        items: cities,
                        selection: $selection1,
                        placeholder: "Pick a city"
                    )
                    .frame(height: 44)
                }

                Group {
                    sectionLabel("Search Enabled")
                    RSDropDownPicker(
                        items: cities,
                        selection: $selection2,
                        placeholder: "Type to search..."
                    )
                    .searchEnabled(true)
                    .frame(height: 44)
                }

                // MARK: Classic Apple Style

                Divider()
                    .padding(.top, 16)

                Text("Classic Apple Style")
                    .font(.headline)

                Group {
                    sectionLabel("Classic Default")
                    RSDropDownPicker(
                        items: cities,
                        selection: $classicSelection1,
                        placeholder: "Classic picker"
                    )
                    .classicStyle()
                    .frame(height: 44)
                }

                Group {
                    sectionLabel("Classic Search")
                    RSDropDownPicker(
                        items: cities,
                        selection: $classicSelection2,
                        placeholder: "Type to search..."
                    )
                    .classicStyle()
                    .searchEnabled(true)
                    .frame(height: 44)
                }

                Spacer(minLength: 200)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground))
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Previews

#Preview("Interactive Demo") {
    RSDropDownDemoRepresentable()
        .ignoresSafeArea()
}

#Preview("SwiftUI Pickers") {
    RSDropDownSwiftUIDemo()
}
