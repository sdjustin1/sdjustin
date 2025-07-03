<cfoutput><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	    <title>sdjustin.com</title>
	</head>

	<body bgcolor="purple">
		<h2 align=center>Coming Soon!</h1>
		<div align=center>#now()#</div>

		<div style="text-align: center;">
			<img src="#application.imageprefix#6.jpg" alt="It is the size of the fight in the dog">
		</div>
		
		<div align="center" style="margin-top: 20px;">
			<hr>
			<cftry>
				<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/" timeout="5">
				<cfif cfhttp.statusCode eq "200 OK">
					<cfset macAddress = trim(cfhttp.fileContent)>
					<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/#macAddress#vpc-id" timeout="5">
					<cfif cfhttp.statusCode eq "200 OK">
						<p><strong>VPC ID:</strong> #cfhttp.fileContent#</p>
					</cfif>
					<cfhttp url="http://169.254.169.254/latest/meta-data/network/interfaces/macs/#macAddress#subnet-id" timeout="5">
					<cfif cfhttp.statusCode eq "200 OK">
						<p><strong>Subnet ID:</strong> #cfhttp.fileContent#</p>
					</cfif>
				</cfif>
				<cfcatch>
					<p><em>VPC info not available (not running in AWS)</em></p>
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