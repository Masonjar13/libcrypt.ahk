#include ..\build\libcrypt.ahk

iterationCnt:=a_tickCount
junk:=0
str:="Hello° µWorld"

encStr:=soupRot.enc(str,iterationCnt,junk)
decStr:=soupRot.dec(encStr,iterationCnt,junk)

msgbox,,SoupRot,% encStr "`n`n" decStr
exitApp
