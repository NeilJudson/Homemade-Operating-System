/* 文件相关 */

#include "bootpack.h"

void file_readfat(int *fat, unsigned char *img)
{
	/*
	* 将磁盘映像中的FAT解压缩
	* fat: 解压缩后的FAT的存放地址
	* img: 磁盘映像的FAT在内存中的存放地址
	*/
	int i, j = 0;
	for (i = 0; i < 2880; i += 2) {
		fat[i + 0] = (img[j + 0]      | img[j + 1] << 8) & 0xfff;
		fat[i + 1] = (img[j + 1] >> 4 | img[j + 2] << 4) & 0xfff;
		j += 3;
	}
	return;
}

void file_loadfile(int clustno, int size, char *buf, int *fat, char *img)
{
	/*
	* 将磁盘映像中的文件加载到buf中
	* clustno:  文件所在扇区号
	* size:     文件大小
	* fat:      解压缩后的FAT的存放地址
	* img:      磁盘映像总文件在内存中的存放地址
	*/
	int i;
	for (;;) {
		if (size <= 512) {
			for (i = 0; i < size; i++) {
				buf[i] = img[clustno * 512 + i];
			}
			break;
		}
		for (i = 0; i < 512; i++) {
			buf[i] = img[clustno * 512 + i];
		}
		size -= 512;
		buf += 512;
		clustno = fat[clustno];                                 // 似乎一种链表结构
	}
	return;
}

struct FILEINFO *file_search(char *name, struct FILEINFO *finfo, int max)
{
	/* 准备文件名 */
	int i, j;
	char s[12];
	for (j = 0; j < 11; j++) {
		s[j] = ' ';
	}
	j = 0;
	for (i = 0; name[i] != 0; i++) {
		if (j >= 11) {
			return 0;                                           /* 没有找到 */
		}
		if (name[i] == '.' && j <= 8) {
			j = 8;
		} else {
			s[j] = name[i];
			if ('a' <= s[j] && s[j] <= 'z') {
				/* 将小写字母转换为大写字母 */
				s[j] -= 0x20;
			} 
			j++;
		}
	}
	/* 寻找文件 */
	for (i = 0; i < max; ) {
		if (finfo[i].name[0] == 0x00) {
			break;
		}
		if ((finfo[i].type & 0x18) == 0) {                      // 既不是非文件，也不是目录
			for (j = 0; j < 11; j++) {
				if (finfo[i].name[j] != s[j]) {
					goto next;
				}
			}
			return finfo + i;                                   /* 找到文件 */
		}
	next:
		i++;
	}
	return 0;                                                   /* 没有找到 */
}
