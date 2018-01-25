<!DOCTYPE html>
<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8" />
	<title><cfoutput>#getTitle()#</cfoutput></title>
	<meta name="viewport" content="width=device-width, initial-scale=1" /> <!-- , minimal-ui -->
	<meta name="apple-mobile-web-app-capable" content="yes" />
	<meta name="format-detection" content="telephone=no" />
<cfoutput>#templateInclude("metaTags")#</cfoutput>
</head>
<body>

<h1>Default Template</h1>
<cfoutput>#templateInclude("breadcrumbs")#</cfoutput>
<cfoutput>#getContent("default")#</cfoutput>

<cfoutput><br />#getTickCount() - request.startTime#ms</cfoutput>
</body>
</html>