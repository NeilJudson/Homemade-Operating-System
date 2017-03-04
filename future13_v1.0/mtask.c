#include "bootpack.h"

struct TASKCTL *taskctl;
struct TIMER *task_timer;

struct TASK *task_now(void)
{
	/*
	* �������ڻ�е�struct TASK���ڴ��ַ
	*/
	struct TASKLEVEL *tl = &taskctl->level[taskctl->runningLevelId];
	return tl->tasks[tl->runningTaskId];
}

void task_add(struct TASK *task)
{
	/*
	* ��struct TASKLEVEL�����һ������
	*/
	struct TASKLEVEL *tl = &taskctl->level[task->level];
	if(tl->numOfTasks < MAX_TASKS_LV)
	{
		tl->tasks[tl->numOfTasks] = task;
		tl->numOfTasks++;
		task->flag = 2;                                         /* ��� */
		return;
	}
	else
	{
		return;                                                 // ������
	}
}

void task_remove(struct TASK *task)
{
	/*
	* ��struct TASKLEVEL��ɾ��һ������
	*/
	int i;
	struct TASKLEVEL *tl = &taskctl->level[task->level];

	/* Ѱ��task���ڵ�λ�� */
	for (i = 0; i < tl->numOfTasks; i++) {
		if (tl->tasks[i] == task) {
			/* ������ */
			break;
		}
	}

	tl->numOfTasks--;
	if (i < tl->runningTaskId) {
		tl->runningTaskId--;                                    /* ��Ҫ�ƶ���Ա��Ҫ��Ӧ�ش��� */
	}
	if (tl->runningTaskId >= tl->numOfTasks) {
		/* ���now��ֵ�����쳣����������� */
		tl->runningTaskId = 0;
	}
	task->flag = 1;                                             /* ������ */

	/* �ƶ� */
	for (; i < tl->numOfTasks; i++) {
		tl->tasks[i] = tl->tasks[i + 1];
	}

	return;
}

void task_switchsub(void)
{
	/*
	* �����л�ʱ�����������л����Ǹ�LEVEL
	*/
	int i;
	/* Ѱ�����ϲ��LEVEL */
	for (i = 0; i < MAX_TASKLEVELS; i++) {
		if (taskctl->level[i].numOfTasks > 0) {
			break;                                              /* �ҵ��� */
		}
	}
	taskctl->runningLevelId = i;
	taskctl->lv_change = 0;
	return;
}

struct TASK *task_init(struct MEMMAN *memman)
{
	int i;
	struct TASK *task;
	struct SEGMENT_DESCRIPTOR *gdt = (struct SEGMENT_DESCRIPTOR *) ADR_GDT;
	taskctl = (struct TASKCTL *) memman_alloc_4k(memman, sizeof (struct TASKCTL));
	for (i = 0; i < MAX_TASKS; i++) {
		taskctl->tasks0[i].flag = 0;
		taskctl->tasks0[i].gdtId = (TASK_GDT0 + i) * 8;
		set_segmdesc(gdt + TASK_GDT0 + i, 103, (int) &taskctl->tasks0[i].tss, AR_TSS32);
	}
	for (i = 0; i < MAX_TASKLEVELS; i++) {
		taskctl->level[i].numOfTasks = 0;
		taskctl->level[i].runningTaskId = 0;
	}
	task = task_alloc();
	task->flag = 2;                                             /* ��б�־ */
	task->priority = 2;                                         /* 0.02�� */
	task->level = 0;                                            /* ���LEVEL */
	task_add(task);
	task_switchsub();                                           /* ����LEVEL */
	load_tr(task->gdtId);                                       // tr�Ĵ�������������CPU��ס��ǰ����������һ������
	task_timer = timer_alloc();
	/* ����û�б�Ҫʹ��time_init */
	timer_settime(task_timer, task->priority);
	return task;
}

struct TASK *task_alloc(void)
{
	/*
	* ������һ��û��task
	*/
	int i;
	struct TASK *task;
	for (i = 0; i < MAX_TASKS; i++) {
		if (taskctl->tasks0[i].flag == 0) {
			task = &taskctl->tasks0[i];
			task->flag = 1;                                     /* ����ʹ�õı�־ */
			task->tss.eflags = 0x00000202;                      /* IF = 1; */
			task->tss.eax = 0;                                  /* ��������Ϊ0 */
			task->tss.ecx = 0;
			task->tss.edx = 0;
			task->tss.ebx = 0;
			task->tss.ebp = 0;
			task->tss.esi = 0;
			task->tss.edi = 0;
			task->tss.es = 0;
			task->tss.ds = 0;
			task->tss.fs = 0;
			task->tss.gs = 0;
			task->tss.ldtr = 0;
			task->tss.iomap = 0x40000000;
			return task;
		}
	}
	return 0;                                                   /* ȫ������ʹ�� */
}

void task_run(struct TASK *task, int level, int priority)
{
	if (level < 0) {
		level = task->level;                                    /* ���ı�LEVEL */
	}
	if (priority > 0) {
		task->priority = priority;                              // ����������ʱ�ı����ȼ�
	}

	if (task->flag == 2 && task->level != level) {              /* �ı��е�LEVEL */
		task_remove(task);                                      /* ����ִ��֮��flag��ֵ���Ϊ1�����������if����Ҳ�ᱻִ�� */
	}
	if (task->flag != 2) {
		/* ������״̬���ѵ����� */
		task->level = level;
		task_add(task);
	}

	taskctl->lv_change = 1;                                     /* �´������л�ʱ���LEVEL */
	return;
}

void task_sleep(struct TASK *task)
{
	struct TASK *now_task;
	if (task->flag == 2) {										/* ���ָ�������ڻ���״̬ */
		/* ������ڻ״̬ */
		now_task = task_now();
		task_remove(task);                                      /* ִ�д����Ļ�flags����Ϊ1 */
		if (task == now_task) {
			/* ��������Լ����ߣ�����Ҫ���������л� */
			task_switchsub();
			now_task = task_now();                              /* ���趨���ȡ��ǰ�����ֵ */
			farjmp(0, now_task->gdtId);
		}
	}
	return;
}

void task_switch(void)
{
	struct TASKLEVEL *tl = &taskctl->level[taskctl->runningLevelId];
	struct TASK *new_task, *now_task = tl->tasks[tl->runningTaskId];
	tl->runningTaskId++;
	if (tl->runningTaskId == tl->numOfTasks) {
		tl->runningTaskId = 0;
	}
	if (taskctl->lv_change != 0) {
		task_switchsub();
		tl = &taskctl->level[taskctl->runningLevelId];
	}
	new_task = tl->tasks[tl->runningTaskId];
	timer_settime(task_timer, new_task->priority);
	if (new_task != now_task) {
		farjmp(0, new_task->gdtId);
	}
	return;
}
