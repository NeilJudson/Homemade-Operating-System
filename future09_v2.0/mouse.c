#include "bootpack.h"
#include "fifo.h"
#include "int.h"

struct FIFO8 mousefifo;

/* PS/2�����ж� */
void inthandler2c(int *esp)
{
	unsigned char data;
	io_out8(PIC1_OCW2, 0x64);							/* ֪ͨPIC IRQ-12�Ѿ�������� */
	io_out8(PIC0_OCW2, 0x62);							/* ֪ͨPIC IRQ-02�Ѿ�������� */
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&mousefifo, data);
	return;
}

#define KEYCMD_SENDTO_MOUSE		0xd4
#define MOUSECMD_ENABLE			0xf4

/* ������� */
void enable_mouse(struct MOUSE_DEC *mdec)
{
	wait_KBC_sendready();
	io_out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
	wait_KBC_sendready();
	io_out8(PORT_KEYDAT, MOUSECMD_ENABLE);
	mdec->phase = 0;									/* ���뵽�ȴ�����0xfa��״̬ */
	return;												/* ˳���Ļ������̿������᷵�ͻ�ACK(0xfa) */
}

int mouse_decode(struct MOUSE_DEC *mdec, unsigned char dat)
{
	if (mdec->phase == 0) {
		/* �ȴ�����0xfa��״̬ */
		if (dat == 0xfa) {
			mdec->phase = 1;
		}
		return 0;
	}
	if (mdec->phase == 1) {
		/* �ȴ����ĵ�1���ֽ� */
		if ((dat & 0xc8) == 0x08) {						// 11001000
			/* �����һ�ֽ���ȷ */
			mdec->buf[0] = dat;
			mdec->phase = 2;
		}
		return 0;
	}
	if (mdec->phase == 2) {
		/* �ȴ����ĵ�2���ֽ� */
		mdec->buf[1] = dat;
		mdec->phase = 3;
		return 0;
	}
	if (mdec->phase == 3) {
		/* �ȴ����ĵ�3���ֽ� */
		mdec->buf[2] = dat;
		mdec->phase = 1;
		mdec->btn = mdec->buf[0] & 0x07;				// button
		mdec->x = mdec->buf[1];
		mdec->y = mdec->buf[2];
		if ((mdec->buf[0] & 0x10) != 0) {				// Ϊ��������
			mdec->x |= 0xffffff00;
		}
		if ((mdec->buf[0] & 0x20) != 0) {				// Ϊ��������
			mdec->y |= 0xffffff00;
		}
		mdec->y = - mdec->y;							/* ��ת���� */
		return 1;
	}
	return -1;											/* Ӧ�ò��ᵽ�� */
}
