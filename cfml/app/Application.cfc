<cfcomponent>
	<cfset this.name="cfmlServerless">
    <cfset this.sessionmanagement="true">
    <cfset this.clientManagement="false">
    <cfset this.setClientCookies="true">
    <cfset this.applicationTimeout = CreateTimeSpan(10, 0, 0, 0)> <!--- 10 days --->
    <cfset application.cookieName = "__ga_tracking_beacon_">

    <cffunction name="onApplicationStart" returntype="boolean">
        <cfset application.counter = 0>
        <cfset application.resultsArray = arrayNew(1)>
        <cfreturn true>
    </cffunction>   

    <!--- the onRequest method is important to address as LL has to handle naked requests  --->
    <!--- that used to be handled by a web server: sdjustin.com/ --> sdjustin.com/index.cfm --->
    <!--- I need to test if this works form mnjustin/rets/-v.cfm --->
    <!--- the include at the bottom may need to move up into the IF block --->
    <cffunction name="onRequest" access="public" returntype="void" hint="I handle the request">
        <cfargument name="path" type="string" required="true" />
        <cfdump label="arguments.path" var="#arguments.path#">
        <cfsetting enablecfoutputonly="true" requesttimeout="180" showdebugoutput="true" />
        <cfset application.counter++ />
        <cfset variables.templateName = arguments.path />
        <cfif variables.templateName eq "/" or variables.templateName eq "">
            <cfset variables.templateName = "index.cfm" />
        <cfelseif left(variables.templateName,1) eq "/">
            <cfset variables.templateName = right(variables.templateName, len(variables.templateName)-1) />
        </cfif>
        <!--- Add .cfm extension if no extension present --->
        <cfif not find(".", listLast(variables.templateName,'/'))>
            <cfset variables.templateName = variables.templateName & ".cfm" />
        </cfif>
        <cfdump label="variables.templateName" var="#variables.templateName#">
        <cfinclude template="#variables.templateName#" />
<!--- 
        <cfargument name="path" type="string" required="true" />
        <cfsetting enablecfoutputonly="true" requesttimeout="180" showdebugoutput="true" />
        <cfset application.counter++ />
        <cfset variables.templateName = listLast(arguments.path,'/') />
        <cfif variables.templateName eq "" or variables.templateName eq "/">
            <cfset variables.templateName = "index.cfm" />
        <!--- the following two lines cause sdjustin.com/test to return results from sdjustin.com/test.cfm --->
        <cfelseif not listLast(variables.templateName,'.') eq 'cfm'>
            <cfset variables.templateName = variables.templateName & ".cfm" />
        </cfif>
        <cfinclude template="#variables.templateName#" />         --->
    </cffunction>
    
    <cffunction name="onRequestStart" access="public" returntype="void">
        <cfif cgi.SERVER_NAME neq 'localhost'>

            <cfset this.datasources["pgjdbc"] = {
                class = 'org.postgresql.Driver',
                connectionString = 'jdbc:postgresql://' 
                    & server.system.environment.DB_CONNECTION_STRING,

                username = server.system.environment.DB_USERNAME,
                password = server.system.environment.DB_PASSWORD
            }>

            <cfset this.defaultDatasource = "pgjdbc">

            <cfset application.imageprefix = "https://sdjustintestbucket.s3.us-east-2.amazonaws.com/cmedia/images/">
        <cfelse>
            <cfinclude template="includes/jlocalsecrets.cfm">
            <cfset application.imageprefix = "../../cmedia/images/">
        </cfif>
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
<!--- 
    <cffunction name="onError" returntype="void" access="public">
        <cfargument name="Exception" type="any" required="true" />
        <cfargument name="EventName" type="string" required="true" />
        <cfoutput>Some error has occured</cfoutput>
        <cfabort />
    </cffunction> --->
</cfcomponent>


