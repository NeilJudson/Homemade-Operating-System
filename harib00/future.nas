; future-os
; TAB=4

		ORG		0xc200			; ָ�������װ�ص�ַ

		MOV		AL,0x13			; VGA�Կ���320x200x8bit��ɫ
		MOV		AH,0x00
		INT		0x10
fin:
		HLT
		JMP		fin
