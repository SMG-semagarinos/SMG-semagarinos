#https://api.telegram.org/bot[BOT_API_KEY]/sendMessage?chat_id=[MY_CHANNEL_NAME]&text=[MY_MESSAGE_TEXT]
#

$botName = "botSM01"
$botDescription = "Probando el servicio de Telegram Bot's"
$botUserName = "SMaga01bot"
$botToken = "666414006:AAGdXms3YvGArLRP_Eu9EGmjeRMOPErCJZg"
$chatID = ""
$chatMensaje = "Probando que llegue le mensaje"
"https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$chatMensaje" | clip
"https://api.telegram.org/bot$botToken/getUpdates" | clip


$botName = "botSM02"
$botDescription = "Probando el servicio de Telegram Bot's"
$botUserName = "SMaga02bot"
$botToken = "874560259:AAGFqqppbWTTVUkkbC0lV8YIoLBg4Z7M2TM"
$chatID = "-1001301629622"
$chatMensaje = "ProbandoMensaje"
"https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$chatMensaje" | clip
"https://api.telegram.org/bot$botToken/getUpdates" | clip
