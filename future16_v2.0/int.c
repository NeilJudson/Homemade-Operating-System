/* 中断相关 */

#include <stdio.h>
#include "int.h"
#include "naskfunc.h"

/* PIC初始化 */
void init_pic(void)
{
	io_out8(PIC0_IMR,  0xff);									/* 禁止所有中断 */
	io_out8(PIC1_IMR,  0xff);									/* 禁止所有中断 */

	io_out8(PIC0_ICW1, 0x11);									/* 边沿触发模式 */
	io_out8(PIC0_ICW2, 0x20);									/* IRQ0-7由INT20-27接收 */
	io_out8(PIC0_ICW3, 0x04);									/* PIC1由IRQ2连接 */
	io_out8(PIC0_ICW4, 0x01);									/* 无缓冲区模式 */

	io_out8(PIC1_ICW1, 0x11);									/* 边沿触发模式 */
	io_out8(PIC1_ICW2, 0x28);									/* IRQ8-15由INT28-2f接收 */
	io_out8(PIC1_ICW3, 0x02);									/* PIC1由IRQ2连接 */
	io_out8(PIC1_ICW4, 0x01);									/* 无缓冲区模式 */

	io_out8(PIC0_IMR,  0xfb);									/* 11111011 PIC1以外全部禁止 */
	io_out8(PIC1_IMR,  0xff);									/* 11111111 禁止所有中断 */

	return;
}

void inthandler27(int *esp)
/* PIC0からの不完全割り込み対策 */
/* Athlon64X2機などではチップセットの都合によりPICの初期化時にこの割り込みが1度だけおこる */
/* この割り込み処理関数は、その割り込みに対して何もしないでやり過ごす */
/* なぜ何もしなくていいの？
	→  この割り込みはPIC初期化時の電気的なノイズによって発生したものなので、
		まじめに何か処理してやる必要がない。									*/
{
	io_out8(PIC0_OCW2, 0x67);									/* 通知PIC IRQ-07已经受理完毕 */
	return;
}
