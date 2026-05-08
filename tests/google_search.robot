*** Settings ***
Library    SeleniumLibrary    run_on_failure=Nothing
Library    OperatingSystem
Library    Collections

*** Variables ***
${URL}        https://www.google.com
${BROWSER}    Chrome
${QUERY}      robotframework
${WAIT}       23s
${MAX}        5

*** Test Cases ***
Google Search And Save Top 5 Visible Links
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Sleep    2s
    Capture Page Screenshot    ${OUTPUT DIR}${/}step1_google_home.png

    # Optional: Consent screen (won't fail if not present)
    Run Keyword And Ignore Error    Click Element    xpath=//button//*[contains(.,'Accept all')]/..
    Run Keyword And Ignore Error    Click Element    xpath=//button//*[contains(.,'I agree')]/..

    # Type query
    Wait Until Element Is Visible    name=q    10s
    Input Text    name=q    ${QUERY}
    Capture Page Screenshot    ${OUTPUT DIR}${/}step2_query_typed.png
    Press Keys    name=q    ENTER

    # Manual CAPTCHA window
    Log To Console    \nIf CAPTCHA appears, solve it manually within ${WAIT}...
    Sleep    ${WAIT}

    # ALWAYS take a checkpoint screenshot after CAPTCHA wait
    Capture Page Screenshot    ${OUTPUT DIR}${/}step3_captcha_or_checkpoint.png

    # Output file in results folder
    ${outfile}=    Set Variable    ${OUTPUT DIR}${/}output.txt
    Run Keyword And Ignore Error    Remove File    ${outfile}
    Create File    ${outfile}

    # Fail if results did not load (CAPTCHA not solved / blocked)
    Ensure Results Loaded Or Fail    ${outfile}

    # Get top 5 visible main results (no duplicate URLs)
    ${toplinks}=    Get Top Visible Main Results No Duplicates    ${MAX}

    ${count}=    Get Length    ${toplinks}
    Run Keyword If    ${count} < ${MAX}    Fail    Only captured ${count} unique links. Google layout/CAPTCHA may have affected results.

    Capture Page Screenshot    ${OUTPUT DIR}${/}step4_results.png

    Log To Console    \nTop ${MAX} Visible Google Result Links:\n
    Append To File    ${outfile}    Top ${MAX} Visible Google Result Links:\n

    FOR    ${link}    IN    @{toplinks}
        Log To Console    ${link}
        Append To File    ${outfile}    ${link}\n
    END

    Close Browser


*** Keywords ***
Ensure Results Loaded Or Fail
    [Arguments]    ${outfile}

    ${ok}=    Run Keyword And Return Status
    ...    Wait Until Page Contains Element    xpath=//div[@id="search"]//a[h3 and @href]    10s

    IF    not ${ok}
        Capture Page Screenshot    ${OUTPUT DIR}${/}step3_captcha_failed.png
        Append To File    ${outfile}    CAPTCHA not solved or results not loaded. Check screenshot: step3_captcha_failed.png\n
        Close Browser
        Fail    CAPTCHA not solved / results not loaded.
    END


Get Top Visible Main Results No Duplicates
    [Arguments]    ${max}

    # Get main organic result blocks (natural top order)
    ${blocks}=    Get Element Count    xpath=//div[@id="search"]//div[contains(@class,"MjjYud")]
    ${final}=     Create List
    ${seen}=      Create List
    ${picked}=    Set Variable    0

    FOR    ${i}    IN RANGE    1    ${blocks}+1
        ${a_locator}=    Set Variable
        ...    xpath=(//div[@id="search"]//div[contains(@class,"MjjYud")])[${i}]//a[h3 and @href][1]

        ${exists}=    Run Keyword And Return Status    Page Should Contain Element    ${a_locator}
        IF    not ${exists}
            CONTINUE
        END

        ${href}=    Get Element Attribute    ${a_locator}    href

        ${is_http}=    Run Keyword And Return Status    Should Start With    ${href}    http
        IF    not ${is_http}
            CONTINUE
        END

        ${is_google}=    Run Keyword And Return Status    Should Contain    ${href}    google.
        IF    ${is_google}
            CONTINUE
        END

        # If redirect (/url?q=...), extract real destination
        ${clean}=    Evaluate    __import__("urllib.parse", fromlist=["urlparse","parse_qs"]).parse_qs(__import__("urllib.parse", fromlist=["urlparse"]).urlparse($href).query).get("q", [$href])[0]

        # Normalize: remove text fragments + trailing slash
        ${clean}=    Evaluate    $clean.split('#:~:text')[0].rstrip('/')

        # Skip duplicate URLs
        ${dup}=    Run Keyword And Return Status    List Should Contain Value    ${seen}    ${clean}
        IF    ${dup}
            CONTINUE
        END

        Append To List    ${seen}     ${clean}
        Append To List    ${final}    ${clean}

        ${picked}=    Evaluate    ${picked} + 1
        Exit For Loop If    ${picked} >= ${max}
    END

    RETURN    ${final}