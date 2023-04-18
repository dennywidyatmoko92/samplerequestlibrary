*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    XML
Library    OperatingSystem
Library    JSONLibrary
#Library    JSON
*** Variables ***
${base_url}    http://simple-books-api.glitch.me  
${reqres}    https://reqres.in      
##https://github.com/vdespa/introduction-to-postman-course/blob/main/simple-books-api.md
##http://marketsquare.github.io/robotframework-requests/doc/RequestsLibrary.html
##https://github.com/dennywidyatmoko92/robottutorialdenny/tree/master/apicoba2/SUITE

##https://transform.tools/json-to-json-schema

*** Variables ***
${error}    
*** Test Cases ***
TC_Get_sample_header

    Create Session    get_status    ${Base_URL}    
      
    ${response}=    Get On Session    get_status    /status
    Log To Console    ${response.status_code}
    Log To Console    ${response.content}    
    Log To Console    ${response.headers}
    Should Be Equal As Strings    ${response.status_code}    200
    ${content_length}    Set Variable    ${response.headers['Content-Length']}
    ${content_type}    Set Variable    ${response.headers['Content-Type']}
    Should Be Equal As Strings    ${content_length}    15
    Should Be Equal As Strings    ${content_type}    application/json; charset=utf-8
    Log To Console    respons time ${response.elapsed.total_seconds()}
    Should Be True  ${response.elapsed.total_seconds()} < 1
    Log To Console    ${response.reason}
    Should Be Equal    ${response.reason}    OK


TC_Register_simple book Invalid
    Create Session    register    ${Base_URL}
    ${data}=    Create dictionary    clientName=    clientEmail=
    #${expected_json}=    Create dictionary    ${error}   
    ${resp}=    POST On Session    register  /api-clients/    json=${data}    expected_status=400 
   
    ${response_content}=    Convert To String    ${resp.content}
    Should Be Equal As Strings    {"error":"Invalid or missing client name."}    ${response_content}    msg=Response body does not match expected JSON
TC_Register_simple book
    Create Session    register    ${Base_URL}   
    ${username} =    Generate Random String    10    [LETTERS]    
    ${email} =    Generate Random String    10    [LETTERS]                                                                    
    &{data}=    Create dictionary  clientName=${username}  clientEmail=${email}@mailinator.com    UMUR=asasas
    ${resp}=    POST On Session    register  /api-clients/    json=${data} 
    Log To Console    ${resp.content}      
    ${resp_body}=    Convert To String    ${resp.content}
    Should Contain    ${resp_body}    accessToken  
    ${token}=    Convert To String    ${resp.json()}[accessToken]
    Log To Console    ${token}
    Set Global Variable    ${token}                                                                                 
    Status Should Be    201    ${resp}
    log   ${resp.json()}    

TC_Submit Order_book 
                                                               
    Create Session    submit order    ${base_url}  
    ${headers}=    Create Dictionary    Authorization=Bearer ee69eca4d86fcb8b094bcd685e6cfc2099cb206d2aed1bc5aa2a335ae66e45f2   
    ${email} =    Generate Random String    5    [LETTERS]                                                                    
    &{data}=    Create dictionary  bookId=1  customerName=${email}    
    ${resp}=    POST On Session    submit order  /orders    json=${data}    headers=${headers}    
    Log To Console    ${resp.content}   
    Should Contain    ${resp.json()}    orderId    created
    ${created}=    Set Variable    ${resp.json()['created']}   
    ${get_order_id}=    Set Variable    ${resp.json()['orderId']}  
    Should Be Equal As Strings    ${created}    True   
    Should Not Be Empty    ${get_order_id} 
    ${resp_body}=    Convert To String    ${resp.content}
    ${status_code} =    Convert To String    ${resp.status_code}
    Should Be Equal    ${status_code}    201  
    #Log To Console    ${token}  
    Log To Console    ${email} 
    ${orderId}=    Convert To String    ${resp.json()}[orderId]      
    Log To Console    ${orderId}    
    Set Global Variable    ${orderId}     
    log   ${resp.json()}

reqres int
    Create Session    get_status    ${reqres}    
    ${response}=    Get On Session    get_status    /api/users    params=page
    Log To Console    ${response.json()}
    JSONLibrary.Validate Json By Schema File    ${response.json()}    ${CURDIR}//submit.json
    JSONLibrary.Dump Json To File    ${CURDIR}//output.txt    ${response.json()}

reqres in single user
    Create Session    get_status    ${reqres}    
    ${response}=    Get On Session    get_status    /api/users/2
    Log    ${response.json()}
    JSONLibrary.Validate Json By Schema File    ${response.json()}    ${CURDIR}//singleuser.json

reqres in create user
    Create Session    create_single_user    ${reqres}
     &{data}=    Create dictionary  name=denny  job=quantity
     ${resp}=    POST On Session    create_single_user    /api/users    json=${data}
    # JSONLibrary.Validate Json By Schema File    ${resp.json()}    ${CURDIR}//createuser.json
    Log    ${resp.json()}
reqres in register sukses
    Create Session    register_sukses    ${reqres}
    ${random_string}=    Generate Random String    10    [LETTERS]
     &{data}=    Create dictionary  email=${random_string}@gmail.com  password=password${random_string}
    
     ${resp}=    POST On Session    register_sukses    /api/users    json=${data}
    JSONLibrary.Validate Json By Schema File    ${resp.json()}    ${CURDIR}//registerreq.json

    Log    ${resp.json()}
    Log To Console    ${resp.status_code}
    Log To Console    ${resp.content}
    ${email}=    Set Variable    ${resp.json()['email']} 
    ${password}=    Set Variable    ${resp.json()['password']} 
    Should Be Equal As Strings    ${resp.status_code}    201
    Should Be Equal    ${email}   ${random_string}@gmail.com
    Should Be Equal    ${password}   password${random_string}
    Log To Console    ${email}
    Log To Console    ${resp.elapsed.total_seconds()}
    Should Be True    ${resp.elapsed.total_seconds()} < 1.417066
    Log To Console    ${resp.reason}
    Should Be Equal    ${resp.reason}    Created
    Log    ${resp.headers}

    JSONLibrary.Dump Json To File    ${CURDIR}//output.txt    ${resp.json()}

menggunakan params
    Create Session    params    ${reqres}
    &{parameter}=    Create Dictionary    delay=1    page=5
    ${resp}=    GET On Session    params    /api/users/    params=&{parameter}
    Log To Console    ${resp.content}
    Log To Console    ${resp.json()}
    JSONLibrary.Validate Json By Schema File    ${resp.json()}    ${CURDIR}//delay.json
    JSONLibrary.Dump Json To File    ${CURDIR}//output.txt    ${resp.json()}

reqres in register tidak sukses
    Create Session    create_single_user    ${reqres}
     &{data}=    Create dictionary  email=den1212121212ny@gmail.com    password=
     ${resp}=    POST On Session    create_single_user    /api/login    json=${data}    expected_status=400 
    JSONLibrary.Validate Json By Schema File    ${resp.json()}    ${CURDIR}//errorlogin.json
    Log    ${resp.json()}
    Log To Console    ${resp.status_code}
    Log To Console    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    400

TC Get an order by book id
    ${expected_json}=    Set Variable    {"id":"", "bookId":"", "customerName":"", "createdBy":"", "quantity":"", "timestamp":""}
    Create Session    get_an_order    ${Base_URL}    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}         
    ${resp}=    Get On Session    get_an_order    /orders/${orderId}    headers=${headers}    
    Log    ${resp.status_code}
    Log    ${resp.content}    
    Log    ${resp.headers}

     ${json_data}=   Evaluate    json.loads('''${resp.content}''')
     
    ${id_type}=    Set Variable    ${json_data['id'].__class__}
    ${id_type2}=    Set Variable    ${json_data.__class__}
    ${id_type}=    Convert To String     ${id_type}
    ${id_type}=    Split String    ${id_type}    
    ${id_type}=    Set Variable    ${id_type}[1]
    ${id_type}=    Remove String    ${id_type}    >    '
    Should Be Equal    ${id_type}    str
    ${book_id_type}=    Set Variable    Output: {0}    ${json_data['bookId'].__class__}
    ${customer_name_type}=    Set Variable    Output: {0}    ${json_data['customerName'].__class__}
    ${created_by_type}=    Set Variable    Output: {0}    ${json_data['createdBy'].__class__}
    ${quantity_type}=    Set Variable    Output: {0}    ${json_data['quantity'].__class__}
    ${timestamp_type}=    Set Variable    Output: {0}    ${json_data['timestamp'].__class__}
    Log    ${json_data['id'].__class__}    # Output: <class 'str'>
    Log    ${json_data['bookId'].__class__}    # Output: <class 'int'>
    Log    ${json_data['customerName'].__class__}    # Output: <class 'str'>
    Log    ${json_data['createdBy'].__class__}    # Output: <class 'str'>
    Log    ${json_data['quantity'].__class__}    # Output: <class 'int'>
    Log    ${json_data['timestamp'].__class__}    # Output: <class 'int'>
      
    ${response_dict}=    Evaluate    ${resp.content.decode('utf-8')}
    ${id}=    Set Variable    ${response_dict['id']}
    ${book_id}=    Set Variable    ${response_dict['bookId']}
    ${customer_name}=    Set Variable    ${response_dict['customerName']}
    ${created_by}=    Set Variable    ${response_dict['createdBy']}
    ${quantity}=    Set Variable    ${response_dict['quantity']}
    ${timestamp}=    Set Variable    ${response_dict['timestamp']}
    ${response_content}=    Decode Bytes To String     ${resp.content}    UTF-8
    Should Be Equal    ${response_content}    {"id":"${id}","bookId":${book_id},"customerName":"${customer_name}","createdBy":"${created_by}","quantity":${quantity},"timestamp":${timestamp}}
    Should Be Equal As Strings    ${resp.status_code}    200

TC Get all order by book id
    Create Session    get_all_order    ${Base_URL}    
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}         
    ${res}=    Get On Session    get_all_order    /orders    headers=${headers}    
    Log    ${res.status_code}
    Log Many    ${res.content}    
    Log    ${res.headers}
    Log    ${res.text}
    Log    ${res.encoding}
    Log    ${res.cookies}
    Log    ${res.history}
    Log    ${res.elapsed}
    Log    ${res.url}
    Should Be True  ${res.elapsed.total_seconds()} < 1
    Should Be Equal As Strings    ${res.status_code}    200



