#!/bin/zsh
# Check the slot key handling in Maccy/Slots.swift without sending real keystrokes:
# posted events are recorded instead, and slot save/paste (main queue) never runs.
set -e
cd "${0:A:h}"
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT

sed -e 's/private static func handle/static func handle/' \
    -e 's/event?\.post(tap: \.cgSessionEventTap)/if let event { posted.append(event) }/' \
    Maccy/Slots.swift > "$dir/Slots.swift"

cat > "$dir/main.swift" <<'EOF'
import AppKit

nonisolated(unsafe) var posted: [CGEvent] = []

// Like the app: main actor by default, but the tap runs on its own thread.
nonisolated func run() {
func key(_ code: Int64, down: Bool, flags: CGEventFlags = .maskCommand, repeat: Bool = false) -> Bool {
  let event = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(code), keyDown: down)!
  event.flags = flags
  if `repeat` { event.setIntegerValueField(.keyboardEventAutorepeat, value: 1) }
  return Slots.handle(down ? .keyDown : .keyUp, event)
}

func command(_ down: Bool) -> Bool {
  let event = CGEvent(keyboardEventSource: nil, virtualKey: 55, keyDown: down)!
  event.flags = down ? .maskCommand : []
  return Slots.handle(.flagsChanged, event)
}

func check(_ name: String, _ ok: Bool) {
  print(ok ? "ok   \(name)" : "FAIL \(name)")
  if !ok { exit(1) }
}

func pastedV() -> Bool {
  defer { posted.removeAll() }
  return posted.count == 2 && posted.allSatisfy {
    $0.getIntegerValueField(.keyboardEventKeycode) == 9 && $0.flags.contains(.maskCommand)
      && $0.getIntegerValueField(.eventSourceUserData) == Slots.marker
  }
}

let (c, v, one, two, a) = (Int64(8), Int64(9), Int64(18), Int64(19), Int64(0))

// Plain ⌘V pastes when V is released.
_ = command(true)
check("⌘V down held back", !key(v, down: true) && posted.isEmpty)
check("⌘V up pastes", !key(v, down: false) && pastedV())

// ⌘ + V held + 2 pastes slot 2 instead of the clipboard.
check("⌘V down held back", !key(v, down: true))
check("digit swallowed", !key(two, down: true) && posted.isEmpty)
check("V up does not paste clipboard", !key(v, down: false) && posted.isEmpty)
check("digit up swallowed", !key(two, down: false))

// Holding V repeats paste like a normal ⌘V.
_ = key(v, down: true)
check("repeat pastes and passes", key(v, down: true, repeat: true) && pastedV())
check("repeat continues", key(v, down: true, repeat: true) && posted.isEmpty)
check("V up passes", key(v, down: false))

// Releasing ⌘ before V pastes right away.
_ = key(v, down: true)
check("⌘ up pastes", command(false) && pastedV())
check("V up swallowed", !key(v, down: false, flags: []) && posted.isEmpty)

// Another key while ⌘V is held back: paste first, then replay the key.
_ = command(true)
_ = key(v, down: true)
check("other key replayed after paste", !key(a, down: true) && posted.count == 3
  && posted[2].getIntegerValueField(.keyboardEventKeycode) == a)
posted.removeAll()
_ = key(a, down: false)
_ = key(v, down: false)

// ⌘C then 1 saves; the copy itself is never delayed.
check("⌘C passes", key(c, down: true))
_ = key(c, down: false)
check("digit after ⌘C swallowed", !key(one, down: true))
check("digit up swallowed", !key(one, down: false))

// ⌘1 without C/V is left to the front app.
_ = command(false)
_ = command(true)
check("plain ⌘1 passes", key(one, down: true) && key(one, down: false))
check("⌘⇧V passes", key(v, down: true, flags: [.maskCommand, .maskShift]) && posted.isEmpty)

// Events we (or Maccy's own paste) post pass through untouched.
let own = CGEvent(keyboardEventSource: nil, virtualKey: 9, keyDown: true)!
own.flags = .maskCommand
own.setIntegerValueField(.eventSourceUserData, value: Slots.marker)
check("marked ⌘V passes", Slots.handle(.keyDown, own))
}

let done = DispatchSemaphore(value: 0)
Thread { run(); done.signal() }.start()
done.wait()
EOF

swiftc -swift-version 6 -default-isolation MainActor -o "$dir/test" "$dir/Slots.swift" Maccy/Accessibility.swift "$dir/main.swift" 2>&1 | grep -v warning || true
[[ -x "$dir/test" ]] || { echo "FAIL compile"; exit 1; }
"$dir/test"
