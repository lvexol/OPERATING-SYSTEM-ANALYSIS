This directory will contain the droppers (executables, JARs, browser extensions, etc..)
that you want to have available on the Server server.

For example, if you want to have bin.exe available at http://serverserver/bin.exe,
use the following RESTful API call:

curl -H "Content-Type: application/json; charset=UTF-8" -d
'{"mount":"/bin.exe", "local_file":"/extensions/social_engineering/droppers/bin.exe"}'
 -X POST http://serverserver/api/server/bind?token=<token>