<cftry>
    <cfquery name="qTestQuery" datasource="pgjdbc">
        SELECT personname
        FROM person                         
    </cfquery>
    <cfcatch>
        <cflog text="Error in qTestQuery: #cfcatch.message#" type="error">
        <cfset qTestQuery = queryNew("personname")>
    </cfcatch>
</cftry> 

<cfdump var="#qTestQuery#">