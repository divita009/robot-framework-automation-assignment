*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    Collections

*** Variables ***
${URL}        https://www.google.com
${BROWSER}    Chrome
${QUERY}      robotframework
${WAIT}       14s
${MAX}        5

*** Test Cases ***
Google Search And Save Top 5 Links
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    2s
    Capture Page Screenshot    ${OUTPUT DIR}${/}step1_home.png

    # Search
    Wait Until Element Is Visible    name=q    10s
    Input Text    name=q    ${QUERY}
    Press Keys    name=q    ENTER

    # Manual CAPTCHA time (if it appears)
    Log To Console    \nIf CAPTCHA appears, solve it manually within ${WAIT}...
    Sleep    ${WAIT}
    Capture Page Screenshot    ${OUTPUT DIR}${/}step2_after_wait.png

    # Output file (safe remove + create)
    ${outfile}=    Set Variable    ${OUTPUT DIR}${/}output.txt
    Run Keyword And Ignore Error    Remove File    ${outfile}
    Create File    ${outfile}

    # Collect top 5 external links
    ${toplinks}=    Get Top External Links    ${MAX}

    Log To Console    \nTop ${MAX} Google Links:\n
    Append To File    ${outfile}    Top ${MAX} Google Links:\n

    FOR    ${link}    IN    @{toplinks}
        Log To Console    ${link}
        Append To File    ${outfile}    ${link}\n
    END

    Capture Page Screenshot    ${OUTPUT DIR}${/}step3_final.png
    Close Browser

*** Keywords ***
Get Top External Links
    [Arguments]    ${max}

    # anchors in search results area
    ${anchors}=    Get WebElements    xpath=//div[@id="search"]//a[@href]
    ${final}=      Create List

    FOR    ${a}    IN    @{anchors}
        ${href}=    Get Element Attribute    ${a}    href

        # Keep only real web links
        ${is_http}=    Run Keyword And Return Status    Should Start With    ${href}    http
        IF    not ${is_http}
            CONTINUE
        END

        # Skip Google internal links (search, accounts, etc.)
        ${is_google}=    Run Keyword And Return Status    Should Contain    ${href}    google.
        IF    ${is_google}
            CONTINUE
        END

        # Avoid duplicates
        ${dup}=    Run Keyword And Return Status    List Should Contain Value    ${final}    ${href}
        IF    ${dup}
            CONTINUE
        END

        Append To List    ${final}    ${href}

        ${length}=    Get Length    ${final}
        Exit For Loop If    ${length} >= ${max}
    END

    [Return]    ${final}