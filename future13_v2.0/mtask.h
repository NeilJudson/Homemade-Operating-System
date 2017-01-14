#include "timer.h"
#include "memory.h"

#ifndef MTASK_H
#define MTASK_H

#define MAX_TASKS		1000									/* ��������� */
#define TASK_GDT0		3										/* �����GDT�ļ��ſ�ʼ�����TSS */

struct TSS32 {
	int backlink, esp0, ss0, esp1, ss1, esp2, ss2, cr3;			// ������������ص���Ϣ
	int eip, eflags, eax, ecx, edx, ebx, esp, ebp, esi, edi;
	int es, cs, ss, ds, fs, gs;
	int ldtr, iomap;
};
struct TASK {
	/*
	* sel��		�������GDT�ı��
	* flags��	��ʾ����״̬��2Ϊ��У�1Ϊ����ʹ�ã�����������״̬��0Ϊδʹ��
	*/
	int sel, flags;
	struct TSS32 tss;
};
struct TASKCTL {
	int running;												/* �������е��������� */
	int now;													/* �������������¼��ǰ�������е����ĸ����� */
	struct TASK *tasks[MAX_TASKS];
	struct TASK tasks0[MAX_TASKS];
};

extern struct TIMER *task_timer;

struct TASK *task_init(struct MEMMAN *memman);
struct TASK *task_alloc(void);
void task_run(struct TASK *task);
void task_switch(void);
void task_sleep(struct TASK *task);

#endif
