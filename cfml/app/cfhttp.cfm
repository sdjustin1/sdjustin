<cfhttp url="https://aws.amazon.com" method="get" result="variables.qRetsData"></cfhttp>
<cfdump label="jcfhttpdump" var="#variables.qRetsData#">