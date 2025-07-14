# 🎶 MOTE - 공간에 음악을 남기다

![배너 이미지 또는 로고](링크)

> MOTE는 사용자가 특정 위치에 음악을 남기고, 공간을 기반으로 음악을 탐색·회고할 수 있도록 돕는 iOS 위치 기반 뮤직 아카이빙 앱입니다.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

## 🗂 목차
- [소개](#소개)
- [프로젝트 기간](#프로젝트-기간)
- [기술 스택](#기술-스택)
- [기능](#기능)
- [시연](#시연)
- [폴더 구조](#폴더-구조)
- [팀 소개](#팀-소개)
- [Git 컨벤션](#git-컨벤션)
- [테스트 방법](#테스트-방법)
- [프로젝트 문서](#프로젝트-문서)
- [라이선스](#lock_with_ink_pen-license)

---

## 📱 소개

> MOTE는 사용자가 특정 장소에 음악을 남기고, 다른 사람의 음악을 발견할 수 있는 위치 기반 iOS 애플리케이션입니다.
사용자는 위치를 기반으로 음악을 기록하고, 동일한 장소에서 과거 자신이나 다른 사용자가 남긴 음악을 탐색할 수 있습니다.
이를 통해 시간과 공간에 따라 축적되는 음악 아카이빙 경험을 제공합니다.

[🔗 앱스토어/웹 링크](https://example.com)


## 📆 프로젝트 기간
- 전체 기간: `2025.07.DD - 2025.07.DD`
- 개발 기간: `2025.07.14 - YYYY.MM.DD`


## 🛠 기술 스택

	•	Language: Swift 5.9
	•	UI: SwiftUI + UIKit (필요 시 병행 사용)
	•	Architecture: MVVM 
	•	Frameworks:
	•	MusicKit – Apple Music API 기반 음악 연동
	•	MapKit – 현재 위치 및 장소 기반 탐색 UI
	•	ARKit, RealityKit – 공간 내 시각적 상호작용 요소 구현
	•	IDE: Xcode 15.0
	•	Testing: XCTest
	•	Design & Docs: Figma, Notion
	•	Collaboration & PM: GitHub Projects
	•	CI/CD: (추후 구성 예정)
	•	Deployment: (App Store 예정)


## 🌟 주요 기능

- ✅ 장소 기반 음악 기록
    사용자는 현재 위치를 기반으로 Apple Music의 곡을 선택해 음악을 기록할 수 있습니다.
- ✅ 주변 장소에 남겨진 음악 탐색
  사용자는 지도 또는 리스트를 통해 인근 공간에 다른 사용자가 남긴 음악을 탐색할 수 있습니다.
- ✅ 같은 장소에서의 나의 과거 음악 회고
  이전에 같은 장소에 남긴 자신의 음악 기록을 시간순으로 확인하고 다시 감상할 수 있습니다.


## 🖼 화면 구성 및 시연

| 기능 | 설명 | 이미지 |
|------|------|--------|
| 예시1 | 기능 요약 | ![gif](링크) |
| 예시2 | 기능 요약 | ![gif](링크) |


## 🧱 폴더 구조

```
📦ProjectName
┣ 📂Feature
┃ ┣ 📂SceneA
┃ ┗ 📂SceneB
┣ 📂Core
┣ 📂UI
┣ 📂Test
┗ 📂Resources
```


## 🧑‍💻 팀 소개

| [Elena (김지윤)] (https://github.com/Jykim-111) | [Avery (정서진)](https://github.com/averysjung) | [OneThing (천은송)](https://github.com/freeskyES) | [Woody (이창건)(https://github.com/Mark3891) | [Henry (김현목)](https://github.com/NOP-YA) | [Kave (황지민)](https://github.com/RoastedJM) |
|:---:|:---:|:---:|:---:|:---:|:---:|
| <img src="https://github.com/Jykim-111.png" width="100" height="100" style="border-radius:50%"/> | <img src="https://github.com/averysjung.png" width="100" height="100" style="border-radius:50%"/> | <img src="https://github.com/freeskyES.png" width="100" height="100" style="border-radius:50%"/> | <img src="https://github.com/Mark3891.png" width="100" height="100" style="border-radius:50%"/> | <img src="https://github.com/NOP-YA.png" width="100" height="100" style="border-radius:50%"/> | <img src="https://github.com/RoastedJM.png" width="100" height="100" style="border-radius:50%"/> |

<!-- [🔗 팀 블로그 / 미디엄 링크](https://medium.com/example) -->

## 🔖 브랜치 전략

→ [docs/branch-guide.md](docs/branch-guide.md) 문서를 참고해주세요.


## 📚 커밋 컨벤션 가이드

→ [docs/commit-guide.md](docs/commit-guide.md) 문서를 참고해주세요.


## ✅ 테스트 방법

1. 이 저장소를 클론합니다.

    ```bash
    git clone https://github.com/DeveloperAcademy-POSTECH/2025-C4-M6-OMR.git
    ```

2. `Xcode`로 `.xcodeproj` 또는 `.xcworkspace` 열기
3. 시뮬레이터 환경 설정: iPhone 15 / iOS 17
4. `Cmd + R`로 실행 / `Cmd + U`로 테스트 실행


## 📎 프로젝트 문서

- [기획 히스토리](링크)
- [디자인 히스토리](링크)
- [기술 문서 (아키텍처 등)](링크)


## 📝 License

This project is licensed under the ~~[CHOOSE A LICENSE](https://choosealicense.com). and update this line~~
