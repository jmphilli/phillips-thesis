#define GC_VARIABLE_STACK ((scheme_get_thread_local_variables())->GC_variable_stack_)
#define GET_GC_VARIABLE_STACK() GC_VARIABLE_STACK
#define SET_GC_VARIABLE_STACK(v) (GC_VARIABLE_STACK = (v))
#define PREPARE_VAR_STACK(size) void *__gc_var_stack__[size+2]; __gc_var_stack__[0] = GET_GC_VARIABLE_STACK(); SET_GC_VARIABLE_STACK(__gc_var_stack__);
#define PREPARE_VAR_STACK_ONCE(size) PREPARE_VAR_STACK(size); __gc_var_stack__[1] = (void *)size;
#define SETUP(x) (__gc_var_stack__[1] = (void *)x)
#ifdef MZ_3M_CHECK_VAR_STACK
static int _bad_var_stack_() { *(long *)0x0 = 1; return 0; }
# define CHECK_GC_V_S ((GC_VARIABLE_STACK == __gc_var_stack__) ? 0 : _bad_var_stack_()),
#else
# define CHECK_GC_V_S /*empty*/
#endif
#define FUNCCALL_each(setup, x) (CHECK_GC_V_S setup, x)
#define FUNCCALL_EMPTY_each(x) (SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]), x)
#define FUNCCALL_AGAIN_each(x) (CHECK_GC_V_S x)
#define FUNCCALL_once(setup, x) FUNCCALL_AGAIN_each(x)
#define FUNCCALL_EMPTY_once(x) FUNCCALL_EMPTY_each(x)
#define FUNCCALL_AGAIN_once(x) FUNCCALL_AGAIN_each(x)
#define PUSH(v, x) (__gc_var_stack__[x+2] = (void *)&(v))
#define PUSHARRAY(v, l, x) (__gc_var_stack__[x+2] = (void *)0, __gc_var_stack__[x+3] = (void *)&(v), __gc_var_stack__[x+4] = (void *)l)
#define BLOCK_SETUP_TOP(x) x
#define BLOCK_SETUP_each(x) BLOCK_SETUP_TOP(x)
#define BLOCK_SETUP_once(x) /* no effect */
#define RET_VALUE_START return (__ret__val__ = 
#define RET_VALUE_END , SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]), __ret__val__)
#define RET_VALUE_EMPTY_START return
#define RET_VALUE_EMPTY_END 
#define RET_NOTHING { SET_GC_VARIABLE_STACK((void **)__gc_var_stack__[0]); return; }
#define RET_NOTHING_AT_END RET_NOTHING
#define DECL_RET_SAVE(type) type __ret__val__;
#define NULLED_OUT 0
#define NULL_OUT_ARRAY(a) memset(a, 0, sizeof(a))
#define GC_CAN_IGNORE /**/
#define __xform_nongcing__ /**/
#define HIDE_FROM_XFORM(x) x
#define XFORM_HIDE_EXPR(x) x
#define HIDE_NOTHING_FROM_XFORM() /**/
#define START_XFORM_SKIP /**/
#define END_XFORM_SKIP /**/
#define START_XFORM_SUSPEND /**/
#define END_XFORM_SUSPEND /**/
#define XFORM_START_SKIP /**/
#define XFORM_END_SKIP /**/
#define XFORM_START_SUSPEND /**/
#define XFORM_END_SUSPEND /**/
#define XFORM_SKIP_PROC /**/
#define XFORM_OK_PLUS +
#define XFORM_OK_MINUS -
#define XFORM_TRUST_PLUS +
#define XFORM_TRUST_MINUS -
#define XFORM_OK_ASSIGN /**/

#define NEW_OBJ(t) new (UseGC) t
#define NEW_ARRAY(t, array) (new (UseGC) t array)
#define NEW_ATOM(t) (new (AtomicGC) t)
#define NEW_PTR(t) (new (UseGC) t)
#define NEW_ATOM_ARRAY(t, array) (new (AtomicGC) t array)
#define NEW_PTR_ARRAY(t, array) (new (UseGC) t* array)
#define DELETE(x) (delete x)
#define DELETE_ARRAY(x) (delete[] x)
#define XFORM_RESET_VAR_STACK /* empty */

typedef unsigned char __uint8_t ; 
typedef unsigned short __uint16_t ; 
typedef int __int32_t ; 
typedef unsigned int __uint32_t ; 
typedef long long __int64_t ; 
typedef unsigned long long __uint64_t ; 
typedef long __darwin_intptr_t ; 
typedef unsigned int __darwin_natural_t ; 
typedef int __darwin_ct_rune_t ; 
typedef union {
  char __mbstate8 [128 ] ; 
  long long _mbstateL ; 
}
__mbstate_t ; 
typedef long unsigned int __darwin_size_t ; 
typedef __builtin_va_list __darwin_va_list ; 
typedef int __darwin_wchar_t ; 
typedef __darwin_wchar_t __darwin_rune_t ; 
typedef int __darwin_wint_t ; 
typedef unsigned long __darwin_clock_t ; 
typedef long __darwin_ssize_t ; 
typedef long __darwin_time_t ; 
struct __darwin_pthread_handler_rec {
  void (* __routine ) (void * ) ; 
  void * __arg ; 
  struct __darwin_pthread_handler_rec * __next ; 
}
; 
struct _opaque_pthread_attr_t {
  long __sig ; 
  char __opaque [36 ] ; 
}
; 
struct _opaque_pthread_cond_t {
  long __sig ; 
  char __opaque [24 ] ; 
}
; 
struct _opaque_pthread_condattr_t {
  long __sig ; 
  char __opaque [4 ] ; 
}
; 
struct _opaque_pthread_mutex_t {
  long __sig ; 
  char __opaque [40 ] ; 
}
; 
struct _opaque_pthread_mutexattr_t {
  long __sig ; 
  char __opaque [8 ] ; 
}
; 
struct _opaque_pthread_once_t {
  long __sig ; 
  char __opaque [4 ] ; 
}
; 
struct _opaque_pthread_rwlock_t {
  long __sig ; 
  char __opaque [124 ] ; 
}
; 
struct _opaque_pthread_rwlockattr_t {
  long __sig ; 
  char __opaque [12 ] ; 
}
; 
struct _opaque_pthread_t {
  long __sig ; 
  struct __darwin_pthread_handler_rec * __cleanup_stack ; 
  char __opaque [596 ] ; 
}
; 
typedef __int64_t __darwin_blkcnt_t ; 
typedef __int32_t __darwin_blksize_t ; 
typedef __int32_t __darwin_dev_t ; 
typedef unsigned int __darwin_fsblkcnt_t ; 
typedef unsigned int __darwin_fsfilcnt_t ; 
typedef __uint32_t __darwin_gid_t ; 
typedef __uint32_t __darwin_id_t ; 
typedef __uint64_t __darwin_ino64_t ; 
typedef __darwin_ino64_t __darwin_ino_t ; 
typedef __darwin_natural_t __darwin_mach_port_name_t ; 
typedef __darwin_mach_port_name_t __darwin_mach_port_t ; 
typedef __uint16_t __darwin_mode_t ; 
typedef __int64_t __darwin_off_t ; 
typedef __int32_t __darwin_pid_t ; 
typedef struct _opaque_pthread_attr_t __darwin_pthread_attr_t ; 
typedef struct _opaque_pthread_cond_t __darwin_pthread_cond_t ; 
typedef struct _opaque_pthread_condattr_t __darwin_pthread_condattr_t ; 
typedef unsigned long __darwin_pthread_key_t ; 
typedef struct _opaque_pthread_mutex_t __darwin_pthread_mutex_t ; 
typedef struct _opaque_pthread_mutexattr_t __darwin_pthread_mutexattr_t ; 
typedef struct _opaque_pthread_once_t __darwin_pthread_once_t ; 
typedef struct _opaque_pthread_rwlock_t __darwin_pthread_rwlock_t ; 
typedef struct _opaque_pthread_rwlockattr_t __darwin_pthread_rwlockattr_t ; 
typedef struct _opaque_pthread_t * __darwin_pthread_t ; 
typedef __uint32_t __darwin_sigset_t ; 
typedef __int32_t __darwin_suseconds_t ; 
typedef __uint32_t __darwin_uid_t ; 
typedef __uint32_t __darwin_useconds_t ; 
typedef unsigned char __darwin_uuid_t [16 ] ; 
typedef char __darwin_uuid_string_t [37 ] ; 
typedef __darwin_va_list va_list ; 
typedef __darwin_off_t off_t ; 
typedef __darwin_size_t size_t ; 
typedef __darwin_off_t fpos_t ; 
struct __sbuf {
  unsigned char * _base ; 
  int _size ; 
}
; 
struct __sFILEX ; 
typedef struct __sFILE {
  unsigned char * _p ; 
  int _r ; 
  int _w ; 
  short _flags ; 
  short _file ; 
  struct __sbuf _bf ; 
  int _lbfsize ; 
  void * _cookie ; 
  int (* _close ) (void * ) ; 
  int (* _read ) (void * , char * , int ) ; 
  fpos_t (* _seek ) (void * , fpos_t , int ) ; 
  int (* _write ) (void * , const char * , int ) ; 
  struct __sbuf _ub ; 
  struct __sFILEX * _extra ; 
  int _ur ; 
  unsigned char _ubuf [3 ] ; 
  unsigned char _nbuf [1 ] ; 
  struct __sbuf _lb ; 
  int _blksize ; 
  fpos_t _offset ; 
}
FILE ; 
extern const char * const sys_errlist [] ; 
int printf (const char * , ... ) ; 
char * ctermid (char * ) ; 
int __swbuf (int , FILE * ) ; 
static __inline int __sputc (int _c , FILE * _p ) {
  if (-- _p -> _w >= 0 || (_p -> _w >= _p -> _lbfsize && (char ) _c != '\n' ) )
    return (* _p -> _p ++ = _c ) ; 
  else return (__swbuf (_c , _p ) ) ; 
}
typedef int jmp_buf [(18 ) ] ; 
typedef int sigjmp_buf [(18 ) + 1 ] ; 
typedef enum {
  P_ALL , P_PID , P_PGID }
idtype_t ; 
typedef __darwin_pid_t pid_t ; 
typedef __darwin_id_t id_t ; 
struct __darwin_i386_thread_state {
  unsigned int __eax ; 
  unsigned int __ebx ; 
  unsigned int __ecx ; 
  unsigned int __edx ; 
  unsigned int __edi ; 
  unsigned int __esi ; 
  unsigned int __ebp ; 
  unsigned int __esp ; 
  unsigned int __ss ; 
  unsigned int __eflags ; 
  unsigned int __eip ; 
  unsigned int __cs ; 
  unsigned int __ds ; 
  unsigned int __es ; 
  unsigned int __fs ; 
  unsigned int __gs ; 
}
; 
struct __darwin_fp_control {
  unsigned short __invalid : 1 , __denorm : 1 , __zdiv : 1 , __ovrfl : 1 , __undfl : 1 , __precis : 1 , : 2 , __pc : 2 , __rc : 2 , : 1 , : 3 ; 
}
; 
struct __darwin_fp_status {
  unsigned short __invalid : 1 , __denorm : 1 , __zdiv : 1 , __ovrfl : 1 , __undfl : 1 , __precis : 1 , __stkflt : 1 , __errsumm : 1 , __c0 : 1 , __c1 : 1 , __c2 : 1 , __tos : 3 , __c3 : 1 , __busy : 1 ; 
}
; 
struct __darwin_mmst_reg {
  char __mmst_reg [10 ] ; 
  char __mmst_rsrv [6 ] ; 
}
; 
struct __darwin_xmm_reg {
  char __xmm_reg [16 ] ; 
}
; 
struct __darwin_i386_float_state {
  int __fpu_reserved [2 ] ; 
  struct __darwin_fp_control __fpu_fcw ; 
  struct __darwin_fp_status __fpu_fsw ; 
  __uint8_t __fpu_ftw ; 
  __uint8_t __fpu_rsrv1 ; 
  __uint16_t __fpu_fop ; 
  __uint32_t __fpu_ip ; 
  __uint16_t __fpu_cs ; 
  __uint16_t __fpu_rsrv2 ; 
  __uint32_t __fpu_dp ; 
  __uint16_t __fpu_ds ; 
  __uint16_t __fpu_rsrv3 ; 
  __uint32_t __fpu_mxcsr ; 
  __uint32_t __fpu_mxcsrmask ; 
  struct __darwin_mmst_reg __fpu_stmm0 ; 
  struct __darwin_mmst_reg __fpu_stmm1 ; 
  struct __darwin_mmst_reg __fpu_stmm2 ; 
  struct __darwin_mmst_reg __fpu_stmm3 ; 
  struct __darwin_mmst_reg __fpu_stmm4 ; 
  struct __darwin_mmst_reg __fpu_stmm5 ; 
  struct __darwin_mmst_reg __fpu_stmm6 ; 
  struct __darwin_mmst_reg __fpu_stmm7 ; 
  struct __darwin_xmm_reg __fpu_xmm0 ; 
  struct __darwin_xmm_reg __fpu_xmm1 ; 
  struct __darwin_xmm_reg __fpu_xmm2 ; 
  struct __darwin_xmm_reg __fpu_xmm3 ; 
  struct __darwin_xmm_reg __fpu_xmm4 ; 
  struct __darwin_xmm_reg __fpu_xmm5 ; 
  struct __darwin_xmm_reg __fpu_xmm6 ; 
  struct __darwin_xmm_reg __fpu_xmm7 ; 
  char __fpu_rsrv4 [14 * 16 ] ; 
  int __fpu_reserved1 ; 
}
; 
struct __darwin_i386_exception_state {
  unsigned int __trapno ; 
  unsigned int __err ; 
  unsigned int __faultvaddr ; 
}
; 
struct __darwin_x86_debug_state32 {
  unsigned int __dr0 ; 
  unsigned int __dr1 ; 
  unsigned int __dr2 ; 
  unsigned int __dr3 ; 
  unsigned int __dr4 ; 
  unsigned int __dr5 ; 
  unsigned int __dr6 ; 
  unsigned int __dr7 ; 
}
; 
struct __darwin_x86_thread_state64 {
  __uint64_t __rax ; 
  __uint64_t __rbx ; 
  __uint64_t __rcx ; 
  __uint64_t __rdx ; 
  __uint64_t __rdi ; 
  __uint64_t __rsi ; 
  __uint64_t __rbp ; 
  __uint64_t __rsp ; 
  __uint64_t __r8 ; 
  __uint64_t __r9 ; 
  __uint64_t __r10 ; 
  __uint64_t __r11 ; 
  __uint64_t __r12 ; 
  __uint64_t __r13 ; 
  __uint64_t __r14 ; 
  __uint64_t __r15 ; 
  __uint64_t __rip ; 
  __uint64_t __rflags ; 
  __uint64_t __cs ; 
  __uint64_t __fs ; 
  __uint64_t __gs ; 
}
; 
struct __darwin_x86_float_state64 {
  int __fpu_reserved [2 ] ; 
  struct __darwin_fp_control __fpu_fcw ; 
  struct __darwin_fp_status __fpu_fsw ; 
  __uint8_t __fpu_ftw ; 
  __uint8_t __fpu_rsrv1 ; 
  __uint16_t __fpu_fop ; 
  __uint32_t __fpu_ip ; 
  __uint16_t __fpu_cs ; 
  __uint16_t __fpu_rsrv2 ; 
  __uint32_t __fpu_dp ; 
  __uint16_t __fpu_ds ; 
  __uint16_t __fpu_rsrv3 ; 
  __uint32_t __fpu_mxcsr ; 
  __uint32_t __fpu_mxcsrmask ; 
  struct __darwin_mmst_reg __fpu_stmm0 ; 
  struct __darwin_mmst_reg __fpu_stmm1 ; 
  struct __darwin_mmst_reg __fpu_stmm2 ; 
  struct __darwin_mmst_reg __fpu_stmm3 ; 
  struct __darwin_mmst_reg __fpu_stmm4 ; 
  struct __darwin_mmst_reg __fpu_stmm5 ; 
  struct __darwin_mmst_reg __fpu_stmm6 ; 
  struct __darwin_mmst_reg __fpu_stmm7 ; 
  struct __darwin_xmm_reg __fpu_xmm0 ; 
  struct __darwin_xmm_reg __fpu_xmm1 ; 
  struct __darwin_xmm_reg __fpu_xmm2 ; 
  struct __darwin_xmm_reg __fpu_xmm3 ; 
  struct __darwin_xmm_reg __fpu_xmm4 ; 
  struct __darwin_xmm_reg __fpu_xmm5 ; 
  struct __darwin_xmm_reg __fpu_xmm6 ; 
  struct __darwin_xmm_reg __fpu_xmm7 ; 
  struct __darwin_xmm_reg __fpu_xmm8 ; 
  struct __darwin_xmm_reg __fpu_xmm9 ; 
  struct __darwin_xmm_reg __fpu_xmm10 ; 
  struct __darwin_xmm_reg __fpu_xmm11 ; 
  struct __darwin_xmm_reg __fpu_xmm12 ; 
  struct __darwin_xmm_reg __fpu_xmm13 ; 
  struct __darwin_xmm_reg __fpu_xmm14 ; 
  struct __darwin_xmm_reg __fpu_xmm15 ; 
  char __fpu_rsrv4 [6 * 16 ] ; 
  int __fpu_reserved1 ; 
}
; 
struct __darwin_x86_exception_state64 {
  unsigned int __trapno ; 
  unsigned int __err ; 
  __uint64_t __faultvaddr ; 
}
; 
struct __darwin_x86_debug_state64 {
  __uint64_t __dr0 ; 
  __uint64_t __dr1 ; 
  __uint64_t __dr2 ; 
  __uint64_t __dr3 ; 
  __uint64_t __dr4 ; 
  __uint64_t __dr5 ; 
  __uint64_t __dr6 ; 
  __uint64_t __dr7 ; 
}
; 
struct __darwin_mcontext32 {
  struct __darwin_i386_exception_state __es ; 
  struct __darwin_i386_thread_state __ss ; 
  struct __darwin_i386_float_state __fs ; 
}
; 
struct __darwin_mcontext64 {
  struct __darwin_x86_exception_state64 __es ; 
  struct __darwin_x86_thread_state64 __ss ; 
  struct __darwin_x86_float_state64 __fs ; 
}
; 
struct __darwin_sigaltstack {
  void * ss_sp ; 
  __darwin_size_t ss_size ; 
  int ss_flags ; 
}
; 
struct __darwin_ucontext {
  int uc_onstack ; 
  __darwin_sigset_t uc_sigmask ; 
  struct __darwin_sigaltstack uc_stack ; 
  struct __darwin_ucontext * uc_link ; 
  __darwin_size_t uc_mcsize ; 
  struct __darwin_mcontext32 * uc_mcontext ; 
}
; 
typedef struct __darwin_sigaltstack stack_t ; 
typedef __darwin_pthread_attr_t pthread_attr_t ; 
typedef __darwin_sigset_t sigset_t ; 
typedef __darwin_uid_t uid_t ; 
union sigval {
  int sival_int ; 
  void * sival_ptr ; 
}
; 
struct sigevent {
  int sigev_notify ; 
  int sigev_signo ; 
  union sigval sigev_value ; 
  void (* sigev_notify_function ) (union sigval ) ; 
  pthread_attr_t * sigev_notify_attributes ; 
}
; 
typedef struct __siginfo {
  int si_signo ; 
  int si_errno ; 
  int si_code ; 
  pid_t si_pid ; 
  uid_t si_uid ; 
  int si_status ; 
  void * si_addr ; 
  union sigval si_value ; 
  long si_band ; 
  unsigned long __pad [7 ] ; 
}
siginfo_t ; 
union __sigaction_u {
  void (* __sa_handler ) (int ) ; 
  void (* __sa_sigaction ) (int , struct __siginfo * , void * ) ; 
}
; 
struct __sigaction {
  union __sigaction_u __sigaction_u ; 
  void (* sa_tramp ) (void * , int , int , siginfo_t * , void * ) ; 
  sigset_t sa_mask ; 
  int sa_flags ; 
}
; 
struct sigaction {
  union __sigaction_u __sigaction_u ; 
  sigset_t sa_mask ; 
  int sa_flags ; 
}
; 
typedef void (* sig_t ) (int ) ; 
struct sigvec {
  void (* sv_handler ) (int ) ; 
  int sv_mask ; 
  int sv_flags ; 
}
; 
struct sigstack {
  char * ss_sp ; 
  int ss_onstack ; 
}
; 
void (* signal (int , void (* ) (int ) ) ) (int ) ; 
struct timeval {
  __darwin_time_t tv_sec ; 
  __darwin_suseconds_t tv_usec ; 
}
; 
typedef __uint64_t rlim_t ; 
struct rusage {
  struct timeval ru_utime ; 
  struct timeval ru_stime ; 
  long ru_maxrss ; 
  long ru_ixrss ; 
  long ru_idrss ; 
  long ru_isrss ; 
  long ru_minflt ; 
  long ru_majflt ; 
  long ru_nswap ; 
  long ru_inblock ; 
  long ru_oublock ; 
  long ru_msgsnd ; 
  long ru_msgrcv ; 
  long ru_nsignals ; 
  long ru_nvcsw ; 
  long ru_nivcsw ; 
}
; 
struct rlimit {
  rlim_t rlim_cur ; 
  rlim_t rlim_max ; 
}
; 
static __inline__ __uint16_t _OSSwapInt16 (__uint16_t _data ) {
  return ((_data << 8 ) | (_data >> 8 ) ) ; 
}
static __inline__ __uint32_t _OSSwapInt32 (__uint32_t _data ) {
  __asm__ ("bswap   %0" : "+r" (_data ) ) ; 
  return _data ; 
}
static __inline__ __uint64_t _OSSwapInt64 (__uint64_t _data ) {
  __asm__ ("bswap   %%eax\n\t" "bswap   %%edx\n\t" "xchgl   %%eax, %%edx" : "+A" (_data ) ) ; 
  return _data ; 
}
union wait {
  int w_status ; 
  struct {
    unsigned int w_Termsig : 7 , w_Coredump : 1 , w_Retcode : 8 , w_Filler : 16 ; 
  }
  w_T ; 
  struct {
    unsigned int w_Stopval : 8 , w_Stopsig : 8 , w_Filler : 16 ; 
  }
  w_S ; 
}
; 
pid_t wait (int * ) __asm ("_" "wait" "$UNIX2003" ) ; 
typedef __darwin_wchar_t wchar_t ; 
typedef struct {
  int quot ; 
  int rem ; 
}
div_t ; 
typedef struct {
  long quot ; 
  long rem ; 
}
ldiv_t ; 
typedef struct {
  long long quot ; 
  long long rem ; 
}
lldiv_t ; 
void * malloc (size_t ) ; 
void _Exit (int ) __attribute__ ((__noreturn__ ) ) ; 
int getsubopt (char * * , char * const * , char * * ) ; 
char * mktemp (char * ) ; 
int mkstemp (char * ) ; 
void setkey (const char * ) __asm ("_" "setkey" "$UNIX2003" ) ; 
typedef signed char int8_t ; 
typedef short int16_t ; 
typedef int int32_t ; 
typedef unsigned int u_int32_t ; 
typedef long long int64_t ; 
typedef unsigned long long u_int64_t ; 
typedef unsigned long uintptr_t ; 
typedef __darwin_dev_t dev_t ; 
typedef __darwin_mode_t mode_t ; 
extern char * suboptarg ; 
void * valloc (size_t ) ; 
typedef __darwin_ssize_t ssize_t ; 
void * memset (void * , int , size_t ) ; 
char * index (const char * , int ) ; 
void swab (const void * , void * , ssize_t ) ; 
static __inline void * __inline_memcpy_chk (void * __dest , const void * __src , size_t __len ) {
  return __builtin___memcpy_chk (__dest , __src , __len , __builtin_object_size (__dest , 0 ) ) ; 
}
static __inline void * __inline_memmove_chk (void * __dest , const void * __src , size_t __len ) {
  return __builtin___memmove_chk (__dest , __src , __len , __builtin_object_size (__dest , 0 ) ) ; 
}
static __inline void * __inline_memset_chk (void * __dest , int __val , size_t __len ) {
  return __builtin___memset_chk (__dest , __val , __len , __builtin_object_size (__dest , 0 ) ) ; 
}
static __inline char * __inline_strcpy_chk (char * __dest , const char * __src ) {
  return __builtin___strcpy_chk (__dest , __src , __builtin_object_size (__dest , 2 > 1 ) ) ; 
}
static __inline char * __inline_stpcpy_chk (char * __dest , const char * __src ) {
  return __builtin___stpcpy_chk (__dest , __src , __builtin_object_size (__dest , 2 > 1 ) ) ; 
}
static __inline char * __inline_strncpy_chk (char * __dest , const char * __src , size_t __len ) {
  return __builtin___strncpy_chk (__dest , __src , __len , __builtin_object_size (__dest , 2 > 1 ) ) ; 
}
static __inline char * __inline_strcat_chk (char * __dest , const char * __src ) {
  return __builtin___strcat_chk (__dest , __src , __builtin_object_size (__dest , 2 > 1 ) ) ; 
}
static __inline char * __inline_strncat_chk (char * __dest , const char * __src , size_t __len ) {
  return __builtin___strncat_chk (__dest , __src , __len , __builtin_object_size (__dest , 2 > 1 ) ) ; 
}
static inline void _mzstrcpy (char * a , const char * b ) {
  ((__builtin_object_size (a , 0 ) != (size_t ) - 1 ) ? __builtin___strcpy_chk (a , b , __builtin_object_size (a , 2 > 1 ) ) : __inline_strcpy_chk (a , b ) ) ; 
}
typedef short Scheme_Type ; 
typedef int mzshort ; 
typedef unsigned int mzchar ; 
typedef long long mzlonglong ; 
typedef unsigned long long umzlonglong ; 
typedef struct Scheme_Object {
  Scheme_Type type ; 
  short keyex ; 
}
Scheme_Object ; 
typedef struct Scheme_Inclhash_Object {
  Scheme_Object so ; 
}
Scheme_Inclhash_Object ; 
typedef struct Scheme_Simple_Object {
  Scheme_Inclhash_Object iso ; 
  union {
    struct {
      mzchar * string_val ; 
      int tag_val ; 
    }
    char_str_val ; 
    struct {
      char * string_val ; 
      int tag_val ; 
    }
    byte_str_val ; 
    struct {
      void * ptr1 , * ptr2 ; 
    }
    two_ptr_val ; 
    struct {
      int int1 ; 
      int int2 ; 
    }
    two_int_val ; 
    struct {
      void * ptr ; 
      int pint ; 
    }
    ptr_int_val ; 
    struct {
      void * ptr ; 
      long pint ; 
    }
    ptr_long_val ; 
    struct {
      struct Scheme_Object * car , * cdr ; 
    }
    pair_val ; 
    struct {
      mzshort len ; 
      mzshort * vec ; 
    }
    svector_val ; 
    struct {
      void * val ; 
      Scheme_Object * type ; 
    }
    cptr_val ; 
  }
  u ; 
}
Scheme_Simple_Object ; 
typedef struct Scheme_Object * (* Scheme_Closure_Func ) (struct Scheme_Object * ) ; 
typedef struct {
  Scheme_Inclhash_Object iso ; 
  union {
    mzchar char_val ; 
    Scheme_Object * ptr_value ; 
    long int_val ; 
    Scheme_Object * ptr_val ; 
  }
  u ; 
}
Scheme_Small_Object ; 
typedef struct {
  Scheme_Object so ; 
  double double_val ; 
}
Scheme_Double ; 
typedef struct Scheme_Symbol {
  Scheme_Inclhash_Object iso ; 
  int len ; 
  char s [4 ] ; 
}
Scheme_Symbol ; 
typedef struct Scheme_Vector {
  Scheme_Inclhash_Object iso ; 
  int size ; 
  Scheme_Object * els [1 ] ; 
}
Scheme_Vector ; 
typedef struct Scheme_Double_Vector {
  Scheme_Object so ; 
  long size ; 
  double els [1 ] ; 
}
Scheme_Double_Vector ; 
typedef struct Scheme_Print_Params Scheme_Print_Params ; 
typedef void (* Scheme_Type_Printer ) (Scheme_Object * v , int for_display , Scheme_Print_Params * pp ) ; 
typedef int (* Scheme_Equal_Proc ) (Scheme_Object * obj1 , Scheme_Object * obj2 , void * cycle_data ) ; 
typedef long (* Scheme_Primary_Hash_Proc ) (Scheme_Object * obj , long base , void * cycle_data ) ; 
typedef long (* Scheme_Secondary_Hash_Proc ) (Scheme_Object * obj , void * cycle_data ) ; 
enum {
  scheme_toplevel_type , scheme_local_type , scheme_local_unbox_type , scheme_syntax_type , scheme_application_type , scheme_application2_type , scheme_application3_type , scheme_sequence_type , scheme_branch_type , scheme_unclosed_procedure_type , scheme_let_value_type , scheme_let_void_type , scheme_letrec_type , scheme_let_one_type , scheme_with_cont_mark_type , scheme_quote_syntax_type , _scheme_values_types_ , scheme_compiled_unclosed_procedure_type , scheme_compiled_let_value_type , scheme_compiled_let_void_type , scheme_compiled_syntax_type , scheme_compiled_toplevel_type , scheme_compiled_quote_syntax_type , scheme_quote_compilation_type , scheme_variable_type , scheme_module_variable_type , _scheme_compiled_values_types_ , scheme_prim_type , scheme_closed_prim_type , scheme_closure_type , scheme_case_closure_type , scheme_cont_type , scheme_escaping_cont_type , scheme_proc_struct_type , scheme_native_closure_type , scheme_proc_chaperone_type , scheme_chaperone_type , scheme_structure_type , scheme_char_type , scheme_integer_type , scheme_bignum_type , scheme_rational_type , scheme_float_type , scheme_double_type , scheme_complex_type , scheme_char_string_type , scheme_byte_string_type , scheme_unix_path_type , scheme_windows_path_type , scheme_symbol_type , scheme_keyword_type , scheme_null_type , scheme_pair_type , scheme_mutable_pair_type , scheme_vector_type , scheme_inspector_type , scheme_input_port_type , scheme_output_port_type , scheme_eof_type , scheme_true_type , scheme_false_type , scheme_void_type , scheme_syntax_compiler_type , scheme_macro_type , scheme_box_type , scheme_thread_type , scheme_stx_offset_type , scheme_cont_mark_set_type , scheme_sema_type , scheme_hash_table_type , scheme_hash_tree_type , scheme_cpointer_type , scheme_offset_cpointer_type , scheme_weak_box_type , scheme_ephemeron_type , scheme_struct_type_type , scheme_module_index_type , scheme_set_macro_type , scheme_listener_type , scheme_namespace_type , scheme_config_type , scheme_stx_type , scheme_will_executor_type , scheme_custodian_type , scheme_random_state_type , scheme_regexp_type , scheme_bucket_type , scheme_bucket_table_type , scheme_subprocess_type , scheme_compilation_top_type , scheme_wrap_chunk_type , scheme_eval_waiting_type , scheme_tail_call_waiting_type , scheme_undefined_type , scheme_struct_property_type , scheme_chaperone_property_type , scheme_multiple_values_type , scheme_placeholder_type , scheme_table_placeholder_type , scheme_case_lambda_sequence_type , scheme_begin0_sequence_type , scheme_rename_table_type , scheme_rename_table_set_type , scheme_module_type , scheme_svector_type , scheme_resolve_prefix_type , scheme_security_guard_type , scheme_indent_type , scheme_udp_type , scheme_udp_evt_type , scheme_tcp_accept_evt_type , scheme_id_macro_type , scheme_evt_set_type , scheme_wrap_evt_type , scheme_handle_evt_type , scheme_nack_guard_evt_type , scheme_semaphore_repost_type , scheme_channel_type , scheme_channel_put_type , scheme_thread_resume_type , scheme_thread_suspend_type , scheme_thread_dead_type , scheme_poll_evt_type , scheme_nack_evt_type , scheme_module_registry_type , scheme_thread_set_type , scheme_string_converter_type , scheme_alarm_type , scheme_thread_recv_evt_type , scheme_thread_cell_type , scheme_channel_syncer_type , scheme_special_comment_type , scheme_write_evt_type , scheme_always_evt_type , scheme_never_evt_type , scheme_progress_evt_type , scheme_certifications_type , scheme_already_comp_type , scheme_readtable_type , scheme_intdef_context_type , scheme_lexical_rib_type , scheme_thread_cell_values_type , scheme_global_ref_type , scheme_cont_mark_chain_type , scheme_raw_pair_type , scheme_prompt_type , scheme_prompt_tag_type , scheme_expanded_syntax_type , scheme_delay_syntax_type , scheme_cust_box_type , scheme_resolved_module_path_type , scheme_module_phase_exports_type , scheme_logger_type , scheme_log_reader_type , scheme_free_id_info_type , scheme_rib_delimiter_type , scheme_noninline_proc_type , scheme_prune_context_type , scheme_future_type , scheme_flvector_type , scheme_place_type , scheme_place_async_channel_type , scheme_place_bi_channel_type , scheme_once_used_type , _scheme_last_normal_type_ , scheme_rt_weak_array , scheme_rt_comp_env , scheme_rt_constant_binding , scheme_rt_resolve_info , scheme_rt_optimize_info , scheme_rt_compile_info , scheme_rt_cont_mark , scheme_rt_saved_stack , scheme_rt_reply_item , scheme_rt_closure_info , scheme_rt_overflow , scheme_rt_overflow_jmp , scheme_rt_meta_cont , scheme_rt_dyn_wind_cell , scheme_rt_dyn_wind_info , scheme_rt_dyn_wind , scheme_rt_dup_check , scheme_rt_thread_memory , scheme_rt_input_file , scheme_rt_input_fd , scheme_rt_oskit_console_input , scheme_rt_tested_input_file , scheme_rt_tested_output_file , scheme_rt_indexed_string , scheme_rt_output_file , scheme_rt_load_handler_data , scheme_rt_pipe , scheme_rt_beos_process , scheme_rt_system_child , scheme_rt_tcp , scheme_rt_write_data , scheme_rt_tcp_select_info , scheme_rt_param_data , scheme_rt_will , scheme_rt_struct_proc_info , scheme_rt_linker_name , scheme_rt_param_map , scheme_rt_finalization , scheme_rt_finalizations , scheme_rt_cpp_object , scheme_rt_cpp_array_object , scheme_rt_stack_object , scheme_rt_preallocated_object , scheme_thread_hop_type , scheme_rt_srcloc , scheme_rt_evt , scheme_rt_syncing , scheme_rt_comp_prefix , scheme_rt_user_input , scheme_rt_user_output , scheme_rt_compact_port , scheme_rt_read_special_dw , scheme_rt_regwork , scheme_rt_buf_holder , scheme_rt_parameterization , scheme_rt_print_params , scheme_rt_read_params , scheme_rt_native_code , scheme_rt_native_code_plus_case , scheme_rt_jitter_data , scheme_rt_module_exports , scheme_rt_delay_load_info , scheme_rt_marshal_info , scheme_rt_unmarshal_info , scheme_rt_runstack , scheme_rt_sfs_info , scheme_rt_validate_clearing , scheme_rt_rb_node , scheme_rt_frozen_tramp , _scheme_last_type_ }
; 
typedef struct Scheme_Cptr {
  Scheme_Inclhash_Object so ; 
  void * val ; 
  Scheme_Object * type ; 
}
Scheme_Cptr ; 
typedef struct Scheme_Offset_Cptr {
  Scheme_Cptr cptr ; 
  long offset ; 
}
Scheme_Offset_Cptr ; 
typedef struct Scheme_Object * (Scheme_Prim ) (int argc , Scheme_Object * argv [] ) ; 
typedef struct Scheme_Object * (Scheme_Primitive_Closure_Proc ) (int argc , struct Scheme_Object * argv [] , Scheme_Object * p ) ; 
typedef struct {
  Scheme_Object so ; 
  unsigned short flags ; 
}
Scheme_Prim_Proc_Header ; 
typedef struct {
  Scheme_Prim_Proc_Header pp ; 
  Scheme_Primitive_Closure_Proc * prim_val ; 
  const char * name ; 
  mzshort mina ; 
  union {
    mzshort * cases ; 
    mzshort maxa ; 
  }
  mu ; 
}
Scheme_Primitive_Proc ; 
typedef struct {
  Scheme_Primitive_Proc pp ; 
  mzshort minr , maxr ; 
}
Scheme_Prim_W_Result_Arity ; 
typedef struct Scheme_Primitive_Closure {
  Scheme_Primitive_Proc p ; 
  mzshort count ; 
  Scheme_Object * val [1 ] ; 
}
Scheme_Primitive_Closure ; 
typedef struct Scheme_Object * (Scheme_Closed_Prim ) (void * d , int argc , struct Scheme_Object * argv [] ) ; 
typedef struct {
  Scheme_Prim_Proc_Header pp ; 
  Scheme_Closed_Prim * prim_val ; 
  void * data ; 
  const char * name ; 
  mzshort mina , maxa ; 
}
Scheme_Closed_Primitive_Proc ; 
typedef struct {
  Scheme_Closed_Primitive_Proc p ; 
  mzshort * cases ; 
}
Scheme_Closed_Case_Primitive_Proc ; 
typedef struct {
  Scheme_Closed_Primitive_Proc p ; 
  mzshort minr , maxr ; 
}
Scheme_Closed_Prim_W_Result_Arity ; 
typedef struct Scheme_Hash_Table {
  Scheme_Inclhash_Object iso ; 
  int size ; 
  int count ; 
  Scheme_Object * * keys ; 
  Scheme_Object * * vals ; 
  void (* make_hash_indices ) (void * v , long * h1 , long * h2 ) ; 
  int (* compare ) (void * v1 , void * v2 ) ; 
  Scheme_Object * mutex ; 
  int mcount ; 
}
Scheme_Hash_Table ; 
typedef struct Scheme_Hash_Tree Scheme_Hash_Tree ; 
typedef struct Scheme_Bucket {
  Scheme_Object so ; 
  void * val ; 
  char * key ; 
}
Scheme_Bucket ; 
typedef struct Scheme_Bucket_Table {
  Scheme_Object so ; 
  int size ; 
  int count ; 
  Scheme_Bucket * * buckets ; 
  char weak , with_home ; 
  void (* make_hash_indices ) (void * v , long * h1 , long * h2 ) ; 
  int (* compare ) (void * v1 , void * v2 ) ; 
  Scheme_Object * mutex ; 
}
Scheme_Bucket_Table ; 
enum {
  SCHEME_hash_string , SCHEME_hash_ptr , SCHEME_hash_bound_id , SCHEME_hash_weak_ptr }
; 
typedef struct Scheme_Env Scheme_Env ; 
typedef struct {
  jmp_buf jb ; 
  unsigned long stack_frame ; 
}
mz_one_jit_jmp_buf ; 
typedef mz_one_jit_jmp_buf mz_jit_jmp_buf [1 ] ; 
typedef struct {
  mz_jit_jmp_buf jb ; 
  long gcvs ; 
  long gcvs_cnt ; 
}
mz_jmp_buf ; 
typedef struct Scheme_Jumpup_Buf {
  void * stack_from , * stack_copy ; 
  long stack_size , stack_max_size ; 
  struct Scheme_Cont * cont ; 
  mz_jmp_buf buf ; 
  void * gc_var_stack ; 
  void * external_stack ; 
}
Scheme_Jumpup_Buf ; 
typedef struct Scheme_Jumpup_Buf_Holder {
  Scheme_Type type ; 
  Scheme_Jumpup_Buf buf ; 
}
Scheme_Jumpup_Buf_Holder ; 
typedef struct Scheme_Continuation_Jump_State {
  struct Scheme_Object * jumping_to_continuation ; 
  Scheme_Object * val ; 
  mzshort num_vals ; 
  short is_kill , is_escape ; 
}
Scheme_Continuation_Jump_State ; 
typedef struct Scheme_Cont_Frame_Data {
  long cont_mark_pos ; 
  long cont_mark_stack ; 
  void * cache ; 
}
Scheme_Cont_Frame_Data ; 
typedef struct objhead {
  unsigned long hash : ((8 * sizeof (unsigned long ) ) - (4 + 3 + 14 ) ) ; 
  unsigned long type : 3 ; 
  unsigned long mark : 1 ; 
  unsigned long btc_mark : 1 ; 
  unsigned long moved : 1 ; 
  unsigned long dead : 1 ; 
  unsigned long size : 14 ; 
}
objhead ; 
typedef void (Scheme_Close_Custodian_Client ) (Scheme_Object * o , void * data ) ; 
typedef void (* Scheme_Exit_Closer_Func ) (Scheme_Object * , Scheme_Close_Custodian_Client * , void * ) ; 
typedef Scheme_Object * (* Scheme_Custodian_Extractor ) (Scheme_Object * o ) ; 
typedef struct Scheme_Object Scheme_Custodian_Reference ; 
typedef struct Scheme_Custodian Scheme_Custodian ; 
typedef Scheme_Bucket_Table Scheme_Thread_Cell_Table ; 
typedef struct Scheme_Config Scheme_Config ; 
typedef int (* Scheme_Ready_Fun ) (Scheme_Object * o ) ; 
typedef void (* Scheme_Needs_Wakeup_Fun ) (Scheme_Object * , void * ) ; 
typedef Scheme_Object * (* Scheme_Sync_Sema_Fun ) (Scheme_Object * , int * repost ) ; 
typedef int (* Scheme_Sync_Filter_Fun ) (Scheme_Object * ) ; 
typedef struct Scheme_Thread {
  Scheme_Object so ; 
  struct Scheme_Thread * next ; 
  struct Scheme_Thread * prev ; 
  struct Scheme_Thread_Set * t_set_parent ; 
  Scheme_Object * t_set_next ; 
  Scheme_Object * t_set_prev ; 
  mz_jmp_buf * error_buf ; 
  Scheme_Continuation_Jump_State cjs ; 
  struct Scheme_Meta_Continuation * decompose_mc ; 
  Scheme_Thread_Cell_Table * cell_values ; 
  Scheme_Config * init_config ; 
  Scheme_Object * init_break_cell ; 
  int can_break_at_swap ; 
  Scheme_Object * * runstack ; 
  Scheme_Object * * runstack_start ; 
  long runstack_size ; 
  struct Scheme_Saved_Stack * runstack_saved ; 
  Scheme_Object * * runstack_tmp_keep ; 
  Scheme_Object * * spare_runstack ; 
  long spare_runstack_size ; 
  struct Scheme_Thread * * runstack_owner ; 
  struct Scheme_Saved_Stack * runstack_swapped ; 
  long cont_mark_pos ; 
  long cont_mark_stack ; 
  struct Scheme_Cont_Mark * * cont_mark_stack_segments ; 
  int cont_mark_seg_count ; 
  int cont_mark_stack_bottom ; 
  int cont_mark_pos_bottom ; 
  struct Scheme_Thread * * cont_mark_stack_owner ; 
  struct Scheme_Cont_Mark * cont_mark_stack_swapped ; 
  struct Scheme_Prompt * meta_prompt ; 
  struct Scheme_Meta_Continuation * meta_continuation ; 
  long engine_weight ; 
  void * stack_start ; 
  void * stack_end ; 
  Scheme_Jumpup_Buf jmpup_buf ; 
  struct Scheme_Dynamic_Wind * dw ; 
  int next_meta ; 
  int running ; 
  Scheme_Object * suspended_box ; 
  Scheme_Object * resumed_box ; 
  Scheme_Object * dead_box ; 
  Scheme_Object * running_box ; 
  struct Scheme_Thread * nester , * nestee ; 
  double sleep_end ; 
  int block_descriptor ; 
  Scheme_Object * blocker ; 
  Scheme_Ready_Fun block_check ; 
  Scheme_Needs_Wakeup_Fun block_needs_wakeup ; 
  char ran_some ; 
  char suspend_to_kill ; 
  struct Scheme_Thread * return_marks_to ; 
  Scheme_Object * returned_marks ; 
  struct Scheme_Overflow * overflow ; 
  struct Scheme_Comp_Env * current_local_env ; 
  Scheme_Object * current_local_mark ; 
  Scheme_Object * current_local_name ; 
  Scheme_Object * current_local_certs ; 
  Scheme_Object * current_local_modidx ; 
  Scheme_Env * current_local_menv ; 
  Scheme_Object * current_local_bindings ; 
  int current_phase_shift ; 
  struct Scheme_Marshal_Tables * current_mt ; 
  Scheme_Object * constant_folding ; 
  Scheme_Object * reading_delayed ; 
  Scheme_Object * (* overflow_k ) (void ) ; 
  Scheme_Object * overflow_reply ; 
  Scheme_Object * * tail_buffer ; 
  int tail_buffer_size ; 
  Scheme_Object * * values_buffer ; 
  int values_buffer_size ; 
  struct {
    struct {
      Scheme_Object * wait_expr ; 
    }
    eval ; 
    struct {
      Scheme_Object * tail_rator ; 
      Scheme_Object * * tail_rands ; 
      long tail_num_rands ; 
    }
    apply ; 
    struct {
      Scheme_Object * * array ; 
      long count ; 
    }
    multiple ; 
    struct {
      void * p1 , * p2 , * p3 , * p4 , * p5 ; 
      long i1 , i2 , i3 , i4 ; 
    }
    k ; 
  }
  ku ; 
  short suspend_break ; 
  short external_break ; 
  Scheme_Simple_Object * list_stack ; 
  int list_stack_pos ; 
  void (* on_kill ) (struct Scheme_Thread * p ) ; 
  void * kill_data ; 
  void (* private_on_kill ) (void * ) ; 
  void * private_kill_data ; 
  void * * private_kill_next ; 
  void * * user_tls ; 
  int user_tls_size ; 
  long gmp_tls [6 ] ; 
  void * gmp_tls_data ; 
  long accum_process_msec ; 
  long current_start_process_msec ; 
  struct Scheme_Thread_Custodian_Hop * mr_hop ; 
  Scheme_Custodian_Reference * mref ; 
  Scheme_Object * extra_mrefs ; 
  Scheme_Object * transitive_resumes ; 
  Scheme_Object * name ; 
  Scheme_Object * mbox_first ; 
  Scheme_Object * mbox_last ; 
  Scheme_Object * mbox_sema ; 
  long saved_errno ; 
  struct GC_Thread_Info * gc_info ; 
}
Scheme_Thread ; 
typedef struct {
  void * orig_return_address ; 
  void * stack_frame ; 
  struct Scheme_Object * cache ; 
  void * orig_result ; 
}
Stack_Cache_Elem ; 
typedef long rxpos ; 
struct gmp_tmp_stack {
  void * end ; 
  void * alloc_point ; 
  struct gmp_tmp_stack * prev ; 
}
; 
typedef struct Thread_Local_Variables {
  void * * GC_variable_stack_ ; 
  struct NewGC * GC_instance_ ; 
  unsigned long GC_gen0_alloc_page_ptr_ ; 
  unsigned long GC_gen0_alloc_page_end_ ; 
  void * bignum_cache_ [16 ] ; 
  int cache_count_ ; 
  struct Scheme_Hash_Table * toplevels_ht_ ; 
  struct Scheme_Hash_Table * locals_ht_ [2 ] ; 
  volatile int scheme_fuel_counter_ ; 
  unsigned long scheme_stack_boundary_ ; 
  unsigned long volatile scheme_jit_stack_boundary_ ; 
  volatile int scheme_future_need_gc_pause_ ; 
  int scheme_use_rtcall_ ; 
  int in_jit_critical_section_ ; 
  void * jit_buffer_cache_ ; 
  long jit_buffer_cache_size_ ; 
  int jit_buffer_cache_registered_ ; 
  struct Scheme_Object * quick_stx_ ; 
  int scheme_continuation_application_count_ ; 
  int scheme_cont_capture_count_ ; 
  int scheme_prompt_capture_count_ ; 
  struct Scheme_Prompt * available_prompt_ ; 
  struct Scheme_Prompt * available_cws_prompt_ ; 
  struct Scheme_Prompt * available_regular_prompt_ ; 
  struct Scheme_Dynamic_Wind * available_prompt_dw_ ; 
  struct Scheme_Meta_Continuation * available_prompt_mc_ ; 
  struct Scheme_Object * cached_beg_stx_ ; 
  struct Scheme_Object * cached_mod_stx_ ; 
  struct Scheme_Object * cached_mod_beg_stx_ ; 
  struct Scheme_Object * cached_dv_stx_ ; 
  struct Scheme_Object * cached_ds_stx_ ; 
  int cached_stx_phase_ ; 
  struct Scheme_Cont * offstack_cont_ ; 
  struct Scheme_Overflow * offstack_overflow_ ; 
  struct Scheme_Overflow_Jmp * scheme_overflow_jmp_ ; 
  void * scheme_overflow_stack_start_ ; 
  void * * codetab_tree_ ; 
  int during_set_ ; 
  Stack_Cache_Elem stack_cache_stack_ [32 ] ; 
  long stack_cache_stack_pos_ ; 
  struct Scheme_Object * * fixup_runstack_base_ ; 
  int fixup_already_in_place_ ; 
  void * retry_alloc_r1_ ; 
  double save_fp_ ; 
  struct Scheme_Bucket_Table * starts_table_ ; 
  struct Scheme_Modidx * modidx_caching_chain_ ; 
  struct Scheme_Object * global_shift_cache_ ; 
  struct mz_proc_thread * proc_thread_self_ ; 
  struct Scheme_Object * scheme_orig_stdout_port_ ; 
  struct Scheme_Object * scheme_orig_stderr_port_ ; 
  struct Scheme_Object * scheme_orig_stdin_port_ ; 
  struct mz_fd_set * scheme_fd_set_ ; 
  struct Scheme_Custodian * new_port_cust_ ; 
  int external_event_fd_ ; 
  int put_external_event_fd_ ; 
  char * read_string_byte_buffer_ ; 
  struct ITimer_Data * itimerdata_ ; 
  char * quick_buffer_ ; 
  char * quick_encode_buffer_ ; 
  struct Scheme_Hash_Table * cache_ht_ ; 
  char * regstr_ ; 
  char * regparsestr_ ; 
  int regmatchmin_ ; 
  int regmatchmax_ ; 
  int regmaxbackposn_ ; 
  int regsavepos_ ; 
  struct Scheme_Hash_Table * regbackknown_ ; 
  struct Scheme_Hash_Table * regbackdepends_ ; 
  rxpos regparse_ ; 
  rxpos regparse_end_ ; 
  int regnpar_ ; 
  int regncounter_ ; 
  rxpos regcode_ ; 
  rxpos regcodesize_ ; 
  rxpos regcodemax_ ; 
  long regmaxlookback_ ; 
  long rx_buffer_size_ ; 
  rxpos * startp_buffer_cache_ ; 
  rxpos * endp_buffer_cache_ ; 
  rxpos * maybep_buffer_cache_ ; 
  rxpos * match_stack_buffer_cache_ ; 
  unsigned long scheme_os_thread_stack_base_ ; 
  int traversers_registered_ ; 
  struct Finalizations * * save_fns_ptr_ ; 
  struct Scheme_Object * scheme_system_idle_channel_ ; 
  struct Scheme_Object * system_idle_put_evt_ ; 
  void * stack_copy_cache_ [10 ] ; 
  long stack_copy_size_cache_ [10 ] ; 
  int scc_pos_ ; 
  struct Scheme_Object * nominal_ipair_cache_ ; 
  struct Scheme_Object * mark_id_ ; 
  struct Scheme_Object * current_rib_timestamp_ ; 
  struct Scheme_Hash_Table * quick_hash_table_ ; 
  struct Scheme_Object * last_phase_shift_ ; 
  struct Scheme_Object * unsealed_dependencies_ ; 
  struct Scheme_Hash_Table * id_marks_ht_ ; 
  struct Scheme_Hash_Table * than_id_marks_ht_ ; 
  struct Scheme_Bucket_Table * interned_skip_ribs_ ; 
  struct Scheme_Thread * scheme_current_thread_ ; 
  struct Scheme_Thread * scheme_main_thread_ ; 
  struct Scheme_Thread * scheme_first_thread_ ; 
  struct Scheme_Thread_Set * scheme_thread_set_top_ ; 
  int num_running_threads_ ; 
  int swap_no_setjmp_ ; 
  int thread_swap_count_ ; 
  int scheme_did_gc_count_ ; 
  struct Scheme_Future_State * scheme_future_state_ ; 
  struct Scheme_Future_Thread_State * scheme_future_thread_state_ ; 
  void * jit_future_storage_ [2 ] ; 
  struct Scheme_Object * * scheme_current_runstack_start_ ; 
  struct Scheme_Object * * scheme_current_runstack_ ; 
  long scheme_current_cont_mark_stack_ ; 
  long scheme_current_cont_mark_pos_ ; 
  struct Scheme_Custodian * main_custodian_ ; 
  struct Scheme_Custodian * last_custodian_ ; 
  struct Scheme_Hash_Table * limited_custodians_ ; 
  struct Scheme_Thread * swap_target_ ; 
  struct Scheme_Object * scheduled_kills_ ; 
  int do_atomic_ ; 
  int missed_context_switch_ ; 
  int have_activity_ ; 
  int scheme_active_but_sleeping_ ; 
  int thread_ended_with_activity_ ; 
  int scheme_no_stack_overflow_ ; 
  int needs_sleep_cancelled_ ; 
  int tls_pos_ ; 
  struct Scheme_Object * the_nested_exn_handler_ ; 
  struct Scheme_Object * cust_closers_ ; 
  struct Scheme_Object * thread_swap_callbacks_ ; 
  struct Scheme_Object * thread_swap_out_callbacks_ ; 
  struct Scheme_Object * recycle_cell_ ; 
  struct Scheme_Object * maybe_recycle_cell_ ; 
  int recycle_cc_count_ ; 
  void * gmp_mem_pool_ ; 
  unsigned long max_total_allocation_ ; 
  unsigned long current_total_allocation_ ; 
  struct gmp_tmp_stack gmp_tmp_xxx_ ; 
  struct gmp_tmp_stack * gmp_tmp_current_ ; 
  struct Scheme_Logger * scheme_main_logger_ ; 
  int intdef_counter_ ; 
  int builtin_ref_counter_ ; 
  int env_uid_counter_ ; 
  int scheme_overflow_count_ ; 
  struct Scheme_Object * original_pwd_ ; 
  long scheme_hash_request_count_ ; 
  long scheme_hash_iteration_count_ ; 
  struct Scheme_Env * initial_modules_env_ ; 
  int num_initial_modules_ ; 
  struct Scheme_Object * * initial_modules_ ; 
  struct Scheme_Object * initial_renames_ ; 
  struct Scheme_Bucket_Table * initial_toplevel_ ; 
  int generate_lifts_count_ ; 
  int special_is_ok_ ; 
  int scheme_force_port_closed_ ; 
  int fd_reserved_ ; 
  int the_fd_ ; 
  int scheme_num_read_syntax_objects_ ; 
  struct Scheme_Load_Delay * clear_bytes_chain_ ; 
  const char * failure_msg_for_read_ ; 
  void * * dgc_array_ ; 
  int * dgc_count_ ; 
  int dgc_size_ ; 
  void (* save_oom_ ) (void ) ; 
  int current_lifetime_ ; 
  int scheme_main_was_once_suspended_ ; 
  int buffer_init_size_ ; 
  long scheme_total_gc_time_ ; 
  long start_this_gc_time_ ; 
  long end_this_gc_time_ ; 
  volatile short delayed_break_ready_ ; 
  struct Scheme_Thread * main_break_target_thread_ ; 
  long scheme_code_page_total_ ; 
  int locale_on_ ; 
  void * current_locale_name_ptr_ ; 
  int gensym_counter_ ; 
  struct Scheme_Object * dummy_input_port_ ; 
  struct Scheme_Object * dummy_output_port_ ; 
  struct Scheme_Bucket_Table * place_local_modpath_table_ ; 
  struct Scheme_Hash_Table * opened_libs_ ; 
  struct mzrt_mutex * jit_lock_ ; 
}
Thread_Local_Variables ; 
struct sched_param {
  int sched_priority ; 
  char __opaque [4 ] ; 
}
; 
struct timespec {
  __darwin_time_t tv_sec ; 
  long tv_nsec ; 
}
; 
typedef __darwin_clock_t clock_t ; 
typedef __darwin_time_t time_t ; 
struct tm {
  int tm_sec ; 
  int tm_min ; 
  int tm_hour ; 
  int tm_mday ; 
  int tm_mon ; 
  int tm_year ; 
  int tm_wday ; 
  int tm_yday ; 
  int tm_isdst ; 
  long tm_gmtoff ; 
  char * tm_zone ; 
}
; 
extern char * tzname [] ; 
extern long timezone __asm ("_" "timezone" "$UNIX2003" ) ; 
time_t time (time_t * ) ; 
typedef __darwin_pthread_cond_t pthread_cond_t ; 
typedef __darwin_pthread_condattr_t pthread_condattr_t ; 
typedef __darwin_pthread_key_t pthread_key_t ; 
typedef __darwin_pthread_mutex_t pthread_mutex_t ; 
typedef __darwin_pthread_mutexattr_t pthread_mutexattr_t ; 
typedef __darwin_pthread_once_t pthread_once_t ; 
typedef __darwin_pthread_rwlock_t pthread_rwlock_t ; 
typedef __darwin_pthread_rwlockattr_t pthread_rwlockattr_t ; 
typedef __darwin_pthread_t pthread_t ; 
typedef __darwin_mach_port_t mach_port_t ; 
void * pthread_getspecific (pthread_key_t ) ; 
int pthread_kill (pthread_t , int ) ; 
int pthread_sigmask (int , const sigset_t * , sigset_t * ) __asm ("_" "pthread_sigmask" "$UNIX2003" ) ; 
extern pthread_key_t scheme_thread_local_key ; 
static inline Thread_Local_Variables * scheme_get_thread_local_variables () __attribute__ ((used ) ) ; 
static inline Thread_Local_Variables * scheme_get_thread_local_variables () {
  Thread_Local_Variables * x = ((void * ) 0 ) ; 
  asm volatile ("movl %%gs:0x48(,%1,4), %0" : "=r" (x ) : "r" (scheme_thread_local_key ) ) ; 
  return x ; 
}
typedef void (* Scheme_Kill_Action_Func ) (void * ) ; 
typedef int (* Scheme_Frozen_Stack_Proc ) (void * ) ; 
enum {
  MZCONFIG_ENV , MZCONFIG_INPUT_PORT , MZCONFIG_OUTPUT_PORT , MZCONFIG_ERROR_PORT , MZCONFIG_ERROR_DISPLAY_HANDLER , MZCONFIG_ERROR_PRINT_VALUE_HANDLER , MZCONFIG_EXIT_HANDLER , MZCONFIG_INIT_EXN_HANDLER , MZCONFIG_EVAL_HANDLER , MZCONFIG_COMPILE_HANDLER , MZCONFIG_LOAD_HANDLER , MZCONFIG_LOAD_COMPILED_HANDLER , MZCONFIG_PRINT_HANDLER , MZCONFIG_PROMPT_READ_HANDLER , MZCONFIG_READ_HANDLER , MZCONFIG_READTABLE , MZCONFIG_READER_GUARD , MZCONFIG_CAN_READ_GRAPH , MZCONFIG_CAN_READ_COMPILED , MZCONFIG_CAN_READ_BOX , MZCONFIG_CAN_READ_PIPE_QUOTE , MZCONFIG_CAN_READ_DOT , MZCONFIG_CAN_READ_INFIX_DOT , MZCONFIG_CAN_READ_QUASI , MZCONFIG_CAN_READ_READER , MZCONFIG_READ_DECIMAL_INEXACT , MZCONFIG_PRINT_GRAPH , MZCONFIG_PRINT_STRUCT , MZCONFIG_PRINT_BOX , MZCONFIG_PRINT_VEC_SHORTHAND , MZCONFIG_PRINT_HASH_TABLE , MZCONFIG_PRINT_UNREADABLE , MZCONFIG_PRINT_PAIR_CURLY , MZCONFIG_PRINT_MPAIR_CURLY , MZCONFIG_PRINT_SYNTAX_WIDTH , MZCONFIG_PRINT_READER , MZCONFIG_PRINT_AS_QQ , MZCONFIG_CASE_SENS , MZCONFIG_SQUARE_BRACKETS_ARE_PARENS , MZCONFIG_CURLY_BRACES_ARE_PARENS , MZCONFIG_HONU_MODE , MZCONFIG_ERROR_PRINT_WIDTH , MZCONFIG_ERROR_PRINT_CONTEXT_LENGTH , MZCONFIG_ERROR_ESCAPE_HANDLER , MZCONFIG_ALLOW_SET_UNDEFINED , MZCONFIG_COMPILE_MODULE_CONSTS , MZCONFIG_USE_JIT , MZCONFIG_DISALLOW_INLINE , MZCONFIG_CUSTODIAN , MZCONFIG_INSPECTOR , MZCONFIG_CODE_INSPECTOR , MZCONFIG_USE_COMPILED_KIND , MZCONFIG_USE_USER_PATHS , MZCONFIG_LOAD_DIRECTORY , MZCONFIG_WRITE_DIRECTORY , MZCONFIG_COLLECTION_PATHS , MZCONFIG_PORT_PRINT_HANDLER , MZCONFIG_LOAD_EXTENSION_HANDLER , MZCONFIG_CURRENT_DIRECTORY , MZCONFIG_RANDOM_STATE , MZCONFIG_CURRENT_MODULE_RESOLVER , MZCONFIG_CURRENT_MODULE_NAME , MZCONFIG_CURRENT_MODULE_SRC , MZCONFIG_ERROR_PRINT_SRCLOC , MZCONFIG_CMDLINE_ARGS , MZCONFIG_LOCALE , MZCONFIG_SECURITY_GUARD , MZCONFIG_PORT_COUNT_LINES , MZCONFIG_SCHEDULER_RANDOM_STATE , MZCONFIG_THREAD_SET , MZCONFIG_THREAD_INIT_STACK_SIZE , MZCONFIG_LOAD_DELAY_ENABLED , MZCONFIG_DELAY_LOAD_INFO , MZCONFIG_EXPAND_OBSERVE , MZCONFIG_LOGGER , __MZCONFIG_BUILTIN_COUNT__ }
; 
typedef struct Scheme_Input_Port Scheme_Input_Port ; 
typedef struct Scheme_Output_Port Scheme_Output_Port ; 
typedef struct Scheme_Port Scheme_Port ; 
typedef long (* Scheme_Get_String_Fun ) (Scheme_Input_Port * port , char * buffer , long offset , long size , int nonblock , Scheme_Object * unless ) ; 
typedef long (* Scheme_Peek_String_Fun ) (Scheme_Input_Port * port , char * buffer , long offset , long size , Scheme_Object * skip , int nonblock , Scheme_Object * unless ) ; 
typedef Scheme_Object * (* Scheme_Progress_Evt_Fun ) (Scheme_Input_Port * port ) ; 
typedef int (* Scheme_Peeked_Read_Fun ) (Scheme_Input_Port * port , long amount , Scheme_Object * unless_evt , Scheme_Object * target_ch ) ; 
typedef int (* Scheme_In_Ready_Fun ) (Scheme_Input_Port * port ) ; 
typedef void (* Scheme_Close_Input_Fun ) (Scheme_Input_Port * port ) ; 
typedef void (* Scheme_Need_Wakeup_Input_Fun ) (Scheme_Input_Port * , void * ) ; 
typedef Scheme_Object * (* Scheme_Location_Fun ) (Scheme_Port * ) ; 
typedef void (* Scheme_Count_Lines_Fun ) (Scheme_Port * ) ; 
typedef int (* Scheme_Buffer_Mode_Fun ) (Scheme_Port * , int m ) ; 
typedef Scheme_Object * (* Scheme_Write_String_Evt_Fun ) (Scheme_Output_Port * , const char * str , long offset , long size ) ; 
typedef long (* Scheme_Write_String_Fun ) (Scheme_Output_Port * , const char * str , long offset , long size , int rarely_block , int enable_break ) ; 
typedef int (* Scheme_Out_Ready_Fun ) (Scheme_Output_Port * port ) ; 
typedef void (* Scheme_Close_Output_Fun ) (Scheme_Output_Port * port ) ; 
typedef void (* Scheme_Need_Wakeup_Output_Fun ) (Scheme_Output_Port * , void * ) ; 
typedef Scheme_Object * (* Scheme_Write_Special_Evt_Fun ) (Scheme_Output_Port * , Scheme_Object * ) ; 
typedef int (* Scheme_Write_Special_Fun ) (Scheme_Output_Port * , Scheme_Object * , int nonblock ) ; 
struct Scheme_Port {
  Scheme_Object so ; 
  char count_lines , was_cr ; 
  long position , readpos , lineNumber , charsSinceNewline ; 
  long column , oldColumn ; 
  int utf8state ; 
  Scheme_Location_Fun location_fun ; 
  Scheme_Count_Lines_Fun count_lines_fun ; 
  Scheme_Buffer_Mode_Fun buffer_mode_fun ; 
}
; 
struct Scheme_Input_Port {
  struct Scheme_Port p ; 
  char closed , pending_eof ; 
  Scheme_Object * sub_type ; 
  Scheme_Custodian_Reference * mref ; 
  void * port_data ; 
  Scheme_Get_String_Fun get_string_fun ; 
  Scheme_Peek_String_Fun peek_string_fun ; 
  Scheme_Progress_Evt_Fun progress_evt_fun ; 
  Scheme_Peeked_Read_Fun peeked_read_fun ; 
  Scheme_In_Ready_Fun byte_ready_fun ; 
  Scheme_Close_Input_Fun close_fun ; 
  Scheme_Need_Wakeup_Input_Fun need_wakeup_fun ; 
  Scheme_Object * read_handler ; 
  Scheme_Object * name ; 
  Scheme_Object * peeked_read , * peeked_write ; 
  Scheme_Object * progress_evt , * input_lock , * input_giveup , * input_extras , * input_extras_ready ; 
  unsigned char ungotten [24 ] ; 
  int ungotten_count ; 
  Scheme_Object * special , * ungotten_special ; 
  Scheme_Object * unless , * unless_cache ; 
  struct Scheme_Output_Port * output_half ; 
}
; 
struct Scheme_Output_Port {
  struct Scheme_Port p ; 
  short closed ; 
  Scheme_Object * sub_type ; 
  Scheme_Custodian_Reference * mref ; 
  void * port_data ; 
  Scheme_Write_String_Evt_Fun write_string_evt_fun ; 
  Scheme_Write_String_Fun write_string_fun ; 
  Scheme_Close_Output_Fun close_fun ; 
  Scheme_Out_Ready_Fun ready_fun ; 
  Scheme_Need_Wakeup_Output_Fun need_wakeup_fun ; 
  Scheme_Write_Special_Evt_Fun write_special_evt_fun ; 
  Scheme_Write_Special_Fun write_special_fun ; 
  long pos ; 
  Scheme_Object * name ; 
  Scheme_Object * display_handler ; 
  Scheme_Object * write_handler ; 
  Scheme_Object * print_handler ; 
  struct Scheme_Input_Port * input_half ; 
}
; 
enum {
  MZEXN , MZEXN_FAIL , MZEXN_FAIL_CONTRACT , MZEXN_FAIL_CONTRACT_ARITY , MZEXN_FAIL_CONTRACT_DIVIDE_BY_ZERO , MZEXN_FAIL_CONTRACT_NON_FIXNUM_RESULT , MZEXN_FAIL_CONTRACT_CONTINUATION , MZEXN_FAIL_CONTRACT_VARIABLE , MZEXN_FAIL_SYNTAX , MZEXN_FAIL_READ , MZEXN_FAIL_READ_EOF , MZEXN_FAIL_READ_NON_CHAR , MZEXN_FAIL_FILESYSTEM , MZEXN_FAIL_FILESYSTEM_EXISTS , MZEXN_FAIL_FILESYSTEM_VERSION , MZEXN_FAIL_NETWORK , MZEXN_FAIL_OUT_OF_MEMORY , MZEXN_FAIL_UNSUPPORTED , MZEXN_FAIL_USER , MZEXN_BREAK , MZEXN_OTHER }
; 
typedef struct Scheme_Logger Scheme_Logger ; 
typedef void (* Scheme_Invoke_Proc ) (Scheme_Env * env , long phase_shift , Scheme_Object * self_modidx , void * data ) ; 
struct NewGC ; 
typedef int (* Size_Proc ) (void * obj ) ; 
typedef int (* Size2_Proc ) (void * obj , struct NewGC * ) ; 
typedef int (* Mark_Proc ) (void * obj ) ; 
typedef int (* Mark2_Proc ) (void * obj , struct NewGC * ) ; 
typedef int (* Fixup_Proc ) (void * obj ) ; 
typedef int (* Fixup2_Proc ) (void * obj , struct NewGC * ) ; 
typedef void (* GC_collect_start_callback_Proc ) (void ) ; 
typedef void (* GC_collect_end_callback_Proc ) (void ) ; 
typedef void (* GC_collect_inform_callback_Proc ) (int major_gc , long pre_used , long post_used ) ; 
typedef unsigned long (* GC_get_thread_stack_base_Proc ) (void ) ; 
struct mz_addrinfo {
  int ai_flags ; 
  int ai_family ; 
  int ai_socktype ; 
  int ai_protocol ; 
  size_t ai_addrlen ; 
  struct sockaddr * ai_addr ; 
  struct mz_addrinfo * ai_next ; 
}
; 
extern void scheme_add_evt (Scheme_Type type , Scheme_Ready_Fun ready , Scheme_Needs_Wakeup_Fun wakeup , Scheme_Sync_Filter_Fun filter , int can_redirect ) ; 
extern Scheme_Type scheme_make_type (const char * name ) ; 
extern Scheme_Object scheme_eof [1 ] ; 
extern Scheme_Object scheme_null [1 ] ; 
extern Scheme_Object scheme_true [1 ] ; 
extern Scheme_Object scheme_false [1 ] ; 
extern Scheme_Object scheme_void [1 ] ; 
extern Scheme_Object scheme_undefined [1 ] ; 
extern unsigned short * scheme_uchar_table [] ; 
extern unsigned char * scheme_uchar_cases_table [] ; 
extern unsigned char * scheme_uchar_cats_table [] ; 
extern int scheme_uchar_ups [] ; 
extern int scheme_uchar_downs [] ; 
extern int scheme_uchar_titles [] ; 
extern int scheme_uchar_folds [] ; 
extern unsigned char scheme_uchar_combining_classes [] ; 
extern Scheme_Env * scheme_primitive_module (Scheme_Object * name , Scheme_Env * for_env ) ; 
extern void scheme_finish_primitive_module (Scheme_Env * env ) ; 
extern Scheme_Object * scheme_intern_symbol (const char * name ) ; 
extern Scheme_Object * scheme_initialize (Scheme_Env * global_env ) ; 
extern Scheme_Object * scheme_reload (Scheme_Env * global_env ) ; 
extern Scheme_Object * scheme_module_name (void ) ; 
struct accessx_descriptor {
  unsigned int ad_name_offset ; 
  int ad_flags ; 
  int ad_pad [2 ] ; 
}
; 
typedef __darwin_gid_t gid_t ; 
typedef __darwin_useconds_t useconds_t ; 
typedef __darwin_uuid_t uuid_t ; 
char * ctermid (char * ) ; 
pid_t getpgid (pid_t ) ; 
pid_t getsid (pid_t ) ; 
ssize_t read (int , void * , size_t ) __asm ("_" "read" "$UNIX2003" ) ; 
void swab (const void * , void * , ssize_t ) ; 
ssize_t write (int , const void * , size_t ) __asm ("_" "write" "$UNIX2003" ) ; 
extern int optind , opterr , optopt ; 
typedef struct fd_set {
  __int32_t fds_bits [((((1024 ) % ((sizeof (__int32_t ) * 8 ) ) ) == 0 ) ? ((1024 ) / ((sizeof (__int32_t ) * 8 ) ) ) : (((1024 ) / ((sizeof (__int32_t ) * 8 ) ) ) + 1 ) ) ] ; 
}
fd_set ; 
static __inline int __darwin_fd_isset (int _n , const struct fd_set * _p ) {
  return (_p -> fds_bits [_n / (sizeof (__int32_t ) * 8 ) ] & (1 << (_n % (sizeof (__int32_t ) * 8 ) ) ) ) ; 
}
void _Exit (int ) __attribute__ ((__noreturn__ ) ) ; 
int getpgid (pid_t _pid ) ; 
int getsid (pid_t _pid ) ; 
int mkstemp (char * ) ; 
char * mktemp (char * ) ; 
void setkey (const char * ) __asm ("_" "setkey" "$UNIX2003" ) ; 
void * valloc (size_t ) ; 
extern char * suboptarg ; 
int getsubopt (char * * , char * const * , char * * ) ; 
struct fssearchblock ; 
struct searchstate ; 
typedef int64_t quad_t ; 
typedef struct {
  __darwin_rune_t __min ; 
  __darwin_rune_t __max ; 
  __darwin_rune_t __map ; 
  __uint32_t * __types ; 
}
_RuneEntry ; 
typedef struct {
  int __nranges ; 
  _RuneEntry * __ranges ; 
}
_RuneRange ; 
typedef struct {
  char __name [14 ] ; 
  __uint32_t __mask ; 
}
_RuneCharClass ; 
typedef struct {
  char __magic [8 ] ; 
  char __encoding [32 ] ; 
  __darwin_rune_t (* __sgetrune ) (const char * , __darwin_size_t , char const * * ) ; 
  int (* __sputrune ) (__darwin_rune_t , char * , __darwin_size_t , char * * ) ; 
  __darwin_rune_t __invalid_rune ; 
  __uint32_t __runetype [(1 << 8 ) ] ; 
  __darwin_rune_t __maplower [(1 << 8 ) ] ; 
  __darwin_rune_t __mapupper [(1 << 8 ) ] ; 
  _RuneRange __runetype_ext ; 
  _RuneRange __maplower_ext ; 
  _RuneRange __mapupper_ext ; 
  void * __variable ; 
  int __variable_len ; 
  int __ncharclasses ; 
  _RuneCharClass * __charclasses ; 
}
_RuneLocale ; 
extern _RuneLocale _DefaultRuneLocale ; 
static __inline int isascii (int _c ) {
  return ((_c & ~ 0x7F ) == 0 ) ; 
}
int __maskrune (__darwin_ct_rune_t , unsigned long ) ; 
static __inline int __istype (__darwin_ct_rune_t _c , unsigned long _f ) {
  return (isascii (_c ) ? ! ! (_DefaultRuneLocale . __runetype [_c ] & _f ) : ! ! __maskrune (_c , _f ) ) ; 
}
static __inline __darwin_ct_rune_t __isctype (__darwin_ct_rune_t _c , unsigned long _f ) {
  return (_c < 0 || _c >= (1 << 8 ) ) ? 0 : ! ! (_DefaultRuneLocale . __runetype [_c ] & _f ) ; 
}
__darwin_ct_rune_t __toupper (__darwin_ct_rune_t ) ; 
__darwin_ct_rune_t __tolower (__darwin_ct_rune_t ) ; 
static __inline int __wcwidth (__darwin_ct_rune_t _c ) {
  unsigned int _x ; 
  if (_c == 0 )
    return (0 ) ; 
  _x = (unsigned int ) __maskrune (_c , 0xe0000000L | 0x00040000L ) ; 
  if ((_x & 0xe0000000L ) != 0 )
    return ((_x & 0xe0000000L ) >> 30 ) ; 
  return ((_x & 0x00040000L ) != 0 ? 1 : - 1 ) ; 
}
static __inline int isalnum (int _c ) {
  return (__istype (_c , 0x00000100L | 0x00000400L ) ) ; 
}
static __inline int isalpha (int _c ) {
  return (__istype (_c , 0x00000100L ) ) ; 
}
static __inline int isblank (int _c ) {
  return (__istype (_c , 0x00020000L ) ) ; 
}
static __inline int iscntrl (int _c ) {
  return (__istype (_c , 0x00000200L ) ) ; 
}
static __inline int isdigit (int _c ) {
  return (__isctype (_c , 0x00000400L ) ) ; 
}
static __inline int isgraph (int _c ) {
  return (__istype (_c , 0x00000800L ) ) ; 
}
static __inline int islower (int _c ) {
  return (__istype (_c , 0x00001000L ) ) ; 
}
static __inline int isprint (int _c ) {
  return (__istype (_c , 0x00040000L ) ) ; 
}
static __inline int ispunct (int _c ) {
  return (__istype (_c , 0x00002000L ) ) ; 
}
static __inline int isspace (int _c ) {
  return (__istype (_c , 0x00004000L ) ) ; 
}
static __inline int isupper (int _c ) {
  return (__istype (_c , 0x00008000L ) ) ; 
}
static __inline int isxdigit (int _c ) {
  return (__isctype (_c , 0x00010000L ) ) ; 
}
static __inline int toascii (int _c ) {
  return (_c & 0x7F ) ; 
}
static __inline int tolower (int _c ) {
  return (__tolower (_c ) ) ; 
}
static __inline int toupper (int _c ) {
  return (__toupper (_c ) ) ; 
}
static __inline int digittoint (int _c ) {
  return (__maskrune (_c , 0x0F ) ) ; 
}
static __inline int ishexnumber (int _c ) {
  return (__istype (_c , 0x00010000L ) ) ; 
}
static __inline int isideogram (int _c ) {
  return (__istype (_c , 0x00080000L ) ) ; 
}
static __inline int isnumber (int _c ) {
  return (__istype (_c , 0x00000400L ) ) ; 
}
static __inline int isphonogram (int _c ) {
  return (__istype (_c , 0x00200000L ) ) ; 
}
static __inline int isrune (int _c ) {
  return (__istype (_c , 0xFFFFFFF0L ) ) ; 
}
static __inline int isspecial (int _c ) {
  return (__istype (_c , 0x00100000L ) ) ; 
}
struct lconv {
  char * decimal_point ; 
  char * thousands_sep ; 
  char * grouping ; 
  char * int_curr_symbol ; 
  char * currency_symbol ; 
  char * mon_decimal_point ; 
  char * mon_thousands_sep ; 
  char * mon_grouping ; 
  char * positive_sign ; 
  char * negative_sign ; 
  char int_frac_digits ; 
  char frac_digits ; 
  char p_cs_precedes ; 
  char p_sep_by_space ; 
  char n_cs_precedes ; 
  char n_sep_by_space ; 
  char p_sign_posn ; 
  char n_sign_posn ; 
  char int_p_cs_precedes ; 
  char int_n_cs_precedes ; 
  char int_p_sep_by_space ; 
  char int_n_sep_by_space ; 
  char int_p_sign_posn ; 
  char int_n_sign_posn ; 
}
; 
static __inline__ int __inline_isfinitef (float ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isfinited (double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isfinite (long double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isinff (float ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isinfd (double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isinf (long double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isnanf (float ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isnand (double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isnan (long double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isnormalf (float ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isnormald (double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isnormal (long double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_signbitf (float ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_signbitd (double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_signbit (long double ) __attribute__ ((always_inline ) ) ; 
static __inline__ int __inline_isinff (float __x ) {
  return __builtin_fabsf (__x ) == __builtin_inff () ; 
}
static __inline__ int __inline_isinfd (double __x ) {
  return __builtin_fabs (__x ) == __builtin_inf () ; 
}
static __inline__ int __inline_isinf (long double __x ) {
  return __builtin_fabsl (__x ) == __builtin_infl () ; 
}
static __inline__ int __inline_isfinitef (float __x ) {
  return __x == __x && __builtin_fabsf (__x ) != __builtin_inff () ; 
}
static __inline__ int __inline_isfinited (double __x ) {
  return __x == __x && __builtin_fabs (__x ) != __builtin_inf () ; 
}
static __inline__ int __inline_isfinite (long double __x ) {
  return __x == __x && __builtin_fabsl (__x ) != __builtin_infl () ; 
}
static __inline__ int __inline_isnanf (float __x ) {
  return __x != __x ; 
}
static __inline__ int __inline_isnand (double __x ) {
  return __x != __x ; 
}
static __inline__ int __inline_isnan (long double __x ) {
  return __x != __x ; 
}
static __inline__ int __inline_signbitf (float __x ) {
  union {
    float __f ; 
    unsigned int __u ; 
  }
  __u ; 
  __u . __f = __x ; 
  return (int ) (__u . __u >> 31 ) ; 
}
static __inline__ int __inline_signbitd (double __x ) {
  union {
    double __f ; 
    unsigned int __u [2 ] ; 
  }
  __u ; 
  __u . __f = __x ; 
  return (int ) (__u . __u [1 ] >> 31 ) ; 
}
static __inline__ int __inline_signbit (long double __x ) {
  union {
    long double __ld ; 
    struct {
      unsigned int __m [2 ] ; 
      short __sexp ; 
    }
    __p ; 
  }
  __u ; 
  __u . __ld = __x ; 
  return (int ) (((unsigned short ) __u . __p . __sexp ) >> 15 ) ; 
}
static __inline__ int __inline_isnormalf (float __x ) {
  float fabsf = __builtin_fabsf (__x ) ; 
  if (__x != __x )
    return 0 ; 
  return fabsf < __builtin_inff () && fabsf >= 1.17549435e-38F ; 
}
static __inline__ int __inline_isnormald (double __x ) {
  double fabsf = __builtin_fabs (__x ) ; 
  if (__x != __x )
    return 0 ; 
  return fabsf < __builtin_inf () && fabsf >= 2.2250738585072014e-308 ; 
}
static __inline__ int __inline_isnormal (long double __x ) {
  long double fabsf = __builtin_fabsl (__x ) ; 
  if (__x != __x )
    return 0 ; 
  return fabsf < __builtin_infl () && fabsf >= 3.36210314311209350626e-4932L ; 
}
extern double exp (double ) ; 
extern float fabsf (float ) ; 
struct exception {
  int type ; 
  char * name ; 
  double arg1 ; 
  double arg2 ; 
  double retval ; 
}
; 
extern const char * const sys_signame [32 ] ; 
extern const char * const sys_siglist [32 ] ; 
void (* bsd_signal (int , void (* ) (int ) ) ) (int ) ; 
int pthread_kill (pthread_t , int ) ; 
int pthread_sigmask (int , const sigset_t * , sigset_t * ) __asm ("_" "pthread_sigmask" "$UNIX2003" ) ; 
int sigaction (int , const struct sigaction * , struct sigaction * ) ; 
void (* sigset (int , void (* ) (int ) ) ) (int ) ; 
int sigvec (int , struct sigvec * , struct sigvec * ) ; 
static __inline int __sigbits (int __signo ) {
  return __signo > 32 ? 0 : (1 << (__signo - 1 ) ) ; 
}
typedef unsigned char uint8_t ; 
typedef unsigned short uint16_t ; 
typedef unsigned int uint32_t ; 
typedef unsigned long long uint64_t ; 

#pragma pack(push, 2)

typedef unsigned char UInt8 ; 
typedef signed char SInt8 ; 
typedef unsigned short UInt16 ; 
typedef signed short SInt16 ; 
typedef unsigned long UInt32 ; 
typedef signed long SInt32 ; 
struct wide {
  UInt32 lo ; 
  SInt32 hi ; 
}
; 
typedef struct wide wide ; 
struct UnsignedWide {
  UInt32 lo ; 
  UInt32 hi ; 
}
; 
typedef struct UnsignedWide UnsignedWide ; 
typedef signed long long SInt64 ; 
typedef unsigned long long UInt64 ; 
typedef SInt32 Fixed ; 
typedef SInt32 Fract ; 
typedef UInt32 UnsignedFixed ; 
typedef short ShortFixed ; 
typedef float Float32 ; 
typedef double Float64 ; 
struct Float80 {
  SInt16 exp ; 
  UInt16 man [4 ] ; 
}
; 
typedef struct Float80 Float80 ; 
struct Float96 {
  SInt16 exp [2 ] ; 
  UInt16 man [4 ] ; 
}
; 
typedef struct Float96 Float96 ; 
struct Float32Point {
  Float32 x ; 
  Float32 y ; 
}
; 
typedef struct Float32Point Float32Point ; 
typedef char * Ptr ; 
typedef SInt32 OSStatus ; 
typedef unsigned long ByteCount ; 
typedef unsigned long ItemCount ; 
typedef SInt16 LangCode ; 
typedef SInt16 RegionCode ; 
typedef UInt32 FourCharCode ; 
typedef FourCharCode OSType ; 
typedef FourCharCode ResType ; 
typedef unsigned char Boolean ; 
typedef long (* ProcPtr ) () ; 
typedef void (* Register68kProcPtr ) () ; 
typedef ProcPtr UniversalProcPtr ; 
enum {
  noErr = 0 }
; 
enum {
  kNilOptions = 0 }
; 
enum {
  kVariableLengthArray = 1 }
; 
enum {
  kUnknownType = 0x3F3F3F3F }
; 
typedef UInt32 UTF32Char ; 
typedef UInt16 UniChar ; 
typedef unsigned long UniCharCount ; 
typedef unsigned char Str255 [256 ] ; 
typedef unsigned char Str63 [64 ] ; 
typedef unsigned char Str32 [33 ] ; 
typedef unsigned char Str31 [32 ] ; 
typedef unsigned char Str27 [28 ] ; 
typedef unsigned char Str15 [16 ] ; 
typedef unsigned char Str32Field [34 ] ; 
typedef unsigned char * StringPtr ; 
typedef const unsigned char * ConstStringPtr ; 
typedef const unsigned char * ConstStr255Param ; 
typedef const unsigned char * ConstStr63Param ; 
struct ProcessSerialNumber {
  UInt32 highLongOfPSN ; 
  UInt32 lowLongOfPSN ; 
}
; 
typedef struct ProcessSerialNumber ProcessSerialNumber ; 
struct Point {
  short v ; 
  short h ; 
}
; 
typedef struct Point Point ; 
struct Rect {
  short top ; 
  short left ; 
  short bottom ; 
  short right ; 
}
; 
typedef struct Rect Rect ; 
struct FixedPoint {
  Fixed x ; 
  Fixed y ; 
}
; 
typedef struct FixedPoint FixedPoint ; 
struct FixedRect {
  Fixed left ; 
  Fixed top ; 
  Fixed right ; 
  Fixed bottom ; 
}
; 
typedef struct FixedRect FixedRect ; 
enum {
  normal = 0 , bold = 1 , italic = 2 , underline = 4 , outline = 8 , shadow = 0x10 , condense = 0x20 , extend = 0x40 }
; 
typedef unsigned char Style ; 
typedef SInt32 TimeScale ; 
typedef wide CompTimeValue ; 
typedef struct TimeBaseRecord * TimeBase ; 
struct TimeRecord {
  CompTimeValue value ; 
  TimeScale scale ; 
  TimeBase base ; 
}
; 
typedef struct TimeRecord TimeRecord ; 
struct NumVersion {
  UInt8 nonRelRev ; 
  UInt8 stage ; 
  UInt8 minorAndBugRev ; 
  UInt8 majorRev ; 
}
; 
typedef struct NumVersion NumVersion ; 
enum {
  developStage = 0x20 , alphaStage = 0x40 , betaStage = 0x60 , finalStage = 0x80 }
; 
union NumVersionVariant {
  NumVersion parts ; 
  UInt32 whole ; 
}
; 
typedef union NumVersionVariant NumVersionVariant ; 
typedef NumVersionVariant * NumVersionVariantPtr ; 
struct VersRec {
  NumVersion numericVersion ; 
  short countryCode ; 
  Str255 shortVersion ; 
  Str255 reserved ; 
}
; 
typedef struct VersRec VersRec ; 
typedef VersRec * VersRecPtr ; 
typedef UInt8 Byte ; 

#pragma pack(pop)

typedef unsigned long CFTypeID ; 
typedef unsigned long CFOptionFlags ; 
typedef unsigned long CFHashCode ; 
typedef signed long CFIndex ; 
typedef const void * CFTypeRef ; 
typedef const struct __CFString * CFStringRef ; 
typedef struct __CFString * CFMutableStringRef ; 
typedef CFTypeRef CFPropertyListRef ; 
enum {
  kCFCompareLessThan = - 1 , kCFCompareEqualTo = 0 , kCFCompareGreaterThan = 1 }
; 
typedef CFIndex CFComparisonResult ; 
typedef CFComparisonResult (* CFComparatorFunction ) (const void * val1 , const void * val2 , void * context ) ; 
enum {
  kCFNotFound = - 1 }
; 
typedef struct {
  CFIndex location ; 
  CFIndex length ; 
}
CFRange ; 
static __inline__ __attribute__ ((always_inline ) ) CFRange CFRangeMake (CFIndex loc , CFIndex len ) {
  CFRange range ; 
  range . location = loc ; 
  range . length = len ; 
  return range ; 
}
typedef const struct __CFNull * CFNullRef ; 
typedef const struct __CFAllocator * CFAllocatorRef ; 
typedef const void * (* CFAllocatorRetainCallBack ) (const void * info ) ; 
typedef void (* CFAllocatorReleaseCallBack ) (const void * info ) ; 
typedef CFStringRef (* CFAllocatorCopyDescriptionCallBack ) (const void * info ) ; 
typedef void * (* CFAllocatorAllocateCallBack ) (CFIndex allocSize , CFOptionFlags hint , void * info ) ; 
typedef void * (* CFAllocatorReallocateCallBack ) (void * ptr , CFIndex newsize , CFOptionFlags hint , void * info ) ; 
typedef void (* CFAllocatorDeallocateCallBack ) (void * ptr , void * info ) ; 
typedef CFIndex (* CFAllocatorPreferredSizeCallBack ) (CFIndex size , CFOptionFlags hint , void * info ) ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  CFAllocatorRetainCallBack retain ; 
  CFAllocatorReleaseCallBack release ; 
  CFAllocatorCopyDescriptionCallBack copyDescription ; 
  CFAllocatorAllocateCallBack allocate ; 
  CFAllocatorReallocateCallBack reallocate ; 
  CFAllocatorDeallocateCallBack deallocate ; 
  CFAllocatorPreferredSizeCallBack preferredSize ; 
}
CFAllocatorContext ; 
typedef const void * (* CFArrayRetainCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef void (* CFArrayReleaseCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef CFStringRef (* CFArrayCopyDescriptionCallBack ) (const void * value ) ; 
typedef Boolean (* CFArrayEqualCallBack ) (const void * value1 , const void * value2 ) ; 
typedef struct {
  CFIndex version ; 
  CFArrayRetainCallBack retain ; 
  CFArrayReleaseCallBack release ; 
  CFArrayCopyDescriptionCallBack copyDescription ; 
  CFArrayEqualCallBack equal ; 
}
CFArrayCallBacks ; 
typedef void (* CFArrayApplierFunction ) (const void * value , void * context ) ; 
typedef const struct __CFArray * CFArrayRef ; 
typedef struct __CFArray * CFMutableArrayRef ; 
typedef const void * (* CFBagRetainCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef void (* CFBagReleaseCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef CFStringRef (* CFBagCopyDescriptionCallBack ) (const void * value ) ; 
typedef Boolean (* CFBagEqualCallBack ) (const void * value1 , const void * value2 ) ; 
typedef CFHashCode (* CFBagHashCallBack ) (const void * value ) ; 
typedef struct {
  CFIndex version ; 
  CFBagRetainCallBack retain ; 
  CFBagReleaseCallBack release ; 
  CFBagCopyDescriptionCallBack copyDescription ; 
  CFBagEqualCallBack equal ; 
  CFBagHashCallBack hash ; 
}
CFBagCallBacks ; 
typedef void (* CFBagApplierFunction ) (const void * value , void * context ) ; 
typedef const struct __CFBag * CFBagRef ; 
typedef struct __CFBag * CFMutableBagRef ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
}
CFBinaryHeapCompareContext ; 
typedef struct {
  CFIndex version ; 
  const void * (* retain ) (CFAllocatorRef allocator , const void * ptr ) ; 
  void (* release ) (CFAllocatorRef allocator , const void * ptr ) ; 
  CFStringRef (* copyDescription ) (const void * ptr ) ; 
  CFComparisonResult (* compare ) (const void * ptr1 , const void * ptr2 , void * context ) ; 
}
CFBinaryHeapCallBacks ; 
typedef void (* CFBinaryHeapApplierFunction ) (const void * val , void * context ) ; 
typedef struct __CFBinaryHeap * CFBinaryHeapRef ; 
typedef UInt32 CFBit ; 
typedef const struct __CFBitVector * CFBitVectorRef ; 
typedef struct __CFBitVector * CFMutableBitVectorRef ; 
typedef const void * (* CFDictionaryRetainCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef void (* CFDictionaryReleaseCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef CFStringRef (* CFDictionaryCopyDescriptionCallBack ) (const void * value ) ; 
typedef Boolean (* CFDictionaryEqualCallBack ) (const void * value1 , const void * value2 ) ; 
typedef CFHashCode (* CFDictionaryHashCallBack ) (const void * value ) ; 
typedef struct {
  CFIndex version ; 
  CFDictionaryRetainCallBack retain ; 
  CFDictionaryReleaseCallBack release ; 
  CFDictionaryCopyDescriptionCallBack copyDescription ; 
  CFDictionaryEqualCallBack equal ; 
  CFDictionaryHashCallBack hash ; 
}
CFDictionaryKeyCallBacks ; 
typedef struct {
  CFIndex version ; 
  CFDictionaryRetainCallBack retain ; 
  CFDictionaryReleaseCallBack release ; 
  CFDictionaryCopyDescriptionCallBack copyDescription ; 
  CFDictionaryEqualCallBack equal ; 
}
CFDictionaryValueCallBacks ; 
typedef void (* CFDictionaryApplierFunction ) (const void * key , const void * value , void * context ) ; 
typedef const struct __CFDictionary * CFDictionaryRef ; 
typedef struct __CFDictionary * CFMutableDictionaryRef ; 
typedef const struct __CFData * CFDataRef ; 
typedef struct __CFData * CFMutableDataRef ; 
enum {
  kCFDataSearchBackwards = 1UL << 0 , kCFDataSearchAnchored = 1UL << 1 }
; 
typedef CFOptionFlags CFDataSearchFlags ; 
typedef const struct __CFCharacterSet * CFCharacterSetRef ; 
typedef struct __CFCharacterSet * CFMutableCharacterSetRef ; 
enum {
  kCFCharacterSetControl = 1 , kCFCharacterSetWhitespace , kCFCharacterSetWhitespaceAndNewline , kCFCharacterSetDecimalDigit , kCFCharacterSetLetter , kCFCharacterSetLowercaseLetter , kCFCharacterSetUppercaseLetter , kCFCharacterSetNonBase , kCFCharacterSetDecomposable , kCFCharacterSetAlphaNumeric , kCFCharacterSetPunctuation , kCFCharacterSetCapitalizedLetter = 13 , kCFCharacterSetSymbol = 14 , kCFCharacterSetNewline = 15 , kCFCharacterSetIllegal = 12 }
; 
typedef CFIndex CFCharacterSetPredefinedSet ; 
typedef const struct __CFLocale * CFLocaleRef ; 
enum {
  kCFLocaleLanguageDirectionUnknown = 0 , kCFLocaleLanguageDirectionLeftToRight = 1 , kCFLocaleLanguageDirectionRightToLeft = 2 , kCFLocaleLanguageDirectionTopToBottom = 3 , kCFLocaleLanguageDirectionBottomToTop = 4 }
; 
typedef CFIndex CFLocaleLanguageDirection ; 
typedef UInt32 CFStringEncoding ; 
enum {
  kCFStringEncodingMacRoman = 0 , kCFStringEncodingWindowsLatin1 = 0x0500 , kCFStringEncodingISOLatin1 = 0x0201 , kCFStringEncodingNextStepLatin = 0x0B01 , kCFStringEncodingASCII = 0x0600 , kCFStringEncodingUnicode = 0x0100 , kCFStringEncodingUTF8 = 0x08000100 , kCFStringEncodingNonLossyASCII = 0x0BFF , kCFStringEncodingUTF16 = 0x0100 , kCFStringEncodingUTF16BE = 0x10000100 , kCFStringEncodingUTF16LE = 0x14000100 , kCFStringEncodingUTF32 = 0x0c000100 , kCFStringEncodingUTF32BE = 0x18000100 , kCFStringEncodingUTF32LE = 0x1c000100 }
; 
extern CFStringRef CFStringCreateWithCString (CFAllocatorRef alloc , const char * cStr , CFStringEncoding encoding ) ; 
extern void CFStringGetCharacters (CFStringRef theString , CFRange range , UniChar * buffer ) ; 
extern const UniChar * CFStringGetCharactersPtr (CFStringRef theString ) ; 
enum {
  kCFCompareCaseInsensitive = 1 , kCFCompareBackwards = 4 , kCFCompareAnchored = 8 , kCFCompareNonliteral = 16 , kCFCompareLocalized = 32 , kCFCompareNumerically = 64 , kCFCompareDiacriticInsensitive = 128 , kCFCompareWidthInsensitive = 256 , kCFCompareForcedOrdering = 512 }
; 
typedef CFOptionFlags CFStringCompareFlags ; 
enum {
  kCFStringNormalizationFormD = 0 , kCFStringNormalizationFormKD , kCFStringNormalizationFormC , kCFStringNormalizationFormKC }
; 
typedef CFIndex CFStringNormalizationForm ; 
typedef struct {
  UniChar buffer [64 ] ; 
  CFStringRef theString ; 
  const UniChar * directBuffer ; 
  CFRange rangeToBuffer ; 
  CFIndex bufferedRangeStart ; 
  CFIndex bufferedRangeEnd ; 
}
CFStringInlineBuffer ; 
static __inline__ __attribute__ ((always_inline ) ) void CFStringInitInlineBuffer (CFStringRef str , CFStringInlineBuffer * buf , CFRange range ) {
  buf -> theString = str ; 
  buf -> rangeToBuffer = range ; 
  buf -> directBuffer = CFStringGetCharactersPtr (str ) ; 
  buf -> bufferedRangeStart = buf -> bufferedRangeEnd = 0 ; 
}
static __inline__ __attribute__ ((always_inline ) ) UniChar CFStringGetCharacterFromInlineBuffer (CFStringInlineBuffer * buf , CFIndex idx ) {
  if (buf -> directBuffer ) {
    if (idx < 0 || idx >= buf -> rangeToBuffer . length )
      return 0 ; 
    return buf -> directBuffer [idx + buf -> rangeToBuffer . location ] ; 
  }
  if (idx >= buf -> bufferedRangeEnd || idx < buf -> bufferedRangeStart ) {
    if (idx < 0 || idx >= buf -> rangeToBuffer . length )
      return 0 ; 
    if ((buf -> bufferedRangeStart = idx - 4 ) < 0 )
      buf -> bufferedRangeStart = 0 ; 
    buf -> bufferedRangeEnd = buf -> bufferedRangeStart + 64 ; 
    if (buf -> bufferedRangeEnd > buf -> rangeToBuffer . length )
      buf -> bufferedRangeEnd = buf -> rangeToBuffer . length ; 
    CFStringGetCharacters (buf -> theString , CFRangeMake (buf -> rangeToBuffer . location + buf -> bufferedRangeStart , buf -> bufferedRangeEnd - buf -> bufferedRangeStart ) , buf -> buffer ) ; 
  }
  return buf -> buffer [idx - buf -> bufferedRangeStart ] ; 
}
static __inline__ __attribute__ ((always_inline ) ) Boolean CFStringIsSurrogateHighCharacter (UniChar character ) {
  return ((character >= 0xD800UL ) && (character <= 0xDBFFUL ) ? 1 : 0 ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) Boolean CFStringIsSurrogateLowCharacter (UniChar character ) {
  return ((character >= 0xDC00UL ) && (character <= 0xDFFFUL ) ? 1 : 0 ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) UTF32Char CFStringGetLongCharacterForSurrogatePair (UniChar surrogateHigh , UniChar surrogateLow ) {
  return ((surrogateHigh - 0xD800UL ) << 10 ) + (surrogateLow - 0xDC00UL ) + 0x0010000UL ; 
}
static __inline__ __attribute__ ((always_inline ) ) Boolean CFStringGetSurrogatePairForLongCharacter (UTF32Char character , UniChar * surrogates ) {
  if ((character > 0xFFFFUL ) && (character < 0x110000UL ) ) {
    character -= 0x10000 ; 
    if (((void * ) 0 ) != surrogates ) {
      surrogates [0 ] = (UniChar ) ((character >> 10 ) + 0xD800UL ) ; 
      surrogates [1 ] = (UniChar ) ((character & 0x3FF ) + 0xDC00UL ) ; 
    }
    return 1 ; 
  }
  else {
    if (((void * ) 0 ) != surrogates )
      * surrogates = (UniChar ) character ; 
    return 0 ; 
  }
}
typedef struct __CFError * CFErrorRef ; 
enum {
  kCFURLPOSIXPathStyle = 0 , kCFURLHFSPathStyle , kCFURLWindowsPathStyle }
; 
typedef CFIndex CFURLPathStyle ; 
typedef const struct __CFURL * CFURLRef ; 
enum {
  kCFURLComponentScheme = 1 , kCFURLComponentNetLocation = 2 , kCFURLComponentPath = 3 , kCFURLComponentResourceSpecifier = 4 , kCFURLComponentUser = 5 , kCFURLComponentPassword = 6 , kCFURLComponentUserInfo = 7 , kCFURLComponentHost = 8 , kCFURLComponentPort = 9 , kCFURLComponentParameterString = 10 , kCFURLComponentQuery = 11 , kCFURLComponentFragment = 12 }
; 
typedef CFIndex CFURLComponentType ; 
struct FSRef ; 
enum {
  kCFURLBookmarkCreationPreferFileIDResolutionMask = (1UL << 8 ) , kCFURLBookmarkCreationMinimalBookmarkMask = (1UL << 9 ) , kCFURLBookmarkCreationSuitableForBookmarkFile = (1UL << 10 ) , }
; 
typedef CFOptionFlags CFURLBookmarkCreationOptions ; 
enum {
  kCFBookmarkResolutionWithoutUIMask = (1UL << 8 ) , kCFBookmarkResolutionWithoutMountingMask = (1UL << 9 ) , }
; 
typedef CFOptionFlags CFURLBookmarkResolutionOptions ; 
typedef CFOptionFlags CFURLBookmarkFileCreationOptions ; 
typedef struct __CFBundle * CFBundleRef ; 
typedef struct __CFBundle * CFPlugInRef ; 
enum {
  kCFBundleExecutableArchitectureI386 = 0x00000007 , kCFBundleExecutableArchitecturePPC = 0x00000012 , kCFBundleExecutableArchitectureX86_64 = 0x01000007 , kCFBundleExecutableArchitecturePPC64 = 0x01000012 }
; 
typedef SInt16 CFBundleRefNum ; 
static __inline__ uint16_t OSReadSwapInt16 (const volatile void * base , uintptr_t byteOffset ) {
  uint16_t result ; 
  result = * (volatile uint16_t * ) ((uintptr_t ) base + byteOffset ) ; 
  return _OSSwapInt16 (result ) ; 
}
static __inline__ uint32_t OSReadSwapInt32 (const volatile void * base , uintptr_t byteOffset ) {
  uint32_t result ; 
  result = * (volatile uint32_t * ) ((uintptr_t ) base + byteOffset ) ; 
  return _OSSwapInt32 (result ) ; 
}
static __inline__ uint64_t OSReadSwapInt64 (const volatile void * base , uintptr_t byteOffset ) {
  uint64_t result ; 
  result = * (volatile uint64_t * ) ((uintptr_t ) base + byteOffset ) ; 
  return _OSSwapInt64 (result ) ; 
}
static __inline__ void OSWriteSwapInt16 (volatile void * base , uintptr_t byteOffset , uint16_t data ) {
  * (volatile uint16_t * ) ((uintptr_t ) base + byteOffset ) = _OSSwapInt16 (data ) ; 
}
static __inline__ void OSWriteSwapInt32 (volatile void * base , uintptr_t byteOffset , uint32_t data ) {
  * (volatile uint32_t * ) ((uintptr_t ) base + byteOffset ) = _OSSwapInt32 (data ) ; 
}
static __inline__ void OSWriteSwapInt64 (volatile void * base , uintptr_t byteOffset , uint64_t data ) {
  * (volatile uint64_t * ) ((uintptr_t ) base + byteOffset ) = _OSSwapInt64 (data ) ; 
}
enum {
  OSUnknownByteOrder , OSLittleEndian , OSBigEndian }
; 
static __inline__ int32_t OSHostByteOrder (void ) {
  return OSLittleEndian ; 
}
static __inline__ uint16_t _OSReadInt16 (const volatile void * base , uintptr_t byteOffset ) {
  return * (volatile uint16_t * ) ((uintptr_t ) base + byteOffset ) ; 
}
static __inline__ uint32_t _OSReadInt32 (const volatile void * base , uintptr_t byteOffset ) {
  return * (volatile uint32_t * ) ((uintptr_t ) base + byteOffset ) ; 
}
static __inline__ uint64_t _OSReadInt64 (const volatile void * base , uintptr_t byteOffset ) {
  return * (volatile uint64_t * ) ((uintptr_t ) base + byteOffset ) ; 
}
static __inline__ void _OSWriteInt16 (volatile void * base , uintptr_t byteOffset , uint16_t data ) {
  * (volatile uint16_t * ) ((uintptr_t ) base + byteOffset ) = data ; 
}
static __inline__ void _OSWriteInt32 (volatile void * base , uintptr_t byteOffset , uint32_t data ) {
  * (volatile uint32_t * ) ((uintptr_t ) base + byteOffset ) = data ; 
}
static __inline__ void _OSWriteInt64 (volatile void * base , uintptr_t byteOffset , uint64_t data ) {
  * (volatile uint64_t * ) ((uintptr_t ) base + byteOffset ) = data ; 
}
enum __CFByteOrder {
  CFByteOrderUnknown , CFByteOrderLittleEndian , CFByteOrderBigEndian }
; 
typedef CFIndex CFByteOrder ; 
static __inline__ __attribute__ ((always_inline ) ) CFByteOrder CFByteOrderGetCurrent (void ) {
  int32_t byteOrder = OSHostByteOrder () ; 
  switch (byteOrder ) {
    case OSLittleEndian : return CFByteOrderLittleEndian ; 
    case OSBigEndian : return CFByteOrderBigEndian ; 
    default : break ; 
  }
  return CFByteOrderUnknown ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint16_t CFSwapInt16 (uint16_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint16_t ) ((((__uint16_t ) (arg ) & 0xff00 ) >> 8 ) | (((__uint16_t ) (arg ) & 0x00ff ) << 8 ) ) ) : _OSSwapInt16 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint32_t CFSwapInt32 (uint32_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint32_t ) ((((__uint32_t ) (arg ) & 0xff000000 ) >> 24 ) | (((__uint32_t ) (arg ) & 0x00ff0000 ) >> 8 ) | (((__uint32_t ) (arg ) & 0x0000ff00 ) << 8 ) | (((__uint32_t ) (arg ) & 0x000000ff ) << 24 ) ) ) : _OSSwapInt32 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint64_t CFSwapInt64 (uint64_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint64_t ) ((((__uint64_t ) (arg ) & 0xff00000000000000ULL ) >> 56 ) | (((__uint64_t ) (arg ) & 0x00ff000000000000ULL ) >> 40 ) | (((__uint64_t ) (arg ) & 0x0000ff0000000000ULL ) >> 24 ) | (((__uint64_t ) (arg ) & 0x000000ff00000000ULL ) >> 8 ) | (((__uint64_t ) (arg ) & 0x00000000ff000000ULL ) << 8 ) | (((__uint64_t ) (arg ) & 0x0000000000ff0000ULL ) << 24 ) | (((__uint64_t ) (arg ) & 0x000000000000ff00ULL ) << 40 ) | (((__uint64_t ) (arg ) & 0x00000000000000ffULL ) << 56 ) ) ) : _OSSwapInt64 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint16_t CFSwapInt16BigToHost (uint16_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint16_t ) ((((__uint16_t ) (arg ) & 0xff00 ) >> 8 ) | (((__uint16_t ) (arg ) & 0x00ff ) << 8 ) ) ) : _OSSwapInt16 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint32_t CFSwapInt32BigToHost (uint32_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint32_t ) ((((__uint32_t ) (arg ) & 0xff000000 ) >> 24 ) | (((__uint32_t ) (arg ) & 0x00ff0000 ) >> 8 ) | (((__uint32_t ) (arg ) & 0x0000ff00 ) << 8 ) | (((__uint32_t ) (arg ) & 0x000000ff ) << 24 ) ) ) : _OSSwapInt32 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint64_t CFSwapInt64BigToHost (uint64_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint64_t ) ((((__uint64_t ) (arg ) & 0xff00000000000000ULL ) >> 56 ) | (((__uint64_t ) (arg ) & 0x00ff000000000000ULL ) >> 40 ) | (((__uint64_t ) (arg ) & 0x0000ff0000000000ULL ) >> 24 ) | (((__uint64_t ) (arg ) & 0x000000ff00000000ULL ) >> 8 ) | (((__uint64_t ) (arg ) & 0x00000000ff000000ULL ) << 8 ) | (((__uint64_t ) (arg ) & 0x0000000000ff0000ULL ) << 24 ) | (((__uint64_t ) (arg ) & 0x000000000000ff00ULL ) << 40 ) | (((__uint64_t ) (arg ) & 0x00000000000000ffULL ) << 56 ) ) ) : _OSSwapInt64 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint16_t CFSwapInt16HostToBig (uint16_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint16_t ) ((((__uint16_t ) (arg ) & 0xff00 ) >> 8 ) | (((__uint16_t ) (arg ) & 0x00ff ) << 8 ) ) ) : _OSSwapInt16 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint32_t CFSwapInt32HostToBig (uint32_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint32_t ) ((((__uint32_t ) (arg ) & 0xff000000 ) >> 24 ) | (((__uint32_t ) (arg ) & 0x00ff0000 ) >> 8 ) | (((__uint32_t ) (arg ) & 0x0000ff00 ) << 8 ) | (((__uint32_t ) (arg ) & 0x000000ff ) << 24 ) ) ) : _OSSwapInt32 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint64_t CFSwapInt64HostToBig (uint64_t arg ) {
  return (__builtin_constant_p (arg ) ? ((__uint64_t ) ((((__uint64_t ) (arg ) & 0xff00000000000000ULL ) >> 56 ) | (((__uint64_t ) (arg ) & 0x00ff000000000000ULL ) >> 40 ) | (((__uint64_t ) (arg ) & 0x0000ff0000000000ULL ) >> 24 ) | (((__uint64_t ) (arg ) & 0x000000ff00000000ULL ) >> 8 ) | (((__uint64_t ) (arg ) & 0x00000000ff000000ULL ) << 8 ) | (((__uint64_t ) (arg ) & 0x0000000000ff0000ULL ) << 24 ) | (((__uint64_t ) (arg ) & 0x000000000000ff00ULL ) << 40 ) | (((__uint64_t ) (arg ) & 0x00000000000000ffULL ) << 56 ) ) ) : _OSSwapInt64 (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint16_t CFSwapInt16LittleToHost (uint16_t arg ) {
  return ((uint16_t ) (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint32_t CFSwapInt32LittleToHost (uint32_t arg ) {
  return ((uint32_t ) (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint64_t CFSwapInt64LittleToHost (uint64_t arg ) {
  return ((uint64_t ) (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint16_t CFSwapInt16HostToLittle (uint16_t arg ) {
  return ((uint16_t ) (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint32_t CFSwapInt32HostToLittle (uint32_t arg ) {
  return ((uint32_t ) (arg ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) uint64_t CFSwapInt64HostToLittle (uint64_t arg ) {
  return ((uint64_t ) (arg ) ) ; 
}
typedef struct {
  uint32_t v ; 
}
CFSwappedFloat32 ; 
typedef struct {
  uint64_t v ; 
}
CFSwappedFloat64 ; 
static __inline__ __attribute__ ((always_inline ) ) CFSwappedFloat32 CFConvertFloat32HostToSwapped (Float32 arg ) {
  union CFSwap {
    Float32 v ; 
    CFSwappedFloat32 sv ; 
  }
  result ; 
  result . v = arg ; 
  result . sv . v = CFSwapInt32 (result . sv . v ) ; 
  return result . sv ; 
}
static __inline__ __attribute__ ((always_inline ) ) Float32 CFConvertFloat32SwappedToHost (CFSwappedFloat32 arg ) {
  union CFSwap {
    Float32 v ; 
    CFSwappedFloat32 sv ; 
  }
  result ; 
  result . sv = arg ; 
  result . sv . v = CFSwapInt32 (result . sv . v ) ; 
  return result . v ; 
}
static __inline__ __attribute__ ((always_inline ) ) CFSwappedFloat64 CFConvertFloat64HostToSwapped (Float64 arg ) {
  union CFSwap {
    Float64 v ; 
    CFSwappedFloat64 sv ; 
  }
  result ; 
  result . v = arg ; 
  result . sv . v = CFSwapInt64 (result . sv . v ) ; 
  return result . sv ; 
}
static __inline__ __attribute__ ((always_inline ) ) Float64 CFConvertFloat64SwappedToHost (CFSwappedFloat64 arg ) {
  union CFSwap {
    Float64 v ; 
    CFSwappedFloat64 sv ; 
  }
  result ; 
  result . sv = arg ; 
  result . sv . v = CFSwapInt64 (result . sv . v ) ; 
  return result . v ; 
}
static __inline__ __attribute__ ((always_inline ) ) CFSwappedFloat32 CFConvertFloatHostToSwapped (float arg ) {
  union CFSwap {
    float v ; 
    CFSwappedFloat32 sv ; 
  }
  result ; 
  result . v = arg ; 
  result . sv . v = CFSwapInt32 (result . sv . v ) ; 
  return result . sv ; 
}
static __inline__ __attribute__ ((always_inline ) ) float CFConvertFloatSwappedToHost (CFSwappedFloat32 arg ) {
  union CFSwap {
    float v ; 
    CFSwappedFloat32 sv ; 
  }
  result ; 
  result . sv = arg ; 
  result . sv . v = CFSwapInt32 (result . sv . v ) ; 
  return result . v ; 
}
static __inline__ __attribute__ ((always_inline ) ) CFSwappedFloat64 CFConvertDoubleHostToSwapped (double arg ) {
  union CFSwap {
    double v ; 
    CFSwappedFloat64 sv ; 
  }
  result ; 
  result . v = arg ; 
  result . sv . v = CFSwapInt64 (result . sv . v ) ; 
  return result . sv ; 
}
static __inline__ __attribute__ ((always_inline ) ) double CFConvertDoubleSwappedToHost (CFSwappedFloat64 arg ) {
  union CFSwap {
    double v ; 
    CFSwappedFloat64 sv ; 
  }
  result ; 
  result . sv = arg ; 
  result . sv . v = CFSwapInt64 (result . sv . v ) ; 
  return result . v ; 
}
typedef double CFTimeInterval ; 
typedef CFTimeInterval CFAbsoluteTime ; 
typedef const struct __CFDate * CFDateRef ; 
typedef const struct __CFTimeZone * CFTimeZoneRef ; 
typedef struct {
  SInt32 year ; 
  SInt8 month ; 
  SInt8 day ; 
  SInt8 hour ; 
  SInt8 minute ; 
  double second ; 
}
CFGregorianDate ; 
typedef struct {
  SInt32 years ; 
  SInt32 months ; 
  SInt32 days ; 
  SInt32 hours ; 
  SInt32 minutes ; 
  double seconds ; 
}
CFGregorianUnits ; 
enum {
  kCFGregorianUnitsYears = (1UL << 0 ) , kCFGregorianUnitsMonths = (1UL << 1 ) , kCFGregorianUnitsDays = (1UL << 2 ) , kCFGregorianUnitsHours = (1UL << 3 ) , kCFGregorianUnitsMinutes = (1UL << 4 ) , kCFGregorianUnitsSeconds = (1UL << 5 ) , kCFGregorianAllUnits = 0x00FFFFFF }
; 
enum {
  kCFTimeZoneNameStyleStandard , kCFTimeZoneNameStyleShortStandard , kCFTimeZoneNameStyleDaylightSaving , kCFTimeZoneNameStyleShortDaylightSaving , kCFTimeZoneNameStyleGeneric , kCFTimeZoneNameStyleShortGeneric }
; 
typedef CFIndex CFTimeZoneNameStyle ; 
typedef struct __CFCalendar * CFCalendarRef ; 
enum {
  kCFCalendarUnitEra = (1UL << 1 ) , kCFCalendarUnitYear = (1UL << 2 ) , kCFCalendarUnitMonth = (1UL << 3 ) , kCFCalendarUnitDay = (1UL << 4 ) , kCFCalendarUnitHour = (1UL << 5 ) , kCFCalendarUnitMinute = (1UL << 6 ) , kCFCalendarUnitSecond = (1UL << 7 ) , kCFCalendarUnitWeek = (1UL << 8 ) , kCFCalendarUnitWeekday = (1UL << 9 ) , kCFCalendarUnitWeekdayOrdinal = (1UL << 10 ) , kCFCalendarUnitQuarter = (1UL << 11 ) , }
; 
typedef CFOptionFlags CFCalendarUnit ; 
enum {
  kCFCalendarComponentsWrap = (1UL << 0 ) }
; 
typedef struct __CFDateFormatter * CFDateFormatterRef ; 
enum {
  kCFDateFormatterNoStyle = 0 , kCFDateFormatterShortStyle = 1 , kCFDateFormatterMediumStyle = 2 , kCFDateFormatterLongStyle = 3 , kCFDateFormatterFullStyle = 4 }
; 
typedef CFIndex CFDateFormatterStyle ; 
typedef int boolean_t ; 
typedef __darwin_natural_t natural_t ; 
typedef int integer_t ; 
typedef uint64_t mach_vm_address_t ; 
typedef natural_t mach_port_name_t ; 
typedef natural_t mach_port_type_t ; 
typedef natural_t mach_port_seqno_t ; 
typedef natural_t mach_port_mscount_t ; 
typedef natural_t mach_port_msgcount_t ; 
typedef natural_t mach_port_rights_t ; 
typedef struct mach_port_status {
  mach_port_rights_t mps_pset ; 
  mach_port_seqno_t mps_seqno ; 
  mach_port_mscount_t mps_mscount ; 
  mach_port_msgcount_t mps_qlimit ; 
  mach_port_msgcount_t mps_msgcount ; 
  mach_port_rights_t mps_sorights ; 
  boolean_t mps_srights ; 
  boolean_t mps_pdrequest ; 
  boolean_t mps_nsrequest ; 
  natural_t mps_flags ; 
}
mach_port_status_t ; 
typedef struct mach_port_limits {
  mach_port_msgcount_t mpl_qlimit ; 
}
mach_port_limits_t ; 
typedef struct mach_port_qos {
  unsigned int name : 1 ; 
  unsigned int prealloc : 1 ; 
  boolean_t pad1 : 30 ; 
  natural_t len ; 
}
mach_port_qos_t ; 
typedef struct __CFRunLoop * CFRunLoopRef ; 
typedef struct __CFRunLoopSource * CFRunLoopSourceRef ; 
typedef struct __CFRunLoopObserver * CFRunLoopObserverRef ; 
typedef struct __CFRunLoopTimer * CFRunLoopTimerRef ; 
enum {
  kCFRunLoopRunFinished = 1 , kCFRunLoopRunStopped = 2 , kCFRunLoopRunTimedOut = 3 , kCFRunLoopRunHandledSource = 4 }
; 
enum {
  kCFRunLoopEntry = (1UL << 0 ) , kCFRunLoopBeforeTimers = (1UL << 1 ) , kCFRunLoopBeforeSources = (1UL << 2 ) , kCFRunLoopBeforeWaiting = (1UL << 5 ) , kCFRunLoopAfterWaiting = (1UL << 6 ) , kCFRunLoopExit = (1UL << 7 ) , kCFRunLoopAllActivities = 0x0FFFFFFFU }
; 
typedef CFOptionFlags CFRunLoopActivity ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
  Boolean (* equal ) (const void * info1 , const void * info2 ) ; 
  CFHashCode (* hash ) (const void * info ) ; 
  void (* schedule ) (void * info , CFRunLoopRef rl , CFStringRef mode ) ; 
  void (* cancel ) (void * info , CFRunLoopRef rl , CFStringRef mode ) ; 
  void (* perform ) (void * info ) ; 
}
CFRunLoopSourceContext ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
  Boolean (* equal ) (const void * info1 , const void * info2 ) ; 
  CFHashCode (* hash ) (const void * info ) ; 
  mach_port_t (* getPort ) (void * info ) ; 
  void * (* perform ) (void * msg , CFIndex size , CFAllocatorRef allocator , void * info ) ; 
}
CFRunLoopSourceContext1 ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
}
CFRunLoopObserverContext ; 
typedef void (* CFRunLoopObserverCallBack ) (CFRunLoopObserverRef observer , CFRunLoopActivity activity , void * info ) ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
}
CFRunLoopTimerContext ; 
typedef void (* CFRunLoopTimerCallBack ) (CFRunLoopTimerRef timer , void * info ) ; 
typedef union {
  struct dispatch_object_s * _do ; 
  struct dispatch_continuation_s * _dc ; 
  struct dispatch_queue_s * _dq ; 
  struct dispatch_queue_attr_s * _dqa ; 
  struct dispatch_group_s * _dg ; 
  struct dispatch_source_s * _ds ; 
  struct dispatch_source_attr_s * _dsa ; 
  struct dispatch_semaphore_s * _dsema ; 
}
dispatch_object_t __attribute__ ((transparent_union ) ) ; 
typedef void (* dispatch_function_t ) (void * ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nothrow__ ) ) __attribute__ ((__format__ (printf , 2 , 3 ) ) ) void dispatch_debug (dispatch_object_t object , const char * message , ... ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nothrow__ ) ) __attribute__ ((__format__ (printf , 2 , 0 ) ) ) void dispatch_debugv (dispatch_object_t object , const char * message , va_list ap ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_retain (dispatch_object_t object ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_release (dispatch_object_t object ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__nothrow__ ) ) void * dispatch_get_context (dispatch_object_t object ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_set_context (dispatch_object_t object , void * context ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_set_finalizer_f (dispatch_object_t object , dispatch_function_t finalizer ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_suspend (dispatch_object_t object ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_resume (dispatch_object_t object ) ; 
struct timespec ; 
typedef uint64_t dispatch_time_t ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) dispatch_time_t dispatch_time (dispatch_time_t when , int64_t delta ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) dispatch_time_t dispatch_walltime (const struct timespec * when , int64_t delta ) ; 
typedef struct dispatch_queue_s * dispatch_queue_t ; 
; 
typedef struct dispatch_queue_attr_s * dispatch_queue_attr_t ; 
; 
typedef void (^ dispatch_block_t ) (void ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_async (dispatch_queue_t queue , dispatch_block_t block ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nonnull__ (3 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_async_f (dispatch_queue_t queue , void * context , dispatch_function_t work ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_sync (dispatch_queue_t queue , dispatch_block_t block ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nonnull__ (3 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_sync_f (dispatch_queue_t queue , void * context , dispatch_function_t work ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_apply (size_t iterations , dispatch_queue_t queue , void (^ block ) (size_t ) ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nonnull__ (4 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_apply_f (size_t iterations , dispatch_queue_t queue , void * context , void (* work ) (void * , size_t ) ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__nothrow__ ) ) dispatch_queue_t dispatch_get_current_queue (void ) ; 
__attribute__ ((visibility ("default" ) ) ) extern struct dispatch_queue_s _dispatch_main_q ; 
enum {
  DISPATCH_QUEUE_PRIORITY_HIGH = 2 , DISPATCH_QUEUE_PRIORITY_DEFAULT = 0 , DISPATCH_QUEUE_PRIORITY_LOW = - 2 , }
; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__nothrow__ ) ) dispatch_queue_t dispatch_get_global_queue (long priority , unsigned long flags ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__malloc__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__nothrow__ ) ) dispatch_queue_t dispatch_queue_create (const char * label , dispatch_queue_attr_t attr ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__nothrow__ ) ) const char * dispatch_queue_get_label (dispatch_queue_t queue ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_set_target_queue (dispatch_object_t object , dispatch_queue_t queue ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) __attribute__ ((__noreturn__ ) ) void dispatch_main (void ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nonnull__ (3 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_after (dispatch_time_t when , dispatch_queue_t queue , dispatch_block_t block ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nonnull__ (4 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_after_f (dispatch_time_t when , dispatch_queue_t queue , void * context , dispatch_function_t work ) ; 
typedef int kern_return_t ; 
typedef natural_t mach_msg_timeout_t ; 
typedef unsigned int mach_msg_bits_t ; 
typedef natural_t mach_msg_size_t ; 
typedef integer_t mach_msg_id_t ; 
typedef unsigned int mach_msg_type_name_t ; 
typedef unsigned int mach_msg_copy_options_t ; 
typedef unsigned int mach_msg_descriptor_type_t ; 

#pragma pack(4)

typedef struct {
  natural_t pad1 ; 
  mach_msg_size_t pad2 ; 
  unsigned int pad3 : 24 ; 
  mach_msg_descriptor_type_t type : 8 ; 
}
mach_msg_type_descriptor_t ; 
typedef struct {
  mach_port_t name ; 
  mach_msg_size_t pad1 ; 
  unsigned int pad2 : 16 ; 
  mach_msg_type_name_t disposition : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
}
mach_msg_port_descriptor_t ; 
typedef struct {
  uint32_t address ; 
  mach_msg_size_t size ; 
  boolean_t deallocate : 8 ; 
  mach_msg_copy_options_t copy : 8 ; 
  unsigned int pad1 : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
}
mach_msg_ool_descriptor32_t ; 
typedef struct {
  uint64_t address ; 
  boolean_t deallocate : 8 ; 
  mach_msg_copy_options_t copy : 8 ; 
  unsigned int pad1 : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
  mach_msg_size_t size ; 
}
mach_msg_ool_descriptor64_t ; 
typedef struct {
  void * address ; 
  mach_msg_size_t size ; 
  boolean_t deallocate : 8 ; 
  mach_msg_copy_options_t copy : 8 ; 
  unsigned int pad1 : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
}
mach_msg_ool_descriptor_t ; 
typedef struct {
  uint32_t address ; 
  mach_msg_size_t count ; 
  boolean_t deallocate : 8 ; 
  mach_msg_copy_options_t copy : 8 ; 
  mach_msg_type_name_t disposition : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
}
mach_msg_ool_ports_descriptor32_t ; 
typedef struct {
  uint64_t address ; 
  boolean_t deallocate : 8 ; 
  mach_msg_copy_options_t copy : 8 ; 
  mach_msg_type_name_t disposition : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
  mach_msg_size_t count ; 
}
mach_msg_ool_ports_descriptor64_t ; 
typedef struct {
  void * address ; 
  mach_msg_size_t count ; 
  boolean_t deallocate : 8 ; 
  mach_msg_copy_options_t copy : 8 ; 
  mach_msg_type_name_t disposition : 8 ; 
  mach_msg_descriptor_type_t type : 8 ; 
}
mach_msg_ool_ports_descriptor_t ; 
typedef union {
  mach_msg_port_descriptor_t port ; 
  mach_msg_ool_descriptor_t out_of_line ; 
  mach_msg_ool_ports_descriptor_t ool_ports ; 
  mach_msg_type_descriptor_t type ; 
}
mach_msg_descriptor_t ; 
typedef struct {
  mach_msg_size_t msgh_descriptor_count ; 
}
mach_msg_body_t ; 
typedef struct {
  mach_msg_bits_t msgh_bits ; 
  mach_msg_size_t msgh_size ; 
  mach_port_t msgh_remote_port ; 
  mach_port_t msgh_local_port ; 
  mach_msg_size_t msgh_reserved ; 
  mach_msg_id_t msgh_id ; 
}
mach_msg_header_t ; 
typedef struct {
  mach_msg_header_t header ; 
  mach_msg_body_t body ; 
}
mach_msg_base_t ; 
typedef unsigned int mach_msg_trailer_type_t ; 
typedef unsigned int mach_msg_trailer_size_t ; 
typedef struct {
  mach_msg_trailer_type_t msgh_trailer_type ; 
  mach_msg_trailer_size_t msgh_trailer_size ; 
}
mach_msg_trailer_t ; 
typedef struct {
  mach_msg_trailer_type_t msgh_trailer_type ; 
  mach_msg_trailer_size_t msgh_trailer_size ; 
  mach_port_seqno_t msgh_seqno ; 
}
mach_msg_seqno_trailer_t ; 
typedef struct {
  unsigned int val [2 ] ; 
}
security_token_t ; 
typedef struct {
  mach_msg_trailer_type_t msgh_trailer_type ; 
  mach_msg_trailer_size_t msgh_trailer_size ; 
  mach_port_seqno_t msgh_seqno ; 
  security_token_t msgh_sender ; 
}
mach_msg_security_trailer_t ; 
typedef struct {
  unsigned int val [8 ] ; 
}
audit_token_t ; 
typedef struct {
  mach_msg_trailer_type_t msgh_trailer_type ; 
  mach_msg_trailer_size_t msgh_trailer_size ; 
  mach_port_seqno_t msgh_seqno ; 
  security_token_t msgh_sender ; 
  audit_token_t msgh_audit ; 
}
mach_msg_audit_trailer_t ; 
typedef struct {
  mach_msg_trailer_type_t msgh_trailer_type ; 
  mach_msg_trailer_size_t msgh_trailer_size ; 
  mach_port_seqno_t msgh_seqno ; 
  security_token_t msgh_sender ; 
  audit_token_t msgh_audit ; 
  mach_vm_address_t msgh_context ; 
}
mach_msg_context_trailer_t ; 
typedef struct {
  mach_port_name_t sender ; 
}
msg_labels_t ; 
typedef struct {
  mach_msg_trailer_type_t msgh_trailer_type ; 
  mach_msg_trailer_size_t msgh_trailer_size ; 
  mach_port_seqno_t msgh_seqno ; 
  security_token_t msgh_sender ; 
  audit_token_t msgh_audit ; 
  mach_vm_address_t msgh_context ; 
  int msgh_ad ; 
  msg_labels_t msgh_labels ; 
}
mach_msg_mac_trailer_t ; 
typedef struct {
  mach_msg_header_t header ; 
}
mach_msg_empty_send_t ; 
typedef struct {
  mach_msg_header_t header ; 
  mach_msg_trailer_t trailer ; 
}
mach_msg_empty_rcv_t ; 
typedef union {
  mach_msg_empty_send_t send ; 
  mach_msg_empty_rcv_t rcv ; 
}
mach_msg_empty_t ; 

#pragma pack()

typedef integer_t mach_msg_option_t ; 
typedef kern_return_t mach_msg_return_t ; 
typedef struct dispatch_source_s * dispatch_source_t ; 
; 
typedef const struct dispatch_source_type_s * dispatch_source_type_t ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_data_add ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_data_or ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_mach_send ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_mach_recv ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_proc ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_read ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_signal ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_timer ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_vnode ; 
__attribute__ ((visibility ("default" ) ) ) extern const struct dispatch_source_type_s _dispatch_source_type_write ; 
enum {
  DISPATCH_MACH_SEND_DEAD = 0x1 , }
; 
enum {
  DISPATCH_PROC_EXIT = 0x80000000 , DISPATCH_PROC_FORK = 0x40000000 , DISPATCH_PROC_EXEC = 0x20000000 , DISPATCH_PROC_SIGNAL = 0x08000000 , }
; 
enum {
  DISPATCH_VNODE_DELETE = 0x1 , DISPATCH_VNODE_WRITE = 0x2 , DISPATCH_VNODE_EXTEND = 0x4 , DISPATCH_VNODE_ATTRIB = 0x8 , DISPATCH_VNODE_LINK = 0x10 , DISPATCH_VNODE_RENAME = 0x20 , DISPATCH_VNODE_REVOKE = 0x40 , }
; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__malloc__ ) ) __attribute__ ((__nothrow__ ) ) dispatch_source_t dispatch_source_create (dispatch_source_type_t type , uintptr_t handle , unsigned long mask , dispatch_queue_t queue ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_set_event_handler (dispatch_source_t source , dispatch_block_t handler ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_set_event_handler_f (dispatch_source_t source , dispatch_function_t handler ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_set_cancel_handler (dispatch_source_t source , dispatch_block_t cancel_handler ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_set_cancel_handler_f (dispatch_source_t source , dispatch_function_t cancel_handler ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_cancel (dispatch_source_t source ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) long dispatch_source_testcancel (dispatch_source_t source ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__nothrow__ ) ) uintptr_t dispatch_source_get_handle (dispatch_source_t source ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__nothrow__ ) ) unsigned long dispatch_source_get_mask (dispatch_source_t source ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__warn_unused_result__ ) ) __attribute__ ((__pure__ ) ) __attribute__ ((__nothrow__ ) ) unsigned long dispatch_source_get_data (dispatch_source_t source ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_merge_data (dispatch_source_t source , unsigned long value ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_source_set_timer (dispatch_source_t source , dispatch_time_t start , uint64_t interval , uint64_t leeway ) ; 
typedef struct dispatch_group_s * dispatch_group_t ; 
; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__warn_unused_result__ ) ) dispatch_group_t dispatch_group_create (void ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) void dispatch_group_async (dispatch_group_t group , dispatch_queue_t queue , dispatch_block_t block ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nonnull__ (4 ) ) ) void dispatch_group_async_f (dispatch_group_t group , dispatch_queue_t queue , void * context , dispatch_function_t work ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) long dispatch_group_wait (dispatch_group_t group , dispatch_time_t timeout ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) void dispatch_group_notify (dispatch_group_t group , dispatch_queue_t queue , dispatch_block_t block ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nonnull__ (2 ) ) ) __attribute__ ((__nonnull__ (4 ) ) ) void dispatch_group_notify_f (dispatch_group_t group , dispatch_queue_t queue , void * context , dispatch_function_t work ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) __attribute__ ((__nonnull__ ) ) void dispatch_group_enter (dispatch_group_t group ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nothrow__ ) ) __attribute__ ((__nonnull__ ) ) void dispatch_group_leave (dispatch_group_t group ) ; 
typedef struct dispatch_semaphore_s * dispatch_semaphore_t ; 
; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__malloc__ ) ) __attribute__ ((__nothrow__ ) ) dispatch_semaphore_t dispatch_semaphore_create (long value ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) long dispatch_semaphore_wait (dispatch_semaphore_t dsema , dispatch_time_t timeout ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) long dispatch_semaphore_signal (dispatch_semaphore_t dsema ) ; 
typedef long dispatch_once_t ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ ) ) __attribute__ ((__nothrow__ ) ) void dispatch_once (dispatch_once_t * predicate , dispatch_block_t block ) ; 
__attribute__ ((visibility ("default" ) ) ) __attribute__ ((__nonnull__ (1 ) ) ) __attribute__ ((__nonnull__ (3 ) ) ) __attribute__ ((__nothrow__ ) ) void dispatch_once_f (dispatch_once_t * predicate , void * context , void (* function ) (void * ) ) ; 
typedef struct __CFMessagePort * CFMessagePortRef ; 
enum {
  kCFMessagePortSuccess = 0 , kCFMessagePortSendTimeout = - 1 , kCFMessagePortReceiveTimeout = - 2 , kCFMessagePortIsInvalid = - 3 , kCFMessagePortTransportError = - 4 , kCFMessagePortBecameInvalidError = - 5 }
; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
}
CFMessagePortContext ; 
typedef CFDataRef (* CFMessagePortCallBack ) (CFMessagePortRef local , SInt32 msgid , CFDataRef data , void * info ) ; 
typedef void (* CFMessagePortInvalidationCallBack ) (CFMessagePortRef ms , void * info ) ; 
typedef const struct __CFBoolean * CFBooleanRef ; 
enum {
  kCFNumberSInt8Type = 1 , kCFNumberSInt16Type = 2 , kCFNumberSInt32Type = 3 , kCFNumberSInt64Type = 4 , kCFNumberFloat32Type = 5 , kCFNumberFloat64Type = 6 , kCFNumberCharType = 7 , kCFNumberShortType = 8 , kCFNumberIntType = 9 , kCFNumberLongType = 10 , kCFNumberLongLongType = 11 , kCFNumberFloatType = 12 , kCFNumberDoubleType = 13 , kCFNumberCFIndexType = 14 , kCFNumberNSIntegerType = 15 , kCFNumberCGFloatType = 16 , kCFNumberMaxType = 16 }
; 
typedef CFIndex CFNumberType ; 
typedef const struct __CFNumber * CFNumberRef ; 
typedef struct __CFNumberFormatter * CFNumberFormatterRef ; 
enum {
  kCFNumberFormatterNoStyle = 0 , kCFNumberFormatterDecimalStyle = 1 , kCFNumberFormatterCurrencyStyle = 2 , kCFNumberFormatterPercentStyle = 3 , kCFNumberFormatterScientificStyle = 4 , kCFNumberFormatterSpellOutStyle = 5 }
; 
typedef CFIndex CFNumberFormatterStyle ; 
enum {
  kCFNumberFormatterParseIntegersOnly = 1 }
; 
enum {
  kCFNumberFormatterRoundCeiling = 0 , kCFNumberFormatterRoundFloor = 1 , kCFNumberFormatterRoundDown = 2 , kCFNumberFormatterRoundUp = 3 , kCFNumberFormatterRoundHalfEven = 4 , kCFNumberFormatterRoundHalfDown = 5 , kCFNumberFormatterRoundHalfUp = 6 }
; 
enum {
  kCFNumberFormatterPadBeforePrefix = 0 , kCFNumberFormatterPadAfterPrefix = 1 , kCFNumberFormatterPadBeforeSuffix = 2 , kCFNumberFormatterPadAfterSuffix = 3 }
; 
typedef const struct __CFUUID * CFUUIDRef ; 
typedef struct {
  UInt8 byte0 ; 
  UInt8 byte1 ; 
  UInt8 byte2 ; 
  UInt8 byte3 ; 
  UInt8 byte4 ; 
  UInt8 byte5 ; 
  UInt8 byte6 ; 
  UInt8 byte7 ; 
  UInt8 byte8 ; 
  UInt8 byte9 ; 
  UInt8 byte10 ; 
  UInt8 byte11 ; 
  UInt8 byte12 ; 
  UInt8 byte13 ; 
  UInt8 byte14 ; 
  UInt8 byte15 ; 
}
CFUUIDBytes ; 
typedef void (* CFPlugInDynamicRegisterFunction ) (CFPlugInRef plugIn ) ; 
typedef void (* CFPlugInUnloadFunction ) (CFPlugInRef plugIn ) ; 
typedef void * (* CFPlugInFactoryFunction ) (CFAllocatorRef allocator , CFUUIDRef typeUUID ) ; 
typedef struct __CFPlugInInstance * CFPlugInInstanceRef ; 
typedef Boolean (* CFPlugInInstanceGetInterfaceFunction ) (CFPlugInInstanceRef instance , CFStringRef interfaceName , void * * ftbl ) ; 
typedef void (* CFPlugInInstanceDeallocateInstanceDataFunction ) (void * instanceData ) ; 
typedef int CFSocketNativeHandle ; 
typedef struct __CFSocket * CFSocketRef ; 
enum {
  kCFSocketSuccess = 0 , kCFSocketError = - 1 , kCFSocketTimeout = - 2 }
; 
typedef CFIndex CFSocketError ; 
typedef struct {
  SInt32 protocolFamily ; 
  SInt32 socketType ; 
  SInt32 protocol ; 
  CFDataRef address ; 
}
CFSocketSignature ; 
enum {
  kCFSocketNoCallBack = 0 , kCFSocketReadCallBack = 1 , kCFSocketAcceptCallBack = 2 , kCFSocketDataCallBack = 3 , kCFSocketConnectCallBack = 4 , kCFSocketWriteCallBack = 8 }
; 
typedef CFOptionFlags CFSocketCallBackType ; 
enum {
  kCFSocketAutomaticallyReenableReadCallBack = 1 , kCFSocketAutomaticallyReenableAcceptCallBack = 2 , kCFSocketAutomaticallyReenableDataCallBack = 3 , kCFSocketAutomaticallyReenableWriteCallBack = 8 , kCFSocketLeaveErrors = 64 , kCFSocketCloseOnInvalidate = 128 }
; 
typedef void (* CFSocketCallBack ) (CFSocketRef s , CFSocketCallBackType type , CFDataRef address , const void * data , void * info ) ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
}
CFSocketContext ; 
enum {
  kCFStreamStatusNotOpen = 0 , kCFStreamStatusOpening , kCFStreamStatusOpen , kCFStreamStatusReading , kCFStreamStatusWriting , kCFStreamStatusAtEnd , kCFStreamStatusClosed , kCFStreamStatusError }
; 
typedef CFIndex CFStreamStatus ; 
enum {
  kCFStreamEventNone = 0 , kCFStreamEventOpenCompleted = 1 , kCFStreamEventHasBytesAvailable = 2 , kCFStreamEventCanAcceptBytes = 4 , kCFStreamEventErrorOccurred = 8 , kCFStreamEventEndEncountered = 16 }
; 
typedef CFOptionFlags CFStreamEventType ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  void * (* retain ) (void * info ) ; 
  void (* release ) (void * info ) ; 
  CFStringRef (* copyDescription ) (void * info ) ; 
}
CFStreamClientContext ; 
typedef struct __CFReadStream * CFReadStreamRef ; 
typedef struct __CFWriteStream * CFWriteStreamRef ; 
typedef void (* CFReadStreamClientCallBack ) (CFReadStreamRef stream , CFStreamEventType type , void * clientCallBackInfo ) ; 
typedef void (* CFWriteStreamClientCallBack ) (CFWriteStreamRef stream , CFStreamEventType type , void * clientCallBackInfo ) ; 
enum {
  kCFStreamErrorDomainCustom = - 1 , kCFStreamErrorDomainPOSIX = 1 , kCFStreamErrorDomainMacOSStatus }
; 
typedef struct {
  CFIndex domain ; 
  SInt32 error ; 
}
CFStreamError ; 
enum {
  kCFPropertyListImmutable = 0 , kCFPropertyListMutableContainers , kCFPropertyListMutableContainersAndLeaves }
; 
enum {
  kCFPropertyListOpenStepFormat = 1 , kCFPropertyListXMLFormat_v1_0 = 100 , kCFPropertyListBinaryFormat_v1_0 = 200 }
; 
typedef CFIndex CFPropertyListFormat ; 
enum {
  kCFPropertyListReadCorruptError = 3840 , kCFPropertyListReadUnknownVersionError = 3841 , kCFPropertyListReadStreamError = 3842 , kCFPropertyListWriteStreamError = 3851 , }
; 
typedef const void * (* CFSetRetainCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef void (* CFSetReleaseCallBack ) (CFAllocatorRef allocator , const void * value ) ; 
typedef CFStringRef (* CFSetCopyDescriptionCallBack ) (const void * value ) ; 
typedef Boolean (* CFSetEqualCallBack ) (const void * value1 , const void * value2 ) ; 
typedef CFHashCode (* CFSetHashCallBack ) (const void * value ) ; 
typedef struct {
  CFIndex version ; 
  CFSetRetainCallBack retain ; 
  CFSetReleaseCallBack release ; 
  CFSetCopyDescriptionCallBack copyDescription ; 
  CFSetEqualCallBack equal ; 
  CFSetHashCallBack hash ; 
}
CFSetCallBacks ; 
typedef void (* CFSetApplierFunction ) (const void * value , void * context ) ; 
typedef const struct __CFSet * CFSetRef ; 
typedef struct __CFSet * CFMutableSetRef ; 
enum {
  kCFStringEncodingMacJapanese = 1 , kCFStringEncodingMacChineseTrad = 2 , kCFStringEncodingMacKorean = 3 , kCFStringEncodingMacArabic = 4 , kCFStringEncodingMacHebrew = 5 , kCFStringEncodingMacGreek = 6 , kCFStringEncodingMacCyrillic = 7 , kCFStringEncodingMacDevanagari = 9 , kCFStringEncodingMacGurmukhi = 10 , kCFStringEncodingMacGujarati = 11 , kCFStringEncodingMacOriya = 12 , kCFStringEncodingMacBengali = 13 , kCFStringEncodingMacTamil = 14 , kCFStringEncodingMacTelugu = 15 , kCFStringEncodingMacKannada = 16 , kCFStringEncodingMacMalayalam = 17 , kCFStringEncodingMacSinhalese = 18 , kCFStringEncodingMacBurmese = 19 , kCFStringEncodingMacKhmer = 20 , kCFStringEncodingMacThai = 21 , kCFStringEncodingMacLaotian = 22 , kCFStringEncodingMacGeorgian = 23 , kCFStringEncodingMacArmenian = 24 , kCFStringEncodingMacChineseSimp = 25 , kCFStringEncodingMacTibetan = 26 , kCFStringEncodingMacMongolian = 27 , kCFStringEncodingMacEthiopic = 28 , kCFStringEncodingMacCentralEurRoman = 29 , kCFStringEncodingMacVietnamese = 30 , kCFStringEncodingMacExtArabic = 31 , kCFStringEncodingMacSymbol = 33 , kCFStringEncodingMacDingbats = 34 , kCFStringEncodingMacTurkish = 35 , kCFStringEncodingMacCroatian = 36 , kCFStringEncodingMacIcelandic = 37 , kCFStringEncodingMacRomanian = 38 , kCFStringEncodingMacCeltic = 39 , kCFStringEncodingMacGaelic = 40 , kCFStringEncodingMacFarsi = 0x8C , kCFStringEncodingMacUkrainian = 0x98 , kCFStringEncodingMacInuit = 0xEC , kCFStringEncodingMacVT100 = 0xFC , kCFStringEncodingMacHFS = 0xFF , kCFStringEncodingISOLatin2 = 0x0202 , kCFStringEncodingISOLatin3 = 0x0203 , kCFStringEncodingISOLatin4 = 0x0204 , kCFStringEncodingISOLatinCyrillic = 0x0205 , kCFStringEncodingISOLatinArabic = 0x0206 , kCFStringEncodingISOLatinGreek = 0x0207 , kCFStringEncodingISOLatinHebrew = 0x0208 , kCFStringEncodingISOLatin5 = 0x0209 , kCFStringEncodingISOLatin6 = 0x020A , kCFStringEncodingISOLatinThai = 0x020B , kCFStringEncodingISOLatin7 = 0x020D , kCFStringEncodingISOLatin8 = 0x020E , kCFStringEncodingISOLatin9 = 0x020F , kCFStringEncodingISOLatin10 = 0x0210 , kCFStringEncodingDOSLatinUS = 0x0400 , kCFStringEncodingDOSGreek = 0x0405 , kCFStringEncodingDOSBalticRim = 0x0406 , kCFStringEncodingDOSLatin1 = 0x0410 , kCFStringEncodingDOSGreek1 = 0x0411 , kCFStringEncodingDOSLatin2 = 0x0412 , kCFStringEncodingDOSCyrillic = 0x0413 , kCFStringEncodingDOSTurkish = 0x0414 , kCFStringEncodingDOSPortuguese = 0x0415 , kCFStringEncodingDOSIcelandic = 0x0416 , kCFStringEncodingDOSHebrew = 0x0417 , kCFStringEncodingDOSCanadianFrench = 0x0418 , kCFStringEncodingDOSArabic = 0x0419 , kCFStringEncodingDOSNordic = 0x041A , kCFStringEncodingDOSRussian = 0x041B , kCFStringEncodingDOSGreek2 = 0x041C , kCFStringEncodingDOSThai = 0x041D , kCFStringEncodingDOSJapanese = 0x0420 , kCFStringEncodingDOSChineseSimplif = 0x0421 , kCFStringEncodingDOSKorean = 0x0422 , kCFStringEncodingDOSChineseTrad = 0x0423 , kCFStringEncodingWindowsLatin2 = 0x0501 , kCFStringEncodingWindowsCyrillic = 0x0502 , kCFStringEncodingWindowsGreek = 0x0503 , kCFStringEncodingWindowsLatin5 = 0x0504 , kCFStringEncodingWindowsHebrew = 0x0505 , kCFStringEncodingWindowsArabic = 0x0506 , kCFStringEncodingWindowsBalticRim = 0x0507 , kCFStringEncodingWindowsVietnamese = 0x0508 , kCFStringEncodingWindowsKoreanJohab = 0x0510 , kCFStringEncodingANSEL = 0x0601 , kCFStringEncodingJIS_X0201_76 = 0x0620 , kCFStringEncodingJIS_X0208_83 = 0x0621 , kCFStringEncodingJIS_X0208_90 = 0x0622 , kCFStringEncodingJIS_X0212_90 = 0x0623 , kCFStringEncodingJIS_C6226_78 = 0x0624 , kCFStringEncodingShiftJIS_X0213 = 0x0628 , kCFStringEncodingShiftJIS_X0213_MenKuTen = 0x0629 , kCFStringEncodingGB_2312_80 = 0x0630 , kCFStringEncodingGBK_95 = 0x0631 , kCFStringEncodingGB_18030_2000 = 0x0632 , kCFStringEncodingKSC_5601_87 = 0x0640 , kCFStringEncodingKSC_5601_92_Johab = 0x0641 , kCFStringEncodingCNS_11643_92_P1 = 0x0651 , kCFStringEncodingCNS_11643_92_P2 = 0x0652 , kCFStringEncodingCNS_11643_92_P3 = 0x0653 , kCFStringEncodingISO_2022_JP = 0x0820 , kCFStringEncodingISO_2022_JP_2 = 0x0821 , kCFStringEncodingISO_2022_JP_1 = 0x0822 , kCFStringEncodingISO_2022_JP_3 = 0x0823 , kCFStringEncodingISO_2022_CN = 0x0830 , kCFStringEncodingISO_2022_CN_EXT = 0x0831 , kCFStringEncodingISO_2022_KR = 0x0840 , kCFStringEncodingEUC_JP = 0x0920 , kCFStringEncodingEUC_CN = 0x0930 , kCFStringEncodingEUC_TW = 0x0931 , kCFStringEncodingEUC_KR = 0x0940 , kCFStringEncodingShiftJIS = 0x0A01 , kCFStringEncodingKOI8_R = 0x0A02 , kCFStringEncodingBig5 = 0x0A03 , kCFStringEncodingMacRomanLatin1 = 0x0A04 , kCFStringEncodingHZ_GB_2312 = 0x0A05 , kCFStringEncodingBig5_HKSCS_1999 = 0x0A06 , kCFStringEncodingVISCII = 0x0A07 , kCFStringEncodingKOI8_U = 0x0A08 , kCFStringEncodingBig5_E = 0x0A09 , kCFStringEncodingNextStepJapanese = 0x0B02 , kCFStringEncodingEBCDIC_US = 0x0C01 , kCFStringEncodingEBCDIC_CP037 = 0x0C02 , kCFStringEncodingUTF7 = 0x04000100 , kCFStringEncodingUTF7_IMAP = 0x0A10 , kCFStringEncodingShiftJIS_X0213_00 = 0x0628 }
; 
typedef const void * (* CFTreeRetainCallBack ) (const void * info ) ; 
typedef void (* CFTreeReleaseCallBack ) (const void * info ) ; 
typedef CFStringRef (* CFTreeCopyDescriptionCallBack ) (const void * info ) ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  CFTreeRetainCallBack retain ; 
  CFTreeReleaseCallBack release ; 
  CFTreeCopyDescriptionCallBack copyDescription ; 
}
CFTreeContext ; 
typedef void (* CFTreeApplierFunction ) (const void * value , void * context ) ; 
typedef struct __CFTree * CFTreeRef ; 
enum {
  kCFURLUnknownError = - 10 , kCFURLUnknownSchemeError = - 11 , kCFURLResourceNotFoundError = - 12 , kCFURLResourceAccessViolationError = - 13 , kCFURLRemoteHostUnavailableError = - 14 , kCFURLImproperArgumentsError = - 15 , kCFURLUnknownPropertyKeyError = - 16 , kCFURLPropertyKeyUnavailableError = - 17 , kCFURLTimeoutError = - 18 }
; 
typedef const struct __CFAttributedString * CFAttributedStringRef ; 
typedef struct __CFAttributedString * CFMutableAttributedStringRef ; 
typedef struct __CFNotificationCenter * CFNotificationCenterRef ; 
typedef void (* CFNotificationCallback ) (CFNotificationCenterRef center , void * observer , CFStringRef name , const void * object , CFDictionaryRef userInfo ) ; 
enum {
  CFNotificationSuspensionBehaviorDrop = 1 , CFNotificationSuspensionBehaviorCoalesce = 2 , CFNotificationSuspensionBehaviorHold = 3 , CFNotificationSuspensionBehaviorDeliverImmediately = 4 }
; 
typedef CFIndex CFNotificationSuspensionBehavior ; 
enum {
  kCFNotificationDeliverImmediately = (1UL << 0 ) , kCFNotificationPostToAllSessions = (1UL << 1 ) }
; 
typedef const struct __CFURLEnumerator * CFURLEnumeratorRef ; 
enum {
  kCFURLEnumeratorDescendRecursively = 1UL << 0 , kCFURLEnumeratorSkipInvisibles = 1UL << 1 , kCFURLEnumeratorGenerateFileReferenceURLs = 1UL << 2 , kCFURLEnumeratorSkipPackageContents = 1UL << 3 , }
; 
typedef CFOptionFlags CFURLEnumeratorOptions ; 
enum {
  kCFURLEnumeratorSuccess = 1 , kCFURLEnumeratorEnd = 2 , kCFURLEnumeratorError = 3 }
; 
typedef CFIndex CFURLEnumeratorResult ; 
typedef int CFFileDescriptorNativeDescriptor ; 
typedef struct __CFFileDescriptor * CFFileDescriptorRef ; 
enum {
  kCFFileDescriptorReadCallBack = 1UL << 0 , kCFFileDescriptorWriteCallBack = 1UL << 1 }
; 
typedef void (* CFFileDescriptorCallBack ) (CFFileDescriptorRef f , CFOptionFlags callBackTypes , void * info ) ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  void * (* retain ) (void * info ) ; 
  void (* release ) (void * info ) ; 
  CFStringRef (* copyDescription ) (void * info ) ; 
}
CFFileDescriptorContext ; 
typedef struct __CFMachPort * CFMachPortRef ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  const void * (* retain ) (const void * info ) ; 
  void (* release ) (const void * info ) ; 
  CFStringRef (* copyDescription ) (const void * info ) ; 
}
CFMachPortContext ; 
typedef void (* CFMachPortCallBack ) (CFMachPortRef port , void * msg , CFIndex size , void * info ) ; 
typedef void (* CFMachPortInvalidationCallBack ) (CFMachPortRef port , void * info ) ; 
typedef struct __CFUserNotification * CFUserNotificationRef ; 
typedef void (* CFUserNotificationCallBack ) (CFUserNotificationRef userNotification , CFOptionFlags responseFlags ) ; 
enum {
  kCFUserNotificationStopAlertLevel = 0 , kCFUserNotificationNoteAlertLevel = 1 , kCFUserNotificationCautionAlertLevel = 2 , kCFUserNotificationPlainAlertLevel = 3 }
; 
enum {
  kCFUserNotificationDefaultResponse = 0 , kCFUserNotificationAlternateResponse = 1 , kCFUserNotificationOtherResponse = 2 , kCFUserNotificationCancelResponse = 3 }
; 
enum {
  kCFUserNotificationNoDefaultButtonFlag = (1UL << 5 ) , kCFUserNotificationUseRadioButtonsFlag = (1UL << 6 ) }
; 
static __inline__ __attribute__ ((always_inline ) ) CFOptionFlags CFUserNotificationCheckBoxChecked (CFIndex i ) {
  return ((CFOptionFlags ) (1UL << (8 + i ) ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) CFOptionFlags CFUserNotificationSecureTextField (CFIndex i ) {
  return ((CFOptionFlags ) (1UL << (16 + i ) ) ) ; 
}
static __inline__ __attribute__ ((always_inline ) ) CFOptionFlags CFUserNotificationPopUpSelection (CFIndex n ) {
  return ((CFOptionFlags ) (n << 24 ) ) ; 
}
enum {
  kCFXMLNodeCurrentVersion = 1 }
; 
typedef const struct __CFXMLNode * CFXMLNodeRef ; 
typedef CFTreeRef CFXMLTreeRef ; 
enum {
  kCFXMLNodeTypeDocument = 1 , kCFXMLNodeTypeElement = 2 , kCFXMLNodeTypeAttribute = 3 , kCFXMLNodeTypeProcessingInstruction = 4 , kCFXMLNodeTypeComment = 5 , kCFXMLNodeTypeText = 6 , kCFXMLNodeTypeCDATASection = 7 , kCFXMLNodeTypeDocumentFragment = 8 , kCFXMLNodeTypeEntity = 9 , kCFXMLNodeTypeEntityReference = 10 , kCFXMLNodeTypeDocumentType = 11 , kCFXMLNodeTypeWhitespace = 12 , kCFXMLNodeTypeNotation = 13 , kCFXMLNodeTypeElementTypeDeclaration = 14 , kCFXMLNodeTypeAttributeListDeclaration = 15 }
; 
typedef CFIndex CFXMLNodeTypeCode ; 
typedef struct {
  CFDictionaryRef attributes ; 
  CFArrayRef attributeOrder ; 
  Boolean isEmpty ; 
  char _reserved [3 ] ; 
}
CFXMLElementInfo ; 
typedef struct {
  CFStringRef dataString ; 
}
CFXMLProcessingInstructionInfo ; 
typedef struct {
  CFURLRef sourceURL ; 
  CFStringEncoding encoding ; 
}
CFXMLDocumentInfo ; 
typedef struct {
  CFURLRef systemID ; 
  CFStringRef publicID ; 
}
CFXMLExternalID ; 
typedef struct {
  CFXMLExternalID externalID ; 
}
CFXMLDocumentTypeInfo ; 
typedef struct {
  CFXMLExternalID externalID ; 
}
CFXMLNotationInfo ; 
typedef struct {
  CFStringRef contentDescription ; 
}
CFXMLElementTypeDeclarationInfo ; 
typedef struct {
  CFStringRef attributeName ; 
  CFStringRef typeString ; 
  CFStringRef defaultString ; 
}
CFXMLAttributeDeclarationInfo ; 
typedef struct {
  CFIndex numberOfAttributes ; 
  CFXMLAttributeDeclarationInfo * attributes ; 
}
CFXMLAttributeListDeclarationInfo ; 
enum {
  kCFXMLEntityTypeParameter , kCFXMLEntityTypeParsedInternal , kCFXMLEntityTypeParsedExternal , kCFXMLEntityTypeUnparsed , kCFXMLEntityTypeCharacter }
; 
typedef CFIndex CFXMLEntityTypeCode ; 
typedef struct {
  CFXMLEntityTypeCode entityType ; 
  CFStringRef replacementText ; 
  CFXMLExternalID entityID ; 
  CFStringRef notationName ; 
}
CFXMLEntityInfo ; 
typedef struct {
  CFXMLEntityTypeCode entityType ; 
}
CFXMLEntityReferenceInfo ; 
typedef struct __CFXMLParser * CFXMLParserRef ; 
enum {
  kCFXMLParserValidateDocument = (1UL << 0 ) , kCFXMLParserSkipMetaData = (1UL << 1 ) , kCFXMLParserReplacePhysicalEntities = (1UL << 2 ) , kCFXMLParserSkipWhitespace = (1UL << 3 ) , kCFXMLParserResolveExternalEntities = (1UL << 4 ) , kCFXMLParserAddImpliedAttributes = (1UL << 5 ) , kCFXMLParserAllOptions = 0x00FFFFFF , kCFXMLParserNoOptions = 0 }
; 
enum {
  kCFXMLStatusParseNotBegun = - 2 , kCFXMLStatusParseInProgress = - 1 , kCFXMLStatusParseSuccessful = 0 , kCFXMLErrorUnexpectedEOF = 1 , kCFXMLErrorUnknownEncoding , kCFXMLErrorEncodingConversionFailure , kCFXMLErrorMalformedProcessingInstruction , kCFXMLErrorMalformedDTD , kCFXMLErrorMalformedName , kCFXMLErrorMalformedCDSect , kCFXMLErrorMalformedCloseTag , kCFXMLErrorMalformedStartTag , kCFXMLErrorMalformedDocument , kCFXMLErrorElementlessDocument , kCFXMLErrorMalformedComment , kCFXMLErrorMalformedCharacterReference , kCFXMLErrorMalformedParsedCharacterData , kCFXMLErrorNoData }
; 
typedef CFIndex CFXMLParserStatusCode ; 
typedef void * (* CFXMLParserCreateXMLStructureCallBack ) (CFXMLParserRef parser , CFXMLNodeRef nodeDesc , void * info ) ; 
typedef void (* CFXMLParserAddChildCallBack ) (CFXMLParserRef parser , void * parent , void * child , void * info ) ; 
typedef void (* CFXMLParserEndXMLStructureCallBack ) (CFXMLParserRef parser , void * xmlType , void * info ) ; 
typedef CFDataRef (* CFXMLParserResolveExternalEntityCallBack ) (CFXMLParserRef parser , CFXMLExternalID * extID , void * info ) ; 
typedef Boolean (* CFXMLParserHandleErrorCallBack ) (CFXMLParserRef parser , CFXMLParserStatusCode error , void * info ) ; 
typedef struct {
  CFIndex version ; 
  CFXMLParserCreateXMLStructureCallBack createXMLStructure ; 
  CFXMLParserAddChildCallBack addChild ; 
  CFXMLParserEndXMLStructureCallBack endXMLStructure ; 
  CFXMLParserResolveExternalEntityCallBack resolveExternalEntity ; 
  CFXMLParserHandleErrorCallBack handleError ; 
}
CFXMLParserCallBacks ; 
typedef const void * (* CFXMLParserRetainCallBack ) (const void * info ) ; 
typedef void (* CFXMLParserReleaseCallBack ) (const void * info ) ; 
typedef CFStringRef (* CFXMLParserCopyDescriptionCallBack ) (const void * info ) ; 
typedef struct {
  CFIndex version ; 
  void * info ; 
  CFXMLParserRetainCallBack retain ; 
  CFXMLParserReleaseCallBack release ; 
  CFXMLParserCopyDescriptionCallBack copyDescription ; 
}
CFXMLParserContext ; 
typedef struct __CFStringTokenizer * CFStringTokenizerRef ; 
enum {
  kCFStringTokenizerUnitWord = 0 , kCFStringTokenizerUnitSentence = 1 , kCFStringTokenizerUnitParagraph = 2 , kCFStringTokenizerUnitLineBreak = 3 , kCFStringTokenizerUnitWordBoundary = 4 , kCFStringTokenizerAttributeLatinTranscription = 1UL << 16 , kCFStringTokenizerAttributeLanguage = 1UL << 17 }
; 
enum {
  kCFStringTokenizerTokenNone = 0 , kCFStringTokenizerTokenNormal = 1UL << 0 , kCFStringTokenizerTokenHasSubTokensMask = 1UL << 1 , kCFStringTokenizerTokenHasDerivedSubTokensMask = 1UL << 2 , kCFStringTokenizerTokenHasHasNumbersMask = 1UL << 3 , kCFStringTokenizerTokenHasNonLettersMask = 1UL << 4 , kCFStringTokenizerTokenIsCJWordMask = 1UL << 5 }
; 
typedef CFOptionFlags CFStringTokenizerTokenType ; 
enum {
  kMIDIInvalidClient = - 10830 , kMIDIInvalidPort = - 10831 , kMIDIWrongEndpointType = - 10832 , kMIDINoConnection = - 10833 , kMIDIUnknownEndpoint = - 10834 , kMIDIUnknownProperty = - 10835 , kMIDIWrongPropertyType = - 10836 , kMIDINoCurrentSetup = - 10837 , kMIDIMessageSendErr = - 10838 , kMIDIServerStartErr = - 10839 , kMIDISetupFormatErr = - 10840 , kMIDIWrongThread = - 10841 , kMIDIObjectNotFound = - 10842 , kMIDIIDNotUnique = - 10843 }
; 
typedef void * MIDIObjectRef ; 
typedef struct OpaqueMIDIClient * MIDIClientRef ; 
typedef struct OpaqueMIDIPort * MIDIPortRef ; 
typedef struct OpaqueMIDIDevice * MIDIDeviceRef ; 
typedef struct OpaqueMIDIEntity * MIDIEntityRef ; 
typedef struct OpaqueMIDIEndpoint * MIDIEndpointRef ; 
typedef UInt64 MIDITimeStamp ; 
enum {
  kMIDIObjectType_Other = - 1 , kMIDIObjectType_Device = 0 , kMIDIObjectType_Entity = 1 , kMIDIObjectType_Source = 2 , kMIDIObjectType_Destination = 3 , kMIDIObjectType_ExternalMask = 0x10 , kMIDIObjectType_ExternalDevice = kMIDIObjectType_ExternalMask | kMIDIObjectType_Device , kMIDIObjectType_ExternalEntity = kMIDIObjectType_ExternalMask | kMIDIObjectType_Entity , kMIDIObjectType_ExternalSource = kMIDIObjectType_ExternalMask | kMIDIObjectType_Source , kMIDIObjectType_ExternalDestination = kMIDIObjectType_ExternalMask | kMIDIObjectType_Destination }
; 
typedef SInt32 MIDIObjectType ; 
typedef SInt32 MIDIUniqueID ; 
enum {
  kMIDIInvalidUniqueID = 0 }
; 
typedef struct MIDIPacketList MIDIPacketList ; 
typedef struct MIDISysexSendRequest MIDISysexSendRequest ; 
typedef struct MIDINotification MIDINotification ; 
typedef void (* MIDINotifyProc ) (const MIDINotification * message , void * refCon ) ; 
typedef void (* MIDIReadProc ) (const MIDIPacketList * pktlist , void * readProcRefCon , void * srcConnRefCon ) ; 
typedef void (* MIDICompletionProc ) (MIDISysexSendRequest * request ) ; 

#pragma pack(push, 4)

struct MIDIPacket {
  MIDITimeStamp timeStamp ; 
  UInt16 length ; 
  Byte data [256 ] ; 
}
; 
typedef struct MIDIPacket MIDIPacket ; 
struct MIDIPacketList {
  UInt32 numPackets ; 
  MIDIPacket packet [1 ] ; 
}
; 

#pragma pack(pop)

struct MIDISysexSendRequest {
  MIDIEndpointRef destination ; 
  const Byte * data ; 
  UInt32 bytesToSend ; 
  Boolean complete ; 
  Byte reserved [3 ] ; 
  MIDICompletionProc completionProc ; 
  void * completionRefCon ; 
}
; 
enum {
  kMIDIMsgSetupChanged = 1 , kMIDIMsgObjectAdded = 2 , kMIDIMsgObjectRemoved = 3 , kMIDIMsgPropertyChanged = 4 , kMIDIMsgThruConnectionsChanged = 5 , kMIDIMsgSerialPortOwnerChanged = 6 , kMIDIMsgIOError = 7 }
; 
typedef SInt32 MIDINotificationMessageID ; 
struct MIDINotification {
  MIDINotificationMessageID messageID ; 
  UInt32 messageSize ; 
}
; 
struct MIDIObjectAddRemoveNotification {
  MIDINotificationMessageID messageID ; 
  UInt32 messageSize ; 
  MIDIObjectRef parent ; 
  MIDIObjectType parentType ; 
  MIDIObjectRef child ; 
  MIDIObjectType childType ; 
}
; 
typedef struct MIDIObjectAddRemoveNotification MIDIObjectAddRemoveNotification ; 
struct MIDIObjectPropertyChangeNotification {
  MIDINotificationMessageID messageID ; 
  UInt32 messageSize ; 
  MIDIObjectRef object ; 
  MIDIObjectType objectType ; 
  CFStringRef propertyName ; 
}
; 
typedef struct MIDIObjectPropertyChangeNotification MIDIObjectPropertyChangeNotification ; 
struct MIDIIOErrorNotification {
  MIDINotificationMessageID messageID ; 
  UInt32 messageSize ; 
  MIDIDeviceRef driverDevice ; 
  OSStatus errorCode ; 
}
; 
typedef struct MIDIIOErrorNotification MIDIIOErrorNotification ; 
extern OSStatus MIDIClientCreate (CFStringRef name , MIDINotifyProc notifyProc , void * notifyRefCon , MIDIClientRef * outClient ) __attribute__ ((visibility ("default" ) ) ) ; 
extern OSStatus MIDIInputPortCreate (MIDIClientRef client , CFStringRef portName , MIDIReadProc readProc , void * refCon , MIDIPortRef * outPort ) __attribute__ ((visibility ("default" ) ) ) ; 
extern OSStatus MIDIPortConnectSource (MIDIPortRef port , MIDIEndpointRef source , void * connRefCon ) __attribute__ ((visibility ("default" ) ) ) ; 
extern ItemCount MIDIGetNumberOfSources () __attribute__ ((visibility ("default" ) ) ) ; 
extern MIDIEndpointRef MIDIGetSource (ItemCount sourceIndex0 ) __attribute__ ((visibility ("default" ) ) ) ; 
extern MIDIPacket * MIDIPacketListInit (MIDIPacketList * pktlist ) __attribute__ ((visibility ("default" ) ) ) ; 
typedef struct {
  Scheme_Type t ; 
  int size ; 
  MIDIPacket * * pkts ; 
}
Queue ; 
int getQSize () ; 
Queue * newQueue () ; 
_Bool isEmpty (Queue * q ) ; 
void enqueue (Queue * q , MIDIPacketList * p ) ; 
MIDIPacket * dequeue (Queue * q ) ; 
void nullOp (Scheme_Object * data , void * fds ) ; 
void nullOpA (Scheme_Object * data ) ; 
MIDIPacketList * makeQueueEnd () ; 
Scheme_Object * getQueueForWaiting () ; 
Queue * q ; 
Scheme_Object * scheme_initialize (Scheme_Env * env ) ; 
Scheme_Object * scheme_reload (Scheme_Env * env ) ; 
Scheme_Object * scheme_module_name () ; 
_Bool connect () ; 
_Bool midiInit () ; 
void schemeMidiReadProc (const MIDIPacketList * pktlist , void * readProcRefCon , void * srcConnRefCon ) ; 
int readyProc (Scheme_Object * data ) ; 
void initNewType () ; 
MIDIPacket * getMidi () ; 
Queue * newQueue () {
  Queue * q ; 
  MIDIPacket * * pktlist ; 
  DECL_RET_SAVE (Queue * ) PREPARE_VAR_STACK_ONCE(2);
  BLOCK_SETUP_TOP((PUSH(pktlist, 0), PUSH(q, 1)));
# define XfOrM1_COUNT (2)
# define SETUP_XfOrM1(x) SETUP(XfOrM1_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_once(x)
# define FUNCCALL(s, x) FUNCCALL_once(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_once(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_once(x)
  q = NULLED_OUT ; 
  pktlist = NULLED_OUT ; 
  q = (Queue * ) FUNCCALL(SETUP_XfOrM1(_), malloc (sizeof (Queue ) ) ); 
  pktlist = (MIDIPacket * * ) FUNCCALL(SETUP_XfOrM1(_), malloc (sizeof (MIDIPacket * ) * 100 ) ); 
  q -> size = 0 ; 
  q -> pkts = pktlist ; 
  RET_VALUE_START (q ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
_Bool isEmpty (Queue * q ) {
  /* No conversion */
  return q -> size == 0 ; 
}
int getQSize () {
  /* No conversion */
  return q -> size ; 
}
void enqueue (Queue * q , MIDIPacketList * p ) {
  /* No conversion */
  MIDIPacket * packet ; 
  int i ; 
  packet = & p -> packet [0 ] ; 
  for (i = 0 ; i < p -> numPackets ; i ++ ) {
    q -> pkts [q -> size ] = packet ; 
    q -> size ++ ; 
    packet = ((MIDIPacket * ) & (packet ) -> data [(packet ) -> length ] ) ; 
  }
}
MIDIPacket * dequeue (Queue * q ) {
  /* No conversion */
  MIDIPacket * packet ; 
  int i ; 
  packet = q -> pkts [0 ] ; 
  for (i = 0 ; i < q -> size ; i ++ ) {
    q -> pkts [i ] = q -> pkts [i + 1 ] ; 
  }
  q -> size -- ; 
  return packet ; 
}
Scheme_Object * scheme_initialize (Scheme_Env * env ) {
  Scheme_Env * mod_env ; 
  Scheme_Object * __funcarg128 = NULLED_OUT ; 
  DECL_RET_SAVE (Scheme_Object * ) PREPARE_VAR_STACK_ONCE(2);
  BLOCK_SETUP_TOP((PUSH(mod_env, 0), PUSH(env, 1)));
# define XfOrM10_COUNT (2)
# define SETUP_XfOrM10(x) SETUP(XfOrM10_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_once(x)
# define FUNCCALL(s, x) FUNCCALL_once(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_once(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_once(x)
  mod_env = NULLED_OUT ; 
  mod_env = (__funcarg128 = FUNCCALL(SETUP_XfOrM10(_), scheme_intern_symbol ("SchemeMidi" ) ), FUNCCALL_AGAIN(scheme_primitive_module (__funcarg128 , env ) )) ; 
  FUNCCALL_EMPTY(scheme_finish_primitive_module (mod_env ) ); 
  RET_VALUE_START (scheme_void ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
_Bool connect () {
  _Bool b ; 
  MIDIPacketList * end ; 
  MIDIPacketList * __funcarg129 = NULLED_OUT ; 
  DECL_RET_SAVE (_Bool ) PREPARE_VAR_STACK_ONCE(1);
  BLOCK_SETUP_TOP((PUSH(end, 0)));
# define XfOrM11_COUNT (1)
# define SETUP_XfOrM11(x) SETUP(XfOrM11_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_once(x)
# define FUNCCALL(s, x) FUNCCALL_once(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_once(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_once(x)
  end = NULLED_OUT ; 
  b = FUNCCALL(SETUP_XfOrM11(_), midiInit () ); 
  q = FUNCCALL_AGAIN(newQueue () ); 
  end = FUNCCALL_EMPTY(makeQueueEnd () ); 
  (__funcarg129 = FUNCCALL_EMPTY(makeQueueEnd () ), FUNCCALL_EMPTY(enqueue (q , __funcarg129 ) )) ; 
  FUNCCALL_EMPTY(initNewType () ); 
  RET_VALUE_START (b ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
MIDIPacketList * makeQueueEnd () {
  Byte * buffer ; 
  MIDIPacketList * pktlist ; 
  DECL_RET_SAVE (MIDIPacketList * ) PREPARE_VAR_STACK_ONCE(2);
  BLOCK_SETUP_TOP((PUSH(pktlist, 0), PUSH(buffer, 1)));
# define XfOrM12_COUNT (2)
# define SETUP_XfOrM12(x) SETUP(XfOrM12_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_once(x)
# define FUNCCALL(s, x) FUNCCALL_once(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_once(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_once(x)
  buffer = NULLED_OUT ; 
  pktlist = NULLED_OUT ; 
  buffer = FUNCCALL(SETUP_XfOrM12(_), malloc (sizeof (Byte ) * 2048 ) ); 
  pktlist = (MIDIPacketList * ) buffer ; 
  FUNCCALL(SETUP_XfOrM12(_), MIDIPacketListInit (pktlist ) ); 
  RET_VALUE_START (pktlist ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
Scheme_Object * scheme_reload (Scheme_Env * env ) {
  /* No conversion */
  return scheme_initialize (env ) ; 
}
Scheme_Object * scheme_module_name () {
  /* No conversion */
  return scheme_intern_symbol ("SchemeMidi" ) ; 
}
_Bool midiInit () {
  MIDIPortRef * inPort ; 
  MIDIClientRef * client ; 
  CFStringRef portName ; 
  ItemCount nSrcs ; 
  int iSrc ; 
  DECL_RET_SAVE (_Bool ) PREPARE_VAR_STACK(5);
  BLOCK_SETUP_TOP((PUSH(inPort, 0), PUSH(portName, 1), PUSH(client, 2)));
# define XfOrM15_COUNT (3)
# define SETUP_XfOrM15(x) SETUP(XfOrM15_COUNT)
# define BLOCK_SETUP(x) BLOCK_SETUP_each(x)
# define FUNCCALL(s, x) FUNCCALL_each(s, x)
# define FUNCCALL_EMPTY(x) FUNCCALL_EMPTY_each(x)
# define FUNCCALL_AGAIN(x) FUNCCALL_AGAIN_each(x)
  inPort = NULLED_OUT ; 
  client = NULLED_OUT ; 
  portName = NULLED_OUT ; 
  inPort = (MIDIPortRef * ) FUNCCALL(SETUP_XfOrM15(_), malloc (sizeof (MIDIPortRef ) ) ); 
  client = (MIDIClientRef * ) FUNCCALL(SETUP_XfOrM15(_), malloc (sizeof (MIDIClientRef ) ) ); 
  nSrcs = FUNCCALL(SETUP_XfOrM15(_), MIDIGetNumberOfSources () ); 
  portName = FUNCCALL_AGAIN(CFStringCreateWithCString (((void * ) 0 ) , "my port" , kCFStringEncodingMacRoman ) ); 
  FUNCCALL_AGAIN(MIDIClientCreate (portName , ((void * ) 0 ) , ((void * ) 0 ) , client ) ); 
  FUNCCALL_AGAIN(MIDIInputPortCreate (* client , portName , (MIDIReadProc ) schemeMidiReadProc , client , inPort ) ); 
  for (iSrc = 0 ; iSrc < nSrcs ; ++ iSrc ) {
    MIDIEndpointRef src ; 
    void * srcConnRefCon ; 
    BLOCK_SETUP((PUSH(src, 0+XfOrM15_COUNT), PUSH(srcConnRefCon, 1+XfOrM15_COUNT)));
#   define XfOrM17_COUNT (2+XfOrM15_COUNT)
#   define SETUP_XfOrM17(x) SETUP(XfOrM17_COUNT)
    src = NULLED_OUT ; 
    srcConnRefCon = NULLED_OUT ; 
    src = FUNCCALL(SETUP_XfOrM17(_), MIDIGetSource (iSrc ) ); 
    srcConnRefCon = src ; 
    FUNCCALL(SETUP_XfOrM17(_), MIDIPortConnectSource (* inPort , src , srcConnRefCon ) ); 
  }
  RET_VALUE_START (nSrcs > 0 ) RET_VALUE_END ; 
# undef BLOCK_SETUP
# undef FUNCCALL
# undef FUNCCALL_EMPTY
# undef FUNCCALL_AGAIN
}
void initNewType () {
  /* No conversion */
  Scheme_Type type ; 
  type = scheme_make_type ("SchemeMidiPacketType" ) ; 
  q -> t = type ; 
  scheme_add_evt (type , (Scheme_Ready_Fun ) readyProc , ((void * ) 0 ) , ((void * ) 0 ) , 0 ) ; 
  return ; 
}
void nullOp (Scheme_Object * data , void * fds ) {
  /* No conversion */
}
void nullOpA (Scheme_Object * data ) {
  /* No conversion */
}
Scheme_Object * getQueueForWaiting () {
  /* No conversion */
  return (Scheme_Object * ) q ; 
}
void schemeMidiReadProc (const MIDIPacketList * pktlist , void * readProcRefCon , void * srcConnRefCon ) {
  /* No conversion */
  enqueue (q , pktlist ) ; 
}
int readyProc (Scheme_Object * data ) {
  /* No conversion */
  if (isEmpty ((Queue * ) data ) ) {
    return 0 ; 
  }
  return 1 ; 
}
MIDIPacket * getMidi () {
  /* No conversion */
  return dequeue (q ) ; 
}
