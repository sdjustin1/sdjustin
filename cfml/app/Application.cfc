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

    <cffunction name="onRequestStart" access="public" returntype="void">
        <cfif cgi.http_host eq "sdjustin.com" or cgi.remote_host eq "sdjustin.com">
            <cfheader statuscode="301" statustext="Moved Permanently">
            <cfheader name="Location" value="https://www.sdjustin.com#cgi.path_info##cgi.query_string eq '' ? '' : '?' & cgi.query_string#">
            <cfdump label="dump" var="dump">
            <cfabort>
        </cfif>
                
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

    <!--- the onRequest method addresses routing edge cases --->
    <cffunction name="onRequest" access="public" returntype="void" hint="I handle the request">
        <!--- this works in combination with this from template.yml: --->
        <!--- GetRoot:
                Type: Api
                Properties:
                    Path: /
                    Method: any --->
        <cfif cgi.path_info eq "" or cgi.path_info eq "/">
            <cfset variables.templateName = "index.cfm">
        <!--- this handles SEO friendly URL's: /aboutus routes to /aboutus.cfm --->
        <cfelseif not find(".", cgi.path_info)>
            <cfset variables.templateName = cgi.path_info & ".cfm">
        <!--- this is the majority of cases, just serve what was requested --->
        <cfelse>
            <cfset variables.templateName = cgi.path_info>
        </cfif>        
        <cfinclude template="#variables.templateName#" />
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


