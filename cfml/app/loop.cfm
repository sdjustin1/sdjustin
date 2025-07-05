<!--- <cfsleep time="5000" /> --->
<cfset getWebScrape = false />

<!--- Log Lambda environment info for debugging --->
<cfoutput>Lambda Environment Debug Info:<br></cfoutput>
<cfoutput>Server: #cgi.server_name#<br></cfoutput>
<cfoutput>Request Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>
<cfoutput>---<br></cfoutput>

<!--- Try get the web data 5 times --->
<cfloop from="1" to="5" index="count">
    <cfset startTime = getTickCount() />
    <cfoutput>Request attempt #count# at #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>
    
    <!--- Test 1: DNS resolution timing --->
    <cfset dnsStartTime = getTickCount() />
    <cfhttp url="https://aws.amazon.com" result="response" timeout="10" />
    <cfset dnsEndTime = getTickCount() />
    <cfset totalDuration = dnsEndTime - startTime />
    <cfoutput>DNS + Network completed in #totalDuration#ms<br></cfoutput>
    
    <!--- Test 2: Direct IP to isolate DNS --->
    <cfset ipStartTime = getTickCount() />
    <cfhttp url="https://52.94.236.248" result="ipResponse" timeout="10" />
    <cfset ipEndTime = getTickCount() />
    <cfset ipDuration = ipEndTime - ipStartTime />
    <cfoutput>Direct IP request completed in #ipDuration#ms<br></cfoutput>
    
    <!--- Test 3: DNS-only lookup attempt --->
    <cfset lookupStartTime = getTickCount() />
    <cfhttp url="https://aws.amazon.com" method="HEAD" result="headResponse" timeout="5" />
    <cfset lookupEndTime = getTickCount() />
    <cfset lookupDuration = lookupEndTime - lookupStartTime />
    <cfoutput>HEAD request (DNS + minimal data) completed in #lookupDuration#ms<br></cfoutput>
    
    <!--- Test 4: Add connection details --->
    <cfoutput>Response analysis:<br></cfoutput>
    <cfoutput>- aws.amazon.com result: #response.status_code# (#response.status_text#)<br></cfoutput>
    <cfoutput>- Direct IP result: #ipResponse.status_code# (#ipResponse.status_text#)<br></cfoutput>
    <cfoutput>- HEAD request result: #headResponse.status_code# (#headResponse.status_text#)<br></cfoutput>
    <cfoutput>Performance comparison:<br></cfoutput>
    <cfoutput>- Full request: #totalDuration#ms<br></cfoutput>
    <cfoutput>- Direct IP: #ipDuration#ms<br></cfoutput>
    <cfoutput>- HEAD only: #lookupDuration#ms<br></cfoutput>
    <cfoutput>- DNS penalty: #totalDuration - ipDuration#ms<br></cfoutput>
    <cfoutput>---<br></cfoutput>
    
    <cfif response.status_code eq "200">
        <!--- If we get the web data break the loop --->
        <cfset getWebScrape = true />
        <cfbreak />      
    <cfelse>
        <!--- Some reason it failed, sleep for a second.... --->
        <cfoutput>ERROR at #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")# - Status: #response.status_code# (#response.status_text#)<br></cfoutput>
        <cfoutput>Error Detail: #response.errordetail#<br></cfoutput>
        <cfoutput>File Content: #response.filecontent#<br></cfoutput>
        <cfif structKeyExists(response, "responseheader")>
            <cfoutput>Response Headers: <cfdump var="#response.responseheader#" format="text"><br></cfoutput>
        </cfif>
        <cfdump var="#response#" />
        <cfsleep time="1000" />
    </cfif>
</cfloop>

<cfif getWebScrape>
    <cfdump label="loop counter" var="#count#">
    <cfdump var="#response#" />
<cfelse>
    <cfdump label="loop counter" var="#count#">
    Abort with error!
</cfif>