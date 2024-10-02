# MATLAB Script for download HYCOM GOFS 3.1 outputs

1. You can download HYCOM GOFS 3.1 outputs with this code.
2. You can **set the Period, Area, Depth, temporal resolution** of the data. 
3. Note that, sometimes running may "shut down" with error messages due to HYCOM server problems.   
However, **code would be automatically reruned**. So there is no problem. 
4. There may be cases that the download process have been interrupted, and user manually restart the code.   
In such cases, if the download folder path is the same as before, the new download process will **exclude any previously downloaded MAT files**.
5. The downloaded file format is **"MAT" files with "Structure (Struct)"** data type. 
6. MAT files will be saved in separate folders categorized by year.

If you have any questions or suggestions, please contact me at the following email addres.

hwangjiuk34@gmail.com

More information about HYCOM can be found on the following website.

HYCOM GOFS 3.1 Analysis :   https://www.hycom.org/dataserver/gofs-3pt1/analysis

HYCOM GOFS 3.1 Renalysis :  https://www.hycom.org/dataserver/gofs-3pt1/reanalysis

---

# (Korean) HYCOM 3.1 산출물을 다운받을 수 있는 MATLAB 코드

1. 본 코드를 이용하여 HYCOM 3.1 산출물을 다운받을 수 있습니다.
2. 본 코드에서는 **원하는 기간, 시간 해상도, 지역 범위, 수심**을 선택할 수 있습니다. 
3. 참고하실 점은, HYCOM 서버 자체의 문제로 인하여 다운로드 받는 과정이 중단될 수 있습니다.   
그렇지만, 코드는 **자동으로 재실행**되어 다운로드를 다시 시도하도록 작성되었습니다.   
따라서 서버 문제로 인하여 코드 실행 과정에서 에러 메시지가 나타나더라도, 걱정하실 필요는 없습니다.
4. 다운로드 과정이 중단되어 사용자가 코드를 수동으로 재실행해야 하는 경우가 있을 수 있습니다.   
이러한 경우에 다운로드 폴더 경로가 이전과 동일하다면, 새로운 다운로드 과정에서는 **이미 다운로드된 MAT 파일들을 제외**하고 진행됩니다.
5. 다운로드된 자료는 **MAT 파일** 형식으로, 데이터 타입은 **구조체**의 성격을 가집니다.
6. 다운로드된 MAT 파일들은 연도별 폴더에 분류되어 저장됩니다. 

만약 질문이나 제안이 있다면, 아래의 메일로 연락주세요. 

hwangjiuk34@gmail.com

HYCOM 에 대한 더 많은 정보는 아래의 웹사이트에서 확인하실 수 있습니다. 

HYCOM GOFS 3.1 분석장 :    https://www.hycom.org/dataserver/gofs-3pt1/analysis

HYCOM GOFS 3.1 재분석장 :  https://www.hycom.org/dataserver/gofs-3pt1/reanalysis
