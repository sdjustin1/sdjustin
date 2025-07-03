<cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	    <title>sdjustin.com</title>
	</head>

	<body bgcolor="pink">
		<h2 align=center>Coming Soon!</h1>
		<div align=center>#now()#</div>

		<div style="text-align: center;">
			<img src="#application.imageprefix#6.jpg" alt="It is the size of the fight in the dog">
		</div>
		
		<div align="center" style="margin-top: 20px;">
			<hr>
			<p><strong>Checking AWS Metadata...</strong></p>
			<cftry>
				<!--- Check if we're in AWS Lambda first --->
				<cfif structKeyExists(server, "AWS_LAMBDA_FUNCTION_NAME") or structKeyExists(cgi, "AWS_LAMBDA_FUNCTION_NAME")>
					<p><strong>Environment:</strong> AWS Lambda</p>
				<cfelse>
					<p><strong>Environment:</strong> Local/Non-AWS (metadata service not available)</p>
				</cfif>
				
				<!--- Try metadata service with IMDSv2 token first --->
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
					<p><strong>Reason:</strong> Metadata service unavailable (not running in AWS EC2/Lambda)</p>
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