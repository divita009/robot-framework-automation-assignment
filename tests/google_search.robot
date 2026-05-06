*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${URL}    https://www.google.com
${BROWSER}    Chrome

*** Test Cases ***
Search Robot Framework And Print Results
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

    Input Text    name=q    robotframework
    Press Keys    name=q    ENTER

    Sleep    3s

    ${results}=    Get WebElements    xpath=//h3

    Log To Console    \nTop Results:

    FOR    ${i}    IN RANGE    0    5
        ${text}=    Get Text    ${results}[${i}]
        Log To Console    ${text}
        Append To File    output.txt    ${text}\n
    END

    Close Browser