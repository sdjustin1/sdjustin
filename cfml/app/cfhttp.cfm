<cfhttp url="https://www.deere.com/en/" method="get" result="variables.qRetsData"></cfhttp>
<cfdump label="jcfhttpdump" var="#variables.qRetsData#">