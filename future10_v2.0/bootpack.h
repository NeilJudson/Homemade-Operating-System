#ifndef BOOTPACKH
#define BOOTPACKH

#define ADR_BOOTINFO	0x00000ff0

struct BOOTINFO {												/* 0x0ff0-0x0fff */
	char cyls;													/* ��������Ӳ�̶����δ�Ϊֹ */
	char leds;													/* ����ʱ����LED��״̬ */
	char vmode;													/* �Կ�ģʽΪ����λ��ɫ */
	char reserve;
	short scrnx, scrny;											/* ����ֱ��� */
	char *vram;
};

#endif
