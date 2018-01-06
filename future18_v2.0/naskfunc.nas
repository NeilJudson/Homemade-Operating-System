; naskfunc
; TAB=4

[FORMAT "WCOFF"]								; ����Ŀ���ļ���ģʽ
[INSTRSET "i486p"]								; ��������Ǹ�486�õ�
[BITS 32]										; ����32λģʽ�õĻ�������
[FILE "naskfunc.nas"]							; Դ�ļ�����Ϣ

		; �����а����ĺ�����
		GLOBAL	_io_hlt, _io_cli, _io_sti, _io_stihlt
		GLOBAL	_io_in8,  _io_in16,  _io_in32
		GLOBAL	_io_out8, _io_out16, _io_out32
		GLOBAL	_io_load_eflags, _io_store_eflags
		GLOBAL	_load_gdtr, _load_idtr
		GLOBAL	_load_cr0, _store_cr0
		GLOBAL	_load_tr
		GLOBAL	_asm_inthandler20, _asm_inthandler21
		GLOBAL	_asm_inthandler27, _asm_inthandler2c
		GLOBAL	_memtest_sub
		GLOBAL	_farjmp, _farcall
		GLOBAL	_asm_fex_api
		EXTERN	_inthandler20, _inthandler21
		EXTERN	_inthandler27, _inthandler2c
		EXTERN	_fex_api

[SECTION .text]									; Ŀ���ļ���д����Щ֮����д����

;===============================================================
;
;===============================================================
_io_hlt:										; void io_hlt(void);
		HLT
		RET

; ���ж����ɱ�־��Ϊ0����ֹ�ж�
_io_cli:										; void io_cli(void);
		CLI										; ���жϱ�־��Ϊ0����ֹ�жϷ���
		RET

_io_sti:										; void io_sti(void);
		STI										; ���жϱ�־��Ϊ1�������жϷ���
		RET

_io_stihlt:										; void io_stihlt(void);
		STI
		HLT
		RET

;===============================================================
; ��ָ��װ�ö�ȡ���ݵĺ���
;===============================================================
_io_in8:										; int io_in8(int port);
		MOV		EDX,[ESP+4]						; port
		MOV		EAX,0
		IN		AL,DX							; ����ֵĬ�϶���AX��
		RET

_io_in16:										; int io_in16(int port);
		MOV		EDX,[ESP+4]						; port
		MOV		EAX,0
		IN		AX,DX
		RET

_io_in32:										; int io_in32(int port);
		MOV		EDX,[ESP+4]						; port
		IN		EAX,DX
		RET

;===============================================================
; ��ָ��װ���ﴫ�����ݵĺ���
;===============================================================
_io_out8:										; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]						; port
		MOV		AL,[ESP+8]						; data
		OUT		DX,AL
		RET

_io_out16:										; void io_out16(int port, int data);
		MOV		EDX,[ESP+4]						; port
		MOV		EAX,[ESP+8]						; data
		OUT		DX,AX
		RET

_io_out32:										; void io_out32(int port, int data);
		MOV		EDX,[ESP+4]						; port
		MOV		EAX,[ESP+8]						; data
		OUT		DX,EAX
		RET

;===============================================================
;
;===============================================================
; ��¼�ж����ɱ�־��ֵ
_io_load_eflags:								; int io_load_eflags(void);
		PUSHFD									; ָPUSH EFLAGS������־λ��ֵ��˫�ֳ�ѹ��ջ
		POP		EAX
		RET										; ����EAX�е�ֵ

; ��ԭ�ж����ɱ�־
_io_store_eflags:								; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD									; ָPOP EFLAGS����˫�ֳ�����־λ��ջ��������־�Ĵ���
		RET										; ����EAX�е�ֵ

_load_gdtr:										; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]						; limit
		MOV		[ESP+6],AX						; С���ֽ���
		LGDT	[ESP+6]							; ��16λ���ƣ�6 �ֽ����ݲ�������2����λ�ֽڣ���32λ��ַ�����ݲ�������4����λ�ֽڣ����ص��Ĵ���
		RET

_load_idtr:										; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]						; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET

_load_cr0:										; int load_cr0(void);
		MOV		EAX,CR0
		RET

_store_cr0:										; void store_cr0(int cr0);
		MOV		EAX,[ESP+4]
		MOV		CR0,EAX
		RET

_load_tr:										; void load_tr(int tr);
		LTR		[ESP+4]							; tr�Ĵ�������������CPU��ס��ǰ����������һ������
		RET

;===============================================================
; �жϳ���
;===============================================================
_asm_inthandler20:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler20
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler21
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler27:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler27
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler2c
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

;===============================================================
;
;===============================================================
_memtest_sub:									; unsigned int memtest_sub(unsigned int start, unsigned int end)
		PUSH	EDI                             ; ��EBX, ESI, EDI ��ʹ�������Τǣ�
		PUSH	ESI
		PUSH	EBX
		MOV		ESI,0xaa55aa55					; pat0 = 0xaa55aa55;
		MOV		EDI,0x55aa55aa					; pat1 = 0x55aa55aa;
		MOV		EAX,[ESP+12+4]					; i = start;
mts_loop:
		MOV		EBX,EAX
		ADD		EBX,0xffc						; p = i + 0xffc;
		MOV		EDX,[EBX]						; old = *p;
		MOV		[EBX],ESI						; *p = pat0;
		XOR		DWORD [EBX],0xffffffff			; *p ^= 0xffffffff;
		CMP		EDI,[EBX]						; if (*p != pat1) goto fin;
		JNE		mts_fin
		XOR		DWORD [EBX],0xffffffff 			; *p ^= 0xffffffff;
		CMP		ESI,[EBX]						; if (*p != pat0) goto fin;
		JNE		mts_fin
		MOV		[EBX],EDX						; *p = old;
		ADD		EAX,0x1000						; i += 0x1000;
		CMP		EAX,[ESP+12+8]					; if (i <= end) goto mts_loop;
		JBE		mts_loop
		POP		EBX
		POP		ESI
		POP		EDI
		RET
mts_fin:
		MOV		[EBX],EDX						; *p = old;
		POP		EBX
		POP		ESI
		POP		EDI
		RET

;===============================================================
;
;===============================================================
_farjmp:                                        ; void farjmp(int eip, int cs);
		JMP		FAR	[ESP+4]						; ��ָ���ڴ��ж�ȡ4���ֽ����ݴ���eip�Ĵ������ټ�����ȡ2���ֽ����ݴ���cs�Ĵ���
		RET

_farcall:                                       ; void farcall(int eip, int cs);
		CALL	FAR	[ESP+4]                     ; eip, cs
		RET

_asm_fex_api:
		STI                                     ; ���жϱ�־��Ϊ1�������жϷ���
		PUSHAD                                  ; ���ڱ���Ĵ���ֵ��PUSH��PUSHADָ��ѹ��32λ�Ĵ���������ջ˳���ǣ�EAX,ECX,EDX,EBX,ESP,EBP,ESI,EDI
		PUSHAD                                  ; ������fex_api��ֵ��PUSH
		CALL	_fex_api
		ADD		ESP,32
		POPAD                                   ; ��ȫ���Ĵ�����ֵ��ԭ
		IRETD                                   ; CALL��RET��FAR-CALL��RETF��INT��IRETD��
