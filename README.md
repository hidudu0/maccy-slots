# Maccy Slots

[Maccy](https://github.com/p0deje/Maccy) 2.8.0에 **클립보드 슬롯 3개**를 더한 비공식 포크입니다. 원 개발자와는 관계없습니다. 원본 기능(⇧⌘C 히스토리 창, 고정, 검색 등)은 그대로 있습니다.

> **English:** Unofficial fork of Maccy 2.8.0 that adds three global clipboard slots. Hold ⌘, press C then 1/2/3 to save what you copied into a slot; hold ⌘ and V, press 1/2/3 to paste a slot. Plain ⌘1–3 still go to the front app. Not affiliated with the Maccy project. The whole feature lives in [`Maccy/Slots.swift`](Maccy/Slots.swift).

## 사용법

| 하고 싶은 것 | 누르는 키 |
|---|---|
| 방금 복사한 내용을 슬롯에 저장 | ⌘ 누른 채 **C → 1 / 2 / 3** |
| 슬롯 내용 붙여넣기 | ⌘ + **V 누른 채 1 / 2 / 3** |
| 평소 붙여넣기 | ⌘V 그대로 |
| ⌘1~3만 누름 | 앞에 있는 앱으로 그대로 전달 (탭 전환 등 안 막음) |

- 텍스트, 이미지, 파일 등 복사한 형식 그대로 저장되고, 앱을 껐다 켜도 남아 있습니다.
- ⌘C 자체는 늦어지지 않습니다. 숫자는 ⌘을 계속 누르고 있는 동안에만 슬롯 저장으로 인식합니다.
- 빈 슬롯을 붙여넣으면 경고음만 납니다.

## 설치

1. [Releases](https://github.com/hidudu0/maccy-slots/releases/latest)에서 `Maccy Slots.zip`을 받아 압축을 풀고, `Maccy Slots.app`을 `응용 프로그램` 폴더로 옮깁니다.
2. 처음 열면 macOS가 막습니다 → [주의사항 1](#1-처음-열면-macos가-막습니다)
3. 손쉬운 사용 권한을 켭니다 → [주의사항 2](#2-손쉬운-사용-권한이-필요합니다)
4. (선택) Maccy 설정(⌘,) → 일반 → **로그인 시 실행** 체크

macOS 14 이상, Apple Silicon·Intel 모두 됩니다.

## 주의사항

### 1. 처음 열면 macOS가 막습니다
Apple 개발자 인증서와 공증 없이 ad-hoc 서명한 앱이라 "확인되지 않은 개발자" 경고가 뜹니다. 둘 중 하나로 한 번만 풀면 됩니다.

- 앱을 한 번 열어 본 뒤 **시스템 설정 → 개인정보 보호 및 보안** 맨 아래 **그래도 열기**
- 또는 터미널에서
  ```sh
  xattr -dr com.apple.quarantine "/Applications/Maccy Slots.app"
  ```

### 2. 손쉬운 사용 권한이 필요합니다
키 입력을 가로채야 하는 기능이라 권한이 있어야 동작합니다. 처음 켜면 시스템 요청 창이 뜹니다.

- **시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Maccy Slots** 켜기
- 켜고 나면 3초 안에 재실행 없이 동작합니다.
- 권한이 없을 때 증상: ⌘C → 1을 눌렀는데 슬롯 대신 앞 앱의 ⌘1(탭·창 전환)이 실행됩니다.

### 3. 원본 Maccy와 동시에 켜지 마세요
둘 다 ⇧⌘C를 쓰기 때문에 충돌합니다. 원본 Maccy는 종료하고 로그인 항목에서도 꺼 주세요.

- 번들 ID가 `local.MaccySlots`로 달라서 히스토리·설정이 원본과 **따로** 저장됩니다. 원본 히스토리는 자동으로 넘어오지 않습니다.
- 저장 위치: 히스토리 `~/Library/Application Support/Maccy/Storage.sqlite`, 슬롯 `~/Library/Application Support/Maccy/Slots.plist`

### 4. 새 버전으로 바꾸면 권한이 조용히 풀립니다
새 빌드는 서명이 달라져서 macOS가 다른 앱으로 봅니다. 손쉬운 사용 목록에 켜져 있는 것처럼 보여도 동작하지 않습니다.

- 목록에서 Maccy Slots를 지우고(−) 다시 추가해 켜기
- 그래도 안 되면 터미널에서 아래를 실행한 뒤 앱을 다시 켜고 권한을 새로 주세요.
  ```sh
  tccutil reset All local.MaccySlots
  ```

### 5. 업데이트 버튼을 누르지 마세요
설정의 **자동으로 업데이트 확인**과 **지금 확인하기**는 원본 Maccy의 업데이트를 찾습니다. 원본으로 덮어써지면 슬롯 기능이 사라질 수 있습니다. 자동 확인은 꺼 두었고, 새 버전은 이 저장소의 [Releases](https://github.com/hidudu0/maccy-slots/releases)에서 직접 받아 주세요.

### 6. 보안
이 앱은 기능상 모든 키 입력을 볼 수 있습니다(⌘C·⌘V 뒤의 숫자를 알아채야 하기 때문). 키 입력을 저장하거나 밖으로 보내는 코드는 없고, 키를 다루는 코드는 [`Maccy/Slots.swift`](Maccy/Slots.swift) 한 파일에 다 있습니다. 앱 샌드박스와 Hardened Runtime은 꺼진 빌드입니다. 직접 확인하고 싶으면 아래처럼 소스에서 빌드하세요.

### 7. 동작 방식 때문에 생기는 차이
- **⌘V는 V를 뗄 때 붙여넣어집니다.** ⌘V + 숫자와 구분하려고 V를 누른 순간을 잠깐 붙잡아 둡니다. 평소엔 거의 느낄 수 없고, V를 꾹 누르면 원래처럼 연속으로 붙여넣어집니다.
- **슬롯을 붙여넣으면 클립보드 내용이 그 슬롯 내용으로 바뀝니다.** 슬롯을 클립보드에 올린 뒤 ⌘V를 보내는 방식이라서입니다.
- ⌘ 말고 다른 수정키(⇧ ⌥ ⌃)가 섞이면 슬롯으로 처리하지 않고 앱에 그대로 넘깁니다(⇧⌘V 등).

## 소스에서 빌드

Xcode가 필요합니다(Xcode 27.2, macOS 26.6에서 확인).

```sh
git clone https://github.com/hidudu0/maccy-slots.git
cd maccy-slots
./build.sh
```

`build.sh`가 하는 일:
1. `test_slots.sh`로 키 처리 검사 (실제 키 입력은 보내지 않음, 하나라도 실패하면 중단)
2. Apple Silicon + Intel universal Release 빌드 (ad-hoc 서명)
3. 실행 중인 Maccy Slots 종료 → `/Applications/Maccy Slots.app` 교체 → 실행
4. 공유용 `Maccy Slots.zip` 생성

다시 설치하면 [주의사항 4](#4-새-버전으로-바꾸면-권한이-조용히-풀립니다)가 적용됩니다. 검사만 하려면 `./test_slots.sh`.

## 원본 2.8.0에서 바뀐 것

- [`Maccy/Slots.swift`](Maccy/Slots.swift): 슬롯 기능 전부 (전용 스레드에서 도는 CGEventTap)
- `Maccy/AppDelegate.swift`: 시작할 때 `Slots.start()`
- `Maccy/Clipboard.swift`: Maccy 자체 붙여넣기 이벤트에 표시를 달아 슬롯 처리를 건너뜀
- `Maccy/Accessibility.swift`: 권한이 없으면 시스템 요청 창을 띄움
- 포크 전용 설정: 번들 ID `local.MaccySlots`, 앱 샌드박스 끔, Sparkle 자동 확인 끔
- `build.sh`, `test_slots.sh`

전체 차이: [2.8.0...slots](https://github.com/hidudu0/maccy-slots/compare/2.8.0...slots)

## 라이선스

Maccy © Alex Rodionov, [MIT License](LICENSE). 이 포크도 같은 MIT 라이선스를 따릅니다. 원본 사용법과 FAQ는 [Maccy README](https://github.com/p0deje/Maccy#readme)를 보세요.
