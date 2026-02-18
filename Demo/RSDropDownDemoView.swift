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

        addSection("Default (Apple-native)")
        addDropDown { dd in
            dd.placeholder = "Pick an option"
            dd.optionArray = self.shortItems
        }

        addSection("Pre-selected Item")
        addDropDown { dd in
            dd.optionArray = self.shortItems
            dd.selectedIndex = 2
        }

        addSection("Custom Colors")
        addDropDown { dd in
            dd.placeholder = "Colored dropdown"
            dd.optionArray = self.shortItems
            dd.backgroundColor = .systemIndigo.withAlphaComponent(0.08)
            dd.textColor = .systemIndigo
            dd.configuration.style.rowBackgroundColor = .systemIndigo.withAlphaComponent(0.06)
            dd.configuration.style.rowTextColor = .systemIndigo
            dd.configuration.style.selectedRowColor = .systemIndigo.withAlphaComponent(0.15)
            dd.configuration.chevron.color = .systemIndigo
        }

        addSection("Green Border")
        addDropDown { dd in
            dd.placeholder = "Custom border color"
            dd.optionArray = self.countryItems
            dd.configuration.style.borderColor = .systemGreen
            dd.configuration.style.borderWidth = 1.5
            dd.configuration.style.showShadow = false
            dd.layer.borderColor = UIColor.systemGreen.cgColor
            dd.layer.borderWidth = 1.5
        }

        addSection("Large Rows")
        addDropDown(height: 52) { dd in
            dd.placeholder = "Tall rows"
            dd.optionArray = self.shortItems
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
            dd.configuration.style.rowHeight = 32
            dd.configuration.style.cellFont = .preferredFont(forTextStyle: .footnote)
            dd.configuration.list.maxHeight = 32 * 6
            dd.configuration.chevron.size = 10
            dd.configuration.style.cornerRadius = 6
            dd.font = .preferredFont(forTextStyle: .footnote)
        }

        addSection("Custom Chevron")
        addDropDown { dd in
            dd.placeholder = "Custom icon"
            dd.optionArray = self.countryItems
            dd.configuration.chevron.image = UIImage(systemName: "arrowtriangle.down.fill") ?? UIImage()
            dd.configuration.chevron.size = 10
            dd.configuration.chevron.color = .systemOrange
        }

        addSection("No Shadow, No Border")
        addDropDown { dd in
            dd.placeholder = "Flat style"
            dd.optionArray = self.shortItems
            dd.configuration.style.showShadow = false
            dd.configuration.style.showBorder = false
            dd.configuration.style.cornerRadius = 16
            dd.configuration.style.rowBackgroundColor = .tertiarySystemGroupedBackground
            dd.layer.borderWidth = 0
            dd.layer.cornerRadius = 16
            dd.backgroundColor = .tertiarySystemGroupedBackground
        }

        addSection("With Separators")
        addDropDown { dd in
            dd.placeholder = "Classic separators"
            dd.optionArray = self.shortItems
            dd.configuration.style.showSeparators = true
        }

        addSection("No Checkmark")
        addDropDown { dd in
            dd.optionArray = self.shortItems
            dd.selectedIndex = 1
            dd.configuration.behavior.showCheckmark = false
        }

        addSection("Search / Autocomplete")
        addDropDown { dd in
            dd.placeholder = "Type to search..."
            dd.optionArray = self.countryItems
            dd.configuration.search.isEnabled = true
            dd.configuration.search.clearSelectionOnOpen = true
        }

        addSection("Wide List (custom width)")
        addDropDown { dd in
            dd.placeholder = "Wider list"
            dd.optionArray = self.shortItems
            dd.configuration.list.width = 340
            dd.configuration.list.spacing = 8
        }

        addSection("Long List (50 items)")
        addDropDown { dd in
            dd.placeholder = "Scroll through many items"
            dd.optionArray = self.items
            dd.configuration.list.maxHeight = 44 * 6
        }

        addSection("Dark Card Style")
        addDropDown { dd in
            dd.placeholder = "Dark theme"
            dd.optionArray = self.shortItems
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

        addSection("Red Accent")
        addDropDown { dd in
            dd.placeholder = "Destructive style"
            dd.optionArray = self.shortItems
            dd.configuration.style.selectedRowColor = .systemRed.withAlphaComponent(0.12)
            dd.configuration.chevron.color = .systemRed
            dd.configuration.chevron.size = 14
            dd.tintColor = .systemRed // checkmark color
        }

        // MARK: - Liquid Glass Section

        addGlassSectionHeader()

        addSection("Liquid Glass")
        addDropDown { dd in
            dd.placeholder = "Glass dropdown"
            dd.optionArray = self.shortItems
            dd.configuration = .liquidGlass()
        }

        addSection("Liquid Glass (Pre-selected)")
        addDropDown { dd in
            dd.optionArray = self.shortItems
            dd.configuration = .liquidGlass()
            dd.selectedIndex = 1
        }

        addSection("Liquid Glass + Search")
        addDropDown { dd in
            dd.placeholder = "Type to search..."
            dd.optionArray = self.countryItems
            var config = DropDownConfiguration.liquidGlass()
            config.search.isEnabled = true
            dd.configuration = config
        }

        addSection("Liquid Glass (Long List)")
        addDropDown { dd in
            dd.placeholder = "Scroll through items"
            dd.optionArray = self.items
            dd.configuration = .liquidGlass()
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

    private func addGlassSectionHeader() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "LIQUID GLASS STYLE"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        let subtitle = UILabel()
        subtitle.text = "iOS 26+ glass material, translucent blur fallback"
        subtitle.font = .preferredFont(forTextStyle: .caption2)
        subtitle.textColor = .secondaryLabel
        subtitle.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(separator)
        container.addSubview(label)
        container.addSubview(subtitle)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: container.topAnchor, constant: 28),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            label.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            subtitle.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            subtitle.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitle.bottomAnchor.constraint(equalTo: container.bottomAnchor)
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
    @State private var selection3: String?
    @State private var selection4: String?
    @State private var glassSelection1: String?
    @State private var glassSelection2: String?

    private let cities = ["London", "Paris", "Tokyo", "New York", "Sydney"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("SwiftUI RSDropDownPicker")
                    .font(.title2.bold())
                    .padding(.top)

                Group {
                    sectionLabel("Default")
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

                Group {
                    sectionLabel("Custom Configuration")
                    RSDropDownPicker(
                        items: cities,
                        selection: $selection3,
                        placeholder: "Custom style",
                        configuration: {
                            var config = DropDownConfiguration()
                            config.style.rowHeight = 50
                            config.style.cornerRadius = 14
                            config.chevron.color = .systemPurple
                            config.chevron.size = 14
                            return config
                        }()
                    )
                    .frame(height: 48)
                }

                Group {
                    sectionLabel("No Border, No Shadow")
                    RSDropDownPicker(
                        items: cities,
                        selection: $selection4,
                        placeholder: "Flat style",
                        configuration: {
                            var config = DropDownConfiguration()
                            config.style.showBorder = false
                            config.style.showShadow = false
                            return config
                        }()
                    )
                    .frame(height: 44)
                }

                // MARK: - Liquid Glass

                Divider()
                    .padding(.top, 16)

                Text("Liquid Glass Style")
                    .font(.headline)

                Text("iOS 26+ glass material, translucent blur fallback")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Group {
                    sectionLabel("Glass Default")
                    RSDropDownPicker(
                        items: cities,
                        selection: $glassSelection1,
                        placeholder: "Glass picker"
                    )
                    .glassStyle()
                    .frame(height: 44)
                }

                Group {
                    sectionLabel("Glass + Search")
                    RSDropDownPicker(
                        items: cities,
                        selection: $glassSelection2,
                        placeholder: "Type to search...",
                        configuration: {
                            var config = DropDownConfiguration.liquidGlass()
                            config.search.isEnabled = true
                            return config
                        }()
                    )
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
