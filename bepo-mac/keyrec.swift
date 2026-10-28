import AppKit

// Records the next key (with modifiers) pressed in a small window, prints it, exits.
let app = NSApplication.shared
app.setActivationPolicy(.regular)

let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 460, height: 120),
                   styleMask: [.titled], backing: .buffered, defer: false)
win.title = "warpd key recorder"
let label = NSTextField(labelWithString: "Press the key (or combo) you want to start warpd")
label.font = .systemFont(ofSize: 15)
label.frame = NSRect(x: 20, y: 45, width: 420, height: 30)
win.contentView?.addSubview(label)
win.center()
win.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)

func mods(_ f: NSEvent.ModifierFlags) -> String {
    var s: [String] = []
    if f.contains(.control) { s.append("control") }
    if f.contains(.option) { s.append("option") }
    if f.contains(.command) { s.append("command") }
    if f.contains(.shift) { s.append("shift") }
    if f.contains(.function) { s.append("fn") }
    return s.joined(separator: ",")
}

var started = false
NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { e in
    let t = e.type == .keyDown ? "down" : e.type == .keyUp ? "up" : "flags"
    let ch = e.type == .flagsChanged ? "" : (e.charactersIgnoringModifiers ?? "")
    print("\(t) keycode=\(e.keyCode) chars=\(ch.unicodeScalars.map { String(format: "U+%04X", $0.value) }) mods=\(mods(e.modifierFlags))")
    fflush(stdout)
    if !started {
        started = true
        label.stringValue = "Recording... (4 seconds)"
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { exit(0) }
    }
    return nil
}

DispatchQueue.main.asyncAfter(deadline: .now() + 90) { print("timeout"); exit(1) }
app.run()
