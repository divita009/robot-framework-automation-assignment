*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    Collections
Library    String

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

    # STRICT CHECK: If results are not visible after waiting, FAIL
    Ensure Results Loaded Or Fail    ${outfile}

    # Collect top 5 main result links (unique by domain)
    ${toplinks}=    Get Top Result Links Unique By Domain    ${MAX}

    ${count}=    Get Length    ${toplinks}
    Run Keyword If    ${count} == 0    Fail    Results page loaded but no links were captured.

    Log To Console    \nTop ${MAX} Google Result Links (Unique Domains):\n
    Append To File    ${outfile}    Top ${MAX} Google Result Links (Unique Domains):\n

    FOR    ${link}    IN    @{toplinks}
        Log To Console    ${link}
        Append To File    ${outfile}    ${link}\n
    END

    Capture Page Screenshot    ${OUTPUT DIR}${/}step3_final.png
    Close Browser

*** Keywords ***
Ensure Results Loaded Or Fail
    [Arguments]    ${outfile}

    ${ok}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    xpath=//div[@id="search"]//a[h3 and @href]    10s

    IF    not ${ok}
        Capture Page Screenshot    ${OUTPUT DIR}${/}step_captcha_or_block.png
        Append To File    ${outfile}    CAPTCHA not solved or results did not load. Check screenshot: step_captcha_or_block.png\n
        Close Browser
        Fail    CAPTCHA not solved / results not loaded (failing as required).
    END

Get Top Result Links Unique By Domain
    [Arguments]    ${max}

    ${result_links}=    Get WebElements    xpath=//div[@id="search"]//a[h3 and @href]

    ${final}=      Create List
    ${domains}=    Create List

    FOR    ${a}    IN    @{result_links}
        ${href}=    Get Element Attribute    ${a}    href

        ${is_http}=    Run Keyword And Return Status    Should Start With    ${href}    http
        IF    not ${is_http}
            CONTINUE
        END

        ${is_google}=    Run Keyword And Return Status    Should Contain    ${href}    google.
        IF    ${is_google}
            CONTINUE
        END

        ${domain}=    Evaluate    __import__("urllib.parse", fromlist=["urlparse"]).urlparse($href).netloc
        ${domain}=    Replace String    ${domain}    www.    ${EMPTY}

        ${dup_domain}=    Run Keyword And Return Status    List Should Contain Value    ${domains}    ${domain}
        IF    ${dup_domain}
            CONTINUE
        END

        Append To List    ${domains}    ${domain}
        Append To List    ${final}      ${href}

        ${length}=    Get Length    ${final}
        Exit For Loop If    ${length} >= ${max}
    END

    RETURN    ${final}