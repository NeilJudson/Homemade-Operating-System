; naskfunc
; TAB=4

[FORMAT "WCOFF"]				; ����Ŀ���ļ���ģʽ
[INSTRSET "i486p"]				; ��������Ǹ�486�õ�
[BITS 32]						; ����32λģʽ�õĻ�������
[FILE "naskfunc.nas"]			; Դ�ļ�����Ϣ

		; �����а����ĺ�����
		GLOBAL	_io_hlt, _io_cli, _io_sti, _io_stihlt
		GLOBAL	_io_in8,  _io_in16,  _io_in32
		GLOBAL	_io_out8, _io_out16, _io_out32
		GLOBAL	_io_load_eflags, _io_store_eflags
		GLOBAL	_load_gdtr, _load_idtr

[SECTION .text]	; Ŀ���ļ���д����Щ֮����д����



_io_hlt:	; void io_hlt(void);
		HLT
		RET



; ���ж���ɱ�־��Ϊ0����ֹ�ж�
_io_cli:	; void io_cli(void);
		CLI
		RET

_io_sti:	; void io_sti(void);
		STI
		RET



_io_stihlt:	; void io_stihlt(void);
		STI
		HLT
		RET



_io_in8:	; int io_in8(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AL,DX
		RET

_io_in16:	; int io_in16(int port);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,0
		IN		AX,DX
		RET

_io_in32:	; int io_in32(int port);
		MOV		EDX,[ESP+4]		; port
		IN		EAX,DX
		RET

; ��ָ��װ���ﴫ�����ݵĺ���

_io_out8:	; void io_out8(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		AL,[ESP+8]		; data
		OUT		DX,AL
		RET

_io_out16:	; void io_out16(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,AX
		RET

_io_out32:	; void io_out32(int port, int data);
		MOV		EDX,[ESP+4]		; port
		MOV		EAX,[ESP+8]		; data
		OUT		DX,EAX
		RET



; ��¼�ж���ɱ�־��ֵ
_io_load_eflags:	; int io_load_eflags(void);
		PUSHFD		; ָPUSH EFLAGS������־λ��ֵ��˫�ֳ�ѹ��ջ
		POP		EAX
		RET			; ����EAX�е�ֵ

; ��ԭ�ж���ɱ�־
_io_store_eflags:	; void io_store_eflags(int eflags);
		MOV		EAX,[ESP+4]
		PUSH	EAX
		POPFD		; ָPOP EFLAGS����˫�ֳ�����־λ��ջ��������־�Ĵ���
		RET			; ����EAX�е�ֵ



_load_gdtr:		; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX		; С���ֽ���
		LGDT	[ESP+6]			; ��16λ���ƣ�6 �ֽ����ݲ�������2����λ�ֽڣ���32λ��ַ�����ݲ�������4����λ�ֽڣ����ص��Ĵ���
		RET

_load_idtr:		; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET
