fx_version 'adamant'
game 'gta5'


client_scripts {
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/br.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/nl.lua',
	'config.lua',
	'client/main.lua',
	'client/nui.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/br.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'locales/nl.lua',
	'config.lua',
	'server/main.lua'
}

ui_page "html/index.html"

files {
    'html/**/*',
}

