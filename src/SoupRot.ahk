/* Written by Masonjar13

	A static-class for a length-based rotational cipher.
	
	Works for any unicode string by first encoding the string
	to base64. Decodes back to UTF-8 (could be altered to support
	binary data).

	Methods & Parameters:
---------------
	soupRot.enc()	- encode string
		str			- string to encode
		mult 		- rotation iteration count
		junk		- random character count to be added (default: 0)
	
	soupRot.dec()	- decode string
		str			- string to decode
		mult		- rotation iteration count used to encode
		junk		- random character count used to encode (default: 0)
	
	dependencies (can be found at https://github.com/Masonjar13/AHK-Library)
		randStr()
		rand()
		ifContains()
		isDigit()
		b64e()		- encode string
		b64d()		- decode string (utf-8)
		strPutVar()	- for b64e()
---------------

	Example:
------------
iterationCnt:=a_tickCount
junk:=0
str:="Hello° µWorld"

encStr:=soupRot.enc(str,iterationCnt,junk)
decStr:=soupRot.dec(encStr,iterationCnt,junk)

msgbox,,SoupRot,% encStr "`n`n" decStr
------------

*/

class soupRot {
	enc(str,mult,junk:=0){
		this.b64e(bStr,str)

		str:=bStr
		rotBase:=strLen(str) * mult
		
		for i,a in strSplit(str) {
			
			rot:=mod(rotBase*i,94)
			nC:=asc(a)+rot
			
			while (nC > 126 || nC < 32) {
				if (nC > 126) {
					nC-=94
				} else if (nC < 32) {
					nC+=94
				}
			}
			nStr.=chr(nC)
		
			if (junk) {
				nStr.=soupRot.randStr(junk,junk,1234)
			}
		}
		return nStr
	}
	dec(str,mult,junk:=0){
		i:=0
		rotBase:=strLen(str) * mult // (junk+1)
		
		for _,a in strSplit(str) {
			if (skip) {
				skip--
				continue
			}
			
			rot:=mod(rotBase*++i,94)
			nC:=asc(a)-rot
			
			while (nC > 126 || nC < 32) {
				if (nC > 126) {
					nC-=94
				} else if (nC < 32) {
					nC+=94
				}
			}
			nStr.=chr(nC)
			
			if (junk) {
				skip:=junk
			}
		}
		this.b64d(bStr,nStr)
		return rTrim(bStr,chr(65533)) ;"�"
	}
	
	; Dependencies
	
	randStr(lowerBound,upperBound,mode:=1){
		if (!this.isDigit(lowerBound)||!this.isDigit(upperBound)||!this.isDigit(mode))
			return -1
		loop % this.rand(lowerBound,upperBound) {
			t:=""
			if (strLen(mode)=1) {
				t:=mode
			} else {
				while (!this.ifContains(mode,t))
					t:=this.rand(1,4)
			}
			if (t=1) {
				str.=chr(this.rand(97,122))
			} else if (t=2) {
				str.=chr(this.rand(65,90))
			} else if (t=3) {
				str.=this.rand(0,9)
			} else if (t=4) {
				i:=this.rand(1,4)
				str.=i=1?chr(this.rand(33,47)):i=2?chr(this.rand(58,64)):i=3?chr(this.rand(91,96)):chr(this.rand(123,126))
			}
		}
		return str
	}
	rand(lowerBound,upperBound){
		random,rand,% lowerBound,% upperBound
		return rand
	}
	ifContains(haystack,needle){
		if haystack contains %needle%
			return 1
	}
	isDigit(in){
		if in is digit
			return 1
	}
	b64e(byRef outData,byRef inData ){
		inDataLen:=this.strPutVar(inData,inData,"UTF-8") - 1
		dllCall("Crypt32.dll\CryptBinaryToString","UInt",&inData,"UInt",inDataLen,"UInt",1,"UInt",0,"UIntP",tChars,"CDECL Int")
		varSetCapacity(outData,req:=tChars * (a_isUnicode?2:1),0)
		dllCall("Crypt32.dll\CryptBinaryToString","UInt",&inData,"UInt",inDataLen,"UInt",1,"Str",outData,"UIntP",req,"CDECL Int")
		return tChars
	}
	b64d(byRef outData,byRef inData){
		dllCall("Crypt32.dll\CryptStringToBinary","UInt",&inData,"UInt",strLen(inData),"UInt",1,"UInt",0,"UIntP",bytes,"Int",0,"Int",0,"CDECL Int")
		varSetCapacity(outData,req:=bytes * (a_isUnicode?2:1),0)
		dllCall("Crypt32.dll\CryptStringToBinary","UInt",&inData,"UInt",strLen(inData),"UInt",1,"Str",outData,"UIntP",req,"Int",0,"Int",0,"CDECL Int")
		outData:=strGet(&outData,"utf-8")
		return bytes
	}
	strPutVar(string,byRef var,encoding){
		varSetCapacity(var,strPut(string,encoding)
			* ((encoding="utf-16"||encoding="cp1200")?2:1))
		return strPut(string,&var,encoding)
	}
}