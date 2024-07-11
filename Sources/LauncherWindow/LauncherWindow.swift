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
	private let windowInitializer: FramelessWindow.WindowInitializer
	private let actionItems: () -> ActionItems
	private let listItems: () -> ListItems

	public var body: some Scene {
		FramelessWindow(self.titleKey, id: self.id, windowInitializer: self.modify(window:)) {
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
		}.windowResizability(.contentSize)
	}

	/**
	 Initialize a new LauncherWindow Scene.

	 - Parameters:
	 - title: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect. Default title is "Launcher".
	 - id: A unique string identifier that you can use to open the window. Defaults to a UUID.
	 - appName: The app name to show in the welcome message.
	 - version: The version to show below the welcome message.
	 - iconAssetName: The name of the image asset containing the icon. Note: The default AppIcon is
	 an icon set and not an image set.
	 - windowInitializer: Closure to modify the containing NSWindow of the scene.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		_ title: LocalizedStringKey? = nil,
		id: String?,
		appName: String,
		version: String,
		iconAssetName: String,
		windowInitializer: FramelessWindow.WindowInitializer? = nil,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		self.titleKey = title ?? "Launcher"
		self.id = id ?? UUID().uuidString
		self.appName = appName
		self.version = version
		self.iconAssetName = iconAssetName
		self.windowInitializer = windowInitializer ?? {window in}
		self.actionItems = actionItems
		self.listItems = listItems
	}

	/**
	 Initialize a new LauncherWindow Scene where the `iconAssetName` parameter equals the `appName` parameter.

	 - Parameters:
	 - title: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect.
	 - id: A unique string identifier that you can use to open the window.
	 - appName: The app name to show in the welcome message.
	 - version: The version to show below the welcome message.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		_ title: LocalizedStringKey? = nil,
		id: String?,
		appName: String,
		version: String,
		windowInitializer: FramelessWindow.WindowInitializer? = nil,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		self.init(
			title,
			id: id,
			appName: appName,
			version: version,
			iconAssetName: appName,
			windowInitializer: windowInitializer,
			actionItems: actionItems,
			listItems: listItems
		)
	}

	/**
	 Initialize a new LauncherWindow Scene where the `appName` shall be retrieved from the app bundle.

	 - Parameters:
	 - title: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect.
	 - id: A unique string identifier that you can use to open the window.
	 - version: The version to show below the welcome message.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		_ title: LocalizedStringKey? = nil,
		id: String?,
		version: String,
		windowInitializer: FramelessWindow.WindowInitializer? = nil,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		let appName = Self.getAppNameFromBundle()
		self.init(
			title,
			id: id,
			appName: appName,
			version: version,
			windowInitializer: windowInitializer,
			actionItems: actionItems,
			listItems: listItems
		)
	}

	/**
	 Initialize a new LauncherWindow Scene where the `appName` and `version` parameters shall be
	 retrieved from the app bundle.

	 - Parameters:
	 - title: A localized string key to use for the window’s title in system menus and in the
	 window’s title bar. Provide a title that describes the purpose of the window. As
	 a launcher window does not have a title bar and does not appear in the application
	 window menu, this value has no effect.
	 - id: A unique string identifier that you can use to open the window.
	 - version: The version to show below the welcome message.
	 - actionItems: The view content to display under the welcome message.
	 - listItems: The view content of the list on the right side of the launcher window.
	 */
	public init(
		_ title: LocalizedStringKey? = nil,
		id: String?,
		windowInitializer: FramelessWindow.WindowInitializer? = nil,
		actionItems: @escaping () -> ActionItems,
		listItems: @escaping () -> ListItems
	) {
		let appName = Self.getAppNameFromBundle()
		let version = Self.getAppVersionFromBundle()
		self.init(
			title,
			id: id,
			appName: appName,
			version: version,
			windowInitializer: windowInitializer,
			actionItems: actionItems,
			listItems: listItems
		)
	}

	func modify(window: NSWindow) {
		window.styleMask.remove(.resizable)
		self.windowInitializer(window)
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
