; future-os boot asm
; TAB=4

[INSTRSET "i486p"]								; ����Ҫʹ��486ָ�����������Ϊ���ܹ�ʹ��386�Ժ��LGDT��EAX��CR0�ȹؼ��֡�

VBEMODE	EQU		0x105							; 1024x768x8bit��ɫ
; ����ģʽһ��
; 0x100 :  640 x  400 x 8bit��ɫ
; 0x101 :  640 x  480 x 8bit��ɫ
; 0x103 :  800 x  600 x 8bit��ɫ
; 0x105 : 1024 x  768 x 8bit��ɫ
; 0x107 : 1280 x 1024 x 8bit��ɫ

BOTPAK	EQU		0x00280000						; bootpack
DSKCAC	EQU		0x00100000						; ���̻���ĵط�
DSKCAC0	EQU		0x00008000						; ���̻���ĵط�����ʵģʽ��

; BOOT_INFO�����Ϣ���ڴ��еĴ洢��ַ
CYLS	EQU		0x0ff0							; ���д����������
LEDS	EQU		0x0ff1							; ��ż����ϸ���LEDָʾ�Ƶ�״̬
VMODE	EQU		0x0ff2							; �����ɫ��Ŀ����Ϣ����ɫ��λ����
SCRNX	EQU		0x0ff4							; ��ŷֱ��ʵ�X
SCRNY	EQU		0x0ff6							; ��ŷֱ��ʵ�Y
VRAM	EQU		0x0ff8							; ���ͼ�񻺳����Ŀ�ʼ��ַ

		ORG		0xc200							; ָ�������װ�ص�ַ

;===============================================================
; ������ʾģʽ
;===============================================================
; ȷ��VBE�Ƿ����
		MOV		AX,0x9000
		MOV		ES,AX
		MOV		DI,0
		MOV		AX,0x4f00						; ���Կ������õ�VBE��ϢҪд�뵽�ڴ�����ES:DI��ʼ��512�ֽ���
		INT		0x10							; ����0x10�жϣ�AX=0x4f00����
		CMP		AX,0x004f
		JNE		scrn320
; ���VBE�İ汾
		MOV		AX,[ES:DI+4]
		CMP		AX,0x0200
		JB		scrn320							; if (AX < 0x0200) goto scrn320�����VBE�汾����2.0���ϣ��Ͳ���ʹ�ø߷ֱ���
; ȡ�û���ģʽ��Ϣ
		MOV		CX,VBEMODE
		MOV		AX,0x4f01
		INT		0x10							; ����0x10�жϣ�AX=0x4f01����
		CMP		AX,0x004f
		JNE		scrn320
; ����ģʽ��Ϣ��ȷ��
		CMP		BYTE [ES:DI+0x19],8 			; ��ɫ��������Ϊ8
		JNE		scrn320
		CMP		BYTE [ES:DI+0x1b],4 			; ��ɫ��ָ����ʽ������Ϊ4����ɫ��ģʽ��
		JNE		scrn320
		MOV		AX,[ES:DI+0x00]					; ģʽ���ԣ�bit7Ҫ��1
		AND		AX,0x0080
		JZ		scrn320							; ģʽ���Ե�bit7��0�����Է���
; ����ģʽ�л�
		MOV		BX,VBEMODE+0x4000
		MOV		AX,0x4f02
		INT		0x10							; ����0x10�жϣ�AX=0x4f02����
		MOV		BYTE [VMODE],8					; ��¼����ģʽ
		MOV		AX,[ES:DI+0x12]					; X�ķֱ���
		MOV		[SCRNX],AX
		MOV		AX,[ES:DI+0x14]					; Y�ķֱ���
		MOV		[SCRNY],AX
		MOV		EAX,[ES:DI+0x28]				; VRAM�ĵ�ַ
		MOV		[VRAM],EAX
		JMP		keystatus
; 320x200x8bit��ɫģʽ
scrn320:
		MOV		AX,0x0013						; VGAͼ��320x200x8bit��ɫ
		INT		0x10							; ����0x10�жϣ�AX=0x0013����
		MOV		BYTE [VMODE],8					; ��¼����ģʽ
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

;===============================================================
; 
;===============================================================
; ��BIOSȡ�ü����ϸ���LEDָʾ�Ƶ�״̬
keystatus:
		MOV		AH,0x02
		INT		0x16 							; keyboard BIOS
		MOV		[LEDS],AL

; PIC�ر�һ���ж�
;	����AT���ݻ��Ĺ�����Ҫ��ʼ��PIC��������CLI֮ǰ���У�������ʱ�����
;	������PIC�ĳ�ʼ��
		MOV		AL,0xff
		OUT		0x21,AL							; RIC0_IMR����ֹ��PIC��ȫ���ж�
		NOP										; �������ִ��OUTָ���Щ���ֻ��޷���������
		OUT		0xa1,AL							; RIC1_IMR����ֹ��PIC��ȫ���ж�
		CLI										; ��ֹCPU������ж�

; Ϊ����CPU�ܹ�����1MB���ϵ��ڴ�ռ䣬�趨A20GATE
		CALL	waitkbdout
		MOV		AL,0xd1
		OUT		0x64,AL
		CALL	waitkbdout
		MOV		AL,0xdf							; enable A20
		OUT		0x60,AL
		CALL	waitkbdout

; �л�������ģʽ
		LGDT	[GDTR0]							; �趨��ʱGDT��LGDT�����Ǹ�GDTR��ֵ
		MOV		EAX,CR0
		AND		EAX,0x7fffffff					; ��bit31Ϊ0��Ϊ�˽�ֹ��ҳ
		OR		EAX,0x00000001					; ��bit0Ϊ1��Ϊ���л�������ģʽ
		MOV		CR0,EAX
		JMP		pipelineflush					; CPUΪ�˼ӿ�ָ���ִ���ٶȶ�ʹ�ùܵ����ƣ�ǰһ��ָ���ִ��ʱ���Ϳ�ʼ���ͺ���ָ���Ϊģʽ���ˣ���Ҫ���½���һ�飬���Լ���JMPָ�
pipelineflush:
		MOV		AX,1*8							; �ɶ�д�Ķ� 32bit
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX

;===============================================================
; 
;===============================================================
; bootpack�Ĵ���
		MOV		ESI,bootpack					; ת��Դ
		MOV		EDI,BOTPAK						; ת��Ŀ�ĵ�
		MOV		ECX,512*1024/4
		CALL	memcpy
; ������������ת�͵���������λ��ȥ
; �������������Ƶ�1MB����ڴ���
		MOV		ESI,0x7c00						; ת��Դ
		MOV		EDI,DSKCAC						; ת��Ŀ�ĵ�0x100000
		MOV		ECX,512/4
		CALL	memcpy
; ����ʣ�µ�
		MOV		ESI,DSKCAC0+512					; ת��Դ0x8200
		MOV		EDI,DSKCAC+512					; ת��Ŀ�ĵ�0x100200
		MOV		ECX,0
		MOV		CL,BYTE [CYLS]
		IMUL	ECX,512*18*2/4					; ���������任Ϊ�ֽ���/4
		SUB		ECX,512/4						; ��ȥIPL
		CALL	memcpy

; ������asmhead����ɵĹ���������ȫ����ϣ��Ժ�ͽ���bootpack�����

; bootpack������
; ��bootpack.hrb��0x10c8�ֽڿ�ʼ��0x11a8�ֽڸ��Ƶ�0x00310000�ŵ�ַȥ
		MOV		EBX,BOTPAK						; 0x280000
		MOV		ECX,[EBX+16]
		ADD		ECX,3							; ECX += 3;
		SHR		ECX,2							; ECX /= 4;
		JZ		skip							; û��Ҫת�͵Ķ���ʱ
		MOV		ESI,[EBX+20]					; ת��Դ
		ADD		ESI,EBX
		MOV		EDI,[EBX+12]					; ת��Ŀ�ĵ�
		CALL	memcpy
skip:
		MOV		ESP,[EBX+12]					; ջ��ʼֵ
		JMP		DWORD 2*8:0x0000001b			; J: ����ָ������EIP����0x1b��ͬʱ����CS��Ϊ2*8��=16������������JMPĿ���ַ�д�ð�ţ�:���ģ�����farģʽ��JMPָ�0x1b��ʵ����.fex�ļ��е�HariMain�ĵ�ַ��

;===============================================================
; ��������
;===============================================================
waitkbdout:
		IN		AL,0x64
		AND		AL,0x02
		IN		AL,0x60							; �ն���Ϊ��������ݽ��ջ����е���������
		JNZ		waitkbdout						; AND����������0������ת��waitkbdout
		RET

memcpy:
		MOV		EAX,[ESI]
		ADD		ESI,4
		MOV		[EDI],EAX
		ADD		EDI,4
		SUB		ECX,1
		JNZ		memcpy							; ���������������Ϊ0����ת��memcpy
		RET
; memcpy�ϥ��ɥ쥹�������ץ�ե��������������ʤ���С����ȥ������Ǥ������

		ALIGNB	16								; ���߻����򣬱�αָ��������ڴ�����������һ���ܱ�num�����ĵ�ַ��ʼ���䡣
GDT0:											; ���ﻹ��̫��
		RESB	8								; NULL sector��8��Byte
		DW		0xffff,0x0000,0x9200,0x00cf		; ���Զ�д�ĶΣ�segment��32bit
		DW		0xffff,0x0000,0x9a28,0x0047		; ����ִ�еĶΣ�segment��32bit��bootpack�ã�

		DW		0
GDTR0:											; ���ﻹ��̫��
		DW		8*3-1
		DD		GDT0

		ALIGNB	16

;===============================================================
; bootpack
;===============================================================
bootpack:
