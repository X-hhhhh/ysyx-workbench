#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static void reverse_string(char *str) {
	int len = strlen(str);
	char temp;
	for(int i = 0; i < len / 2; i++) {
		temp = str[len - 1 - i];
		str[len - 1 - i] = str[i];
		str[i] = temp;
	}
}

static char* int2char(int num, char *buffer) {
	int is_negative = 0;
	char *dst = buffer;
	if(num < 0) {is_negative = 1; num = -num;}
	if(num == 0) {*dst = '0'; dst++; *dst = '\0'; return buffer;}

	while(num > 0) {
		*dst = '0' + num % 10;
		num /= 10;
		dst++;
	}
	
	if(is_negative) {*dst = '-'; dst++;}

	*dst = '\0';
	reverse_string(buffer);
	return buffer;
}

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
	va_list args;
	va_start(args, fmt);
	int perc = 0;
	int i, count = 0;
	char buf[50];
	for(; *fmt != '\0'; fmt++) {
		if(perc == 1) {
			switch(*fmt) {
				case 'd': 
					int2char(va_arg(args, int), buf);
					for(i = 0; buf[i] != '\0'; i++) {
						out[count++] = buf[i];
					}
					break;
				case 's': 
					strcpy(buf, va_arg(args, char*));
					for(i = 0; buf[i] != '\0'; i++) {
						out[count++] = buf[i];
					} 
					break;
				default: break;
			}
			perc = 0;
		}else if(*fmt == '%') {
			perc = 1;
		}else {
			out[count++] = *fmt;
		}
	}
	out[count] = '\0';
	va_end(args);	
	return count;	
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
