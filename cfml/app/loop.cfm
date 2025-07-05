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
    <cfhttp url="https://aws.amazon.com" result="response" timeout="10" />
    <cfset endTime = getTickCount() />
    <cfset requestDuration = endTime - startTime />
    <cfoutput>Request completed in #requestDuration#ms<br></cfoutput>
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