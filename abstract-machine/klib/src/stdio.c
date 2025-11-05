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

static double modf(double num, double *integer_part) {
	uint64_t num_bin;
	memcpy(&num_bin, &num, sizeof(uint64_t));
	int64_t e = ((num_bin >> 52) & 0x7FF) - 1023;
	
	//if num has no decimal part
	if(e >= 52) {
		*integer_part = num;
		return 0.0;
	}
	//if num has no integer part
	if(e < 0) {
		*integer_part = 0.0;
		return num;
	}

	uint64_t mask = ~((1ULL << (52 - e)) - 1);
	uint64_t integer_bits = num_bin & mask;
	memcpy(integer_part, &integer_bits, sizeof(double));
	return num - *integer_part;
}

static char* int2str(int64_t num, char *buffer) {
	//if num is INT64_MIN
	if(num == 0x8000000000000000) {
		strcpy(buffer, "-9223372036854775808");
		return buffer;
	}

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
/*
static void double2str(double num, int dec_place, char *buffer) {
	bool sign = false;
	if(num < 0) {sign = true;}

	int i;
	double integer, decimal;
	decimal = modf(num, &integer);
	
	int64_t int_part = (int64_t)integer;
	if(decimal != 0.0) {
		for(i = 0; i < dec_place; i++) {
			decimal *= 10;
		}
		decimal += (sign == true) ? -0.5 : 0.5;
	}
	int64_t dec_part = (int64_t)decimal;
	
	char buf[64];
	strcpy(buffer, "");
	int2str(int_part, buf);
	strcat(buffer, buf);
	strcat(buffer, ".");
	if(decimal == 0.0) {
		for(i = 0; i < dec_place; i++) {
			strcat(buffer, "0");
		}
	}
	int2str(dec_part, buf);
	if(sign == true) {
		strcat(buffer, &buf[1]);
	}else {
		strcat(buffer, buf);
	}
} */

static void double2str(double num, int dec_place, char *buffer) {
	bool sign = false;
	if(num < 0) {sign = true;}

	int i;
	double integer, decimal;
	decimal = modf(num, &integer);
	
	int64_t int_part = (int64_t)integer;
	if(decimal != 0.0) {
		for(i = 0; i < dec_place; i++) {
			decimal *= 10;
		}
		decimal += (sign == true) ? -0.5 : 0.5;
	}
	int64_t dec_part = (int64_t)decimal;
	
	char buf[64];
	strcpy(buffer, "");
	int2str(int_part, buf);
	strcat(buffer, buf);
	strcat(buffer, ".");
	if(decimal == 0.0) {
		for(i = 0; i < dec_place; i++) {
			strcat(buffer, "0");
		}
	}
	int2str(dec_part, buf);
	if(sign == true) {
		strcat(buffer, &buf[1]);
	}else {
		strcat(buffer, buf);
	}
}

int printf(const char *fmt, ...) {
	va_list args;
	va_start(args, fmt);
	int perc = 0;
	int i, count = 0;
	//int extr_num[2];
	char buf[64];
	for(; *fmt != '\0'; fmt++) {
		if(perc == 1) {
			switch(*fmt) {
				case 'd': 
					int2str(va_arg(args, int), buf);
					for(i = 0; buf[i] != '\0'; i++) {
						count++;
						putch(buf[i]);
					}
					perc = 0;
					break;
				case 's': 
					strcpy(buf, va_arg(args, char*));
					for(i = 0; buf[i] != '\0'; i++) {
						count++;
						putch(buf[i]);
					}
					perc = 0;
					break;
				case 'f':
					/*double2str(va_arg(args, double), 6, buf);
					for(i = 0; buf[i] != '\0'; i++) {
						count++;
						putch(buf[i]);
					}
					perc = 0;*/
					break;
				case '.':
				default: break;
			}
		}else if(*fmt == '%') {
			perc = 1;
		}else {
			count++;
			putch(*fmt);
		}
	}
	va_end(args);	
	return count;	
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
	va_list args;
	va_start(args, fmt);
	int perc = 0;
	int i, count = 0;
	//int extr_num[2];
	char buf[64];
	for(; *fmt != '\0'; fmt++) {
		if(perc == 1) {
			switch(*fmt) {
				case 'd': 
					int2str(va_arg(args, int), buf);
					for(i = 0; buf[i] != '\0'; i++) {
						out[count++] = buf[i];
					}
					perc = 0;
					break;
				case 's': 
					strcpy(buf, va_arg(args, char*));
					for(i = 0; buf[i] != '\0'; i++) {
						out[count++] = buf[i];
					}
					perc = 0;
					break;
				case 'f':
					double2str(va_arg(args, double), 6, buf);
					for(i = 0; buf[i] != '\0'; i++) {
						out[count++] = buf[i];
					}
					perc = 0;
					break;
				case '.':
				default: break;
			}
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
