; future-os boot asm
; TAB=4

BOTPAK	EQU		0x00280000		; bootpack
DSKCAC	EQU		0x00100000		; ���̻���ĵط�
DSKCAC0	EQU		0x00008000		; ���̻���ĵط�����ʵģʽ��

; BOOT_INFO�����Ϣ���ڴ��еĴ洢��ַ
CYLS	EQU		0x0ff0			; ���д����������
LEDS	EQU		0x0ff1			; ��ż����ϸ���LEDָʾ�Ƶ�״̬
VMODE	EQU		0x0ff2			; �����ɫ��Ŀ����Ϣ����ɫ��λ����
SCRNX	EQU		0x0ff4			; ��ŷֱ��ʵ�X
SCRNY	EQU		0x0ff6			; ��ŷֱ��ʵ�Y
VRAM	EQU		0x0ff8			; ���ͼ�񻺳����Ŀ�ʼ��ַ

		ORG		0xc200			; ָ�������װ�ص�ַ

; �趨����ģʽ

		MOV		AL,0x13			; VGA�Կ���320x200x8bit��ɫ
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8	; ��¼����ģʽ
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

; ��BIOSȡ�ü����ϸ���LEDָʾ�Ƶ�״̬

		MOV		AH,0x02
		INT		0x16 			; keyboard BIOS
		MOV		[LEDS],AL

; PIC�ر�һ���ж�
;	����AT���ݻ��Ĺ�����Ҫ��ʼ��PIC��������CLI֮ǰ���У�������ʱ�����
;	������PIC�ĳ�ʼ��

		MOV		AL,0xff
		OUT		0x21,AL
		NOP						; �������ִ��OUTָ���Щ���ֻ��޷���������
		OUT		0xa1,AL

		CLI						; ��ֹCPU������ж�

; Ϊ����CPU�ܹ�����1MB���ϵ��ڴ�ռ䣬�趨A20GATE

		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf			; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; �л�������ģʽ

[INSTRSET "i486p"]				; ����Ҫʹ��486ָ�������

		LGDT	[GDTR0]			; �趨��ʱGDT
		MOV		EAX,CR0
		AND		EAX,0x7fffffff	; ��bit31Ϊ0��Ϊ�˽�ֹ��ҳ
		OR		EAX,0x00000001	; ��bit0Ϊ1��Ϊ���л�������ģʽ
		MOV		CR0,EAX
		JMP		pipelineflush
pipelineflush:
		MOV		AX,1*8			; �ɶ�д�Ķ� 32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

; bootpack�Ĵ���

		MOV		ESI,bootpack	; ת��Դ
		MOV		EDI,BOTPAK		; ת��Ŀ�ĵ�
		MOV		ECX,512*1024/4
		CALL	memcpy

; ������������ת�͵���������λ��ȥ

; �������������Ƶ�1MB����ڴ���
		MOV		ESI,0x7c00		; ת��Դ
		MOV		EDI,DSKCAC		; ת��Ŀ�ĵ�
		MOV		ECX,512/4
		CALL	memcpy
; ����ʣ�µ�
		MOV		ESI,DSKCAC0+512	; ת��Դ
		MOV		EDI,DSKCAC+512	; ת��Ŀ�ĵ�
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4	; ���������任Ϊ�ֽ���/4
		SUB		ECX,512/4		; ��ȥIPL
		CALL	memcpy

; ������asmhead����ɵĹ���������ȫ����ϣ��Ժ�ͽ���bootpack�����

; bootpack������
; ��bootpack.hrb��0x10c8�ֽڿ�ʼ��0x11a8�ֽڸ��Ƶ�0x00310000�ŵ�ַȥ
		MOV		EBX,BOTPAK		; 0x280000
		MOV		ECX,[EBX+16]
		ADD		ECX,3			; ECX += 3;
		SHR		ECX,2			; ECX /= 4;
		JZ		skip			; û��Ҫת�͵Ķ���ʱ
		MOV		ESI,[EBX+20]	; ת��Դ
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]	; ת��Ŀ�ĵ�
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]	; ջ��ʼֵ
		JMP		DWORD 2*8:0x0000001b; J: ����ָ������EIP����0x1b��ͬʱ����CS��Ϊ2*8��=16������������JMPĿ���ַ�д�ð�ţ�:���ģ�����farģʽ��JMPָ�



waitkbdout:
		IN		AL,0x64
		AND		AL,0x02
		IN		AL,0x60			; �ն���Ϊ��������ݽ��ջ����е���������
		JNZ		waitkbdout		; AND����������0������ת��waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy			; ���������������Ϊ0����ת��memcpy
		RET
; memcpy�ϥ��ɥ쥹�������ץ�ե��������������ʤ���С����ȥ������Ǥ������



		ALIGNB	16
GDT0:
		RESB	8							; NULL sector
		DW		0xffff,0x0000,0x9200,0x00cf	; ���Զ�д�ĶΣ�segment��32bit
		DW		0xffff,0x0000,0x9a28,0x0047	; ����ִ�еĶΣ�segment��32bit��bootpack�ã�

		DW		0
GDTR0:
		DW		8*3-1
		DD		GDT0

		ALIGNB	16
bootpack:
