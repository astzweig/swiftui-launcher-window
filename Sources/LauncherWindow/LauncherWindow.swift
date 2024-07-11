import SwiftUI
import FramelessWindow

/**
 A SwiftUI scene that creates a single frameless window divided in a left section and right list.

 A launcher window lets the app user select from a list of recent items, i.e. a database or a folder
 while showing a nice welcome message and convenient buttons on the left side of the window.
 */
public struct LauncherWindow<ActionItems: View, ListItems: View>: Scene {
	private let titleKey: LocalizedStringKey
	private let id: String
	private let appName: String
	private let version: String
	private let iconAssetName: String
	private let actionItems: () -> ActionItems
	private let listItems: () -> ListItems

	public var body: some Scene {
		FramelessWindow(withId: self.id) {
			HStack {
				VStack {
					Spacer()
					Image(self.iconAssetName)
					VStack(spacing: 10) {
						Text("Welcome to **\(self.appName)**", comment: "Welcome message on the launcher screen of the app").font(.title)
						Text(self.version).foregroundColor(.secondary)
					}
					Spacer()
					self.actionItems()
					Spacer()
				}.scenePadding()
				List {
					self.listItems()
				}
			}
		}
	}

	/**
	 Initialize a new LauncherWindow Scene.

	 - Parameters:
	 - id: A unique string identifier that you can use to open the window.
	 - titleKey: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect. Default value is `"Launcher"`.
	 - appName: The app name to show in the welcome message.
	 - version: The version to show below the welcome message.
	 - iconAssetName: The name of the image asset containing the icon. Note: The default AppIcon is
	 an icon set and not an image set.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		withId id: String,
		andTitle titleKey: LocalizedStringKey = "Launcher",
		appName: String,
		version: String,
		iconAssetName: String,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		self.titleKey = titleKey
		self.id = id
		self.appName = appName
		self.version = version
		self.iconAssetName = iconAssetName
		self.actionItems = actionItems
		self.listItems = listItems
	}

	/**
	 Initialize a new LauncherWindow Scene where the `iconAssetName` parameter equals the `appName` parameter.

	 - Parameters:
	 - id: A unique string identifier that you can use to open the window.
	 - titleKey: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect. Default value is `"Launcher"`.
	 - appName: The app name to show in the welcome message.
	 - version: The version to show below the welcome message.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		withId id: String,
		andTitle titleKey: LocalizedStringKey = "Launcher",
		appName: String,
		version: String,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		self.init(
			withId: id,
			andTitle: titleKey,
			appName: appName,
			version: version,
			iconAssetName: appName,
			actionItems: actionItems,
			listItems: listItems
		)
	}

	/**
	 Initialize a new LauncherWindow Scene where the `appName` shall be retrieved from the app bundle.

	 - Parameters:
	 - id: A unique string identifier that you can use to open the window.
	 - titleKey: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect. Default value is `"Launcher"`.
	 - version: The version to show below the welcome message.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		withId id: String,
		andTitle titleKey: LocalizedStringKey = "Launcher",
		version: String,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		let appName = Self.getAppNameFromBundle()
		self.init(
			withId: id,
			andTitle: titleKey,
			appName: appName,
			version: version,
			actionItems: actionItems,
			listItems: listItems
		)
	}

	/**
	 Initialize a new LauncherWindow Scene where the `appName` and `version` parameters shall be
	 retrieved from the app bundle.

	 - Parameters:
	 - id: A unique string identifier that you can use to open the window.
	 - titleKey: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect. Default value is `"Launcher"`.
	 - version: The version to show below the welcome message.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		withId id: String,
		andTitle titleKey: LocalizedStringKey = "Launcher",
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		let appName = Self.getAppNameFromBundle()
		let version = Self.getAppVersionFromBundle()
		self.init(
			withId: id,
			andTitle: titleKey,
			appName: appName,
			version: version,
			actionItems: actionItems,
			listItems: listItems
		)
	}

	/**
	 Retrieve the app name from the app's bundle.

	 Try the display version first and the short name second.

	 - Returns: The app name or "Unknown".
	 */
	private static func getAppNameFromBundle() -> String {
		for dictionaryKey in ["CFBundleDisplayName", kCFBundleNameKey as String] {
			if let appName = Bundle.main.object(forInfoDictionaryKey: dictionaryKey) as? String {
				return appName
			}
		}

		return "Unknown"
	}

	/**
	 Retrieve the app version from the app's bundle.

	 Concatenates the normal version and the short version into one string.

	 - Returns: The app version or "Unknown".
	 */
	private static func getAppVersionFromBundle() -> String {
		let objectFor = Bundle.main.object(forInfoDictionaryKey:)
		var version: [String] = []

		if let releaseVersion = objectFor("CFBundleShortVersionString") as? String {
			version.append("Release: \(releaseVersion)")
		}

		if let buildVersion = objectFor(kCFBundleVersionKey as String) as? String {
			version.append("Build: \(buildVersion)")
		}

		return version.count > 0 ? version.joined(separator: " ") : "Unknown"
	}
}
