#ifndef __MODEL_TEST__
#define __MODEL_TEST__

#define TEST_CASE_1

#define XLEN __riscv_xlen
#ifdef __riscv_e
#define RVTEST_E
#endif

#define RVMODEL_DATA_BEGIN  .align 4; .global begin_signature; begin_signature:
#define RVMODEL_DATA_END    .align 4; .global end_signature; end_signature:

#define RVMODEL_BOOT        // empty
#define RVMODEL_HALT \
good_trap: \
  li a0, 0; \
  call halt; \
bad_trap: \
  li a0, 1; \
  call halt;

#define RVMODEL_IO_INIT     // empty
#define RVMODEL_IO_ASSERT_GPR_EQ(_SP, _R, _I) \
  li _SP, _I; \
  bne _SP, _R, bad_trap;

.section .text
.globl main
main:
  call rvtest_entry_point
  li a0, 0
  ret

#endif
