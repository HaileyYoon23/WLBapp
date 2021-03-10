# WLBapp
iOS App. to Manage Working Time for WLB(Work/Life Balance)


# 1. Introduction
## 1.1 Purpose
출퇴근을 하면서 중요하다고 생각하는 정보 중 하나는 **오늘 몇시부터 퇴근이 가능** 하냐에 대한 정보이다. <br>
해당 정보를 통해 그 이후의 출근 계획, 크게는 일주일의 출근계획을 세울 수 있기 때문이다 <br>
또한 이러한 전략은 일과 삶의 조화를 아름답게 이룰 수 있는 원동력이 되어준다 <br><br>
> 일과 삶의 아름다운 조화. Work Life Balance!<br>


이 조화는 더욱 오랜 회사생활을 즐겁게 해줄 수 있다.<br>
허나 iOS 기준, AppStore에 나와있는 어플들은 다양한 유연근무제 형식에 걸맞게 Config.를 하기 힘들고 정말 중요한 **오늘 몇시부터 퇴근 가능**에 대한 정보를 쉽게 보기 힘들다.<br>
따라서 해당 App.을 제작해보기로 한다.
<br><br>



## 1.2 BraninStorming  

<img src="https://user-images.githubusercontent.com/35250492/110629279-56493980-81e7-11eb-9f3f-d72b8acc05f2.jpg" width="600">


# 2. Development
# 2.1 Code Structure

```

┌ ViewController.swift
│ 
├ DetailViewController.swift
│ └ EditDetailViewController.swift
│
└ SettingViewController.swift

```

# 2.1.1 ViewController.swift  
앱 실행 시 첫 화면  
<img src="https://user-images.githubusercontent.com/35250492/110625801-3e6fb680-81e3-11eb-8811-c9447316550a.PNG" width="300">  

# 2.1.2 DetailViewController.swift  
Detail 정보 표시 화면  
<img src="https://user-images.githubusercontent.com/35250492/110625826-47f91e80-81e3-11eb-9d73-ab21af593904.PNG" width="300">  

# 2.1.3 EditDetailViewController.swift  
각 Detail 정보 수정 화면  
<img src="https://user-images.githubusercontent.com/35250492/110626114-aa521f00-81e3-11eb-903a-502dfc25d4c5.PNG" width="300">

# 2.1.4 SettingViewController.swift  
사용자 별 근무 시간 설정 화면  
<img src="https://user-images.githubusercontent.com/35250492/110625820-4596c480-81e3-11eb-959d-80ba4ab9a170.PNG" width="300">  
<br>
# 2.2 DB Structure  
근무 정보 DB는 복잡성을 요구하지는 않지만, 계속해서 DB를 Update 하므로 프로그램 충돌 시의 DB 보존이 가장 중요하다.  
따라서 간편하고 트랜잭션과 원자성 동작을 지원하는 **SQLite**를 사용하였다.  
# 2.2.1 MemoryWorkTime.swift  
<br>

|Id|Commute|OffWork|LastAppUse|Rest|RealWorkedTime|WorkedTime|WeekDay|DayWorkStatus|SpareTimeToWork|IsWorking|
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|CHAR(255)|CHAR(255)|CHAR(255)|CHAR(255)|Int|Int|Int|Int|Int|Int|Int|
|2021.03.02|09:18:03|19:59:24|2405||32455|38460|3|3|111545|0|
|...|...|...|...|...|...|...|...|...|...|...|


# 2.2.2 MemoryInit.swift  
|Id|WeekLeastHour|WeekLeastMin|DayGoalHour|DayGoalMin|DayLeastHour|DayLeastMin|DayLeastStartHour|DayLeastStartMin|LastUpdatedDate|
|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|
|Int|Int|Int|Int|Int|Int|Int|Int|Int|CHAR(255)|
|0|40|0|8|0|4|0|15|0|19:59:24|


# 2.2.3 MemoryWeekInfo.swift  
|Id|NonWorkHour|NonWorkMin|NumOfNonWorkFullDay|NumOfNonWorkHalfDay|
|:-----:|:-----:|:-----:|:-----:|:-----:|
|CHAR(255)|Int|Int|Int|Int|
|2021.03.week1|12|0|1|1|
|...|...|...|...|...|


# 2.2 StoryBoard
<img src="https://user-images.githubusercontent.com/35250492/110471138-1d459200-811f-11eb-9901-24fec2ce4283.png" width="600">

# 3. Result
## 3.1 ViewController.swift  

* 시간 경과 시, bar update  
<img src="https://user-images.githubusercontent.com/35250492/110626585-43813580-81e4-11eb-92ed-acd6e243a3e1.PNG" width="300">
<img src="https://user-images.githubusercontent.com/35250492/110626590-454af900-81e4-11eb-9bf3-6c318b12c3b3.png" width="300"> <br><br>

* 출근 Color Status  

<img src="https://user-images.githubusercontent.com/35250492/110626855-965aed00-81e4-11eb-891e-25aa761dfd18.jpg" width="300"> <br><br>

## 3.2 DetailViewController.swift  

* 요일별 출근 Detail 표출  

<img src="https://user-images.githubusercontent.com/35250492/110626964-bb4f6000-81e4-11eb-9a93-f65460accb8a.PNG" width="300"> <br><br>

## 3.3 EditDetailViewController.swift

* 선택 요일에 대한 출근시간/퇴근시간/휴게시간 수정 (당일 수정 시, 퇴근 전일 경우 퇴근시간 수정 불가)

<img src="https://user-images.githubusercontent.com/35250492/110627166-f8b3ed80-81e4-11eb-8bdb-1769be549098.PNG" width="300"> <br><br>

## 3.4 SettingViewController.swift  

* 사용자 별 출퇴근 관리 설정 변경 (해당 시간에 따라 정상출근/근태수정필요/지각 및 퇴근가능시간 결정)  

<img src="https://user-images.githubusercontent.com/35250492/110627497-652eec80-81e5-11eb-8c55-3af8b693663e.PNG" width="300"> <br><br>

# 4. 업데이트 예정

1. 토/일 자동 비근로 설정
2. 토/일 제외, 일주일의 마지막 근로일만 '퇴근가능시간' 으로 진행. 나머지는 '퇴근목표시간'
3. DayGoal 말고 SpareTime으로 퇴근시간 계산시, DayGoal 초과시 퇴근시간 수정 필요
4. Detail 탭에 금주 총 근무시간 / 휴게시간 display
