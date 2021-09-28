# EasyDiet

## Introduction
>  'Easy Diet' 는 쉽고 편리한 체중 다이어리 앱입니다. 
체중과 메모를 기록하고, 그것을 토대로 그래프에 시각화 시키는 것이 가능합니다. 

+ 개발 기간 : 2021.08.01 ~ 09.01
+ 참여 인원 : iOS 1명
+ 개발 목표
     - 달력 기반의 앱을 만들되, 그래프 또한 적용하여 체중 다이어리에 걸맞는 앱을 제작하자
+ 사용 기술
     - Language : Swift
     - Architecture: MVC
    - Framework : UIKit, CoreData
    - Library: Charts, FSCalendar
+ 배운 점
  - CoreData의 상태변화를 Notification을 통해 각 컨트롤러에게 전달하게하는 방법.
  - 커스텀 폰트를 적용하는 방법.
  - 텍스트 필드를 버튼처럼 활용하여, PickerView가 보여지게하는 방법.


## Screen Shot

<img src = "https://user-images.githubusercontent.com/83950413/135060733-92cbb892-54ca-4c53-a802-221eb0a85291.png" width = "20%" height = "20%" > <img src = https://user-images.githubusercontent.com/83950413/135060752-fb16ecda-36f9-44e4-978b-87706a8c500c.png width = "20%" height = "20%" > <img src = "https://user-images.githubusercontent.com/83950413/135060757-e42a515b-4f04-4e2f-ad99-5db69f3fea21.png" width = "20%" height = "20%" > <img src = "https://user-images.githubusercontent.com/83950413/135060762-aa23ea16-cd60-4097-b83b-db581848b674.png" width = "20%" height = "20%" >


## 앱스토어 링크 
 + https://apps.apple.com/kr/app/easy-diet/id1584944045

## 느낀점
페이지가 많지않아 짧은 기간안에 앱을 제작할 수 있었다. 하지만 그만큼 UI에 신경을 많이 썼으며, 커스텀폰트도 처음으로 적용해보았다. 꽤나 고생했던 부분은 그래프였는데, UISegmentedControl로 분류되어있는 기간을 기준으로 그래프에 적용하는 것이 어렵기도 했고, 무엇보다 날짜의 기준을 잡는게 애매하였다. 고민 끝에 토글되어있는 x축을 중심으로 좌우 여백을 선택된 기간의 반씩을 적용하기로 했는데, 나름 괜찮게? 시각화된 것 같아서 만족스러웠다. 

