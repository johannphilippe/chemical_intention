/*
    This file is used for configuration (audio and system configuration)
*/

; The following variables describe audio configuration
; * sr = samplerate
; * ksmps = vector size 
; * nchnls = number of channels
; * 0dbfs = value of full scale amplitude
; It is recommanded not to change these variables, except nchnls (that must match the number of speakers you are using).

sr	=	48000
ksmps	=	64
nchnls	=	4
0dbfs	=	1

; The following macros can be enabled / disabled to allow : 
; * The compiled plugins (Hypercurve and lua_csound). 
; * Binaural mode 
; * WEB to enable or disable some custom implementations for WEB  (Web IDE only)
; To enable / disable a macro, simply add/emove comment sign ";" at the beginning of the following the macros line.

;#define ENABLE_PLUGINS ## ; Enables the use of compiled plugin opcodes (hypercurve and lua_csound)
;#define BINAURAL ## ; Enables binaural mode 
;#define WEB ##


