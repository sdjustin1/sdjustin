<cfcomponent>
	<cfset this.name="cfmlServerless">
    <cfset this.sessionmanagement="false">
    <cfset this.clientManagement="false">
    <cfset this.setClientCookies="false">
    <cfset this.applicationTimeout = CreateTimeSpan(10, 0, 0, 0)> <!--- 10 days --->

    <cffunction name="onRequest" access="public" returntype="void" hint="I handle the request">
        <cfargument name="path" type="string" required="true" />
        <cfsetting enablecfoutputonly="true" requesttimeout="180" showdebugoutput="true" />
        <cfset application.counter++ />
        <cfinclude template="#listLast(arguments.path,'/')#" />
    </cffunction>
    
    <cffunction name="onRequestStart" access="public" returntype="void">
        <cfif cgi.SERVER_NAME neq 'localhost'>
<!--- 
            <cfset this.datasources["pgjdbc"] = {
                class = 'org.postgresql.Driver',
                connectionString = 'jdbc:postgresql://' & server.system.environment.DB_CONNECTION_STRING,
                username = server.system.environment.DB_USERNAME,
                password = server.system.environment.DB_PASSWORD
            }> --->

            <cfset this.datasources["pgjdbc"] = {
                database = "jdb5", 
                host = "db5-instance-1.cnuyg6kg8zqc.us-east-2.rds.amazonaws.com", 
                port = "5432", 
                type = "postgresql", 
                username = server.system.environment.DB_USERNAME, 
                password = server.system.environment.DB_PASSWORD
            }> 

            <cfset this.defaultDatasource = "pgjdbc">

            <cfset application.imageprefix = "https://sdjustintestbucket.s3.us-east-2.amazonaws.com/">
        <cfelse>
            <cfset application.imageprefix = "/sdjustin2/images/">
        </cfif>
    </cffunction>       

    <cffunction name="onApplicationStart" returntype="boolean">
        <cfset application.counter = 0>
        <cfset application.resultsArray = arrayNew(1)>
        <cfreturn true>
    </cffunction>       

    <cffunction name="getCounter" returntype="any">
        <cfreturn application.counter>
    </cffunction>

    <cffunction name="getLambdaContext" returntype="any" access="public">
        <!--- see https://docs.aws.amazon.com/lambda/latest/dg/java-context-object.html --->
        <cfreturn getPageContext().getRequest().getAttribute("lambdaContext") />
    </cffunction>

    <cffunction name="logger" returntype="void" access="public">
        <cfargument name="msg" type="string" required="true" />
        <cfset getLambdaContext().getLogger().log(arguments.msg) />
    </cffunction>    

    <cffunction name="getRequestID" returntype="string" access="public">
        <cfif isNull(getLambdaContext())>
            <!--- Not running in Lambda --->
            <cfif not request.keyExists("_request_id")>
                <cfset request._request_id = createUUID()>
            </cfif>
            <cfreturn request._request_id>
        <cfelse>
            <cfreturn getLambdaContext().getAwsRequestId()>
        </cfif>
    </cffunction>

    <cffunction name="OnMissingTemplate" output="true">
        <cfargument name="targetPage" type="string">
        <cfinclude template="404.cfm">
        <cfreturn true>
    </cffunction>

    <cffunction name="onError" returntype="void" access="public">
        <cfargument name="Exception" type="any" required="true" />
        <cfargument name="EventName" type="string" required="true" />
        <cfoutput>Some error has occured</cfoutput>
        <cfabort />
    </cffunction>
</cfcomponent>


