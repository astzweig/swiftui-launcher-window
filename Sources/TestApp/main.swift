import SwiftUI
import LauncherWindow

struct NewSourceFolderButton: View {
	var body: some View {
		Button {
			print("New Source Folder Button pressed")
		} label: {
			HStack {
				Image(systemName: "folder")
					.font(.largeTitle)
					.foregroundStyle(.blue)
				VStack(alignment: .leading) {
					Text("Source Folder").bold()
					Text("Where do you keep your documents?").foregroundStyle(.secondary)
				}.foregroundStyle(.foreground)
			}
		}.buttonStyle(BorderlessButtonStyle())
	}

	static func modify(window: NSWindow) {
		print("Modify window of TestApp was called successfully.")
	}
}

struct RecentSourceFolderListItem: View {
	let url: URL
	let timestamp: Date = Date.now
	static let shortDateFormat = Date.FormatStyle(date: .numeric).year(.twoDigits)

	var body: some View {
		HStack() {
			Image(nsImage: NSWorkspace.shared.icon(forFile: url.path()))
			VStack(alignment: .leading) {
				HStack(alignment: .top) {
					Text(url.lastPathComponent)
						.bold()
					Spacer(minLength: 100)
					Text("\(timestamp, format: Self.shortDateFormat)")
				}
				Text(url.path())
					.truncationMode(.head)
			}
		}.frame(maxWidth: 300)
	}
}

struct TestApp: App {
	var body: some Scene {
		LauncherWindow("Single Window", id: "single-window", windowInitializer: self.modify(window:)) {
			NewSourceFolderButton()
		} listItems: {
			RecentSourceFolderListItem(url: URL(string: "/Users/Shared")!)
		}
	}

	func modify(window: NSWindow) {
		print("Modify window of TestApp was called successfully.")
	}
}

DispatchQueue.main.async {
	let app = NSApplication.shared
	app.setActivationPolicy(.regular)
	app.activate(ignoringOtherApps: true)
}

TestApp.main()
