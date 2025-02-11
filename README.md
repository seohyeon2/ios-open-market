
# 🛒 오픈 마켓

## 목차
* [Project Storage](#-project-storage)
* [Team](#-team)
* [Run screen](#-run-screen)
* [Development Environment and Library](#-development-environment-and-library)
* [Timeline](#-timeline)
    * [week1](#week-1)
    * [week2](#week-2)
    * [week3](#week-3)
    * [week4](#week-4)
* [Project Contents](#project-contents)
    * [Core Feature Experience](#-core-feature-experience)
* [TroubleShooting](#-troubleshooting)
* [Reference page](#reference-page)

## 💾 Project Storage
>**프로젝트 기간** : 2022-07-11 ~ 2022-08-05<br>
**소개** : 네트워크 통신을 통해 상품 API를 가져와 물건을 매매하는 앱입니다. <br>
**리뷰어** : [**라이언**](https://github.com/ryan-son)

## 👥 Team
    
| [현이](https://github.com/seohyeon2) | [언체인](https://github.com/unchain123) |
|:---:|:---:|
|<img src = "https://i.imgur.com/0UjNUFH.jpg" width="250" height="250">|<img src = "https://i.imgur.com/GlPnCo7.png" width="250" height="250">|

---
## 📺 Run screen
### Home screen

| ListCollectionView | GridCollectionView |
|:---:|:---:|
|<img src = https://i.imgur.com/SBqTBAk.gif width=200 height=400>|<img src = https://i.imgur.com/op5su98.gif width=200 height=400>|

### Product registration screen

| 상품 등록 과정 | 상품 등록 성공 | 상품 등록 실패 |
|:---:|:---:|:---:|
|<img src = https://i.imgur.com/YjuWno2.gif width=200 height=400>|<img src = https://i.imgur.com/XVGljW8.png width=200 height=400>|<img src = https://i.imgur.com/1tiOGeA.png width=200 height=400>|


## 🛠 Development Environment and Library
[![swift](https://img.shields.io/badge/swift-5.6-orange)]()
[![xcode](https://img.shields.io/badge/Xcode-13.4.1-blue)]()
[![swiftLint](https://img.shields.io/badge/SwiftLint-13.2-green)]()
---

## 🕖 Timeline

### Week 1
- **2022-07-11 (월)** 
  - 오픈마켓 I STEP1: URLSession에 대해서 파악하기 위해 공부
 
- **2022-07-12 (화)**
  - 오픈마켓 I STEP1: STEP1 PR

- **2022-07-13 (수)**
  - 오픈마켓 I STEP1: URLSession에 대해 다시 공부하고 CollectionView 공부

- **2022-07-14 (목)**
  - 오픈마켓 I STEP1: 리팩토링
  
- **2022-07-15 (금)**
  - 오픈마켓 I STEP1: Readme.md 작성 및 리팩토링

### Week 2
- **2022-07-18 (월)** 
  - 오픈마켓 I STEP2: 리팩토링
 
- **2022-07-19 (화)**
  - 오픈마켓 I STEP1: CollectionView 공부

- **2022-07-20 (수)**
  - 오픈마켓 I STEP2: List Collection View, Segmented Control 구현

- **2022-07-21 (목)**
  - 오픈마켓 I STEP2: 오토레이아웃 및 Grid 구현
  
- **2022-07-22 (금)**
  - 오픈마켓 I STEP2: Readme.md 작성 및 STEP2 PR 

### Week 3
- **2022-07-25 (월)** 
  - 오픈마켓 II STEP1: multipart/form-data 구조 공부 및 예제 코드 작성
 
- **2022-07-26 (화)**
  - 오픈마켓 I STEP1: 리팩토링

- **2022-07-27 (수)**
  - 오픈마켓 I STEP2: 리팩토링

- **2022-07-28 (목)**
  - 오픈마켓 II STEP1: http메서드 공부및 POST 메서드 구현
  
- **2022-07-29 (금)**
  - 오픈마켓 II STEP1: POST 메서드 구현 및 레이아웃 구현

### Week 4
- **2022-08-01 (월)** 
  - 오픈마켓 II STEP1: RegistrationViewController UI 구현
 
- **2022-08-02 (화)**
  - 오픈마켓 II STEP1: POST 메서드 수정 및 키보드 구현

- **2022-08-03 (수)**
  - 오픈마켓 II STEP2: STEP2에 필요한 개념 공부

- **2022-08-04 (목)**
  - 오픈마켓 II STEP1: 리팩토링
  
- **2022-08-05 (금)**
  - 오픈마켓 II STEP1: 리팩토링
  - 오픈마켓 II STEP2: RegistrationViewController UI 및 기능 구현
---

## Project Contents

### 💻 Core Feature Experience
- [x] UIAlertController 액션의 completion handler 활용
- [x] UIAlertController의 textFields 활용
- [x] UICollectionView 를 통한 좌우 스크롤 기능 구현

---

### 🏀 TroubleShooting

#### 1. Application Test VS Library Test

- ApplicationTest와 LibraryTest의 차이는 극명하다.
- ApplicationTest는 iOS앱과 관련된 부분을 검사할 때 주로 사용한다. 
- LibraryTest는 앱과 상관없는 로직을 테스트하기 위해 사용한다.
- 호스트 앱을 시뮬레이터에 설치할 필요가 없어서 테스트가 더 빠르고 이따금씩 동작이 불안정한 시뮬레이터의 영향을 덜받는다.
- 아래와 같이 기존의 테스트를 진행했을 때와 LivraryTest로 바꿔서 테스트를 진행했을 때 테스트당 걸리는 시간이 거의 10배에 가까운 유의미한 결과를 얻을 수 있었다.

|Application Test 걸린시간|Library Test 걸린시간|
|--|--|
|<img src = https://i.imgur.com/onFx9QR.png width = 300 height = 100> |<img src = https://i.imgur.com/OZAEbUi.png width = 700 height = 100>|

#### 2. URLSession Unit Test

- 비동기 테스트 시, 사진과 같이 XCTAssert 메서드가 호출조차 되지 않고 테스트가 끝나 버린다.
- `expectation(description:), fulfill(), wait(for:timeout:` 코드를 이용하였더니 비동기 작업을 기다리게 되어, 테스트가 가능하게 되었다. 
![](https://i.imgur.com/YaxLbBg.png)

#### 3. 네트워크 맵핑모델 트러블

- 네트워크에서 마지막 페이지까지 데이터를 받아오는 재귀함수를 만들었는데 마지막 페이지는 137이었는데 72번 페이지에서 재귀함수가 탈출하는 이슈가 발생했다.
- LLDB를 이용해 함수의 분기마다 확인을 했을 때 72번째 페이지를 디코딩 하는 과정에서 맵핑에 실패하여 함수를 탈출함.
- 문제가 생긴 키값(price, bargainPrice, discountedPrice)이 Double값이 아니라 Int로 모델을 만들었기 때문에 Double값을 나타내는 72번째 페이지에서는 맵핑을 실패 했던 것이었다.
- 문제가 있던 키값의 타입을 Double로 바꿔서 해결 할 수 있었다.
- 마켓의 상품가격들이 한화뿐만 아니라 USD등 외화도 포함이 되었기 때문에 Int로 하는 것은 제대로된 모델링이 아니었던 것 같다. 사소한 부분도 잘 확인해서 이런 실수를 하지 않도록 해야 겠다.

| 네트워크 맵핑모델 | 서버 정보 | 트러블 결과 |
|:--:|:--:|:--:|
|<img src = https://i.imgur.com/x9fe0O9.png width = 180 height = 60> |<img src = https://i.imgur.com/3BQxRVi.png width = 500 height = 200>|<img src = https://i.imgur.com/MoPV79O.png width = 800 height = 200>|

#### 4. 리스트 형식의 collectionview에서 이미지의 크기가 작아지던 현상
- 처음 UICollectionView의 List형식레이아웃을 잡을 대 아래와 같이 apperance를 설정해 줬다.
```swift
let config = UICollectionLayoutListConfiguration(appearance: .plain)
//처음설정
imageStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 80),
imageStackView.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
//변경해본설정
imageStackView.widthAnchor.constraint(equalToConstant: 80),
imageStackView.heightAnchor.constraint(equalToConstant: 80)
```
- 그랬더니 처음엔 아래의 사진과 같이 사진이 작게 표현되는 셀들이 있었고 이 원인이 lessThanOrEqual이라고 했기 때문에 작아저 버리는거라고 생각해서 equalToConstant로 변경을 했더니 아래와 같이 Autolayout에서 충돌이 일어나는 것을 확인 할 수 있었다.

| 충돌 원인 |
|:--:|
|<img src = https://i.imgur.com/LwSy5Os.png width = 600 height = 150>|
| 충돌 화면 |
|<img src = https://i.imgur.com/rfAzEsn.png width = 250 height = 500>|


- 우리가 확인한 충돌 원인은 `UICollectionLayoutListConfiguration(appearance: .plain)`이 내부적으로 높이를 44로 설정해주고 있다는 것이었다. 그래서 우리가 설정해준 heightAncor = 80 과는 충돌을 일으켰고 두 값중에 어떤 값이 맞는지 판단하지 못한 컴파일러가 두 값을 무작위로 내보내고 있다고 판단했다.
- 처음으로 생각했던 해결 방법은 이미지의 크기에 Priority를 높여서 셀의 크기가 아닌 이미지의 크기를 반영하도록 하게 하는 방법 이었는데 이 방법을 사용하니 이미지를 제외한 다른 레이블들은 밀려나버리는 현상이 발생하여 대안을 찾게 되었다
- 최종적으로 우리가 선택한 방법은 내부적으로 알 수 없는 값이 지정되어있는 `UICollectionViewCompositionalLayout.list`가 아닌 `UICollectionViewCompositionalLayout(section: )`으로 변경해서 직접 collectionView의 item,group,section의 사이즈를 지정해 주는 방법 이었다.


#### 5.snapshot apply 시점 오류

- 기존 `snapshot`의 `apply` 적용은 데이터를 받아오는 시점(`getProductList`호출 시)에만 진행되었다.
그랬더니 `getProductList` 메서드로 데이터를 가져오는 시간 동안에는 `segmentedControl`로 layout 변경이 가능했지만,
모든 데이터를 받아온 후로는 layout을 변경해 주면 아래와 같이 layout 자체가 날아가는 현상이 발생했다.

| 오류화면 |
|:--:|
|<img src = https://i.imgur.com/tt55i4h.png width = 200 height = 300>|


- debug 창을 통해 layout이 깨지는 시점과 `getProductList` 메서드의 escaping closer 종료 시점과 동일하다는 것을 알 수 있었다.
이를 통해 모든 데이터가 받아 온 후에도 `apply` 적용을 해주면 되겠다는 아이디어를 얻을 수 있었고,
`segmentedControl`에서 바꿀 때에도 `apply` 적용을 해주었더니 layout 깨짐 현상을 해결 할 수 있었다.

| 기존의 코드 | 해결한 코드 |
| :--: | :--: |
|<img src = https://i.imgur.com/orryKJl.png width = 400 height = 200>|<img src = https://i.imgur.com/ZK8yfsf.png width = 400 height = 200>|


#### 6. URLRequest Timeinterval Test
- URLRequest의 Timeinterval 값은 default값이 60초인데 이 시간을 넘으면 어떻게 되는지 확인하기 위해 실기기로 테스트를 진행 해 보았다.
- 실기기에서 테스트 할 때 아래와 같은 컨디션으로 설정을 해준 다음 테스트를 진행 했다.
<img src = https://i.imgur.com/4VYU6h0.png width = 225 height = 200>
- 결과를 빠르게 확인하기 위해 Timeinterval을 10초로 설정하고 진행 하였고 10초가 지난 다음에는 아래와 같이 우리가 설정해준 얼럿 메세지를 확인 할 수 있었다.

| 얼럿메세지 | 이후 로딩뷰|
| :--: | :--: |
|<img src = https://i.imgur.com/YLyBtW9.png width = 200 height = 400>|<img src = https://i.imgur.com/2STJ1Ms.png width = 200 height = 400>|

### 7. remove Observer
- 상품등록 화면에서 키보드의 입력 상태를 확인하기 위해 NotificationCenter를 사용해 Observer를 추가한 뒤 다시 remove Observer를 해야 한다고 생각했고 removeOBserver메서드를 사용 했었는데 이게 꼭 필요할까요? 라는 리뷰어의 말을 듣고 공식문서를 찾아보았다.
- 아래와 같은 글을 발견하고 우리의 타겟 버전은 14.0이기 때문에 누구보다 빠르게 removeObserver메서드를 지웠다.

<img src = https://i.imgur.com/8v6wmC5.png width = 500 height = 50>
---


### Reference page

- [Implementing Modern Collection Views](https://developer.apple.com/documentation/uikit/views_and_controls/collection_views/implementing_modern_collection_views)
