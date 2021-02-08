;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                              ;
;  ProTracker2: Compiled Music Player v1.01                    ;
;                                            by Andrew Collier ;
;                                                              ;
;   Free for use in programs provided ProTracker is mentioned  ;
;                            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;1997
;
; VERSION HISTORY:
;
; 1.01 In DOPATTBREAK, for end-of-song looping, changed
;      to LD DE,(RESETPLAYER+1) instead of a literal which
;      was not initialised.
;      31-5-2000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STARTPLAYER:
RESETPLAYER:
               LD   HL,32768
               JP   RPLAYERDASH

PLAYROUTINE:
               LD   HL,SOUNDTABLE
               LD   BC,511
               LD   E,0

BYTE0:         LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE1:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE2:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE3:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE4:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE5:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B


BYTE6:         LD   E,8
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE7:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTEA:         LD   D,16
               LD   A,(SOUNDTABLE+12)

               OUT  (C),D
               DEC  B
               OUT  (C),A
               INC  B

BYTE8:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE9:         INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTEB:         INC  D
               LD   A,(SOUNDTABLE+13)

               OUT  (C),D
               DEC  B
               OUT  (C),A
               INC  B


BYTE10:        INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE11:        INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B



BYTE14:        LD   E,18
               LD   HL,SOUNDTABLE+14
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B




BYTE15:        INC  E
               INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE16:        INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE17:        INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B


BYTE18:        INC  E
               INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

BYTE19:        INC  E
               LD   A,(HL)
               INC  L

               OUT  (C),E
               DEC  B
               OUT  (C),A
               INC  B

				ret
AFTERSOUNDCHIP:




DELAY:         EQU  $+1
               LD   A,00
               DEC  A
               JP   NZ,NOCHANGES

PATTDELAY:     EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOPATTERND
               DEC  A
               LD   (PATTDELAY),A
               JP   PATDELAYTEMPO

NOPATTERND:
               LD   (DELAYFLAG1),A
               LD   (DELAYFLAG2),A
               LD   (DELAYFLAG3),A
               LD   (DELAYFLAG4),A
               LD   (DELAYFLAG5),A
               LD   (DELAYFLAG6),A






NEXTPLAYADDR:  EQU  $+1
               LD   HL,0000

NEXTCOMMAND1:  LD   A,(HL)
               LD   (JRCOMMAND1),A
JRCOMMAND1:    EQU  $+1
               JR   JRSTARTS
JRSTARTS:

JRNOTE:        EQU  $-JRSTARTS
               JP   DONOTE1
JRNEWINST:     EQU  $-JRSTARTS
               JP   DONEWINST1
JRNEWORN:      EQU  $-JRSTARTS
               JP   DONEWORN1
JRNEWBOTH:     EQU  $-JRSTARTS
               JP   DONEWBOTH1
JRNOORN:       EQU  $-JRSTARTS
               JP   DONOORN1
JRNOORNINS:    EQU  $-JRSTARTS
               JP   DONOORNINS1

JRNOCOMMAND:   EQU  $-JRSTARTS
               JP   DONOCOMMAND1
JRSETVOLUME:   EQU  $-JRSTARTS
               JP   DOSETVOLUME1
JRCUTNOTE:     EQU  $-JRSTARTS
               JP   DOCUTNOTE1
JRSETCHORD:    EQU  $-JRSTARTS
               JP   DOSETCHORD1
JRUPSLIDE:     EQU  $-JRSTARTS
               JP   DOUPSLIDE1
JRDNSLIDE:     EQU  $-JRSTARTS
               JP   DODNSLIDE1
JRPORTAMENTO:  EQU  $-JRSTARTS
               JP   DOPORTAMENTO1
JRREPORTAM:    EQU  $-JRSTARTS
               JP   DOREPORTAM1
JRVIBRATO:     EQU  $-JRSTARTS
               JP   DOVIBRATO1
JRTREMOLO:     EQU  $-JRSTARTS
               JP   DOTREMOLO1
JRDELAYNOTE:   EQU  $-JRSTARTS
               JP   DODELAYNOTE1
JRCUTCHANNEL:  EQU  $-JRSTARTS
               JP   DOCUTCHANNEL1


               DEFS 18


JRNONOTE1:     EQU  $-JRSTARTS
               JP   AFTERCHANGES1
JRNONOTE2:     EQU  $-JRSTARTS
               JP   AFTERCHANGES2
JRNONOTE3:     EQU  $-JRSTARTS
               JP   AFTERCHANGES3
JRNONOTE4:     EQU  $-JRSTARTS
               JP   AFTERCHANGES4
JRNONOTE5:     EQU  $-JRSTARTS
               JP   AFTERCHANGES5
JRNONOTEROW:   EQU  $-JRSTARTS
               JP   AFTERCHANGES6

JRLOWENVELOPE: EQU  $-JRSTARTS
               JP   DOENVELOPE1
JRHIGHENVELOPE:EQU  $-JRSTARTS
               JP   DOENVELOPE2


JRNEWTEMPO:    EQU  $-JRSTARTS
               JP   DONEWTEMPO
JRPATTDELAY:   EQU  $-JRSTARTS
               JP   DOPATTDELAY
JRJUMPLOOP:    EQU  $-JRSTARTS
               JP   DOJUMPLOOP
JRPATTBREAK:   EQU  $-JRSTARTS
               JP   DOPATTBREAK
JRNEWSONGPOS:  EQU  $-JRSTARTS
               JP   DONEWSONGPOS




DONEWTEMPO:    INC  HL
               LD   A,(HL)
               LD   (TEMPO),A
               INC  HL
               JR   NEXTCOMMAND1

DOPATTDELAY:   INC  HL
               LD   A,(HL)
               LD   (PATTDELAY),A
               INC  HL
               JP   NEXTCOMMAND1

DOJUMPLOOP:
               INC  HL
REPEATNUM:     EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NEWREPEAT
               DEC  A
               LD   (REPEATNUM),A
               JR   Z,DONEREPEAT

REPEATADDR:    EQU  $+1
               LD   DE,0000
               LD   (NEXTPLAYADDR),DE
               LD   A,AFTERSETADDR-SETADDR
               LD   (SKIPSETADDR),A

DONEREPEAT:    INC  HL
               INC  HL
               INC  HL
               JP   NEXTCOMMAND1

NEWREPEAT:
               LD   A,(HL)
               LD   (REPEATNUM),A
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)
               INC  HL
               LD   (REPEATADDR),DE
               LD   (NEXTPLAYADDR),DE
               LD   A,AFTERSETADDR-SETADDR
               LD   (SKIPSETADDR),A
               JP   NEXTCOMMAND1

DONEWSONGPOS:
               LD   A,(SKIPSETADDR)
               OR   A
               JR   Z,YESSONGPOS
               INC  HL
               INC  HL
               INC  HL
               JP   NEXTCOMMAND1

YESSONGPOS:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)
               INC  HL
               LD   A,(DE)
               JR   NOLOOPSONG

DOPATTBREAK:
               INC  HL
               LD   A,(SKIPSETADDR)
               OR   A
               JP   NZ,NEXTCOMMAND1

NEXTSONGPOS:   EQU  $+1
               LD   DE,0000
               LD   A,(DE)
               OR   A
               JR   NZ,NOLOOPSONG
               INC  DE
               LD   A,(DE)
               DEC  DE
               OR   A
               LD   A,(DE)
               JR   NZ,NOLOOPSONG

;BEGINSONG:     EQU  $+1
;               LD   DE,32768

; In 1.01 changed to:
               LD   DE,(RESETPLAYER+1)
               LD   A,(DE)

NOLOOPSONG:    LD   (NEXTPLAYADDR),A
               INC  DE
               LD   A,(DE)
               LD   (NEXTPLAYADDR+1),A
               INC  DE
               LD   (NEXTSONGPOS),DE
               LD   A,AFTERSETADDR-SETADDR
               LD   (SKIPSETADDR),A
               JP   NEXTCOMMAND1


DOENVELOPE1:   INC  HL
               LD   A,(HL)
               LD   (SOUNDTABLE+18),A
               INC  HL
               JP   NEXTCOMMAND1

DOENVELOPE2:   INC  HL
               LD   A,(HL)
               LD   (SOUNDTABLE+19),A
               INC  HL
               JP   NEXTCOMMAND1

DOCUTNOTE1:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (CUTAFTERT1),A
               LD   DE,AFTERCOMMAND1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1

DONOCOMMAND1:  INC  HL
               LD   DE,AFTERCOMMAND1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1


DOSETVOLUME1:  INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMEL1),A
               INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMER1),A
               INC  HL
               LD   DE,JPSETVOLUME1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1

DOSETCHORD1:   INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD1_1),A
               LD   A,E
               AND  15
               LD   (OCTCHORD1_1),A
               INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD1_2),A
               LD   A,E
               AND  15
               LD   (OCTCHORD1_2),A
               LD   DE,JPCHORD1_0
               LD   (JPCOMMAND1),DE
               INC  HL
               JP   NEXTCOMMAND1


DOUPSLIDE1:    INC  HL
               LD   A,(HL)
               LD   (UPSPEED1),A
               LD   A,7
               LD   (UPOCTTARGET1),A
               LD   A,255
               LD   (UPTONETARGET1),A
               LD   DE,JPUPSLIDE1
               LD   (JPCOMMAND1),DE

               INC  HL
               JP   NEXTCOMMAND1


DODNSLIDE1:    INC  HL
               LD   A,(HL)
               LD   (DNSPEED1),A
               XOR  A
               LD   (DNOCTTARGET1),A
               LD   (DNTONETARGET1),A
               LD   DE,JPDNSLIDE1
               LD   (JPCOMMAND1),DE

               INC  HL
               JP   NEXTCOMMAND1

DOPORTAMENTO1: INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER1),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   E,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   D,A
               LD   A,(BASEOCT1)
               CP   D
               JR   C,PORTAMUP1
               JR   NZ,PORTAMDN1
               LD   A,(BASETONE1)
               CP   E
               JR   C,PORTAMUP1
PORTAMDN1:     LD   A,(HL)
               INC  HL
               LD   (DNSPEED1),A
               LD   A,D
               LD   (DNOCTTARGET1),A
               LD   A,E
               LD   (DNTONETARGET1),A
               LD   DE,JPDNSLIDE1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1

PORTAMUP1:     LD   A,(HL)
               INC  HL
               LD   (UPSPEED1),A
               LD   A,D
               LD   (UPOCTTARGET1),A
               LD   A,E
               LD   (UPTONETARGET1),A
               LD   DE,JPUPSLIDE1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1

DOREPORTAM1:   INC  HL
               LD   A,(HL)
               INC  HL
               LD   (UPSPEED1),A
               LD   (DNSPEED1),A
               JP   NEXTCOMMAND1

DOVIBRATO1:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (VIBRATABLE1),DE
               LD   A,(HL)
               INC  HL
               LD   (VIBRASPEED1),A
               LD   DE,JPVIBRATO1
               LD   (JPCOMMAND1),DE

               JP   NEXTCOMMAND1

DOTREMOLO1:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (TREMOLOTABLE1),DE
               LD   A,(HL)
               INC  HL
               LD   (TREMOLOSPEED1),A
               LD   DE,JPTREMOLO1
               LD   (JPCOMMAND1),DE

               JP   NEXTCOMMAND1

DOCUTCHANNEL1:
               INC  HL
               XOR  A
               LD   (DELAYFLAG1),A
               INC  A
               LD   (DELAY1),A
               LD   DE,AFTERCOMMAND1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1

DODELAYNOTE1:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (DELAY1),A
               LD   A,1
               LD   (DELAYFLAG1),A
               LD   DE,AFTERCOMMAND1
               LD   (JPCOMMAND1),DE
               JP   NEXTCOMMAND1


DONOORN1:
               XOR  A
               LD   (ORNLEN1),A
               JP   DONOTE1

DONOORNINS1:   XOR  A
               LD   (ORNLEN1),A
               JP   DONEWINST1

DONEWORN1:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN1),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN1),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR1),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR1+1),A
               INC  DE
               LD   (ORNADDR1),DE
               JP   DONOTE1
DONEWBOTH1:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN1),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN1),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR1),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR1+1),A
               INC  DE
               LD   (ORNADDR1),DE

DONEWINST1:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (INSTLEN1),A
               INC  DE
               LD   A,(DE)
               LD   (REPLEN1),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR1),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR1+1),A
               INC  DE
               LD   (INSTADDR1),DE
DONOTE1:
               INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER1),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   (BASETONE1),A
               INC  HL
               LD   A,(HL)
               LD   (BASEOCT1),A

INSTLEN1:      EQU  $+1
               LD   A,00
               LD   (PLAYLEN1),A
INSTADDR1:     EQU  $+1
               LD   DE,0000
               LD   (PLAYADDR1),DE

ORNLEN1:       EQU  $+1
               LD   A,00
               LD   (ORNPLAYLEN1),A
ORNADDR1:      EQU  $+1
               LD   DE,0000
               LD   (ORNPLAYADDR1),DE





AFTERCHANGES1:
               INC  HL

NEXTCOMMAND2:  LD   A,(HL)
               LD   (JRCOMMAND2),A
JRCOMMAND2:    EQU  $+1
               JR   $
               JP   DONOTE2
               JP   DONEWINST2
               JP   DONEWORN2
               JP   DONEWBOTH2
               JP   DONOORN2
               JP   DONOORNINS2

               JP   DONOCOMMAND2
               JP   DOSETVOLUME2
               JP   DOCUTNOTE2
               JP   DOSETCHORD2
               JP   DOUPSLIDE2
               JP   DODNSLIDE2
               JP   DOPORTAMENTO2
               JP   DOREPORTAM2

               JP   DOVIBRATO2
               JP   DOTREMOLO2
               JP   DODELAYNOTE2
               JP   DOCUTCHANNEL2
               DEFS 18


               JP   AFTERCHANGES2
               JP   AFTERCHANGES3
               JP   AFTERCHANGES4
               JP   AFTERCHANGES5
               JP   AFTERCHANGES6

DOCUTNOTE2:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (CUTAFTERT2),A
               LD   DE,AFTERCOMMAND2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2

DONOCOMMAND2:  INC  HL
               LD   DE,AFTERCOMMAND2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2


DOSETVOLUME2:  INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMEL2),A
               INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMER2),A
               INC  HL
               LD   DE,JPSETVOLUME2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2



DOSETCHORD2:   INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD2_1),A
               LD   A,E
               AND  15
               LD   (OCTCHORD2_1),A
               INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD2_2),A
               LD   A,E
               AND  15
               LD   (OCTCHORD2_2),A
               LD   DE,JPCHORD2_0
               LD   (JPCOMMAND2),DE
               INC  HL
               JP   NEXTCOMMAND2



DOUPSLIDE2:    INC  HL
               LD   A,(HL)
               LD   (UPSPEED2),A
               LD   A,7
               LD   (UPOCTTARGET2),A
               LD   A,255
               LD   (UPTONETARGET2),A
               LD   DE,JPUPSLIDE2
               LD   (JPCOMMAND2),DE

               INC  HL
               JP   NEXTCOMMAND2


DODNSLIDE2:    INC  HL
               LD   A,(HL)
               LD   (DNSPEED2),A
               XOR  A
               LD   (DNOCTTARGET2),A
               LD   (DNTONETARGET2),A
               LD   DE,JPDNSLIDE2
               LD   (JPCOMMAND2),DE

               INC  HL
               JP   NEXTCOMMAND2

DOPORTAMENTO2: INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER2),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   E,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   D,A
               LD   A,(BASEOCT2)
               CP   D
               JR   C,PORTAMUP2
               JR   NZ,PORTAMDN2
               LD   A,(BASETONE2)
               CP   E
               JR   C,PORTAMUP2
PORTAMDN2:     LD   A,(HL)
               INC  HL
               LD   (DNSPEED2),A
               LD   A,D
               LD   (DNOCTTARGET2),A
               LD   A,E
               LD   (DNTONETARGET2),A
               LD   DE,JPDNSLIDE2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2

PORTAMUP2:     LD   A,(HL)
               INC  HL
               LD   (UPSPEED2),A
               LD   A,D
               LD   (UPOCTTARGET2),A
               LD   A,E
               LD   (UPTONETARGET2),A
               LD   DE,JPUPSLIDE2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2

DOREPORTAM2:   INC  HL
               LD   A,(HL)
               INC  HL
               LD   (UPSPEED2),A
               LD   (DNSPEED2),A
               JP   NEXTCOMMAND2

DOVIBRATO2:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (VIBRATABLE2),DE
               LD   A,(HL)
               INC  HL
               LD   (VIBRASPEED2),A
               LD   DE,JPVIBRATO2
               LD   (JPCOMMAND2),DE

               JP   NEXTCOMMAND2


DOTREMOLO2:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (TREMOLOTABLE2),DE
               LD   A,(HL)
               INC  HL
               LD   (TREMOLOSPEED2),A
               LD   DE,JPTREMOLO2
               LD   (JPCOMMAND2),DE

               JP   NEXTCOMMAND2

DOCUTCHANNEL2:
               INC  HL
               XOR  A
               LD   (DELAYFLAG2),A
               INC  A
               LD   (DELAY2),A
               LD   DE,AFTERCOMMAND2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2

DODELAYNOTE2:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (DELAY2),A
               LD   A,1
               LD   (DELAYFLAG2),A
               LD   DE,AFTERCOMMAND2
               LD   (JPCOMMAND2),DE
               JP   NEXTCOMMAND2


DONOORN2:
               XOR  A
               LD   (ORNLEN2),A
               JP   DONOTE2

DONOORNINS2:   XOR  A
               LD   (ORNLEN2),A
               JP   DONEWINST2

DONEWORN2:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN2),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN2),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR2),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR2+1),A
               INC  DE
               LD   (ORNADDR2),DE
               JP   DONOTE2
DONEWBOTH2:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN2),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN2),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR2),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR2+1),A
               INC  DE
               LD   (ORNADDR2),DE

DONEWINST2:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (INSTLEN2),A
               INC  DE
               LD   A,(DE)
               LD   (REPLEN2),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR2),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR2+1),A
               INC  DE
               LD   (INSTADDR2),DE
DONOTE2:
               INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER2),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   (BASETONE2),A
               INC  HL
               LD   A,(HL)
               LD   (BASEOCT2),A

INSTLEN2:      EQU  $+1
               LD   A,00
               LD   (PLAYLEN2),A
INSTADDR2:     EQU  $+1
               LD   DE,0000
               LD   (PLAYADDR2),DE

ORNLEN2:       EQU  $+1
               LD   A,00
               LD   (ORNPLAYLEN2),A
ORNADDR2:      EQU  $+1
               LD   DE,0000
               LD   (ORNPLAYADDR2),DE





AFTERCHANGES2:

               INC  HL

NEXTCOMMAND3:  LD   A,(HL)
               LD   (JRCOMMAND3),A
JRCOMMAND3:    EQU  $+1
               JR   $
               JP   DONOTE3
               JP   DONEWINST3
               JP   DONEWORN3
               JP   DONEWBOTH3
               JP   DONOORN3
               JP   DONOORNINS3

               JP   DONOCOMMAND3
               JP   DOSETVOLUME3
               JP   DOCUTNOTE3
               JP   DOSETCHORD3
               JP   DOUPSLIDE3
               JP   DODNSLIDE3
               JP   DOPORTAMENTO3
               JP   DOREPORTAM3

               JP   DOVIBRATO3
               JP   DOTREMOLO3
               JP   DODELAYNOTE3
               JP   DOCUTCHANNEL3
               DEFS 18

               JP   AFTERCHANGES3
               JP   AFTERCHANGES4
               JP   AFTERCHANGES5
               JP   AFTERCHANGES6

DOCUTNOTE3:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (CUTAFTERT3),A
               LD   DE,AFTERCOMMAND3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3

DONOCOMMAND3:  INC  HL
               LD   DE,AFTERCOMMAND3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3


DOSETVOLUME3:  INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMEL3),A
               INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMER3),A
               INC  HL
               LD   DE,JPSETVOLUME3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3



DOSETCHORD3:   INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD3_1),A
               LD   A,E
               AND  15
               LD   (OCTCHORD3_1),A
               INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD3_2),A
               LD   A,E
               AND  15
               LD   (OCTCHORD3_2),A
               LD   DE,JPCHORD3_0
               LD   (JPCOMMAND3),DE
               INC  HL
               JP   NEXTCOMMAND3



DOUPSLIDE3:    INC  HL
               LD   A,(HL)
               LD   (UPSPEED3),A
               LD   A,7
               LD   (UPOCTTARGET3),A
               LD   A,255
               LD   (UPTONETARGET3),A
               LD   DE,JPUPSLIDE3
               LD   (JPCOMMAND3),DE

               INC  HL
               JP   NEXTCOMMAND3


DODNSLIDE3:    INC  HL
               LD   A,(HL)
               LD   (DNSPEED3),A
               XOR  A
               LD   (DNOCTTARGET3),A
               LD   (DNTONETARGET3),A
               LD   DE,JPDNSLIDE3
               LD   (JPCOMMAND3),DE

               INC  HL
               JP   NEXTCOMMAND3


DOPORTAMENTO3: INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER3),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   E,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   D,A
               LD   A,(BASEOCT3)
               CP   D
               JR   C,PORTAMUP3
               JR   NZ,PORTAMDN3
               LD   A,(BASETONE3)
               CP   E
               JR   C,PORTAMUP3
PORTAMDN3:     LD   A,(HL)
               INC  HL
               LD   (DNSPEED3),A
               LD   A,D
               LD   (DNOCTTARGET3),A
               LD   A,E
               LD   (DNTONETARGET3),A
               LD   DE,JPDNSLIDE3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3

PORTAMUP3:     LD   A,(HL)
               INC  HL
               LD   (UPSPEED3),A
               LD   A,D
               LD   (UPOCTTARGET3),A
               LD   A,E
               LD   (UPTONETARGET3),A
               LD   DE,JPUPSLIDE3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3

DOREPORTAM3:   INC  HL
               LD   A,(HL)
               INC  HL
               LD   (UPSPEED3),A
               LD   (DNSPEED3),A
               JP   NEXTCOMMAND3
DOVIBRATO3:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (VIBRATABLE3),DE
               LD   A,(HL)
               INC  HL
               LD   (VIBRASPEED3),A
               LD   DE,JPVIBRATO3
               LD   (JPCOMMAND3),DE

               JP   NEXTCOMMAND3


DOTREMOLO3:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (TREMOLOTABLE3),DE
               LD   A,(HL)
               INC  HL
               LD   (TREMOLOSPEED3),A
               LD   DE,JPTREMOLO3
               LD   (JPCOMMAND3),DE

               JP   NEXTCOMMAND3
DOCUTCHANNEL3:
               INC  HL
               XOR  A
               LD   (DELAYFLAG3),A
               INC  A
               LD   (DELAY3),A
               LD   DE,AFTERCOMMAND3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3

DODELAYNOTE3:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (DELAY3),A
               LD   A,1
               LD   (DELAYFLAG3),A
               LD   DE,AFTERCOMMAND3
               LD   (JPCOMMAND3),DE
               JP   NEXTCOMMAND3



DONOORN3:
               XOR  A
               LD   (ORNLEN3),A
               JP   DONOTE3

DONOORNINS3:   XOR  A
               LD   (ORNLEN3),A
               JP   DONEWINST3

DONEWORN3:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN3),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN3),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR3),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR3+1),A
               INC  DE
               LD   (ORNADDR3),DE
               JP   DONOTE3
DONEWBOTH3:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN3),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN3),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR3),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR3+1),A
               INC  DE
               LD   (ORNADDR3),DE

DONEWINST3:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (INSTLEN3),A
               INC  DE
               LD   A,(DE)
               LD   (REPLEN3),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR3),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR3+1),A
               INC  DE
               LD   (INSTADDR3),DE
DONOTE3:
               INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER3),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   (BASETONE3),A
               INC  HL
               LD   A,(HL)
               LD   (BASEOCT3),A

INSTLEN3:      EQU  $+1
               LD   A,00
               LD   (PLAYLEN3),A
INSTADDR3:     EQU  $+1
               LD   DE,0000
               LD   (PLAYADDR3),DE

ORNLEN3:       EQU  $+1
               LD   A,00
               LD   (ORNPLAYLEN3),A
ORNADDR3:      EQU  $+1
               LD   DE,0000
               LD   (ORNPLAYADDR3),DE

AFTERCHANGES3:

               INC  HL

NEXTCOMMAND4:  LD   A,(HL)
               LD   (JRCOMMAND4),A
JRCOMMAND4:    EQU  $+1
               JR   $
               JP   DONOTE4
               JP   DONEWINST4
               JP   DONEWORN4
               JP   DONEWBOTH4
               JP   DONOORN4
               JP   DONOORNINS4

               JP   DONOCOMMAND4
               JP   DOSETVOLUME4
               JP   DOCUTNOTE4
               JP   DOSETCHORD4

               JP   DOUPSLIDE4
               JP   DODNSLIDE4
               JP   DOPORTAMENTO4
               JP   DOREPORTAM4

               JP   DOVIBRATO4
               JP   DOTREMOLO4
               JP   DODELAYNOTE4
               JP   DOCUTCHANNEL4
               DEFS 18


               JP   AFTERCHANGES4
               JP   AFTERCHANGES5
               JP   AFTERCHANGES6


DOCUTNOTE4:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (CUTAFTERT4),A
               LD   DE,AFTERCOMMAND4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4

DONOCOMMAND4:  INC  HL
               LD   DE,AFTERCOMMAND4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4


DOSETVOLUME4:  INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMEL4),A
               INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMER4),A
               INC  HL
               LD   DE,JPSETVOLUME4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4

DOSETCHORD4:   INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD4_1),A
               LD   A,E
               AND  15
               LD   (OCTCHORD4_1),A
               INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD4_2),A
               LD   A,E
               AND  15
               LD   (OCTCHORD4_2),A
               LD   DE,JPCHORD4_0
               LD   (JPCOMMAND4),DE
               INC  HL
               JP   NEXTCOMMAND4


DOUPSLIDE4:    INC  HL
               LD   A,(HL)
               LD   (UPSPEED4),A
               LD   A,7
               LD   (UPOCTTARGET4),A
               LD   A,255
               LD   (UPTONETARGET4),A
               LD   DE,JPUPSLIDE4
               LD   (JPCOMMAND4),DE

               INC  HL
               JP   NEXTCOMMAND4


DODNSLIDE4:    INC  HL
               LD   A,(HL)
               LD   (DNSPEED4),A
               XOR  A
               LD   (DNOCTTARGET4),A
               LD   (DNTONETARGET4),A
               LD   DE,JPDNSLIDE4
               LD   (JPCOMMAND4),DE

               INC  HL
               JP   NEXTCOMMAND4


DOPORTAMENTO4: INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER4),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   E,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   D,A
               LD   A,(BASEOCT4)
               CP   D
               JR   C,PORTAMUP4
               JR   NZ,PORTAMDN4
               LD   A,(BASETONE4)
               CP   E
               JR   C,PORTAMUP4
PORTAMDN4:     LD   A,(HL)
               INC  HL
               LD   (DNSPEED4),A
               LD   A,D
               LD   (DNOCTTARGET4),A
               LD   A,E
               LD   (DNTONETARGET4),A
               LD   DE,JPDNSLIDE4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4

PORTAMUP4:     LD   A,(HL)
               INC  HL
               LD   (UPSPEED4),A
               LD   A,D
               LD   (UPOCTTARGET4),A
               LD   A,E
               LD   (UPTONETARGET4),A
               LD   DE,JPUPSLIDE4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4

DOREPORTAM4:   INC  HL
               LD   A,(HL)
               INC  HL
               LD   (UPSPEED4),A
               LD   (DNSPEED4),A
               JP   NEXTCOMMAND4


DOVIBRATO4:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (VIBRATABLE4),DE
               LD   A,(HL)
               INC  HL
               LD   (VIBRASPEED4),A
               LD   DE,JPVIBRATO4
               LD   (JPCOMMAND4),DE

               JP   NEXTCOMMAND4


DOTREMOLO4:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (TREMOLOTABLE4),DE
               LD   A,(HL)
               INC  HL
               LD   (TREMOLOSPEED4),A
               LD   DE,JPTREMOLO4
               LD   (JPCOMMAND4),DE

               JP   NEXTCOMMAND4

DOCUTCHANNEL4:
               INC  HL
               XOR  A
               LD   (DELAYFLAG4),A
               INC  A
               LD   (DELAY4),A
               LD   DE,AFTERCOMMAND4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4

DODELAYNOTE4:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (DELAY4),A
               LD   A,1
               LD   (DELAYFLAG4),A
               LD   DE,AFTERCOMMAND4
               LD   (JPCOMMAND4),DE
               JP   NEXTCOMMAND4


DONOORN4:
               XOR  A
               LD   (ORNLEN4),A
               JP   DONOTE4

DONOORNINS4:   XOR  A
               LD   (ORNLEN4),A
               JP   DONEWINST4

DONEWORN4:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN4),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN4),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR4),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR4+1),A
               INC  DE
               LD   (ORNADDR4),DE
               JP   DONOTE4
DONEWBOTH4:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN4),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN4),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR4),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR4+1),A
               INC  DE
               LD   (ORNADDR4),DE

DONEWINST4:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (INSTLEN4),A
               INC  DE
               LD   A,(DE)
               LD   (REPLEN4),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR4),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR4+1),A
               INC  DE
               LD   (INSTADDR4),DE
DONOTE4:
               INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER4),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   (BASETONE4),A
               INC  HL
               LD   A,(HL)
               LD   (BASEOCT4),A

INSTLEN4:      EQU  $+1
               LD   A,00
               LD   (PLAYLEN4),A
INSTADDR4:     EQU  $+1
               LD   DE,0000
               LD   (PLAYADDR4),DE

ORNLEN4:       EQU  $+1
               LD   A,00
               LD   (ORNPLAYLEN4),A
ORNADDR4:      EQU  $+1
               LD   DE,0000
               LD   (ORNPLAYADDR4),DE

AFTERCHANGES4:


               INC  HL

NEXTCOMMAND5:  LD   A,(HL)
               LD   (JRCOMMAND5),A
JRCOMMAND5:    EQU  $+1
               JR   $
               JP   DONOTE5
               JP   DONEWINST5
               JP   DONEWORN5
               JP   DONEWBOTH5
               JP   DONOORN5
               JP   DONOORNINS5

               JP   DONOCOMMAND5
               JP   DOSETVOLUME5
               JP   DOCUTNOTE5
               JP   DOSETCHORD5

               JP   DOUPSLIDE5
               JP   DODNSLIDE5
               JP   DOPORTAMENTO5
               JP   DOREPORTAM5

               JP   DOVIBRATO5
               JP   DOTREMOLO5
               JP   DODELAYNOTE5
               JP   DOCUTCHANNEL5
               DEFS 18

               JP   AFTERCHANGES5
               JP   AFTERCHANGES6


DOCUTNOTE5:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (CUTAFTERT5),A
               LD   DE,AFTERCOMMAND5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5

DONOCOMMAND5:  INC  HL
               LD   DE,AFTERCOMMAND5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5


DOSETVOLUME5:  INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMEL5),A
               INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMER5),A
               INC  HL
               LD   DE,JPSETVOLUME5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5

DOSETCHORD5:   INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD5_1),A
               LD   A,E
               AND  15
               LD   (OCTCHORD5_1),A
               INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD5_2),A
               LD   A,E
               AND  15
               LD   (OCTCHORD5_2),A
               LD   DE,JPCHORD5_0
               LD   (JPCOMMAND5),DE
               INC  HL
               JP   NEXTCOMMAND5


DOUPSLIDE5:    INC  HL
               LD   A,(HL)
               LD   (UPSPEED5),A
               LD   A,7
               LD   (UPOCTTARGET5),A
               LD   A,255
               LD   (UPTONETARGET5),A
               LD   DE,JPUPSLIDE5
               LD   (JPCOMMAND5),DE

               INC  HL
               JP   NEXTCOMMAND5


DODNSLIDE5:    INC  HL
               LD   A,(HL)
               LD   (DNSPEED5),A
               XOR  A
               LD   (DNOCTTARGET5),A
               LD   (DNTONETARGET5),A
               LD   DE,JPDNSLIDE5
               LD   (JPCOMMAND5),DE

               INC  HL
               JP   NEXTCOMMAND5


DOPORTAMENTO5: INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER5),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   E,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   D,A
               LD   A,(BASEOCT5)
               CP   D
               JR   C,PORTAMUP5
               JR   NZ,PORTAMDN5
               LD   A,(BASETONE5)
               CP   E
               JR   C,PORTAMUP5
PORTAMDN5:     LD   A,(HL)
               INC  HL
               LD   (DNSPEED5),A
               LD   A,D
               LD   (DNOCTTARGET5),A
               LD   A,E
               LD   (DNTONETARGET5),A
               LD   DE,JPDNSLIDE5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5

PORTAMUP5:     LD   A,(HL)
               INC  HL
               LD   (UPSPEED5),A
               LD   A,D
               LD   (UPOCTTARGET5),A
               LD   A,E
               LD   (UPTONETARGET5),A
               LD   DE,JPUPSLIDE5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5

DOREPORTAM5:   INC  HL
               LD   A,(HL)
               INC  HL
               LD   (UPSPEED5),A
               LD   (DNSPEED5),A
               JP   NEXTCOMMAND5

DOVIBRATO5:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (VIBRATABLE5),DE
               LD   A,(HL)
               INC  HL
               LD   (VIBRASPEED5),A
               LD   DE,JPVIBRATO5
               LD   (JPCOMMAND5),DE

               JP   NEXTCOMMAND5




DOTREMOLO5:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (TREMOLOTABLE5),DE
               LD   A,(HL)
               INC  HL
               LD   (TREMOLOSPEED5),A
               LD   DE,JPTREMOLO5
               LD   (JPCOMMAND5),DE

               JP   NEXTCOMMAND5


DOCUTCHANNEL5:
               INC  HL
               XOR  A
               LD   (DELAYFLAG5),A
               INC  A
               LD   (DELAY5),A
               LD   DE,AFTERCOMMAND5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5

DODELAYNOTE5:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (DELAY5),A
               LD   A,1
               LD   (DELAYFLAG5),A
               LD   DE,AFTERCOMMAND5
               LD   (JPCOMMAND5),DE
               JP   NEXTCOMMAND5



DONOORN5:
               XOR  A
               LD   (ORNLEN5),A
               JP   DONOTE5

DONOORNINS5:   XOR  A
               LD   (ORNLEN5),A
               JP   DONEWINST5

DONEWORN5:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN5),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN5),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR5),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR5+1),A
               INC  DE
               LD   (ORNADDR5),DE
               JP   DONOTE5
DONEWBOTH5:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN5),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN5),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR5),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR5+1),A
               INC  DE
               LD   (ORNADDR5),DE

DONEWINST5:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (INSTLEN5),A
               INC  DE
               LD   A,(DE)
               LD   (REPLEN5),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR5),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR5+1),A
               INC  DE
               LD   (INSTADDR5),DE
DONOTE5:
               INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER5),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   (BASETONE5),A
               INC  HL
               LD   A,(HL)
               LD   (BASEOCT5),A

INSTLEN5:      EQU  $+1
               LD   A,00
               LD   (PLAYLEN5),A
INSTADDR5:     EQU  $+1
               LD   DE,0000
               LD   (PLAYADDR5),DE

ORNLEN5:       EQU  $+1
               LD   A,00
               LD   (ORNPLAYLEN5),A
ORNADDR5:      EQU  $+1
               LD   DE,0000
               LD   (ORNPLAYADDR5),DE

AFTERCHANGES5:

               INC  HL

NEXTCOMMAND6:  LD   A,(HL)
               LD   (JRCOMMAND6),A
JRCOMMAND6:    EQU  $+1
               JR   $
               JP   DONOTE6
               JP   DONEWINST6
               JP   DONEWORN6
               JP   DONEWBOTH6
               JP   DONOORN6
               JP   DONOORNINS6

               JP   DONOCOMMAND6
               JP   DOSETVOLUME6
               JP   DOCUTNOTE6
               JP   DOSETCHORD6

               JP   DOUPSLIDE6
               JP   DODNSLIDE6
               JP   DOPORTAMENTO6
               JP   DOREPORTAM6

               JP   DOVIBRATO6
               JP   DOTREMOLO6
               JP   DODELAYNOTE6
               JP   DOCUTCHANNEL6

               DEFS 18

               JP   AFTERCHANGES6


DOCUTNOTE6:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (CUTAFTERT6),A
               LD   DE,AFTERCOMMAND6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6

DONOCOMMAND6:  INC  HL
               LD   DE,AFTERCOMMAND6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6


DOSETVOLUME6:  INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMEL6),A
               INC  HL
               LD   A,(HL)
               LD   (SUBVOLUMER6),A
               INC  HL
               LD   DE,JPSETVOLUME6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6

DOSETCHORD6:   INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD6_1),A
               LD   A,E
               AND  15
               LD   (OCTCHORD6_1),A
               INC  HL
               LD   A,(HL)
               LD   E,A
               AND  240
               LD   (OSCHORD6_2),A
               LD   A,E
               AND  15
               LD   (OCTCHORD6_2),A
               LD   DE,JPCHORD6_0
               LD   (JPCOMMAND6),DE
               INC  HL
               JP   NEXTCOMMAND6

DOUPSLIDE6:    INC  HL
               LD   A,(HL)
               LD   (UPSPEED6),A
               LD   A,7
               LD   (UPOCTTARGET6),A
               LD   A,255
               LD   (UPTONETARGET6),A
               LD   DE,JPUPSLIDE6
               LD   (JPCOMMAND6),DE

               INC  HL
               JP   NEXTCOMMAND6


DODNSLIDE6:    INC  HL
               LD   A,(HL)
               LD   (DNSPEED6),A
               XOR  A
               LD   (DNOCTTARGET6),A
               LD   (DNTONETARGET6),A
               LD   DE,JPDNSLIDE6
               LD   (JPCOMMAND6),DE

               INC  HL
               JP   NEXTCOMMAND6


DOPORTAMENTO6: INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER6),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   E,A
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   D,A
               LD   A,(BASEOCT6)
               CP   D
               JR   C,PORTAMUP6
               JR   NZ,PORTAMDN6
               LD   A,(BASETONE6)
               CP   E
               JR   C,PORTAMUP6
PORTAMDN6:     LD   A,(HL)
               INC  HL
               LD   (DNSPEED6),A
               LD   A,D
               LD   (DNOCTTARGET6),A
               LD   A,E
               LD   (DNTONETARGET6),A
               LD   DE,JPDNSLIDE6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6

PORTAMUP6:     LD   A,(HL)
               INC  HL
               LD   (UPSPEED6),A
               LD   A,D
               LD   (UPOCTTARGET6),A
               LD   A,E
               LD   (UPTONETARGET6),A
               LD   DE,JPUPSLIDE6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6

DOREPORTAM6:   INC  HL
               LD   A,(HL)
               INC  HL
               LD   (UPSPEED6),A
               LD   (DNSPEED6),A
               JP   NEXTCOMMAND6





DOVIBRATO6:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (VIBRATABLE6),DE
               LD   A,(HL)
               INC  HL
               LD   (VIBRASPEED6),A
               LD   DE,JPVIBRATO6
               LD   (JPCOMMAND6),DE

               JP   NEXTCOMMAND6




DOTREMOLO6:    INC  HL
               LD   E,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
               ADD  VIBRATABLE/256
               LD   D,A
               LD   (TREMOLOTABLE6),DE
               LD   A,(HL)
               INC  HL
               LD   (TREMOLOSPEED6),A
               LD   DE,JPTREMOLO6
               LD   (JPCOMMAND6),DE

               JP   NEXTCOMMAND6

DOCUTCHANNEL6:
               INC  HL
               XOR  A
               LD   (DELAYFLAG6),A
               INC  A
               LD   (DELAY6),A
               LD   DE,AFTERCOMMAND6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6

DODELAYNOTE6:
               INC  HL
               LD   A,(HL)
               INC  HL
               LD   (DELAY6),A
               LD   A,1
               LD   (DELAYFLAG6),A
               LD   DE,AFTERCOMMAND6
               LD   (JPCOMMAND6),DE
               JP   NEXTCOMMAND6


DONOORN6:
               XOR  A
               LD   (ORNLEN6),A
               JP   DONOTE6

DONOORNINS6:   XOR  A
               LD   (ORNLEN6),A
               JP   DONEWINST6

DONEWORN6:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN6),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN6),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR6),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR6+1),A
               INC  DE
               LD   (ORNADDR6),DE
               JP   DONOTE6
DONEWBOTH6:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (ORNLEN6),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPLEN6),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR6),A
               INC  DE
               LD   A,(DE)
               LD   (ORNREPADDR6+1),A
               INC  DE
               LD   (ORNADDR6),DE

DONEWINST6:
               INC  HL
               LD   E,(HL)
               INC  HL
               LD   D,(HL)

               LD   A,(DE)
               LD   (INSTLEN6),A
               INC  DE
               LD   A,(DE)
               LD   (REPLEN6),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR6),A
               INC  DE
               LD   A,(DE)
               LD   (REPADDR6+1),A
               INC  DE
               LD   (INSTADDR6),DE
DONOTE6:
               INC  HL
               LD   A,(HL)
               LD   (NOTENUMBER6),A
               LD   E,A
               LD   D,SEMITONETABLE/256
               LD   A,(DE)
               LD   (BASETONE6),A
               INC  HL
               LD   A,(HL)
               LD   (BASEOCT6),A

INSTLEN6:      EQU  $+1
               LD   A,00
               LD   (PLAYLEN6),A
INSTADDR6:     EQU  $+1
               LD   DE,0000
               LD   (PLAYADDR6),DE

ORNLEN6:       EQU  $+1
               LD   A,00
               LD   (ORNPLAYLEN6),A
ORNADDR6:      EQU  $+1
               LD   DE,0000
               LD   (ORNPLAYADDR6),DE

AFTERCHANGES6:




SKIPSETADDR:   EQU  $+1
               JR   SETADDR
SETADDR:       INC  HL
               LD   (NEXTPLAYADDR),HL
AFTERSETADDR:  XOR  A
               LD   (SKIPSETADDR),A

PATDELAYTEMPO:
TEMPO:         EQU  $+1
               LD   A,00

NOCHANGES:     LD   (DELAY),A


               XOR  A
               LD   L,A
               LD   H,A
               LD   E,A
               EXX

DELAY1:        EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NODELAY1
DELAYFLAG1:    EQU  $+1
               SUB  00
               LD   (DELAY1),A
               LD   A,0
               JP   NZ,AFTERCH1

NODELAY1:


CUTAFTERT1:    EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOCUT1

               DEC  A
               LD   (CUTAFTERT1),A
               JR   NZ,NOCUT1
               LD   (PLAYLEN1),A
NOCUT1:


PLAYLEN1:      EQU  $+1
               LD   A,00
               OR   A
               JP   Z,AFTERCH1
PLAYADDR1:     EQU  $+1
               LD   DE,0000
               LD   HL,4
               ADD  HL,DE

               DEC  A
               JR   NZ,DOCH1
REPADDR1:      EQU  $+1
               LD   HL,0000
REPLEN1:       EQU  $+1
               LD   A,00
DOCH1:         LD   (PLAYLEN1),A

               LD   (PLAYADDR1),HL
               EX   DE,HL


               LD   C,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
BASETONE1:     EQU  $+1
               ADD  00
               LD   E,A

               LD   A,(HL)
               INC  HL
BASEOCT1:      EQU  $+1
               ADC  00
               LD   D,A

               LD   A,(HL)
               LD   L,A
               AND  3
               LD   H,A

               BIT  3,L
               JR   Z,FREQ1
               EXX
               LD   L,1
               EXX
FREQ1:

               BIT  2,L
               JR   Z,NOISE1
               LD   A,H
               EXX
               LD   D,A
               LD   H,1
               EXX
NOISE1:

ORNPLAYLEN1:   EQU  $+1
               LD   A,00
               OR   A
               JR   Z,ENDEDORN1

ORNPLAYADDR1:  EQU  $+1
               LD   HL,0000

               LD   A,(HL)
               INC  HL
NOTENUMBER1:   EQU  $+1
               ADD  00
               LD   (ORNOFFSET1),A
ORNOFFSET1:    EQU  $+1
               LD   A,(ADDORNAMENT)
               ADD  E
               LD   E,A
               LD   A,(HL)
               INC  HL
               ADC  D
               LD   D,A

               LD   A,(ORNPLAYLEN1)
               DEC  A
               JR   NZ,AFTERORN1

ORNREPADDR1:   EQU  $+1
               LD   HL,0000
ORNREPLEN1:    EQU  $+1
               LD   A,00
AFTERORN1:
               LD   (ORNPLAYLEN1),A
               LD   (ORNPLAYADDR1),HL

ENDEDORN1:

JPCOMMAND1:    EQU  $+1
               JP   AFTERCOMMAND1


JPSETVOLUME1:

               LD   A,C
               AND  15
SUBVOLUMEL1:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLL1
               XOR  A
NORESETVOLL1:  LD   L,A
               LD   A,C
               AND  240
SUBVOLUMER1:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLR1
               XOR  A
NORESETVOLR1:  OR   L
               LD   C,A
               JP   AFTERCOMMAND1


JPVIBRATO1:
VIBRATABLE1:   EQU  $+1
               LD   HL,0000
VIBRATIME1:    EQU  $+1
               LD   A,00
VIBRASPEED1:   EQU  $+1
               ADD  00
               AND  63
               LD   (VIBRATIME1),A
               OR   L
               LD   L,A
               LD   A,E
               LD   E,(HL)
               ADD  E
               BIT  7,E
               LD   E,A
               LD   A,D
               JR   Z,OCTAVIBRA1
               CCF
               SBC  0
               LD   D,A
               JP   AFTERCOMMAND1

OCTAVIBRA1:    ADC  0
               LD   D,A
               JP   AFTERCOMMAND1


JPTREMOLO1:
TREMOLOTABLE1: EQU  $+1
               LD   HL,0000
TREMOLOTIME1:  EQU  $+1
               LD   A,00
TREMOLOSPEED1: EQU  $+1
               ADD  00
               AND  63
               LD   (TREMOLOTIME1),A
               OR   L
               LD   L,A

               LD   A,C
               AND  15

               ADD  (HL)
               CP   16
               JR   C,OKAYTLCHAN1
               CP   128
               LD   A,0
               SBC  0
               AND  15
OKAYTLCHAN1:
               LD   (TREMCHAN1),A
               LD   A,C

               RRA
               RRA
               RRA
               RRA

               AND  15
               ADD  (HL)
               CP   16
               JR   C,OKAYTRCHAN1
               CP   128
               LD   A,0
               SBC  0
OKAYTRCHAN1:
               RLA
               RLA
               RLA
               RLA

               AND  240

TREMCHAN1:     EQU  $+1
               OR   00
               LD   C,A

               JP   AFTERCOMMAND1


JPCHORD1_1:
               LD   A,(NOTENUMBER1)
OSCHORD1_1:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,SEMITONETABLE/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD1_1:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD1_2
               LD   (JPCOMMAND1),HL
               JR   AFTERCOMMAND1


JPCHORD1_2:
               LD   A,(NOTENUMBER4)
OSCHORD1_2:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,ADDORNAMENT/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD1_2:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD1_0
               LD   (JPCOMMAND1),HL
               JR   AFTERCOMMAND1


JPCHORD1_0:    LD   HL,JPCHORD1_1
               LD   (JPCOMMAND1),HL
               JR   AFTERCOMMAND1




JPUPSLIDE1:    LD   A,(BASETONE1)
UPSPEED1:      EQU  $+1
               ADD  00
               LD   L,A
               LD   (BASETONE1),A
               LD   A,(BASEOCT1)
               ADC  0
               LD   (BASEOCT1),A
UPOCTTARGET1:  EQU  $+1
               CP   00
UPTONETARGET1: EQU  $+1
               LD   A,00
               JR   C,AFTERCOMMAND1
               JR   NZ,NOTOKAYUP1
               CP   L
               JR   NC,AFTERCOMMAND1

NOTOKAYUP1:
               LD   (BASETONE1),A
               LD   A,(UPOCTTARGET1)
               LD   (BASEOCT1),A

               LD   HL,AFTERCOMMAND1
               LD   (JPCOMMAND1),HL
               JP   (HL)


JPDNSLIDE1:    LD   A,(BASETONE1)
DNSPEED1:      EQU  $+1
               SUB  00
               LD   L,A
               LD   (BASETONE1),A
               LD   A,(BASEOCT1)
               SBC  0
               LD   (BASEOCT1),A
DNOCTTARGET1:  EQU  $+1
               CP   00
DNTONETARGET1: EQU  $+1
               LD   A,00
               JR   C,NOTOKAYDN1
               JR   NZ,AFTERCOMMAND1
               CP   L
               JR   C,AFTERCOMMAND1

NOTOKAYDN1:
               LD   (BASETONE1),A
               LD   A,(DNOCTTARGET1)
               LD   (BASEOCT1),A

               LD   HL,AFTERCOMMAND1
               LD   (JPCOMMAND1),HL
               JP   (HL)



AFTERCOMMAND1:
               LD   A,D
               AND  7
               BIT  3,D
               JR   Z,OKAYTONE1


               XOR  A
               LD   E,A
               BIT  7,D
               JR   NZ,OKAYTONE1

               DEC  E
               LD   A,7

OKAYTONE1:     EXX
               LD   E,A
               EXX

               LD   A,E
               LD   (SOUNDTABLE+6),A

               LD   A,C
AFTERCH1:
               LD   (SOUNDTABLE+0),A



DELAY2:        EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NODELAY2
DELAYFLAG2:    EQU  $+1
               SUB  00
               LD   (DELAY2),A
               LD   A,0
               JP   NZ,AFTERCH2

NODELAY2:

CUTAFTERT2:    EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOCUT2

               DEC  A
               LD   (CUTAFTERT2),A
               JR   NZ,NOCUT2
               LD   (PLAYLEN2),A
NOCUT2:


PLAYLEN2:      EQU  $+1
               LD   A,00
               OR   A
               JP   Z,AFTERCH2
PLAYADDR2:     EQU  $+1
               LD   DE,0000
               LD   HL,4
               ADD  HL,DE

               DEC  A
               JR   NZ,DOCH2
REPADDR2:      EQU  $+1
               LD   HL,0000
REPLEN2:       EQU  $+1
               LD   A,00
DOCH2:         LD   (PLAYLEN2),A

               LD   (PLAYADDR2),HL
               EX   DE,HL


               LD   C,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
BASETONE2:     EQU  $+1
               ADD  00
               LD   E,A

               LD   A,(HL)
               INC  HL
BASEOCT2:      EQU  $+1
               ADC  00
               LD   D,A

               LD   A,(HL)
               LD   L,A
               AND  3
               LD   H,A

               BIT  3,L
               JR   Z,FREQ2
               EXX
               LD   A,L
               OR   2
               LD   L,A
               EXX
FREQ2:

               BIT  2,L
               JR   Z,NOISE2
               LD   A,H
               EXX
               LD   D,A
               LD   A,H
               OR   2
               LD   H,A
               EXX
NOISE2:

ORNPLAYLEN2:   EQU  $+1
               LD   A,00
               OR   A
               JR   Z,ENDEDORN2

ORNPLAYADDR2:  EQU  $+1
               LD   HL,0000

               LD   A,(HL)
               INC  HL
NOTENUMBER2:   EQU  $+1
               ADD  00
               LD   (ORNOFFSET2),A
ORNOFFSET2:    EQU  $+1
               LD   A,(ADDORNAMENT)
               ADD  E
               LD   E,A
               LD   A,(HL)
               INC  HL
               ADC  D
               LD   D,A

               LD   A,(ORNPLAYLEN2)
               DEC  A
               JR   NZ,AFTERORN2

ORNREPADDR2:   EQU  $+1
               LD   HL,0000
ORNREPLEN2:    EQU  $+1
               LD   A,00
AFTERORN2:
               LD   (ORNPLAYLEN2),A
               LD   (ORNPLAYADDR2),HL


ENDEDORN2:

JPCOMMAND2:    EQU  $+1
               JP   AFTERCOMMAND2

JPSETVOLUME2:


               LD   A,C
               AND  15
SUBVOLUMEL2:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLL2
               XOR  A
NORESETVOLL2:  LD   L,A
               LD   A,C
               AND  240
SUBVOLUMER2:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLR2
               XOR  A
NORESETVOLR2:  OR   L
               LD   C,A
               JP   AFTERCOMMAND2
JPVIBRATO2:
VIBRATABLE2:   EQU  $+1
               LD   HL,0000
VIBRATIME2:    EQU  $+1
               LD   A,00
VIBRASPEED2:   EQU  $+1
               ADD  00
               AND  63
               LD   (VIBRATIME2),A
               OR   L
               LD   L,A
               LD   A,E
               LD   E,(HL)
               ADD  E
               BIT  7,E
               LD   E,A
               LD   A,D
               JR   Z,OCTAVIBRA2
               CCF
               SBC  0
               LD   D,A
               JP   AFTERCOMMAND2

OCTAVIBRA2:    ADC  0
               LD   D,A
               JP   AFTERCOMMAND2

JPTREMOLO2:
TREMOLOTABLE2: EQU  $+1
               LD   HL,0000
TREMOLOTIME2:  EQU  $+1
               LD   A,00
TREMOLOSPEED2: EQU  $+1
               ADD  00
               AND  63
               LD   (TREMOLOTIME2),A
               OR   L
               LD   L,A

               LD   A,C
               AND  15

               ADD  (HL)
               CP   16
               JR   C,OKAYTLCHAN2
               CP   128
               LD   A,0
               SBC  0
               AND  15
OKAYTLCHAN2:
               LD   (TREMCHAN2),A
               LD   A,C

               RRA
               RRA
               RRA
               RRA

               AND  15
               ADD  (HL)
               CP   16
               JR   C,OKAYTRCHAN2
               CP   128
               LD   A,0
               SBC  0
OKAYTRCHAN2:
               RLA
               RLA
               RLA
               RLA

               AND  240

TREMCHAN2:     EQU  $+1
               OR   00
               LD   C,A

               JP   AFTERCOMMAND2




JPCHORD2_1:
               LD   A,(NOTENUMBER2)
OSCHORD2_1:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,SEMITONETABLE/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD2_1:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD2_2
               LD   (JPCOMMAND2),HL
               JR   AFTERCOMMAND2

JPCHORD2_2:
               LD   A,(NOTENUMBER2)
OSCHORD2_2:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,ADDORNAMENT/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD2_2:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD2_0
               LD   (JPCOMMAND2),HL
               JR   AFTERCOMMAND2


JPCHORD2_0:    LD   HL,JPCHORD2_1
               LD   (JPCOMMAND2),HL
               JR   AFTERCOMMAND2




JPUPSLIDE2:    LD   A,(BASETONE2)
UPSPEED2:      EQU  $+1
               ADD  00
               LD   L,A
               LD   (BASETONE2),A
               LD   A,(BASEOCT2)
               ADC  0
               LD   (BASEOCT2),A
UPOCTTARGET2:  EQU  $+1
               CP   00
UPTONETARGET2: EQU  $+1
               LD   A,00
               JR   C,AFTERCOMMAND2
               JR   NZ,NOTOKAYUP2
               CP   L
               JR   NC,AFTERCOMMAND2

NOTOKAYUP2:
               LD   (BASETONE2),A
               LD   A,(UPOCTTARGET2)
               LD   (BASEOCT2),A

               LD   HL,AFTERCOMMAND2
               LD   (JPCOMMAND2),HL
               JP   (HL)


JPDNSLIDE2:    LD   A,(BASETONE2)
DNSPEED2:      EQU  $+1
               SUB  00
               LD   L,A
               LD   (BASETONE2),A
               LD   A,(BASEOCT2)
               SBC  0
               LD   (BASEOCT2),A
DNOCTTARGET2:  EQU  $+1
               CP   00
DNTONETARGET2: EQU  $+1
               LD   A,00
               JR   C,NOTOKAYDN2
               JR   NZ,AFTERCOMMAND2
               CP   L
               JR   C,AFTERCOMMAND2

NOTOKAYDN2:
               LD   (BASETONE2),A
               LD   A,(DNOCTTARGET2)
               LD   (BASEOCT2),A

               LD   HL,AFTERCOMMAND2
               LD   (JPCOMMAND2),HL
               JP   (HL)



AFTERCOMMAND2:


               LD   A,D
               AND  7
               BIT  3,D
               JR   Z,OKAYTONE2


               XOR  A
               LD   E,A
               BIT  7,D
               JR   NZ,OKAYTONE2

               DEC  E
               LD   A,7

OKAYTONE2:
               RLCA
               RLCA
               RLCA
               RLCA
               EXX
               OR   E
               LD   E,A
               EXX

               LD   A,E
               LD   (SOUNDTABLE+7),A

               LD   A,C
AFTERCH2:
               LD   (SOUNDTABLE+1),A


               EXX
               LD   A,E
               LD   (SOUNDTABLE+12),A
               LD   E,0
               EXX







DELAY3:        EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NODELAY3
DELAYFLAG3:    EQU  $+1
               SUB  00
               LD   (DELAY3),A
               LD   A,0
               JP   NZ,AFTERCH3

NODELAY3:

CUTAFTERT3:    EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOCUT3

               DEC  A
               LD   (CUTAFTERT3),A
               JR   NZ,NOCUT3
               LD   (PLAYLEN3),A
NOCUT3:


PLAYLEN3:      EQU  $+1
               LD   A,00
               OR   A
               JP   Z,AFTERCH3
PLAYADDR3:     EQU  $+1
               LD   DE,0000
               LD   HL,4
               ADD  HL,DE

               DEC  A
               JR   NZ,DOCH3
REPADDR3:      EQU  $+1
               LD   HL,0000
REPLEN3:       EQU  $+1
               LD   A,00
DOCH3:         LD   (PLAYLEN3),A

               LD   (PLAYADDR3),HL
               EX   DE,HL


               LD   C,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
BASETONE3:     EQU  $+1
               ADD  00
               LD   E,A

               LD   A,(HL)
               INC  HL
BASEOCT3:      EQU  $+1
               ADC  00
               LD   D,A

               LD   A,(HL)
               LD   L,A
               AND  3
               LD   H,A

               BIT  3,L
               JR   Z,FREQ3
               EXX
               LD   A,L
               OR   4
               LD   L,A
               EXX
FREQ3:

               BIT  2,L
               JR   Z,NOISE3
               LD   A,H
               EXX
               LD   D,A
               LD   A,H
               OR   4
               LD   H,A
               EXX
NOISE3:

ORNPLAYLEN3:   EQU  $+1
               LD   A,00
               OR   A
               JR   Z,ENDEDORN3

ORNPLAYADDR3:  EQU  $+1
               LD   HL,0000

               LD   A,(HL)
               INC  HL
NOTENUMBER3:   EQU  $+1
               ADD  00
               LD   (ORNOFFSET3),A
ORNOFFSET3:    EQU  $+1
               LD   A,(ADDORNAMENT)
               ADD  E
               LD   E,A
               LD   A,(HL)
               INC  HL
               ADC  D
               LD   D,A

               LD   A,(ORNPLAYLEN3)
               DEC  A
               JR   NZ,AFTERORN3

ORNREPADDR3:   EQU  $+1
               LD   HL,0000
ORNREPLEN3:    EQU  $+1
               LD   A,00
AFTERORN3:
               LD   (ORNPLAYLEN3),A
               LD   (ORNPLAYADDR3),HL


ENDEDORN3:

JPCOMMAND3:    EQU  $+1
               JP   AFTERCOMMAND3



JPSETVOLUME3:


               LD   A,C
               AND  15
SUBVOLUMEL3:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLL3
               XOR  A
NORESETVOLL3:  LD   L,A
               LD   A,C
               AND  240
SUBVOLUMER3:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLR3
               XOR  A
NORESETVOLR3:  OR   L
               LD   C,A
               JP   AFTERCOMMAND3


JPVIBRATO3:
VIBRATABLE3:   EQU  $+1
               LD   HL,0000
VIBRATIME3:    EQU  $+1
               LD   A,00
VIBRASPEED3:   EQU  $+1
               ADD  00
               AND  63
               LD   (VIBRATIME3),A
               OR   L
               LD   L,A
               LD   A,E
               LD   E,(HL)
               ADD  E
               BIT  7,E
               LD   E,A
               LD   A,D
               JR   Z,OCTAVIBRA3
               CCF
               SBC  0
               LD   D,A
               JP   AFTERCOMMAND3

OCTAVIBRA3:    ADC  0
               LD   D,A
               JP   AFTERCOMMAND3

JPTREMOLO3:
TREMOLOTABLE3: EQU  $+1
               LD   HL,0000
TREMOLOTIME3:  EQU  $+1
               LD   A,00
TREMOLOSPEED3: EQU  $+1
               ADD  00
               AND  63
               LD   (TREMOLOTIME3),A
               OR   L
               LD   L,A

               LD   A,C
               AND  15

               ADD  (HL)
               CP   16
               JR   C,OKAYTLCHAN3
               CP   128
               LD   A,0
               SBC  0
               AND  15
OKAYTLCHAN3:
               LD   (TREMCHAN3),A
               LD   A,C

               RRA
               RRA
               RRA
               RRA

               AND  15
               ADD  (HL)
               CP   16
               JR   C,OKAYTRCHAN3
               CP   128
               LD   A,0
               SBC  0
OKAYTRCHAN3:
               RLA
               RLA
               RLA
               RLA

               AND  240

TREMCHAN3:     EQU  $+1
               OR   00
               LD   C,A

               JP   AFTERCOMMAND3




JPCHORD3_1:
               LD   A,(NOTENUMBER3)
OSCHORD3_1:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,SEMITONETABLE/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD3_1:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD3_2
               LD   (JPCOMMAND3),HL
               JR   AFTERCOMMAND3

JPCHORD3_2:
               LD   A,(NOTENUMBER3)
OSCHORD3_2:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,ADDORNAMENT/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD3_2:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD3_0
               LD   (JPCOMMAND3),HL
               JR   AFTERCOMMAND3



JPCHORD3_0:    LD   HL,JPCHORD3_1
               LD   (JPCOMMAND3),HL
               JR   AFTERCOMMAND3

JPUPSLIDE3:    LD   A,(BASETONE3)
UPSPEED3:      EQU  $+1
               ADD  00
               LD   L,A
               LD   (BASETONE3),A
               LD   A,(BASEOCT3)
               ADC  0
               LD   (BASEOCT3),A
UPOCTTARGET3:  EQU  $+1
               CP   00
UPTONETARGET3: EQU  $+1
               LD   A,00
               JR   C,AFTERCOMMAND3
               JR   NZ,NOTOKAYUP3
               CP   L
               JR   NC,AFTERCOMMAND3

NOTOKAYUP3:
               LD   (BASETONE3),A
               LD   A,(UPOCTTARGET3)
               LD   (BASEOCT3),A

               LD   HL,AFTERCOMMAND3
               LD   (JPCOMMAND3),HL
               JP   (HL)


JPDNSLIDE3:    LD   A,(BASETONE3)
DNSPEED3:      EQU  $+1
               SUB  00
               LD   L,A
               LD   (BASETONE3),A
               LD   A,(BASEOCT3)
               SBC  0
               LD   (BASEOCT3),A
DNOCTTARGET3:  EQU  $+1
               CP   00
DNTONETARGET3: EQU  $+1
               LD   A,00
               JR   C,NOTOKAYDN3
               JR   NZ,AFTERCOMMAND3
               CP   L
               JR   C,AFTERCOMMAND3

NOTOKAYDN3:
               LD   (BASETONE3),A
               LD   A,(DNOCTTARGET3)
               LD   (BASEOCT3),A

               LD   HL,AFTERCOMMAND3
               LD   (JPCOMMAND3),HL
               JP   (HL)




AFTERCOMMAND3:



               LD   A,D
               AND  7

               BIT  3,D
               JR   Z,OKAYTONE3


               XOR  A
               LD   E,A
               BIT  7,D
               JR   NZ,OKAYTONE3

               DEC  E
               LD   A,7

OKAYTONE3:     EXX
               LD   E,A

               EXX

               LD   A,E
               LD   (SOUNDTABLE+8),A

               LD   A,C
AFTERCH3:
               LD   (SOUNDTABLE+2),A



DELAY4:        EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NODELAY4
DELAYFLAG4:    EQU  $+1
               SUB  00
               LD   (DELAY4),A
               LD   A,0
               JP   NZ,AFTERCH4

NODELAY4:

CUTAFTERT4:    EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOCUT4

               DEC  A
               LD   (CUTAFTERT4),A
               JR   NZ,NOCUT4
               LD   (PLAYLEN4),A
NOCUT4:


PLAYLEN4:      EQU  $+1
               LD   A,00
               OR   A
               JP   Z,AFTERCH4
PLAYADDR4:     EQU  $+1
               LD   DE,0000
               LD   HL,4
               ADD  HL,DE

               DEC  A
               JR   NZ,DOCH4
REPADDR4:      EQU  $+1
               LD   HL,0000
REPLEN4:       EQU  $+1
               LD   A,00
DOCH4:         LD   (PLAYLEN4),A

               LD   (PLAYADDR4),HL
               EX   DE,HL


               LD   C,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
BASETONE4:     EQU  $+1
               ADD  00
               LD   E,A

               LD   A,(HL)
               INC  HL
BASEOCT4:      EQU  $+1
               ADC  00
               LD   D,A

               LD   A,(HL)
               LD   L,A
               AND  48
               LD   H,A

               BIT  3,L
               EXX
               JR   Z,FREQ4
               LD   A,L
               OR   8
               LD   L,A

FREQ4:         LD   A,D
               EXX
               BIT  2,L
               JR   Z,NOISE4
               AND  3
               OR   H
               EXX
               LD   D,A
               LD   A,H
               OR   8
               LD   H,A
               EXX
NOISE4:

ORNPLAYLEN4:   EQU  $+1
               LD   A,00
               OR   A
               JR   Z,ENDEDORN4

ORNPLAYADDR4:  EQU  $+1
               LD   HL,0000

               LD   A,(HL)
               INC  HL
NOTENUMBER4:   EQU  $+1
               ADD  00
               LD   (ORNOFFSET4),A
ORNOFFSET4:    EQU  $+1
               LD   A,(ADDORNAMENT)
               ADD  E
               LD   E,A
               LD   A,(HL)
               INC  HL
               ADC  D
               LD   D,A

               LD   A,(ORNPLAYLEN4)
               DEC  A
               JR   NZ,AFTERORN4

ORNREPADDR4:   EQU  $+1
               LD   HL,0000
ORNREPLEN4:    EQU  $+1
               LD   A,00
AFTERORN4:
               LD   (ORNPLAYLEN4),A
               LD   (ORNPLAYADDR4),HL


ENDEDORN4:

JPCOMMAND4:    EQU  $+1
               JP   AFTERCOMMAND4

JPSETVOLUME4:


               LD   A,C
               AND  15
SUBVOLUMEL4:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLL4
               XOR  A
NORESETVOLL4:  LD   L,A
               LD   A,C
               AND  240
SUBVOLUMER4:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLR4
               XOR  A
NORESETVOLR4:  OR   L
               LD   C,A
               JP   AFTERCOMMAND4

JPVIBRATO4:
VIBRATABLE4:   EQU  $+1
               LD   HL,0000
VIBRATIME4:    EQU  $+1
               LD   A,00
VIBRASPEED4:   EQU  $+1
               ADD  00
               AND  63
               LD   (VIBRATIME4),A
               OR   L
               LD   L,A
               LD   A,E
               LD   E,(HL)
               ADD  E
               BIT  7,E
               LD   E,A
               LD   A,D
               JR   Z,OCTAVIBRA4
               CCF
               SBC  0
               LD   D,A
               JP   AFTERCOMMAND4

OCTAVIBRA4:    ADC  0
               LD   D,A
               JP   AFTERCOMMAND4


JPTREMOLO4:
TREMOLOTABLE4: EQU  $+1
               LD   HL,0000
TREMOLOTIME4:  EQU  $+1
               LD   A,00
TREMOLOSPEED4: EQU  $+1
               ADD  00
               AND  63
               LD   (TREMOLOTIME4),A
               OR   L
               LD   L,A

               LD   A,C
               AND  15

               ADD  (HL)
               CP   16
               JR   C,OKAYTLCHAN4
               CP   128
               LD   A,0
               SBC  0
               AND  15
OKAYTLCHAN4:
               LD   (TREMCHAN4),A
               LD   A,C

               RRA
               RRA
               RRA
               RRA

               AND  15
               ADD  (HL)
               CP   16
               JR   C,OKAYTRCHAN4
               CP   128
               LD   A,0
               SBC  0
OKAYTRCHAN4:
               RLA
               RLA
               RLA
               RLA

               AND  240

TREMCHAN4:     EQU  $+1
               OR   00
               LD   C,A

               JP   AFTERCOMMAND4




JPCHORD4_1:
               LD   A,(NOTENUMBER4)
OSCHORD4_1:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,SEMITONETABLE/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD4_1:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD4_2
               LD   (JPCOMMAND4),HL
               JR   AFTERCOMMAND4

JPCHORD4_2:
               LD   A,(NOTENUMBER4)
OSCHORD4_2:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,ADDORNAMENT/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD4_2:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD4_0
               LD   (JPCOMMAND4),HL
               JR   AFTERCOMMAND4


JPCHORD4_0:    LD   HL,JPCHORD4_1
               LD   (JPCOMMAND4),HL
               JR   AFTERCOMMAND4

JPUPSLIDE4:    LD   A,(BASETONE4)
UPSPEED4:      EQU  $+1
               ADD  00
               LD   L,A
               LD   (BASETONE4),A
               LD   A,(BASEOCT4)
               ADC  0
               LD   (BASEOCT4),A
UPOCTTARGET4:  EQU  $+1
               CP   00
UPTONETARGET4: EQU  $+1
               LD   A,00
               JR   C,AFTERCOMMAND4
               JR   NZ,NOTOKAYUP4
               CP   L
               JR   NC,AFTERCOMMAND4

NOTOKAYUP4:
               LD   (BASETONE4),A
               LD   A,(UPOCTTARGET4)
               LD   (BASEOCT4),A

               LD   HL,AFTERCOMMAND4
               LD   (JPCOMMAND4),HL
               JP   (HL)


JPDNSLIDE4:    LD   A,(BASETONE4)
DNSPEED4:      EQU  $+1
               SUB  00
               LD   L,A
               LD   (BASETONE4),A
               LD   A,(BASEOCT4)
               SBC  0
               LD   (BASEOCT4),A
DNOCTTARGET4:  EQU  $+1
               CP   00
DNTONETARGET4: EQU  $+1
               LD   A,00
               JR   C,NOTOKAYDN4
               JR   NZ,AFTERCOMMAND4
               CP   L
               JR   C,AFTERCOMMAND4

NOTOKAYDN4:
               LD   (BASETONE4),A
               LD   A,(DNOCTTARGET4)
               LD   (BASEOCT4),A

               LD   HL,AFTERCOMMAND4
               LD   (JPCOMMAND4),HL
               JP   (HL)




AFTERCOMMAND4:



               LD   A,D
               AND  7
               BIT  3,D
               JR   Z,OKAYTONE4


               XOR  A
               LD   E,A
               BIT  7,D
               JR   NZ,OKAYTONE4

               DEC  E
               LD   A,7

OKAYTONE4:
               RLCA
               RLCA
               RLCA
               RLCA
               EXX
               OR   E
               LD   E,A
               EXX

               LD   A,E
               LD   (SOUNDTABLE+9),A

               LD   A,C
AFTERCH4:
               LD   (SOUNDTABLE+3),A


               EXX
               LD   A,E
               LD   (SOUNDTABLE+13),A
               LD   E,0
               EXX



DELAY5:        EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NODELAY5
DELAYFLAG5:    EQU  $+1
               SUB  00
               LD   (DELAY5),A
               LD   A,0
               JP   NZ,AFTERCH5

NODELAY5:

CUTAFTERT5:    EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOCUT5

               DEC  A
               LD   (CUTAFTERT5),A
               JR   NZ,NOCUT5
               LD   (PLAYLEN5),A
NOCUT5:



PLAYLEN5:      EQU  $+1
               LD   A,00
               OR   A
               JP   Z,AFTERCH5
PLAYADDR5:     EQU  $+1
               LD   DE,0000
               LD   HL,4
               ADD  HL,DE

               DEC  A
               JR   NZ,DOCH5
REPADDR5:      EQU  $+1
               LD   HL,0000
REPLEN5:       EQU  $+1
               LD   A,00
DOCH5:         LD   (PLAYLEN5),A

               LD   (PLAYADDR5),HL
               EX   DE,HL


               LD   C,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
BASETONE5:     EQU  $+1
               ADD  00
               LD   E,A

               LD   A,(HL)
               INC  HL
BASEOCT5:      EQU  $+1
               ADC  00
               LD   D,A

               LD   A,(HL)
               LD   L,A
               AND  3
               LD   H,A

               BIT  3,L
               EXX
               JR   Z,FREQ5
               LD   A,L
               OR   16
               LD   L,A

FREQ5:         LD   A,D
               EXX
               BIT  2,L
               JR   Z,NOISE5
               AND  3
               OR   H
               EXX
               LD   D,A
               LD   A,H
               OR   16
               LD   H,A
               EXX
NOISE5:

ORNPLAYLEN5:   EQU  $+1
               LD   A,00
               OR   A
               JR   Z,ENDEDORN5

ORNPLAYADDR5:  EQU  $+1
               LD   HL,0000

               LD   A,(HL)
               INC  HL
NOTENUMBER5:   EQU  $+1
               ADD  00
               LD   (ORNOFFSET5),A
ORNOFFSET5:    EQU  $+1
               LD   A,(ADDORNAMENT)
               ADD  E
               LD   E,A
               LD   A,(HL)
               INC  HL
               ADC  D
               LD   D,A

               LD   A,(ORNPLAYLEN5)
               DEC  A
               JR   NZ,AFTERORN5

ORNREPADDR5:   EQU  $+1
               LD   HL,0000
ORNREPLEN5:    EQU  $+1
               LD   A,00
AFTERORN5:
               LD   (ORNPLAYLEN5),A
               LD   (ORNPLAYADDR5),HL


ENDEDORN5:

JPCOMMAND5:    EQU  $+1
               JP   AFTERCOMMAND5




JPSETVOLUME5:


               LD   A,C
               AND  15
SUBVOLUMEL5:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLL5
               XOR  A
NORESETVOLL5:  LD   L,A
               LD   A,C
               AND  240
SUBVOLUMER5:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLR5
               XOR  A
NORESETVOLR5:  OR   L
               LD   C,A
               JP   AFTERCOMMAND5

JPVIBRATO5:
VIBRATABLE5:   EQU  $+1
               LD   HL,0000
VIBRATIME5:    EQU  $+1
               LD   A,00
VIBRASPEED5:   EQU  $+1
               ADD  00
               AND  63
               LD   (VIBRATIME5),A
               OR   L
               LD   L,A
               LD   A,E
               LD   E,(HL)
               ADD  E
               BIT  7,E
               LD   E,A
               LD   A,D
               JR   Z,OCTAVIBRA5
               CCF
               SBC  0
               LD   D,A
               JP   AFTERCOMMAND5

OCTAVIBRA5:    ADC  0
               LD   D,A
               JP   AFTERCOMMAND5



JPTREMOLO5:
TREMOLOTABLE5: EQU  $+1
               LD   HL,0000
TREMOLOTIME5:  EQU  $+1
               LD   A,00
TREMOLOSPEED5: EQU  $+1
               ADD  00
               AND  63
               LD   (TREMOLOTIME5),A
               OR   L
               LD   L,A

               LD   A,C
               AND  15

               ADD  (HL)
               CP   16
               JR   C,OKAYTLCHAN5
               CP   128
               LD   A,0
               SBC  0
               AND  15
OKAYTLCHAN5:
               LD   (TREMCHAN5),A
               LD   A,C

               RRA
               RRA
               RRA
               RRA

               AND  15
               ADD  (HL)
               CP   16
               JR   C,OKAYTRCHAN5
               CP   128
               LD   A,0
               SBC  0
OKAYTRCHAN5:
               RLA
               RLA
               RLA
               RLA

               AND  240

TREMCHAN5:     EQU  $+1
               OR   00
               LD   C,A

               JP   AFTERCOMMAND5




JPCHORD5_1:
               LD   A,(NOTENUMBER5)
OSCHORD5_1:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,SEMITONETABLE/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD5_1:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD5_2
               LD   (JPCOMMAND5),HL
               JR   AFTERCOMMAND5

JPCHORD5_2:
               LD   A,(NOTENUMBER5)
OSCHORD5_2:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,ADDORNAMENT/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD5_2:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD5_0
               LD   (JPCOMMAND5),HL
               JR   AFTERCOMMAND5


JPCHORD5_0:    LD   HL,JPCHORD5_1
               LD   (JPCOMMAND5),HL
               JR   AFTERCOMMAND5

JPUPSLIDE5:    LD   A,(BASETONE5)
UPSPEED5:      EQU  $+1
               ADD  00
               LD   L,A
               LD   (BASETONE5),A
               LD   A,(BASEOCT5)
               ADC  0
               LD   (BASEOCT5),A
UPOCTTARGET5:  EQU  $+1
               CP   00
UPTONETARGET5: EQU  $+1
               LD   A,00
               JR   C,AFTERCOMMAND5
               JR   NZ,NOTOKAYUP5
               CP   L
               JR   NC,AFTERCOMMAND5

NOTOKAYUP5:
               LD   (BASETONE5),A
               LD   A,(UPOCTTARGET5)
               LD   (BASEOCT5),A

               LD   HL,AFTERCOMMAND5
               LD   (JPCOMMAND5),HL
               JP   (HL)


JPDNSLIDE5:    LD   A,(BASETONE5)
DNSPEED5:      EQU  $+1
               SUB  00
               LD   L,A
               LD   (BASETONE5),A
               LD   A,(BASEOCT5)
               SBC  0
               LD   (BASEOCT5),A
DNOCTTARGET5:  EQU  $+1
               CP   00
DNTONETARGET5: EQU  $+1
               LD   A,00
               JR   C,NOTOKAYDN5
               JR   NZ,AFTERCOMMAND5
               CP   L
               JR   C,AFTERCOMMAND5

NOTOKAYDN5:
               LD   (BASETONE5),A
               LD   A,(DNOCTTARGET5)
               LD   (BASEOCT5),A

               LD   HL,AFTERCOMMAND5
               LD   (JPCOMMAND5),HL
               JP   (HL)


AFTERCOMMAND5:


               LD   A,D
               AND  7

               BIT  3,D
               JR   Z,OKAYTONE5


               XOR  A
               LD   E,A
               BIT  7,D
               JR   NZ,OKAYTONE5

               DEC  E
               LD   A,7

OKAYTONE5:     EXX
               LD   E,A

               EXX

               LD   A,E
               LD   (SOUNDTABLE+10),A

               LD   A,C
AFTERCH5:
               LD   (SOUNDTABLE+4),A



DELAY6:        EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NODELAY6
DELAYFLAG6:    EQU  $+1
               SUB  00
               LD   (DELAY6),A
               LD   A,0
               JP   NZ,AFTERCH6

NODELAY6:


CUTAFTERT6:    EQU  $+1
               LD   A,00
               OR   A
               JR   Z,NOCUT6

               DEC  A
               LD   (CUTAFTERT6),A
               JR   NZ,NOCUT6
               LD   (PLAYLEN6),A
NOCUT6:


PLAYLEN6:      EQU  $+1
               LD   A,00
               OR   A
               JP   Z,AFTERCH6
PLAYADDR6:     EQU  $+1
               LD   DE,0000
               LD   HL,4
               ADD  HL,DE

               DEC  A
               JR   NZ,DOCH6
REPADDR6:      EQU  $+1
               LD   HL,0000
REPLEN6:       EQU  $+1
               LD   A,00
DOCH6:         LD   (PLAYLEN6),A

               LD   (PLAYADDR6),HL
               EX   DE,HL


               LD   C,(HL)
               INC  HL
               LD   A,(HL)
               INC  HL
BASETONE6:     EQU  $+1
               ADD  00
               LD   E,A

               LD   A,(HL)
               INC  HL
BASEOCT6:      EQU  $+1
               ADC  00
               LD   D,A

               LD   A,(HL)
               LD   L,A
               AND  48
               LD   H,A

               BIT  3,L
               EXX
               JR   Z,FREQ6
               LD   A,L
               OR   32
               LD   L,A

FREQ6:         LD   A,D
               EXX
               BIT  2,L
               JR   Z,NOISE6
               AND  3
               OR   H
               EXX
               LD   D,A
               LD   A,H
               OR   32
               LD   H,A
               EXX
NOISE6:

ORNPLAYLEN6:   EQU  $+1
               LD   A,00
               OR   A
               JR   Z,ENDEDORN6

ORNPLAYADDR6:  EQU  $+1
               LD   HL,0000

               LD   A,(HL)
               INC  HL
NOTENUMBER6:   EQU  $+1
               ADD  00
               LD   (ORNOFFSET6),A
ORNOFFSET6:    EQU  $+1
               LD   A,(ADDORNAMENT)
               ADD  E
               LD   E,A
               LD   A,(HL)
               INC  HL
               ADC  D
               LD   D,A

               LD   A,(ORNPLAYLEN6)
               DEC  A
               JR   NZ,AFTERORN6

ORNREPADDR6:   EQU  $+1
               LD   HL,0000
ORNREPLEN6:    EQU  $+1
               LD   A,00
AFTERORN6:
               LD   (ORNPLAYLEN6),A
               LD   (ORNPLAYADDR6),HL


ENDEDORN6:



JPCOMMAND6:    EQU  $+1
               JP   AFTERCOMMAND6



JPSETVOLUME6:


               LD   A,C
               AND  15
SUBVOLUMEL6:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLL6
               XOR  A
NORESETVOLL6:  LD   L,A
               LD   A,C
               AND  240
SUBVOLUMER6:   EQU  $+1
               SUB  00
               JR   NC,NORESETVOLR6
               XOR  A
NORESETVOLR6:  OR   L
               LD   C,A
               JP   AFTERCOMMAND6


JPVIBRATO6:
VIBRATABLE6:   EQU  $+1
               LD   HL,0000
VIBRATIME6:    EQU  $+1
               LD   A,00
VIBRASPEED6:   EQU  $+1
               ADD  00
               AND  63
               LD   (VIBRATIME6),A
               OR   L
               LD   L,A
               LD   A,E
               LD   E,(HL)
               ADD  E
               BIT  7,E
               LD   E,A
               LD   A,D
               JR   Z,OCTAVIBRA6
               CCF
               SBC  0
               LD   D,A
               JP   AFTERCOMMAND6

OCTAVIBRA6:    ADC  0
               LD   D,A
               JP   AFTERCOMMAND6



JPTREMOLO6:
TREMOLOTABLE6: EQU  $+1
               LD   HL,0000
TREMOLOTIME6:  EQU  $+1
               LD   A,00
TREMOLOSPEED6: EQU  $+1
               ADD  00
               AND  63
               LD   (TREMOLOTIME6),A
               OR   L
               LD   L,A

               LD   A,C
               AND  15

               ADD  (HL)
               CP   16
               JR   C,OKAYTLCHAN6
               CP   128
               LD   A,0
               SBC  0
               AND  15
OKAYTLCHAN6:
               LD   (TREMCHAN6),A
               LD   A,C

               RRA
               RRA
               RRA
               RRA

               AND  15
               ADD  (HL)
               CP   16
               JR   C,OKAYTRCHAN6
               CP   128
               LD   A,0
               SBC  0
OKAYTRCHAN6:
               RLA
               RLA
               RLA
               RLA

               AND  240

TREMCHAN6:     EQU  $+1
               OR   00
               LD   C,A

               JP   AFTERCOMMAND6




JPCHORD6_1:
               LD   A,(NOTENUMBER6)
OSCHORD6_1:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,SEMITONETABLE/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD6_1:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD6_2
               LD   (JPCOMMAND6),HL
               JR   AFTERCOMMAND6

JPCHORD6_2:
               LD   A,(NOTENUMBER6)
OSCHORD6_2:    EQU  $+1
               ADD  00
               LD   L,A
               LD   H,ADDORNAMENT/256
               LD   A,(HL)
               ADD  E
               LD   E,A
               LD   A,D
OCTCHORD6_2:   EQU  $+1
               ADC  00
               LD   D,A
               LD   HL,JPCHORD6_0
               LD   (JPCOMMAND6),HL
               JR   AFTERCOMMAND6

JPCHORD6_0:    LD   HL,JPCHORD6_1
               LD   (JPCOMMAND6),HL
               JR   AFTERCOMMAND6

JPUPSLIDE6:    LD   A,(BASETONE6)
UPSPEED6:      EQU  $+1
               ADD  00
               LD   L,A
               LD   (BASETONE6),A
               LD   A,(BASEOCT6)
               ADC  0
               LD   (BASEOCT6),A
UPOCTTARGET6:  EQU  $+1
               CP   00
UPTONETARGET6: EQU  $+1
               LD   A,00
               JR   C,AFTERCOMMAND6
               JR   NZ,NOTOKAYUP6
               CP   L
               JR   NC,AFTERCOMMAND6

NOTOKAYUP6:
               LD   (BASETONE6),A
               LD   A,(UPOCTTARGET6)
               LD   (BASEOCT6),A

               LD   HL,AFTERCOMMAND6
               LD   (JPCOMMAND6),HL
               JP   (HL)


JPDNSLIDE6:    LD   A,(BASETONE6)
DNSPEED6:      EQU  $+1
               SUB  00
               LD   L,A
               LD   (BASETONE6),A
               LD   A,(BASEOCT6)
               SBC  0
               LD   (BASEOCT6),A
DNOCTTARGET6:  EQU  $+1
               CP   00
DNTONETARGET6: EQU  $+1
               LD   A,00
               JR   C,NOTOKAYDN6
               JR   NZ,AFTERCOMMAND6
               CP   L
               JR   C,AFTERCOMMAND6

NOTOKAYDN6:
               LD   (BASETONE6),A
               LD   A,(DNOCTTARGET6)
               LD   (BASEOCT6),A

               LD   HL,AFTERCOMMAND6
               LD   (JPCOMMAND6),HL
               JP   (HL)





AFTERCOMMAND6:



               LD   A,D
               AND  7
               BIT  3,D
               JR   Z,OKAYTONE6


               XOR  A
               LD   E,A
               BIT  7,D
               JR   NZ,OKAYTONE6

               DEC  E
               LD   A,7

OKAYTONE6:
               RLCA
               RLCA
               RLCA
               RLCA
               EXX
               OR   E
               LD   E,A
               EXX

               LD   A,E
               LD   (SOUNDTABLE+11),A

               LD   A,C
AFTERCH6:
               LD   (SOUNDTABLE+5),A


               EXX
               LD   A,E
               LD   (SOUNDTABLE+14),A

               LD   A,L
               LD   (SOUNDTABLE+15),A
               LD   A,H
               LD   (SOUNDTABLE+16),A
               LD   A,D
               LD   (SOUNDTABLE+17),A

               ; appears in PTCOMPILER source
               EXX

               RET






RPLAYERDASH:   LD   BC,511
               LD   D,28

SILENTLOOP:    OUT  (C),D
               DEC  B
               OUT  (C),B
               INC  B
               DEC  D
               JR   NZ,SILENTLOOP

               OUT  (C),D
               DEC  B
               OUT  (C),B
               INC  B

               LD   A,28
               OUT  (C),A
               DEC  B
               LD   A,1
               OUT  (C),A

               LD   E,(HL)
               INC  HL
               LD   D,(HL)
               INC  HL
               LD   (NEXTSONGPOS),HL
               LD   (NEXTPLAYADDR),DE

               LD   A,1
               LD   (DELAY),A
               LD   A,6
               LD   (TEMPO),A

               XOR  A
               LD   (PLAYLEN1),A
               LD   (INSTLEN1),A
               LD   (ORNPLAYLEN1),A
               LD   (ORNLEN1),A
               LD   (PLAYLEN2),A
               LD   (INSTLEN2),A
               LD   (ORNPLAYLEN2),A
               LD   (ORNLEN2),A
               LD   (PLAYLEN3),A
               LD   (INSTLEN3),A
               LD   (ORNPLAYLEN3),A
               LD   (ORNLEN3),A
               LD   (PLAYLEN4),A
               LD   (INSTLEN4),A
               LD   (ORNPLAYLEN4),A
               LD   (ORNLEN4),A
               LD   (PLAYLEN5),A
               LD   (INSTLEN5),A
               LD   (ORNPLAYLEN5),A
               LD   (ORNLEN5),A
               LD   (PLAYLEN6),A
               LD   (INSTLEN6),A
               LD   (ORNPLAYLEN6),A
               LD   (ORNLEN6),A
               LD   (CUTAFTERT1),A
               LD   (CUTAFTERT2),A
               LD   (CUTAFTERT3),A
               LD   (CUTAFTERT4),A
               LD   (CUTAFTERT5),A
               LD   (CUTAFTERT6),A



               LD   HL,AFTERCOMMAND1
               LD   (JPCOMMAND1),HL
               LD   HL,AFTERCOMMAND2
               LD   (JPCOMMAND2),HL
               LD   HL,AFTERCOMMAND3
               LD   (JPCOMMAND3),HL
               LD   HL,AFTERCOMMAND4
               LD   (JPCOMMAND4),HL
               LD   HL,AFTERCOMMAND5
               LD   (JPCOMMAND5),HL
               LD   HL,AFTERCOMMAND6
               LD   (JPCOMMAND6),HL

               LD   HL,SOUNDTABLE
               LD   (HL),0
               LD   DE,SOUNDTABLE+1
               LD   BC,19
               LDIR

               JP   PLAYROUTINE





               DEFS 256-$\256

VIBRATABLE:    MDAT "VIBRATABLE"


SEMITONETABLE: DEFB 5,33,60,85,109,132,153,173,192,210,227,243
               DEFB 0,0,0,0
ADDORNAMENT:   DEFB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0      ;0
               DEFB 28,27,25,24,23,21,20,19,18,17,16,18  ;1
               DEFB 0,0,0,0
               DEFB 55,52,49,47,44,41,39,37,35,33,34,46  ;2
               DEFB 0,0,0,0
               DEFB 80,76,72,68,64,60,57,54,51,51,63,73  ;3
               DEFB 0,0,0,0
               DEFB 104,99,93,88,83,78,74,70,69,79,89,98 ;4
               DEFB 0,0,0,0
               DEFB 127,120,113,107,101,95,90,88,97,106,114,122
               DEFB 0,0,0,0                              ;5
               DEFB 148,140,132,125,118,111,108,116,124,131,138
               DEFB 145,0,0,0,0                          ;6
               DEFB 168,159,150,142,134,129,136,143,149,155,161
               DEFB 166,0,0,0,0                          ;7
               DEFB 187,177,167,158,152,157,163,168,173,178,182
               DEFB 186,0,0,0,0                          ;8
               DEFB 205,194,183,176,180,184,188,192,196,199,202
               DEFB 205,0,0,0,0                          ;9
               DEFB 222,210,201,204,207,209,212,215,217,219,221
               DEFB 223,0,0,0,0                          ;10
               DEFB 238,228,229,231,232,233,235,236,237,238,239
               DEFB 240,0,0,0,0                          ;11


SOUNDTABLE:    DEFS 20


ENDPLAYER:
PLAYERLENGTH:  EQU  ENDPLAYER-STARTPLAYER
