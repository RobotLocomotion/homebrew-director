# Copyright (c) 2018, Massachusetts Institute of Technology.
# Copyright (c) 2018, Toyota Research Institute.
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

class MumpsAT51 < Formula
  desc "Multifrontal massively parallel sparse direct solver"
  homepage "http://www.mumps-solver.org/"
  url "https://drake-homebrew.csail.mit.edu/mirror/mumps-5.1.2.tar.gz"
  sha256 "08a1fc988f5d22f9578ecfd66638b619d8201b118674f041a868d2e5f0d9af99"
  revision 2

  bottle do
    cellar :any
    root_url "https://drake-homebrew.csail.mit.edu/bottles"
    sha256 "b1e5e9e80319695357031792a2b60a5ad02f491a36058634c8f27bd2bdc25f50" => :mojave
    sha256 "5a851f4377a2a8447c21aedf456af3c3ef6fe7956961f6df18b4cb5d6d344639" => :high_sierra
  end

  keg_only :versioned_formula

  depends_on "gcc"
  depends_on "veclibfort"

  def install
    cp "Make.inc/Makefile.G95.SEQ", "Makefile.inc"

    args = [
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
    system "make", "alllib", *args

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
