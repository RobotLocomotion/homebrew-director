# Copyright 2012-2018 Robot Locomotion Group @ CSAIL. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from
#     this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Copyright 2009-2018 Homebrew contributors.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class MumpsAT51 < Formula
  desc "Multifrontal massively parallel sparse direct solver"
  homepage "http://www.mumps-solver.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/mumps-5.1.2.tar.gz"
  sha256 "08a1fc988f5d22f9578ecfd66638b619d8201b118674f041a868d2e5f0d9af99"

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "cf07f9cc11b61765a748e92d03acaaa9135d0c9a3983ce14c38a969b59e5a7a2" => :high_sierra
    sha256 "3dd23fc3197a61213673001887bcf8183ac92e7a4b7e3de1d86d3157e32b5fa6" => :sierra
    sha256 "0196b8f566a2f5d96234dccdfb417fa9ae9267cca824d576cb86fd31af19f810" => :el_capitan
  end

  keg_only :versioned_formula

  depends_on "gcc"
  depends_on "veclibfort"

  def install
    ENV.fortran

    cp "Make.inc/Makefile.G95.SEQ", "Makefile.inc"

    make_args = [
      "AR=#{ENV.fc} -dynamiclib -Wl,-install_name -Wl,#{lib}/$(notdir $@) -undefined dynamic_lookup -o",
      "CC=#{ENV.cc} -fPIC",
      "CDEFS=-DAdd_",
      "FC=#{ENV.fc} -fPIC",
      "FL=#{ENV.fc} -fPIC",
      "LIBBLAS=-L#{Formula["veclibfort"].opt_lib} -lvecLibFort",
      "LIBEXT=.dylib",
      "OPTF=-O",
      "ORDERINGSF=-Dpord",
      "RANLIB=echo",
    ]

    ENV.deparallelize
    system "make", "alllib", *make_args

    include.install Dir["include/*.h"]
    include.install Dir["libseq/*.h"]

    lib.install Dir["lib/*"]
    lib.install "libseq/libmpiseq.dylib"
  end

  test do
    (testpath/"version.c").write <<~EOS
      #include <assert.h>
      #include <string.h>
      #include <dmumps_c.h>
      int main() {
        assert(strcmp(MUMPS_VERSION, "5.1.2") == 0);
        return 0;
      }
    EOS

    system ENV.cc, "version.c", "-I#{opt_include}"
    system "./a.out"
  end
end
