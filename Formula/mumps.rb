# Copyright (c) 2019, Massachusetts Institute of Technology.
# Copyright (c) 2019, Toyota Research Institute.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Copyright (c) 2009-2018, Homebrew contributors.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class Mumps < Formula
  desc "Multifrontal massively parallel sparse direct solver"
  homepage "http://www.mumps-solver.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/mumps-5.2.0.tar.gz"
  sha256 "90899679bfb83cedd9e4a01c85e4e66162c86dda3774dbd2ab4add8521a8c255"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "fcadc30ac8150c484c74736b4384ac16b487c74c413ffa5b4e30670c73240c3d" => :mojave
    sha256 "8dcac833510c99c6f3f0287e93d860b9ba19f721c312b7066194c7132cfc47a9" => :high_sierra
  end

  keg_only "this formula conflicts with the mpich and open-mpi formulae"

  depends_on "gcc"
  depends_on "veclibfort"

  patch do
    url "https://drake-homebrew.csail.mit.edu/patches/mumps-5.2.0-makefile-inc-generic-seq.patch"
    sha256 "d345a6fc2337b02980d261a4273164cce38e4b6091e9c7af5c5d4fd4b6f47d66"
  end

  def install
    cp "Make.inc/Makefile.inc.generic.SEQ", "Makefile.inc"
    inreplace "Makefile.inc", "@rpath/", "#{opt_lib}/"

    ENV.deparallelize
    system "make", "alllib"

    include.install Dir["include/*.h", "libseq/*.h"]
    lib.install Dir["lib/*.dylib", "libseq/*.dylib"]
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <assert.h>
      #include <stdio.h>
      #include <string.h>
      #include <dmumps_c.h>
      #include <mpi.h>
      int main(int argc, char **argv) {
        DMUMPS_STRUC_C id;
        MUMPS_INT n = 2;
        MUMPS_INT8 nnz = 2;
        MUMPS_INT irn[] = {1, 2};
        MUMPS_INT jcn[] = {1, 2};
        double a[2];
        double rhs[2];
        MUMPS_INT myid, ierr;
        int error = 0;
        ierr = MPI_Init(&argc, &argv);
        assert(ierr == 0);
        ierr = MPI_Comm_rank(MPI_COMM_WORLD, &myid);
        assert(ierr == 0);
        rhs[0] = 1.0; rhs[1] = 4.0;
        a[0] = 1.0; a[1] = 2.0;
        id.comm_fortran = -987654; id.par = 1; id.sym = 0; id.job = -1;
        dmumps_c(&id);
        if (myid == 0) {
          id.n = n; id.nnz = nnz; id.irn = irn; id.jcn = jcn; id.a = a; id.rhs = rhs;
        }
        id.icntl[0] = -1; id.icntl[1] = -1; id.icntl[2] = -1; id.icntl[3] = 0; id.job = 6;
        dmumps_c(&id);
        if (id.infog[0] < 0) {
          error = 1;
        }
        id.job = -2;
        dmumps_c(&id);
        if (myid == 0) {
          assert(error == 0);
        }
        ierr = MPI_Finalize();
        assert(ierr == 0);
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{opt_include}", "-L#{opt_lib}", "-ldmumps", "-lmpiseq", "-lmumps_common", "-llapack"
    system "./a.out"
  end
end
