/*
    This file is used for configuration (audio and system configuration)
*/

; The following variables describe audio configuration
; * sr = samplerate
; * ksmps = vector size 
; * nchnls = number of channels
; * 0dbfs = value of full scale amplitude
; It is recommanded not to change these variables

sr	=	48000
ksmps	=	64
nchnls	=	2
0dbfs	=	1

; The following macros can be enabled / disabled to allow : 
; * The compiled plugins (Hypercurve and lua_csound). The latter might change slightly the way probabilities are calculated. 
; * Binaural mode for headphones. 
; * WEB to enable or disable some custom implementations for WEB 
; To enable / disable a macro, simply add/emove comment sign ";" at the beginning of the macros line.

#define ENABLE_PLUGINS ## ; Enables the use of compiled plugin opcodes (hypercurve and lua_csound)
;#define BINAURAL ## ; Enables binaural mode 
;#define WEB ##


