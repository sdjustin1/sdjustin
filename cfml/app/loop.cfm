<cfsleep time="5000" />
<cfset getWebScrape = false />

<!--- Try get the web data 5 times --->
<cfloop from="1" to="5" index="count">
    <cfoutput>Request attempt #count#<br></cfoutput>
    <cfhttp url="https://aws.amazon.com" result="r" timeout="3" />
    <cfif r.status_code eq "200">
        <!--- If we get the web data break the loop --->
        <cfset getWebScrape = true />
        <cfbreak />      
    <cfelse>
        <!--- Some reason it failed, sleep for a second.... --->
        <cfdump var="#r#" />
        <cfoutput>#r.status_code#</cfoutput><br />
        <cfsleep time="1000" />
    </cfif>
</cfloop>

<cfif getWebScrape>
    <cfdump label="loop counter" var="#count#">
    <cfdump var="#r#" />
<cfelse>
    <cfdump label="loop counter" var="#count#">
    Abort with error!
</cfif>