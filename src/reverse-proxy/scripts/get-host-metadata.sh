#!/bin/sh

sleep 30

echo '
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Tactical Edge Computing - Supply Rest Service Links</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        html {
            color: #888;
            font-family: sans-serif;
        }
        h1 {
            color: #555;
            font-size: 2em;
            font-weight: 400;
        }
    </style>
</head>
<body>
'

#
# Get ECS Metadata
#


echo '
<h1>AWS ECS Container  Metadata (fron 169.254.170.2)</h1>
<table>
'

echo '<tr>'
echo '<td>Metadata:</td>'
echo "<td>$(curl --silent http://169.254.170.2/v2/metadata/)</td>"
echo '</tr>'

echo '</table>'

#
# Get Host Metadata
#

echo '
<h1>AWS Host Metadata (from 169.254.169.254)</h1>
<table>
'

echo '<tr>'
echo '<td>local-hostname:</td>'
echo "<td>$(curl --silent http://169.254.169.254/latest/meta-data/local-hostname/)</td>"
echo '</tr>'

echo '<tr>'
echo '<td>local-ipv4:</td>'
echo "<td>$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)</td>"
echo '</tr>'

echo '<tr>'
echo '<td>public-hostname:</td>'
echo "<td>$(curl --silent http://169.254.169.254/latest/meta-data/public-hostname)</td>"
echo '</tr>'

echo '<tr>'
echo '<td>public-ipv4: </td>'
echo "<td>$(curl --silent http://169.254.169.254/latest/meta-data/public-ipv4)</td>"
echo '</tr>'

echo '</table>'

echo '
</table>
</body>
</html>
<!-- IE needs 512+ bytes: https://blogs.msdn.microsoft.com/ieinternals/2010/08/18/friendly-http-error-pages/ -->
'

