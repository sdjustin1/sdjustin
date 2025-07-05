<!--- Log Lambda environment info for debugging --->
<cfset lambdaStartTime = getTickCount() />
<cfset requestId = createUUID() />
<cfoutput>Lambda Environment Debug Info:<br></cfoutput>
<cfoutput>Server: #cgi.server_name#<br></cfoutput>
<cfoutput>Request Time: #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>
<cfoutput>Lambda Start: #lambdaStartTime#ms<br></cfoutput>
<cfoutput>Request ID: #requestId#<br></cfoutput>
<cfoutput>---<br></cfoutput>

<!--- CloudWatch Metrics Helper Function --->
<cffunction name="sendCloudWatchMetric" access="public" returntype="void">
    <cfargument name="metricName" type="string" required="true">
    <cfargument name="value" type="numeric" required="true">
    <cfargument name="unit" type="string" default="Count">
    <cfargument name="namespace" type="string" default="Lambda/NetworkMonitoring">
    
    <cftry>
        <cfhttp url="http://169.254.169.254/latest/meta-data/instance-id" timeout="1" result="instanceCheck" />
        <cfif instanceCheck.status_code eq 200>
            <!--- Running on EC2, can use AWS CLI --->
            <cfexecute name="aws" arguments="cloudwatch put-metric-data --namespace '#arguments.namespace#' --metric-data MetricName='#arguments.metricName#',Value=#arguments.value#,Unit='#arguments.unit#' --region us-east-2" timeout="5" />
        <cfelse>
            <!--- Lambda environment - log structured data for CloudWatch Logs Insights --->
            <cflog file="cloudwatch_metrics" text="METRIC|#arguments.namespace#|#arguments.metricName#|#arguments.value#|#arguments.unit#|#requestId#" />
        </cfif>
        <cfcatch>
            <!--- Fallback to structured logging --->
            <cflog file="cloudwatch_metrics" text="METRIC|#arguments.namespace#|#arguments.metricName#|#arguments.value#|#arguments.unit#|#requestId#" />
        </cfcatch>
    </cftry>
</cffunction>

<!--- Try get the web data 5 times --->

    <cfset startTime = getTickCount() />
    <cfoutput>Request attempt at #dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss.l")#<br></cfoutput>
    
    <!--- Test 2: Use HTTP instead of HTTPS for direct IP --->
    <cfset ipStartTime = getTickCount() />
    <cfhttp url="http://3.167.152.101" result="ipResponse" timeout="10">
        <cfhttpparam type="header" name="Host" value="aws.amazon.com" />
    </cfhttp>
    <cfset ipEndTime = getTickCount() />
    <cfset ipDuration = ipEndTime - ipStartTime />
    <cfoutput>Direct IP (HTTP) request completed in #ipDuration#ms<br></cfoutput>
    
    <!--- Send CloudWatch metrics for Direct IP test --->
    <cfset sendCloudWatchMetric("DirectIPRequestDuration", ipDuration, "Milliseconds") />
    <cfif ipResponse.status_code eq 200>
        <cfset sendCloudWatchMetric("DirectIPSuccess", 1) />
    <cfelse>
        <cfset sendCloudWatchMetric("DirectIPFailure", 1) />
        <cfset sendCloudWatchMetric("DirectIPTimeout", 1) />
    </cfif>

    <!--- Test 1: DNS resolution timing --->
    <cfset dnsStartTime = getTickCount() />
    <cfhttp url="https://aws.amazon.com" result="response" timeout="10" />
    <cfset dnsEndTime = getTickCount() />
    <cfset totalDuration = dnsEndTime - startTime />
    <cfoutput>DNS + Network completed in #totalDuration#ms<br></cfoutput>
    
    <!--- Send CloudWatch metrics for main request --->
    <cfset sendCloudWatchMetric("MainRequestDuration", totalDuration, "Milliseconds") />
    <cfif response.status_code eq 200>
        <cfset sendCloudWatchMetric("MainRequestSuccess", 1) />
    <cfelse>
        <cfset sendCloudWatchMetric("MainRequestFailure", 1) />
        <cfif response.status_code eq 408>
            <cfset sendCloudWatchMetric("MainRequestTimeout", 1) />
        </cfif>
    </cfif>
        
    
    <!--- Test 3: DNS-only lookup attempt --->
    <cfset lookupStartTime = getTickCount() />
    <cfhttp url="https://aws.amazon.com" method="HEAD" result="headResponse" timeout="5" />
    <cfset lookupEndTime = getTickCount() />
    <cfset lookupDuration = lookupEndTime - lookupStartTime />
    <cfoutput>HEAD request (DNS + minimal data) completed in #lookupDuration#ms<br></cfoutput>
    
    <!--- Send CloudWatch metrics for HEAD request --->
    <cfset sendCloudWatchMetric("HeadRequestDuration", lookupDuration, "Milliseconds") />
    <cfif headResponse.status_code eq 200>
        <cfset sendCloudWatchMetric("HeadRequestSuccess", 1) />
    <cfelse>
        <cfset sendCloudWatchMetric("HeadRequestFailure", 1) />
        <cfif headResponse.status_code eq 408>
            <cfset sendCloudWatchMetric("HeadRequestTimeout", 1) />
        </cfif>
    </cfif>
    
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
    
    <cfif response.status_code neq "200">
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

<!--- Send final CloudWatch metrics --->
<cfset sendCloudWatchMetric("TotalLambdaExecutionTime", totalLambdaTime, "Milliseconds") />

<cfif totalLambdaTime GT 25000>
    <cfoutput><strong>WARNING: Approaching API Gateway 30s timeout! (#totalLambdaTime#ms)</strong><br></cfoutput>
    <cfset sendCloudWatchMetric("ApiGatewayTimeoutWarning", 1) />
</cfif>

<cfif totalLambdaTime GT 30000>
    <cfoutput><strong>CRITICAL: API Gateway timeout likely occurred! (#totalLambdaTime#ms)</strong><br></cfoutput>
    <cfset sendCloudWatchMetric("ApiGatewayTimeoutCritical", 1) />
</cfif>

<!--- Calculate and send network failure rate --->
<cfset networkFailures = 0 />
<cfset totalRequests = 3 />
<cfif ipResponse.status_code neq 200>
    <cfset networkFailures = networkFailures + 1 />
</cfif>
<cfif response.status_code neq 200>
    <cfset networkFailures = networkFailures + 1 />
</cfif>
<cfif headResponse.status_code neq 200>
    <cfset networkFailures = networkFailures + 1 />
</cfif>

<cfset failureRate = (networkFailures / totalRequests) * 100 />
<cfset sendCloudWatchMetric("NetworkFailureRate", failureRate, "Percent") />
<cfset sendCloudWatchMetric("NetworkFailureCount", networkFailures, "Count") />

<cfif networkFailures eq 3>
    <cfset sendCloudWatchMetric("CompleteNetworkFailure", 1) />
    <cfoutput>CRITICAL: Complete network failure detected!<br></cfoutput>
</cfif>

<cfoutput>===== END TIMING REPORT =====<br></cfoutput>