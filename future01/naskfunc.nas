; naskfunc
; TAB=4

[FORMAT "WCOFF"]				; ����Ŀ���ļ���ģʽ
[INSTRSET "i486p"]				; ��������Ǹ�486�õ�
[BITS 32]						; ����32λģʽ�õĻ�������
[FILE "naskfunc.nas"]			; Դ�ļ�����Ϣ

		; �����а����ĺ�����
		GLOBAL	_io_hlt

[SECTION .text]	; Ŀ���ļ���д����Щ֮����д����

_io_hlt:	; void io_hlt(void);
		HLT
		RET
