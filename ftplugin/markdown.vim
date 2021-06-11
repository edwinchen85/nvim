setlocal textwidth=80
setlocal spell
" workaround to disable ftplugin omnifunc
call timer_start(0, { tid -> execute('setlocal omnifunc=')})
