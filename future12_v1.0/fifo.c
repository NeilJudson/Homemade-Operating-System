#include "bootpack.h"

#define FLAGS_OVERRUN	0x0001

/* ��ʼ��FIFO������ */
void fifo32_init(struct FIFO32 *fifo, int size, int *buf)
{
	fifo->size = size;
	fifo->buf = buf;
	fifo->free = size;											/* �������Ĵ�С */
	fifo->flags = 0;
	fifo->p = 0;												/* ��һ������д��λ�� */
	fifo->q = 0;												/* ��һ�����ݶ���λ�� */
	return;
}

/* ��FIFO�������ݲ����� */
int fifo32_put(struct FIFO32 *fifo, int data)
{
	if (fifo->free == 0) {
		/* ����û���ˣ���� */
		fifo->flags |= FLAGS_OVERRUN;
		return -1;
	}
	fifo->buf[fifo->p] = data;
	fifo->p++;
	if (fifo->p == fifo->size) {
		fifo->p = 0;
	}
	fifo->free--;
	return 0;
}

/* ��FIFOȡ��һ������ */
int fifo32_get(struct FIFO32 *fifo)
{
	int data;
	if (fifo->free == fifo->size) {
		/* ���������Ϊ�գ��򷵻�-1 */
		return -1;
	}
	data = fifo->buf[fifo->q];
	fifo->q++;
	if (fifo->q == fifo->size) {
		fifo->q = 0;
	}
	fifo->free++;
	return data;
}

/* ����һ�»����˶������� */
int fifo32_status(struct FIFO32 *fifo)
{
	return fifo->size - fifo->free;
}