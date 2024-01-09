*** Settings ***
Library    RPA.Browser.Selenium    auto_close=${False}
Library    Collections
Library    OperatingSystem
Library    String
Library    Process
Library    RPA.Desktop
Library    RPA.Robocorp.WorkItems
Library    RPA.Robocorp.Storage 
Library    excel_to_csv.py
library    RPA.Database
*** Variables ***
${SHARED_PATH}     %{DOWNLOAD_FOLDER}
${Expected_Message}    %{Fileupload_Status}
${username}           %{USERNAME}
${password}           %{PASSWORD}
${DOWNLOAD_FOLDER}    %{FileDownloadPAth}
${Input_Path}     %{Input_Filepath}
${output_file_path}   
${Test}    
${EPF_Inspection_Charges}                  0
${EDLI_Administration_Charges}             0
${EDLI_Inspection_Charges}                 0
${Total_Number_Of_Employees_In_Month}      0
${Total_Number_Of_Excluded_Employees_In_Month}  0
${Total_Gross_Wages_Of_Excluded_Employees_In_Month}  0
${xpected_Message}    %{Fileupload_Status}
${Counter}    0
${Retry_Limit}    2

*** Keywords ***
Click Element When Visible
    [Arguments]    ${PreLocator}    ${Elementtype}    ${PostLocator}
    Wait Until Element Is Visible     ${PreLocator}   timeout=120    error=${Elementtype} not visible within 2m
    Click Element     ${PreLocator}
    Wait Until Element Is Visible    ${PostLocator}    timeout=30    error= unable to navigate to next page
    Log    Successfully Clicked on ${Elementtype}
Open EPF India Website
    Open Browser    https://www.epfindia.gov.in/site_en/index.php#    chrome    options=add_experimental_option("detach", True) 
    Maximize Browser Window
    Wait Until Element Is Visible    xpath://*[@id="ecr_panel_1"]    timeout=30     error=Unbale to launch EPF website..    
Click ECR/Returns/Payment Button
    Click Element     xpath://*[@id="ecr_panel_1"]
    Switch Window        EPFO: Home     timeout=30s
    Wait Until Element Is Visible    xpath://*[@id="btnCloseModal"]    timeout=30s     error= Unable to find Alert Popup..
Accept Popup
    Click Button    xpath://*[@id="btnCloseModal"]  
    Log    Opened EPFO login page   
Enter Username and Password
    [Arguments]    ${username}    ${password}
    # ${USERNAME}=    Get Environment Variable    USERNAME
    # ${PASSWORD}=    Get Environment Variable    PASSWORD
    Wait Until Element Is Visible   xpath://*[@id="username"]    timeout=30s     error=Unable to find username input
    Input Text    xpath://*[@id="username"]    ${username}       username button
    Input Text    xpath://*[@id="password"]    ${password}       password button
    Log    Entered username and password   
Click Signin Button
    Click Button    //button[@class='btn btn-success btn-logging']
    TRY
        Wait Until Element Is Visible       //*[contains(@class, 'dropdown-toggle') and contains(text(), 'Payment')]    timeout=30s    error=Unable to login EPFO
    EXCEPT    message 
        Click Element    //*[@id="digitalJeevanAlertBox"]//*[@id="alertButtton"]/a
        Wait Until Element Is Visible       //*[contains(@class, 'dropdown-toggle') and contains(text(), 'Payment')]    timeout=30s    error=Unable to login EPFO
    END    
    Log    Successfully logging EPFO
Click Payments Menu
    Click Element When Visible    //*[contains(@class, 'dropdown-toggle') and contains(text(), 'Payment')]    Payment Menu    //ul[@class='dropdown-menu m1']//a[text()='ECR/RETURN FILING']     # payment
Click ECR/RETURN FILE Menu Item  
    Click Element When Visible    //ul[@class='dropdown-menu m1']//a[text()='ECR/RETURN FILING']    ECR/RETURN FILE Menu Item     //tr[@class='row1 trs']//a[text()='ECR Upload']   # ECR/RETURN FILE 
Click ECR Upload Hyperlink
    Click Element When Visible    //tr[@class='row1 trs']//a[text()='ECR Upload']    ECR Upload Hyperlink      //*[@id="ui-id-3"]      # ECR Upload     
 Click ECR file upload Button    
    Click Element When Visible    //*[@id="ui-id-3"]     ECR file upload Button    //input[@id='wageMonth']     # ECR file upload
Click WageMonth Button 
    Click Element When Visible    //input[@id='wageMonth']       Month Button   //*[@id="ui-datepicker-div"]/div[2]/button[1]                 # Month
    Click Element When Visible   //*[@id="ui-datepicker-div"]/div[2]/button[1]   Declaration of month    //Div/button[contains(text(), 'Done')]       # Declaration of month
    Click Element When Visible    //Div//button[contains(text(), 'Done')]      Done    //input[@id='salaryDate']
    Click Element When Visible    //input[@id='salaryDate']   Salary Dispursal    //*[@id="ui-datepicker-div"]/table/tbody/tr[1]/td[2]/a  # Salary dispursal
    Click Element When Visible    //*[@id="ui-datepicker-div"]/table/tbody/tr[1]/td[2]/a     Date of salary Dispursal        ecrFileType 
    Select Radio Button    ecrFileType    E          # ECR declaration
    Input Text       xpath://*[@id="ecrFileUploadRemarks"]       ok                                                  #remarksUpload Textfile
    ${result}=   Run Keyword   excel_to_csv.excel_to_text
    Log    ${result} 
    Sleep   5s                          
    Choose File    //*[@id="multiFile"]  ${result}
    Wait Until Element Is Visible    //*[@id="btnUploadECRFile"]    timeout=30s    error=unable to find Upload button
    Click Element When Visible    //*[@id="btnUploadECRFile"]    upload    xpath=//div[@class='alert alert-success']
    Wait Until Element Is Visible    xpath=//div[@class='alert alert-success']    timeout=30s    error= unable to find Success message
Validate and Wait for Appear Verify
    ${actual_message} =    Get Text     xpath=//div[@class='alert alert-success']
    IF    $actual_message == $Expected_Message
        WHILE    $Counter > $Retry_Limit
            TRY
                Wait Until Element Is Visible    //*[@id="tbClaimList"]//tbody/tr[1]/td[12]/a[contains(text(), 'Verify')]   timeout=30s   error=not found
            EXCEPT
                Sleep    30        
                ${Counter}= ${Counter} + 1       
                Log    ${Counter} 
            END
        END
    ELSE
        Sleep    120
    END    
    Click Element     //*[@id="tbClaimList"]//tbody/tr[1]/td[12]/a[contains(text(), 'Verify')]
    Handle Alert  
     ${files}=    List Files In Directory    ${DOWNLOAD_FOLDER}
        FOR  ${file}    IN    @{files}
           ${lowercase_file}=    Convert To Lowercase    ${file}
           Run Keyword If    "${lowercase_file}".startswith("EPF_Regular_ECR") or "${lowercase_file}".startswith("EPF_Regular_ECR")    Move File    ${DOWNLOAD_FOLDER}/${file}    ${SHARED_PATH}/${file}
           Run Keyword If    "${lowercase_file}".startswith("tnma") or "${lowercase_file}".startswith("tnma")    Move File    ${DOWNLOAD_FOLDER}/${file}    ${SHARED_PATH}/${file}
           Run Keyword If    "${lowercase_file}".startswith("ECR_CHLN_REC_TNMA") or "${lowercase_file}".startswith("ECR_CHLN_REC_TNMA")    Move File    ${DOWNLOAD_FOLDER}/${file}    ${SHARED_PATH}/${file}

        END     
Download ECR File
        Click Element When Visible  //div[@class='form-horizontal algncenter']/table/tbody/tr[1]/td[9]/a[1]    ECR    //div[@class='form-horizontal algncenter']/table/tbody/tr[1]/td[10]/a
Download ECR Statement
        Click Element When Visible    //div[@class='form-horizontal algncenter']/table/tbody/tr[1]/td[10]/a   ECR Statament    xpath=//div[@class='alert alert-success'] 

       
Generate TRRN Number and Click Prepare Challan Button
        Wait Until Element Is Visible    xpath=//div[@class='alert alert-success']   
        ${text}=    Get Text    xpath=//div[@class='alert alert-success']
        Log    Original Text: ${text}        
        ${transid}  Get Regexp Matches  ${text}  (?sim)(?<=TRRN is\\s)\\d+         
        Log  NewText: ${transid[0]} 
        Sleep   10s
        ${link_element}    Get web Element    xpath=//tr[td[text()='${transid[0]}']]//a[contains(text(), 'Prepare Challan')]
        Click Element    ${link_element}
        Input Text    //input[@id='epfInspectionCharges']         ${EPF_Inspection_Charges}
        Input Text    //input[@id="edliAdministrationCharges"]     ${EDLI_Administration_Charges}
        Input Text    //input[@id="edliInspectionCharges"]        ${EDLI_Inspection_Charges}
        Input Text    //input[@id='totalNumberOfEmployeesInMonth']    ${Total_Number_Of_Employees_In_Month}
        Input Text    //input[@id="totalNumberOfExcludedEmployeesInMonth"]    ${Total_Number_Of_Excluded_Employees_In_Month}
        Input Text    //input[@id="totalGrossWagesOfExcludedEmployeesInMonth"]    ${Total_Gross_Wages_Of_Excluded_Employees_In_Month}
        Wait Until Element Is Visible    //button[@id='submitEcr']    timeout= 30    error= unable to submit button    
        Click Element  //button[@id='submitEcr']
        Handle Alert
        Wait Until Element Is Visible    //tr[td[text()='${transid[0]}']]//a[contains(@title, 'Click to finalize challan')]    timeout= 30    error= unable to find finalize element         
        Click Element   //tr[td[text()='${transid[0]}']]//a[contains(@title, 'Click to finalize challan')]
        Handle Alert        
        Click Element When Visible      //span[@class="glyphicon glyphicon-download-alt"]      DOwnload receipt file    //tr[td[text()='${transid[0]}']]//a[contains(text(), 'Pay')]
        Wait Until Element Is Visible    //tr[td[text()='${transid[0]}']]//a[contains(text(), 'Pay')]    timeout= 30    error= unable to find pay button 
        Click Element       //tr[td[text()='${transid[0]}']]//a[contains(text(), 'Pay')]
      
*** Test Cases ***
Launch EPFO website
    TRY
        Open EPF India Website
    EXCEPT    
        Close Browser
        Open EPF India Website
    END 
  Open EPF India Website
  Click ECR/Returns/Payment Button
  Accept Popup


Login EPFO Application 
    Enter Username and Password   ${username}    ${password}
    Click Signin Button
Go to ECR upload page
    Click Payments Menu
    Click ECR/RETURN FILE Menu Item 
    Click ECR Upload Hyperlink
    Click ECR file upload Button 
Data of ECR Fileupload
    Click WageMonth Button    
ECR File Verification  
    Validate and Wait for Appear Verify          
    Download ECR File
    Download ECR Statement
    Generate TRRN Number and Click Prepare Challan Button
   





 
# robot --outputdir /home/buzzadmin/robotframework/siva/output_directory/$(date +%Y%m%d_%H%M%S)_output /home/buzzadmin/robotframework/siva

   







 
















