#include <am.h>

void rvtest_entry_point();
void rvtest_error();

int main() {
    asm volatile("call rvtest_entry_point");
    // should not return
    asm volatile("li a0, 1; call halt");
}

void rvtest_error() {
    asm volatile("li a0, 1; call halt");
}