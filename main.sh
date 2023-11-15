#!/bin/bash
set -x
curl https://toolshed.g2.bx.psu.edu/api/repositories > repos.json
cat repos.json| jq '[.[] | {"key": (.owner +"/" + .name), "value": (.times_downloaded) }] | from_entries' -S > downloads.json
cat repos.json| jq '.[] | [.owner +"/" + .name, .times_downloaded] | @tsv' -r > downloads.tsv

cat repos.json | jq '[.[] | {"owner": .owner, "dls": .times_downloaded}] | group_by(.owner) | map({"key": first.owner, "value": (map(.dls) | add)}) | from_entries' > downloads-by-user.json
cat repos.json | jq '[.[] | {"owner": .owner, "dls": .times_downloaded}] | group_by(.owner) | map([first.owner, (map(.dls) | add)]) | .[] | @tsv' -r > downloads-by-user.tsv

cat head.html > downloads-by-user.html
cat >> downloads-by-user.html <<-EOF
	<header class="container">
		<h1>Downloads by User</h1>
		<nav aria-label="breadcrumb">
			<ul>
				<li><a href="index.html">Home</a></li>
				<li>Downloads by User (HTML)</li>
			</ul>
		</nav>
	</header>
	<main class="container">
	<p>Collected from the Toolshed API, updated weekly.</p>
	<table>
		<thead>
			<tr><th scope='col'>Owner</th><th scope='col'>Downloads</th></tr>
		</thead>
		<tbody>
EOF

cat downloads-by-user.json | jq '. | to_entries[] | "<tr><td>" + .key + "</td><td>" + (.value | tostring) + "</td></tr>"' -r  >> downloads-by-user.html
echo "</tbody></table>" >> downloads-by-user.html
cat tail.html >> downloads-by-user.html
