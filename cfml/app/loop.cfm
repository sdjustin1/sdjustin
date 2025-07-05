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
    
    <!--- Test 2: Use HTTP instead of HTTPS for direct IP --->
    <cfset ipStartTime = getTickCount() />
    <cfhttp url="http://3.167.152.101" result="ipResponse" timeout="10">
        <cfhttpparam type="header" name="Host" value="aws.amazon.com" />
    </cfhttp>
    <cfset ipEndTime = getTickCount() />
    <cfset ipDuration = ipEndTime - ipStartTime />
    <cfoutput>Direct IP (HTTP) request completed in #ipDuration#ms<br></cfoutput>
    
    <!--- Test 2b: Alternative approach - different domain with simpler SSL --->
    <cfset altStartTime = getTickCount() />
    <cfhttp url="https://httpbin.org/get" result="altResponse" timeout="10" />
    <cfset altEndTime = getTickCount() />
    <cfset altDuration = altEndTime - altStartTime />
    <cfoutput>Alternative domain request completed in #altDuration#ms<br></cfoutput>
    
    <!--- Test 3: DNS-only lookup attempt --->
    <cfset lookupStartTime = getTickCount() />
    <cfhttp url="https://aws.amazon.com" method="HEAD" result="headResponse" timeout="5" />
    <cfset lookupEndTime = getTickCount() />
    <cfset lookupDuration = lookupEndTime - lookupStartTime />
    <cfoutput>HEAD request (DNS + minimal data) completed in #lookupDuration#ms<br></cfoutput>
    
    <!--- Test 4: Add connection details --->
    <cfoutput>Response analysis:<br></cfoutput>
    <cfoutput>- aws.amazon.com result: #response.status_code# (#response.status_text#)<br></cfoutput>
    <cfoutput>- Direct IP (HTTP) result: #ipResponse.status_code# (#ipResponse.status_text#)<br></cfoutput>
    <cfoutput>- Alternative domain result: #altResponse.status_code# (#altResponse.status_text#)<br></cfoutput>
    <cfoutput>- HEAD request result: #headResponse.status_code# (#headResponse.status_text#)<br></cfoutput>
    <cfoutput>Performance comparison:<br></cfoutput>
    <cfoutput>- Full request (aws.amazon.com): #totalDuration#ms<br></cfoutput>
    <cfoutput>- Direct IP (HTTP): #ipDuration#ms<br></cfoutput>
    <cfoutput>- Alternative domain: #altDuration#ms<br></cfoutput>
    <cfoutput>- HEAD only: #lookupDuration#ms<br></cfoutput>
    <cfif ipResponse.status_code GT 0>
        <cfoutput>- DNS penalty estimate: #totalDuration - ipDuration#ms<br></cfoutput>
    <cfelse>
        <cfoutput>- DNS penalty: Cannot calculate (IP test failed)<br></cfoutput>
        <cfoutput>- Data transfer penalty: #totalDuration - lookupDuration#ms<br></cfoutput>
    </cfif>
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