<!--- Log Lambda environment info for debugging --->
<cfset lambdaStartTime = getTickCount() />
<cfoutput>Lambda Environment Debug Info:<br></cfoutput>
<cfoutput>Server: #cgi.server_name#<br></cfoutput>
<cfoutput>Request Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>
<cfoutput>Lambda Start: #lambdaStartTime#ms<br></cfoutput>
<cfoutput>Request ID: #createUUID()#<br></cfoutput>
<cfoutput>---<br></cfoutput>

<!--- Try get the web data 5 times --->

    <cfset startTime = getTickCount() />
    <cfoutput>Request attempt #count# at #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>
    
    <!--- Test 2: Use HTTP instead of HTTPS for direct IP --->
    <cfset ipStartTime = getTickCount() />
    <cfhttp url="http://3.167.152.101" result="ipResponse" timeout="10">
        <cfhttpparam type="header" name="Host" value="aws.amazon.com" />
    </cfhttp>
    <cfset ipEndTime = getTickCount() />
    <cfset ipDuration = ipEndTime - ipStartTime />
    <cfoutput>Direct IP (HTTP) request completed in #ipDuration#ms<br></cfoutput>

    <!--- Test 1: DNS resolution timing --->
    <cfset dnsStartTime = getTickCount() />
    <cfhttp url="https://aws.amazon.com" result="response" timeout="10" />
    <cfset dnsEndTime = getTickCount() />
    <cfset totalDuration = dnsEndTime - startTime />
    <cfoutput>DNS + Network completed in #totalDuration#ms<br></cfoutput>
        
    
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
    <cfoutput>- HEAD request result: #headResponse.status_code# (#headResponse.status_text#)<br></cfoutput>
    <cfoutput>Performance comparison:<br></cfoutput>
    <cfoutput>- Full request (aws.amazon.com): #totalDuration#ms<br></cfoutput>
    <cfoutput>- Direct IP (HTTP): #ipDuration#ms<br></cfoutput>
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
        <cfset loopIterationTime = getTickCount() - startTime />
        <cfset cumulativeTime = getTickCount() - lambdaStartTime />
        <cfoutput>ERROR at #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")# - Status: #response.status_code# (#response.status_text#)<br></cfoutput>
        <cfoutput>Error Detail: #response.errordetail#<br></cfoutput>
        <cfoutput>File Content: #response.filecontent#<br></cfoutput>
        <cfoutput>This iteration took: #loopIterationTime#ms<br></cfoutput>
        <cfoutput>Cumulative time: #cumulativeTime#ms<br></cfoutput>
        <cfif cumulativeTime GT 25000>
            <cfoutput><strong>WARNING: Approaching API Gateway timeout! (#cumulativeTime#ms)</strong><br></cfoutput>
        </cfif>
        <cfif structKeyExists(response, "responseheader")>
            <cfoutput>Response Headers: <cfdump var="#response.responseheader#" format="text"><br></cfoutput>
        </cfif>
        <cfdump var="#response#" />
        
        <!--- Reduce sleep time if approaching timeout --->
        <cfif cumulativeTime GT 25000>
            <cfoutput>Skipping sleep due to timeout risk<br></cfoutput>
        <cfelse>
            <cfsleep time="1000" />
        </cfif>
    </cfif>


<!--- Final timing and API Gateway timeout detection --->
<cfset lambdaEndTime = getTickCount() />
<cfset totalLambdaTime = lambdaEndTime - lambdaStartTime />
<cfoutput>===== FINAL TIMING REPORT =====<br></cfoutput>
<cfoutput>Total Lambda Execution Time: #totalLambdaTime#ms<br></cfoutput>
<cfoutput>Request End Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>

<cfif totalLambdaTime GT 25000>
    <cfoutput><strong>WARNING: Approaching API Gateway 30s timeout! (#totalLambdaTime#ms)</strong><br></cfoutput>
</cfif>

<cfif totalLambdaTime GT 30000>
    <cfoutput><strong>CRITICAL: API Gateway timeout likely occurred! (#totalLambdaTime#ms)</strong><br></cfoutput>
</cfif>

<cfoutput>===== END TIMING REPORT =====<br></cfoutput>