#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  panic("Not implemented");
}

char *strcpy(char *dst, const char *src) {
	size_t i = 0;
	while(src[i] != '\0') {
		dst[i] = src[i];
		i++;
	}
	dst[i] = '\0';
	return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
  panic("Not implemented");
}

char *strcat(char *dst, const char *src) {
	size_t i = 0;
	while(dst[i] != '\0') {
		i++;	
	}
	while(*src != '\0') {
		dst[i++] = *src;
		src++;
	}
	dst[i] = '\0';
	return dst;
}

int strcmp(const char *s1, const char *s2) {
	while(*s1 != '\0' && *s2 != '\0') {
		if(*s1 != *s2) {
			return *s1 - *s2;
		}
		s1++;
		s2++;
	}	
	if(*s1 == *s2) return 0;
	return *s1 - *s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  panic("Not implemented");
}

void *memset(void *s, int c, size_t n) {
	unsigned char uc = (unsigned char)c;
	unsigned char *p = s;
	for(int i = 0; i < n; i++) {
		p[i] = uc;
	}
	return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  panic("Not implemented");
}

void *memcpy(void *out, const void *in, size_t n) {
  panic("Not implemented");
}

int memcmp(const void *s1, const void *s2, size_t n) {
	for(int i = 0; n > 0; n--) {
		i = *(char*)s1 - *(char*)s2;
		if(i) {return i;}
		s1 = (char*)s1 + 1;
		s2 = (char*)s2 + 1;
	}
	return 0;
}

#endif
