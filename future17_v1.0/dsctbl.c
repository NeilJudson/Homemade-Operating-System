/* GDT��IDT��descriptor table����� */

#include "bootpack.h"

void init_gdtidt(void)
{
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) ADR_GDT;
	struct GATE_DESCRIPTOR    *idt = (struct GATE_DESCRIPTOR    *) ADR_IDT;
	int i;

	/* GDT��ʼ�� */
	for (i = 0; i <= LIMIT_GDT / 8; i++) {						// LIMIT_GDTΪ��Ŷ���Ϣ���ڴ���Byte����һ������Ϣ��Ҫ8Byte
		set_segmdesc(gdt + i, 0, 0, 0);
	}
	set_segmdesc(gdt + 1, 0xffffffff,   0x00000000, AR_DATA32_RW); // 1�ŶΣ�4GB����ʾCPU���ܹ����ȫ���ڴ汾��
	set_segmdesc(gdt + 2, LIMIT_BOTPAK, ADR_BOTPAK, AR_CODE32_ER); // 2�ŶΣ�512KB����ַ0x280000�����ú�������bootpack.hrb
	load_gdtr(LIMIT_GDT, ADR_GDT);

	/* IDT��ʼ�� */
	for (i = 0; i <= LIMIT_IDT / 8; i++) {
		set_gatedesc(idt + i, 0, 0, 0);
	}
	load_idtr(LIMIT_IDT, ADR_IDT);

	/* IDT���趨 */
	set_gatedesc(idt + 0x20, (int) asm_inthandler20, 2 * 8, AR_INTGATE32);
	set_gatedesc(idt + 0x21, (int) asm_inthandler21, 2 * 8, AR_INTGATE32); // ��ʾasm_inthandler21������һ�Σ����κ���2����3λ�б�����ã�����Ϊ0
	set_gatedesc(idt + 0x27, (int) asm_inthandler27, 2 * 8, AR_INTGATE32); // AR_INTGATE32 = 0x008e����ʾ���������жϴ������Ч�趨
	set_gatedesc(idt + 0x2c, (int) asm_inthandler2c, 2 * 8, AR_INTGATE32);
	set_gatedesc(idt + 0x40, (int)      asm_fex_api, 2 * 8, AR_INTGATE32); // 0x30-0xff���ǿ��е�

	return;
}

void set_segmdesc(struct SEGMENT_DESCRIPTOR *sd, unsigned int limit, int base, int ar)
{
	/*
	* sd:
	* limit:	�ε��ֽ���-1
	* base:		��ַ
	* ar:		����Ȩ��
	*/
	if (limit > 0xfffff) {
		ar |= 0x8000;											// Gbit��־λΪ1��limit�ĵ�λΪҳ��1ҳָ4KB
		limit /= 0x1000;
	}
	sd->limit_low    = limit & 0xffff;
	sd->limit_high   = ((limit >> 16) & 0x0f) | ((ar >> 8) & 0xf0); // �����Ը�4λд��limit_high�ĸ�4λ
	sd->base_low     = base & 0xffff;
	sd->base_mid     = (base >> 16) & 0xff;
	sd->base_high    = (base >> 24) & 0xff;
	sd->access_right = ar & 0xff;
	return;
}

void set_gatedesc(struct GATE_DESCRIPTOR *gd, int offset, int selector, int ar)
{
	gd->offset_low   = offset & 0xffff;
	gd->offset_high  = (offset >> 16) & 0xffff;
	gd->selector     = selector;
	gd->dw_count     = (ar >> 8) & 0xff;
	gd->access_right = ar & 0xff;
	return;
}
