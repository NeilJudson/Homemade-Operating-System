#include "timer.h"
#include "naskfunc.h"
#include "int.h"
#include "mtask.h"

#define PIT_CTRL	0x0043
#define PIT_CNT0	0x0040

struct TIMERCTL timerctl;

#define TIMER_FLAGS_ALLOC	1									/* ������״̬ */
#define TIMER_FLAGS_USING	2									/* ��ʱ�������� */

void init_pit(void)
{
	int i;
	struct TIMER *t;
	io_out8(PIT_CTRL, 0x34);
	io_out8(PIT_CNT0, 0x9c);									// �ж����ڵĵ�8λ
	io_out8(PIT_CNT0, 0x2e);									// �ж����ڵĸ�8λ
	timerctl.count = 0;
	for (i = 0; i < MAX_TIMER; i++) {
		timerctl.timers0[i].flags = 0;							/* δʹ�� */
	}
	t = timer_alloc();											/* ȡ��һ�� */
	t->timeout = 0xffffffff;
	t->flags = TIMER_FLAGS_USING;
	t->nextTimer = 0;											/* ĩβ */
	timerctl.t0 = t;											/* ��Ϊ����ֻ���ڱ���������������ǰ�� */
	timerctl.nextTime = 0xffffffff;								/* ��Ϊֻ���ڱ���������һ����ʱʱ�̾����ڱ���ʱ�� */
	return;
}

struct TIMER *timer_alloc(void)
{
	int i;
	for (i = 0; i < MAX_TIMER; i++) {
		if (timerctl.timers0[i].flags == 0) {
			timerctl.timers0[i].flags = TIMER_FLAGS_ALLOC;
			return &timerctl.timers0[i];
		}
	}
	return 0;													/* û�ҵ� */
}

void timer_free(struct TIMER *timer)
{
	timer->flags = 0;											/* δʹ�� */
	return;
}

void timer_init(struct TIMER *timer, struct FIFO32 *fifo, int data)
{
	timer->fifo = fifo;
	timer->data = data;
	return;
}

void timer_settime(struct TIMER *timer, unsigned int timeout)
{
	int e;
	struct TIMER *t, *s;
	timer->timeout = timeout + timerctl.count;
	timer->flags = TIMER_FLAGS_USING;
	e = io_load_eflags();
	io_cli();
	t = timerctl.t0;
	if (timer->timeout <= t->timeout) {
		/* ������ǰ�������� */
		timerctl.t0 = timer;
		timer->nextTimer = t;									/* ������t */
		timerctl.nextTime = timer->timeout;
		io_store_eflags(e);
		return;
	}
	/* ��Ѱ����λ�� */
	for (;;) {
		s = t;
		t = t->nextTimer;
		if (timer->timeout <= t->timeout) {
			/* ���뵽s��t֮��ʱ */
			s->nextTimer = timer;								/* s����һ����timer */
			timer->nextTimer = t;								/* timer����һ����t */
			io_store_eflags(e);
			return;
		}
	}
}

void inthandler20(int *esp)
{
	struct TIMER *timer;
	char ts = 0;
	io_out8(PIC0_OCW2, 0x60);									/* ��IRQ-00�źŽ������˵���Ϣ֪ͨ��PIC */
	timerctl.count++;
	if (timerctl.nextTime > timerctl.count) {
		return;													/* ��������һ��ʱ�̣����Խ��� */
	}
	timer = timerctl.t0;										/* ���Ȱ���ǰ��ĵ�ַ����timer */
	for (;;) {
		/* timers�Ķ�ʱ�������ڶ����У����Բ�ȷ��flags */
		if (timer->timeout > timerctl.count) {
			break;
		}
		/* ��ʱ */
		timer->flags = TIMER_FLAGS_ALLOC;
		if (timer != mt_timer) {
			fifo32_put(timer->fifo, timer->data);
		} else {
			ts = 1;												/* timer��ʱ */
		}
		timer = timer->nextTimer;								/* ��һ��ʱ���ĵ�ַ����timer */
	}
	/* ����λ */
	timerctl.t0 = timer;
	/* timerctl.nextTime���趨 */
	timerctl.nextTime = timer->timeout;
	if (ts != 0) {
		mt_taskswitch();
	}
	return;
}
