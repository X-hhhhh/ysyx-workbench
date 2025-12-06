#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
	size_t len = 0;
	while(*s != '\0') {
		len++;
		s++;
	}
	return len;
}

char *strcpy(char *dst, const char *src) {
	assert(dst && src);
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
	assert(dst && src);
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
	assert(s1 && s2);
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
	assert(s1 && s2);
	int i;
	for(i = 0; *s1 != '\0' && *s2 != '\0' && i < n; i++) {
		if(*s1 != *s2) {
			return *s1 - *s2;
		}
		s1++;
		s2++;
	}
	if(i == n) return 0;
	return *s1 - *s2;
}

void *memset(void *s, int c, size_t n) {
	assert(s);
	unsigned char uc = (unsigned char)c;
	unsigned char *p = s;
	for(int i = 0; i < n; i++) {
		p[i] = uc;
	}
	return s;
}

void *memmove(void *dst, const void *src, size_t n) {
	assert(dst && src);
	void *ret = dst;
	if(dst < src) {
		while(n--) {
			*(char*)dst = *(char*)src;
			dst = (char*)dst + 1;
			src = (char*)src + 1;
		}
	}else {
		while(n--) {
			*((char*)dst + n - 1) = *((char*)src + n - 1);
		}
	}
	return ret;
}

void *memcpy(void *out, const void *in, size_t n) {
	assert(in && out);
	uint8_t *out_t = out;
	for(int i = 0; i < n; i++) {
		*out_t = *(uint8_t*)in;
		out_t = out_t + 1;
		in = (uint8_t*)in + 1;
	}
	return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
	assert(s1 && s2);
	for(int i = 0; n > 0; n--) {
		i = *(uint8_t*)s1 - *(uint8_t*)s2;
		if(i) {return i;}
		s1 = (uint8_t*)s1 + 1;
		s2 = (uint8_t*)s2 + 1;
	}
	return 0;
}

#endif
