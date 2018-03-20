<cfsilent>
	<cfset local.crumbs = []>
	<cfloop array="#getBreadCrumbs()#" index="local.crumb">
		<cfset arrayAppend(local.crumbs, '<a href="#local.crumb.url#">#local.crumb.title#</a>')>
	</cfloop>
</cfsilent>
<div style="padding: 10px 0">
	<cfoutput>#arrayToList(local.crumbs, " &gt; ")#</cfoutput>
</div>