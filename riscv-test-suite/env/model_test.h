#ifndef __MODEL_TEST__
#define __MODEL_TEST__

#define TEST_CASE_1

#define RVMODEL_DATA_BEGIN  .align 4; .global begin_signature; begin_signature:
#define RVMODEL_DATA_END    .align 4; .global end_signature; end_signature:

#define RVMODEL_BOOT        // empty
#define RVMODEL_HALT        li a0, 0; j halt;
#define RVMODEL_IO_INIT     // empty
#define RVMODEL_IO_ASSERT_GPR_EQ(_SP, _R, _I) \
    li _SP, _I; \
    bne _SP, _R, rvtest_error;

#endif