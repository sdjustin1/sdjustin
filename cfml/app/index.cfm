<cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	    <title>sdjustin.com</title>
	</head>

	<body bgcolor="brown">
		<h2 align=center>Coming Soon!</h1>
		<div align=center>#now()#</div>

		<div style="text-align: center;">
			<img src="#application.imageprefix#6.jpg" alt="It is the size of the fight in the dog">
		</div>
		
		<div align="center" style="margin-top: 20px;">
			<hr>
			<p><strong>Checking AWS Metadata...</strong></p>
			<cftry>
				<!--- Check if we're in AWS Lambda using system environment --->
				<cfset isLambda = false>
				<cftry>
					<cfset systemEnv = createObject("java", "java.lang.System").getenv()>
					<cfif structKeyExists(systemEnv, "AWS_LAMBDA_FUNCTION_NAME") or 
						  structKeyExists(systemEnv, "AWS_EXECUTION_ENV") or
						  structKeyExists(systemEnv, "LAMBDA_TASK_ROOT") or
						  structKeyExists(systemEnv, "_HANDLER") or
						  structKeyExists(systemEnv, "AWS_LAMBDA_RUNTIME_API")>
						<cfset isLambda = true>
					</cfif>
					<cfcatch>
						<cfset isLambda = false>
					</cfcatch>
				</cftry>
				
				<cfif isLambda>
					<p><strong>Environment:</strong> AWS Lambda</p>
				<cfelse>
					<p><strong>Environment:</strong> Local/Non-AWS</p>
				</cfif>
				
				<!--- Show Lambda function name if detected --->
				<cfif isLambda>
					<cftry>
						<cfset lambdaFunctionName = createObject("java", "java.lang.System").getenv("AWS_LAMBDA_FUNCTION_NAME")>
						<cfif isDefined("lambdaFunctionName") and lambdaFunctionName neq "">
							<p><strong>Function Name:</strong> #lambdaFunctionName#</p>
						</cfif>
						<cfcatch></cfcatch>
					</cftry>
				</cfif>
				
				<!--- Lambda functions don't have access to metadata service, show available AWS info instead --->
				<cfif isLambda>
					<p><strong>AWS Information (from environment variables):</strong></p>
					<cftry>
						<cfset sysEnv = createObject("java", "java.lang.System").getenv()>
						<cfif structKeyExists(sysEnv, "AWS_REGION")>
							<p><strong>Region:</strong> #sysEnv["AWS_REGION"]#</p>
						</cfif>
						<cfif structKeyExists(sysEnv, "AWS_LAMBDA_FUNCTION_MEMORY_SIZE")>
							<p><strong>Memory Size:</strong> #sysEnv["AWS_LAMBDA_FUNCTION_MEMORY_SIZE"]# MB</p>
						</cfif>
						<cfif structKeyExists(sysEnv, "AWS_LAMBDA_LOG_GROUP_NAME")>
							<p><strong>Log Group:</strong> #sysEnv["AWS_LAMBDA_LOG_GROUP_NAME"]#</p>
						</cfif>
						<cfcatch>
							<p>Error reading environment variables</p>
						</cfcatch>
					</cftry>
					
					<!--- Try to get VPC info using AWS SDK --->
					<p><strong>VPC Information:</strong></p>
					<cftry>
						<cfset region = sysEnv["AWS_REGION"]>
						<cfset functionName = sysEnv["AWS_LAMBDA_FUNCTION_NAME"]>
						
						<!--- Use AWS SDK to get Lambda function configuration --->
						<cfset lambdaClient = createObject("java", "com.amazonaws.services.lambda.AWSLambdaClientBuilder").standard().withRegion(region).build()>
						<cfset getFunctionRequest = createObject("java", "com.amazonaws.services.lambda.model.GetFunctionRequest").withFunctionName(functionName)>
						<cfset functionResult = lambdaClient.getFunction(getFunctionRequest)>
						<cfset vpcConfig = functionResult.getConfiguration().getVpcConfig()>
						
						<cfif vpcConfig.getVpcId() neq "">
							<p><strong>VPC ID:</strong> #vpcConfig.getVpcId()#</p>
							<cfset subnetIds = vpcConfig.getSubnetIds()>
							<cfif arrayLen(subnetIds) gt 0>
								<p><strong>Subnet IDs:</strong> #arrayToList(subnetIds)#</p>
							</cfif>
							<cfset securityGroupIds = vpcConfig.getSecurityGroupIds()>
							<cfif arrayLen(securityGroupIds) gt 0>
								<p><strong>Security Groups:</strong> #arrayToList(securityGroupIds)#</p>
							</cfif>
						<cfelse>
							<p><strong>VPC:</strong> Not configured (using default VPC)</p>
						</cfif>
						
						<cfcatch>
							<p><strong>VPC Info:</strong> Unable to retrieve (#cfcatch.message#)</p>
						</cfcatch>
					</cftry>
					
					<p><strong>Note:</strong> Metadata service is not available in Lambda functions (only in EC2 instances)</p>
				<cfelse>
					<!--- Try metadata service for EC2 instances --->
					<cfhttp url="http://169.254.169.254/latest/api/token" method="PUT" timeout="1" result="tokenResult">
						<cfhttpparam type="header" name="X-aws-ec2-metadata-token-ttl-seconds" value="21600">
					</cfhttp>
					
					<cfif structKeyExists(tokenResult, "statusCode") and tokenResult.statusCode eq "200 OK">
						<cfset token = tokenResult.fileContent>
						<p><strong>IMDSv2 Token:</strong> Retrieved</p>
						
						<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/" timeout="2" result="httpResult">
							<cfhttpparam type="header" name="X-aws-ec2-metadata-token" value="#token#">
						</cfhttp>
					<cfelse>
						<!--- Fallback to IMDSv1 --->
						<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/" timeout="2" result="httpResult">
					</cfif>
					
					<p>HTTP Status: #httpResult.statusCode#</p>
					<cfif httpResult.statusCode eq "200 OK">
						<cfset macAddress = trim(httpResult.fileContent)>
						<p><strong>MAC:</strong> #macAddress#</p>
						
						<cfif isDefined("token")>
							<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/#macAddress#/vpc-id" timeout="2" result="vpcResult">
								<cfhttpparam type="header" name="X-aws-ec2-metadata-token" value="#token#">
							</cfhttp>
							<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/#macAddress#/subnet-id" timeout="2" result="subnetResult">
								<cfhttpparam type="header" name="X-aws-ec2-metadata-token" value="#token#">
							</cfhttp>
						<cfelse>
							<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/#macAddress#/vpc-id" timeout="2" result="vpcResult">
							<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/#macAddress#/subnet-id" timeout="2" result="subnetResult">
						</cfif>
						
						<cfif vpcResult.statusCode eq "200 OK">
							<p><strong>VPC ID:</strong> #vpcResult.fileContent#</p>
						</cfif>
						<cfif subnetResult.statusCode eq "200 OK">
							<p><strong>Subnet ID:</strong> #subnetResult.fileContent#</p>
						</cfif>
					<cfelse>
						<p><strong>Status:</strong> #httpResult.statusCode#</p>
						<p><strong>Reason:</strong> Metadata service unavailable (not running in AWS EC2)</p>
					</cfif>
				</cfif>
				<cfcatch type="any">
					<p><strong>Error:</strong> #cfcatch.message#</p>
					<p><strong>Detail:</strong> #cfcatch.detail#</p>
					<p><strong>Environment:</strong> Local/Non-AWS (metadata service not accessible)</p>
				</cfcatch>
			</cftry>
		</div>
	</body>
</html>
<p align=center>lucee #server.lucee.version#</p>
</cfoutput>

<!--- <cfdump var="#application#">
<cfdump var="#session#">
<cfdump var="#cookie#"> --->