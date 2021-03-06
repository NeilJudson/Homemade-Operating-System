; future-os boot asm
; TAB=4

[INSTRSET "i486p"]								; ＾�誨�聞喘486峺綜￣議偃峰��頁葎阻嬬校聞喘386參朔議LGDT��EAX��CR0吉購囚忖。

VBEMODE	EQU		0x105							; 1024x768x8bit科弼
; 鮫中庁塀匯誓
; 0x100 :  640 x  400 x 8bit科弼
; 0x101 :  640 x  480 x 8bit科弼
; 0x103 :  800 x  600 x 8bit科弼
; 0x105 : 1024 x  768 x 8bit科弼
; 0x107 : 1280 x 1024 x 8bit科弼

BOTPAK	EQU		0x00280000						; bootpack
DSKCAC	EQU		0x00100000						; 甘徒産贋議仇圭
DSKCAC0	EQU		0x00008000						; 甘徒産贋議仇圭��寔糞庁塀��

; BOOT_INFO�犢慚渡�壓坪贋嶄議贋刈仇峽
CYLS	EQU		0x0ff0							; 贋慧亟秘議庠中倖方
LEDS	EQU		0x0ff1							; 贋慧囚徒貧光嶽LED峺幣菊議彜蓑
VMODE	EQU		0x0ff2							; 贋慧冲弼方朕議佚連��冲弼議了方。
SCRNX	EQU		0x0ff4							; 贋慧蛍掩楕議X
SCRNY	EQU		0x0ff6							; 贋慧蛍掩楕議Y
VRAM	EQU		0x0ff8							; 贋慧夕�饂些綰�議蝕兵仇峽

		ORG		0xc200							; 峺苧殻會議廾墮仇峽

;===============================================================
; 譜崔�塋渉Ｊ�
;===============================================================
; 鳩範VBE頁倦贋壓
		MOV		AX,0x9000
		MOV		ES,AX
		MOV		DI,0
		MOV		AX,0x4f00						; 緩�埒�嬬旋喘議VBE佚連勣亟秘欺坪贋嶄參ES:DI蝕兵議512忖准嶄
		INT		0x10							; 距喘0x10嶄僅��AX=0x4f00孔嬬
		CMP		AX,0x004f
		JNE		scrn320
; 殊臥VBE議井云
		MOV		AX,[ES:DI+4]
		CMP		AX,0x0200
		JB		scrn320							; if (AX < 0x0200) goto scrn320��泌惚VBE井云音頁2.0參貧��祥音嬬聞喘互蛍掩楕
; 函誼鮫中庁塀佚連
		MOV		CX,VBEMODE
		MOV		AX,0x4f01
		INT		0x10							; 距喘0x10嶄僅��AX=0x4f01孔嬬
		CMP		AX,0x004f
		JNE		scrn320
; 鮫中庁塀佚連議鳩範
		CMP		BYTE [ES:DI+0x19],8 			; 冲弼方��駅倬葎8
		JNE		scrn320
		CMP		BYTE [ES:DI+0x1b],4 			; 冲弼議峺協圭塀��駅倬葎4�┻�弼医庁塀��
		JNE		scrn320
		MOV		AX,[ES:DI+0x00]					; 庁塀奉來��bit7勣頁1
		AND		AX,0x0080
		JZ		scrn320							; 庁塀奉來議bit7頁0��侭參慧虹
; 鮫中庁塀俳算
		MOV		BX,VBEMODE+0x4000
		MOV		AX,0x4f02
		INT		0x10							; 距喘0x10嶄僅��AX=0x4f02孔嬬
		MOV		BYTE [VMODE],8					; 芝村鮫中庁塀
		MOV		AX,[ES:DI+0x12]					; X議蛍掩楕
		MOV		[SCRNX],AX
		MOV		AX,[ES:DI+0x14]					; Y議蛍掩楕
		MOV		[SCRNY],AX
		MOV		EAX,[ES:DI+0x28]				; VRAM議仇峽
		MOV		[VRAM],EAX
		JMP		keystatus
; 320x200x8bit科弼庁塀
scrn320:
		MOV		AX,0x0013						; VGA夕、320x200x8bit科弼
		INT		0x10							; 距喘0x10嶄僅��AX=0x0013孔嬬
		MOV		BYTE [VMODE],8					; 芝村鮫中庁塀
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

;===============================================================
; 
;===============================================================
; 喘BIOS函誼囚徒貧光嶽LED峺幣菊議彜蓑
keystatus:
		MOV		AH,0x02
		INT		0x16 							; keyboard BIOS
		MOV		[LEDS],AL

; PIC購液匯俳嶄僅
;	功象AT惹否字議号鯉��泌惚勣兜兵晒PIC��駅倬壓CLI岻念序佩��倦夸嗤扮氏航軟。
;	昧朔序佩PIC議兜兵晒
		MOV		AL,0xff
		OUT		0x21,AL							; RIC0_IMR��鋤峭麼PIC議畠何嶄僅
		NOP										; 泌惚銭偬峇佩OUT峺綜��嗤乂字嶽氏涙隈屎械塰佩
		OUT		0xa1,AL							; RIC1_IMR��鋤峭貫PIC議畠何嶄僅
		CLI										; 鋤峭CPU雫艶議嶄僅

; 葎阻斑CPU嬬校恵諒1MB參貧議坪贋腎寂��譜協A20GATE
		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf							; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; 俳算欺隠擦庁塀
		LGDT	[GDTR0]							; 譜協匝扮GDT��LGDT恬喘頁公GDTR験峙
		MOV		EAX,CR0
		AND		EAX,0x7fffffff					; 譜bit31葎0��葎阻鋤峭蛍匈
		OR		EAX,0x00000001					; 譜bit0葎1��葎阻俳算欺隠擦庁塀
		MOV		CR0,EAX
		JMP		pipelineflush					; CPU葎阻紗酔峺綜議峇佩堀業遇聞喘砿祇字崙��念匯訳峺綜珊壓峇佩扮��祥蝕兵盾瞥朔偬峺綜。咀葎庁塀延阻��祥勣嶷仟盾瞥匯演��侭參紗秘JMP峺綜。
pipelineflush:
		MOV		AX,1*8							; 辛響亟議粁 32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

;===============================================================
; 
;===============================================================
; bootpack議勧僕
		MOV		ESI,bootpack					; 廬僕坿
		MOV		EDI,BOTPAK						; 廬僕朕議仇
		MOV		ECX,512*1024/4
		CALL	memcpy
; 甘徒方象恷嶮廬僕欺万云栖議了崔肇
; 繍尼強蛭曝鹸崙欺1MB朔議坪贋曝
		MOV		ESI,0x7c00						; 廬僕坿
		MOV		EDI,DSKCAC						; 廬僕朕議仇0x100000
		MOV		ECX,512/4
		CALL	memcpy
; 侭嗤複和議
		MOV		ESI,DSKCAC0+512					; 廬僕坿0x8200
		MOV		EDI,DSKCAC+512					; 廬僕朕議仇0x100200
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4					; 貫庠中方延算葎忖准方/4
		SUB		ECX,512/4						; 受肇IPL
		CALL	memcpy

; 駅倬喇asmhead栖頼撹議垢恬��崛緩畠何頼穎��參朔祥住喇bootpack栖頼撹

; bootpack議尼強
; 繍bootpack.hrb及0x10c8忖准蝕兵議0x11a8忖准鹸崙欺0x00310000催仇峽肇
		MOV		EBX,BOTPAK						; 0x280000
		MOV		ECX,[EBX+16]
		ADD		ECX,3							; ECX += 3;
		SHR		ECX,2							; ECX /= 4;
		JZ		skip							; 短嗤勣廬僕議叫廉扮
		MOV		ESI,[EBX+20]					; 廬僕坿
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]					; 廬僕朕議仇
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]					; 媚兜兵峙
		JMP		DWORD 2*8:0x0000001b			; J: 宸訳峺綜壓��EIP贋秘0x1b議揖扮��繍CS崔葎2*8��=16��。�騁睹�壓JMP朕炎仇峽嶄揮丹催��:��議��祥頁far庁塀議JMP峺綜。

;===============================================================
; 痕方協吶
;===============================================================
waitkbdout:
		IN		AL,0x64
		AND		AL,0x02
		IN		AL,0x60							; 腎響��葎阻賠腎方象俊辺産喝嶄議征侍方象
		JNZ		waitkbdout						; AND潤惚泌惚音頁0��祥柳廬欺waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy							; 受隈塰麻潤惚泌惚音葎0祥柳廬欺memcpy
		RET
; memcpyはアドレスサイズプリフィクスを秘れ梨れなければ、ストリング凋綜でも��ける

		ALIGNB	16								; 御盆祉園殻會��云留峺綜和中議坪贋延楚駅倬貫和匯倖嬬瓜num屁茅議仇峽蝕兵蛍塘。
GDT0:											; 宸戦珊音湊峡
		RESB	8								; NULL sector��8倖Byte
		DW		0xffff,0x0000,0x9200,0x00cf		; 辛參響亟議粁��segment��32bit
		DW		0xffff,0x0000,0x9a28,0x0047		; 辛參峇佩議粁��segment��32bit��bootpack喘��

		DW		0
GDTR0:											; 宸戦珊音湊峡
		DW		8*3-1
		DD		GDT0

		ALIGNB	16

;===============================================================
; bootpack
;===============================================================
bootpack:
