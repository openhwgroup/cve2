// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "cve2_simple_system.h"

int main(int argc, char **argv) {
  SimpleSystem simple_system(
      "TOP.cve2_simple_system.u_ram.u_ram.gen_generic.u_impl_generic",
      1024 * 1024);

  return simple_system.Main(argc, argv);
}
