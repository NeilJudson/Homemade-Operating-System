#ifndef TIMERH
#define TIMERH
struct TIMERCTL {
	unsigned int count;
	unsigned int timeout;
	struct FIFO8 *fifo;
	unsigned char data;
};

extern struct TIMERCTL timerctl;

void init_pit(void);
void inthandler20(int *esp);
void settimer(unsigned int timeout, struct FIFO8 *fifo, unsigned char data);
#endif