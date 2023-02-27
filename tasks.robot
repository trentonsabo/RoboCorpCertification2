*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc and save receipts in a .zip file. 
                    

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.RobotLogListener
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.FileSystem

*** Variables ***
${PDF_TEMP_OUTPUT_DIRECTORY}=       ${CURDIR}${/}temp

*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Open the robot order website and click the button
    Download the orders.csv file
    Fill out each robot form and take screenshots of each robot and save pdfs of each receipt
    Create ZIP package from PDF files

*** Keywords ***
Open the robot order website and click the button
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the orders.csv file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

Close the annoying modal
    Wait Until Page Contains Element    class:alert-buttons
    Click Button    Yep

Fill and submit the form for one person
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    Preview
    Click Button    id:order
    FOR    ${i}    IN RANGE    9999999
        ${success} =    Is Element Visible    id:receipt
        IF    ${success}            BREAK
        Click Button    id:order
    END

Fill out each robot form and take screenshots of each robot and save pdfs of each receipt
    ${orders} =    Read table from CSV    orders.csv    dialect=excel    header=${True}
    Log    Found columns: ${orders.columns}
    Set up directory
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill and submit the form for one person    ${order}
        ${screenshot} =    Screenshot
        ...    id:robot-preview-image
        ...    ${OUTPUT_DIR}${/}robot_preview_${order}[Order number].jpeg
        Wait Until Element Is Visible    id:receipt    #receipt is the locator
        ${receipt_html} =    Get Element Attribute    id:receipt    outerHTML
        Html To Pdf
        ...    ${receipt_html}
        ...    ${PDF_TEMP_OUTPUT_DIRECTORY}${/}receipt_${order}[Order number].pdf
        Wait Until Page Contains Element    id:order-another
        Click Button    id:order-another
        ${file} =    Create List
        ...    ${OUTPUT_DIR}${/}robot_preview_${order}[Order number].jpeg
        ...    ${PDF_TEMP_OUTPUT_DIRECTORY}${/}receipt_${order}[Order number].pdf
        Add Files To Pdf    ${file}    ${PDF_TEMP_OUTPUT_DIRECTORY}${/}receipt_${order}[Order number].pdf
    END

Set up directory
    Create Directory    ${PDF_TEMP_OUTPUT_DIRECTORY}


Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${PDF_TEMP_OUTPUT_DIRECTORY}
    ...    ${zip_file_name}


 
